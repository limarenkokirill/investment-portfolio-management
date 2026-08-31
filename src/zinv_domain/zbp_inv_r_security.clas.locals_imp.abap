CLASS lhc_Security DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Security RESULT result.

    CONSTANTS c_status_active
      TYPE zinv_sec_status
      VALUE 'ACTIVE'.

     CONSTANTS c_status_delisted
      TYPE zinv_sec_status
      VALUE 'DELISTED'.

    CONSTANTS c_state_area_validate_isin
      TYPE string
        VALUE 'VALIDATE_ISIN'.

    CONSTANTS c_state_area_validate_opendate
        TYPE string
        VALUE 'VALIDATE_OPEN_DATE'.

    CONSTANTS c_security_type_stock
        TYPE zinv_sec_type
        VALUE 'STOCK'.

    CONSTANTS c_state_area_validate_sec_type
      TYPE string
      VALUE 'VALIDATE_SECURITY_TYPE'.

    CONSTANTS c_state_area_unique_isin
        TYPE string
        VALUE 'VALIDATE_UNIQUE_ISIN'.

    CONSTANTS c_state_area_unique_ticker
      TYPE string
      VALUE 'VALIDATE_UNIQUE_TICKER'.

    CONSTANTS c_state_area_delisted
      TYPE string
      VALUE 'DELISTED_ACTIVE_SECURITIES'.

    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~SetInitialStatus.

    METHODS NormalizeIdentifiers FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~NormalizeIdentifiers.

    METHODS ValidateISIN FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~ValidateISIN.

    METHODS ValidateOpenDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~ValidateOpenDate.

    METHODS ValidateSecurityType FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~ValidateSecurityType.

    METHODS validatesecurityTicker FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~validatesecurityTicker.

    METHODS delist FOR MODIFY
      IMPORTING keys FOR ACTION Security~delist RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Security RESULT result.

    METHODS is_create_granted
        RETURNING VALUE(is_create_granted) TYPE abap_boolean.

    METHODS is_update_granted
        RETURNING VALUE(granted) TYPE abap_bool.

ENDCLASS.

CLASS lhc_Security IMPLEMENTATION.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = COND #(
        WHEN is_create_granted( ) = abap_true
        THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = COND #(
      WHEN is_update_granted(  ) = abap_true
      THEN if_abap_behv=>auth-allowed
      ELSE if_abap_behv=>auth-unauthorized
       ).
    ENDIF.

  ENDMETHOD.

  METHOD is_create_granted.

    AUTHORITY-CHECK OBJECT 'ZINV_SEC'
    ID 'ACTVT' FIELD '01'.

    RETURN  COND #(
        when sy-subrc = 0
        THEN abap_true
        ELSE abap_false ).

  ENDMETHOD.

  METHOD is_update_granted.

    AUTHORITY-CHECK OBJECT 'ZINV_SEC'
    ID 'ACTVT' FIELD '02'.

    RETURN  COND #(
        when sy-subrc = 0
        THEN abap_true
        ELSE abap_false ).

  ENDMETHOD.

  METHOD SetInitialStatus.
    MODIFY ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR key IN keys
      ( %tky = key-%tky
          Status = c_status_active ) ).
  ENDMETHOD.

  METHOD NormalizeIdentifiers.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( isin Ticker )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    DATA securities_for_update TYPE TABLE FOR UPDATE zinv_r_security.

    LOOP AT securities ASSIGNING FIELD-SYMBOL(<security>).

      DATA(normalized_isin) = CONV zinv_isin(
        to_upper( val = <security>-isin )
      ).

      DATA(normalized_ticker) = CONV zinv_ticker(
        to_upper( val = <security>-Ticker )
      ).

      IF normalized_isin = <security>-isin
         AND normalized_ticker = <security>-Ticker.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky   = <security>-%tky
        isin   = normalized_isin
        Ticker = normalized_ticker
      ) TO securities_for_update.

    ENDLOOP.


    CHECK securities_for_update IS NOT INITIAL.

    MODIFY ENTITIES OF zinv_r_security IN LOCAL MODE
      ENTITY Security
        UPDATE FIELDS ( isin Ticker )
        WITH securities_for_update
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD ValidateISIN.

    DATA duplicate_buffer_isins TYPE STANDARD TABLE OF zinv_isin WITH EMPTY KEY.
    DATA isin_range             TYPE RANGE OF zinv_isin.
    DATA isin_format_error      TYPE abap_boolean VALUE abap_false.
    DATA isin_unique_error      TYPE abap_boolean VALUE abap_false.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( isin )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(group_securities) GROUP BY (
        isin = group_securities-isin
        size = GROUP SIZE
        )
        INTO DATA(group_key).

        IF NOT matches(
           val   = group_key-isin
           pcre = `[A-Z0-9]{12}`
         ).
            CONTINUE.
        ENDIF.

        IF group_key-size < 2.
            CONTINUE.
        ENDIF.

        APPEND  group_key-isin TO duplicate_buffer_isins.

    ENDLOOP.

    LOOP AT securities INTO DATA(unique_security).
         IF NOT matches(
           val   = unique_security-isin
           pcre = `[A-Z0-9]{12}`
         ).
            CONTINUE.
         ENDIF.

      APPEND VALUE #( sign = 'I'
        option = 'EQ'
        low = unique_security-isin ) TO isin_range.
    ENDLOOP.

    IF isin_range IS NOT INITIAL.
        SELECT FROM zinv_security
        FIELDS isin
        WHERE isin IN @isin_range
        INTO TABLE @DATA(t_notUniqISIN).
    ENDIF.

    LOOP AT securities INTO DATA(security).

        isin_format_error = abap_false.
        isin_unique_error = abap_false.

      "Invalidate an earlier state message for this validation
      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_validate_isin
      ) TO reported-Security.

      IF NOT matches(
           val   = security-isin
           pcre = `[A-Z0-9]{12}`
         ).
        isin_format_error = abap_true.
      ELSEIF line_exists( t_notUniqISIN[ ISIN = security-isin ] ) or line_exists( duplicate_buffer_isins[ table_line = security-isin ] ).
        isin_unique_error = abap_true.
      ENDIF.

    if isin_unique_error = abap_false and isin_format_error = abap_false.
        CONTINUE.
    endif.

    DATA(text_error_format) = `ISIN must contain exactly 12 uppercase letters or digits.`.
    DATA(text_error_unique) = |ISIN { security-isin } already exists.|.
    DATA(text_error)        =  COND string(
        WHEN isin_unique_error = abap_true  THEN text_error_unique
        ELSE text_error_format ).

    APPEND VALUE #(
        %tky = security-%tky
      ) TO failed-Security.

      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_validate_isin
        %msg        = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = text_error
        )
        %element-isin = if_abap_behv=>mk-on
      ) TO reported-Security.

    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateOpenDate.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( OpenDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    DATA(system_date) =
        cl_abap_context_info=>get_system_date( ).

    LOOP AT securities INTO DATA(security).

      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_validate_opendate
      ) TO reported-Security.

      IF security-OpenDate <= system_date.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = security-%tky
      ) TO failed-Security.

      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_validate_opendate
        %msg        = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = `Open date cannot be in the future.`
        )
        %element-OpenDate = if_abap_behv=>mk-on
      ) TO reported-Security.

    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateSecurityType.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( SecurityType )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(security).

      APPEND VALUE #(
      %tky        = security-%tky
      %state_area = c_state_area_validate_sec_type
      ) TO reported-Security.

      IF security-SecurityType = c_security_type_stock.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = security-%tky ) TO failed-security.

      APPEND VALUE #(
      %tky = security-%tky
      %state_area = c_state_area_validate_sec_type
      %element-securitytype = if_abap_behv=>mk-on
      %msg = new_message_with_text(
      severity =  if_abap_behv_message=>severity-error
      text = 'Security Type can be only <STOCK>' ) ) TO reported-security.

    ENDLOOP.

  ENDMETHOD.

  METHOD validatesecurityTicker.

    DATA duplicate_buffer_tickers TYPE STANDARD TABLE OF ZINV_TICKER WITH EMPTY KEY.
    DATA ticker_range TYPE RANGE OF zinv_ticker.
    DATA db_ticker_conflict TYPE abap_boolean VALUE abap_false.
    DATA buffer_ticker_conflict TYPE abap_boolean VALUE abap_false.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( SecurityUUID Ticker )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(duplicate_tickers) GROUP BY (
        ticker = duplicate_tickers-Ticker
        size = GROUP SIZE
         ) INTO DATA(group_ticker).
        IF group_ticker-size < 2.
            APPEND VALUE #(
                sign = 'I' option = 'EQ' low = group_ticker-ticker ) TO ticker_range.
            CONTINUE.
        ENDIF.

        APPEND group_ticker-ticker To duplicate_buffer_tickers.

    ENDLOOP.

    if ticker_range is not initial.
        SELECT FROM zinv_security
        FIELDS securityuuid, ticker
        WHERE ticker IN @ticker_range
        INTO TABLE @DATA(db_ticker).
    endif.

   LOOP AT securities INTO DATA(security).

    buffer_ticker_conflict = abap_false.
    db_ticker_conflict = abap_false.

    APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_unique_ticker
      ) TO reported-Security.

    if line_exists( duplicate_buffer_tickers[ table_line = security-Ticker ] ) .
        buffer_ticker_conflict = abap_true.
    ELSE.

    if ticker_range is not initial.
        LOOP AT db_ticker TRANSPORTING NO FIELDS WHERE (
            ticker = security-Ticker AND securityuuid <> security-SecurityUUID ).
                db_ticker_conflict = abap_true.
            EXIT.
        ENDLOOP.
    endif.

    endif.

    IF db_ticker_conflict = abap_false AND buffer_ticker_conflict = abap_false.
        CONTINUE.
    ENDIF.

     APPEND VALUE #(
        %tky = security-%tky
      ) TO failed-Security.

      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_unique_ticker
        %msg        = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     =  |Ticker { security-Ticker } already exists.|
        )
        %element-ticker = if_abap_behv=>mk-on
      ) TO reported-Security.



   ENDLOOP.


  ENDMETHOD.

  METHOD delist.

    DATA update_table TYPE TABLE FOR UPDATE zinv_r_security.

    FINAL(c_date) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( Status SecurityName )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(security).

        if security-Status = c_status_active.

            APPEND VALUE #(
                %tky = security-%tky
                status = c_status_delisted
                CloseDate =  c_date ) to update_table.

        ELSE.
            APPEND VALUE #(
                %tky        = security-%tky
                %op-%action-delist = if_abap_behv=>mk-on
                %msg        = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = |Security { security-SecurityName } is already delisted.| )
             ) TO reported-security.

            APPEND VALUE #(
                %tky        = security-%tky
             ) to failed-security.

        endif.

    ENDLOOP.

    CHECK update_table IS NOT INITIAL.

    MODIFY ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    UPDATE FIELDS ( Status CloseDate )
    WITH update_table
    FAILED FINAL(fail_update)
    REPORTED FINAL(reported_update).

    APPEND LINES OF fail_update-security TO failed-security.
    APPEND LINES OF reported_update-security TO reported-security.



    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    ALL FIELDS WITH CORRESPONDING #( update_table )
    RESULT DATA(updated_securities).

    LOOP AT updated_securities INTO DATA(upd_security).
    IF line_exists( fail_update-security[ KEY id
         COMPONENTS %tky = upd_security-%tky ] ).
        CONTINUE.
    ENDIF.

  APPEND VALUE #(
    %tky   = upd_security-%tky
    %param = upd_security
  ) TO result.

ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(security).
        APPEND VALUE #(
            %tky = security-%tky
            %features-%action-delist = COND #(
            when security-Status = c_status_active THEN if_abap_behv=>fc-o-enabled
            ELSE if_abap_behv=>fc-o-disabled )
         ) TO result.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
