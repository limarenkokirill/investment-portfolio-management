CLASS lhc_Security DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Security RESULT result.

    CONSTANTS c_status_active
      TYPE zinv_sec_status
      VALUE 'ACTIVE'.

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

    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~SetInitialStatus.

    METHODS NormalizeIdentifiers FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~NormalizeIdentifiers.

    METHODS ValidateISIN FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~ValidateISIN.

    METHODS ValidateOpenDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~ValidateOpenDate.
    METHODS ValiddateSecurityType FOR VALIDATE ON SAVE
      IMPORTING keys FOR Security~ValiddateSecurityType.

ENDCLASS.

CLASS lhc_Security IMPLEMENTATION.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

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

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( isin )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(security).

      "Invalidate an earlier state message for this validation
      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_validate_isin
      ) TO reported-Security.

      IF matches(
           val   = security-isin
           pcre = `[A-Z0-9]{12}`
         ).
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky = security-%tky
      ) TO failed-Security.

      APPEND VALUE #(
        %tky        = security-%tky
        %state_area = c_state_area_validate_isin
        %msg        = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = `ISIN must contain exactly 12 uppercase letters or digits.`
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

  METHOD ValiddateSecurityType.

    READ ENTITIES OF zinv_r_security IN LOCAL MODE
    ENTITY Security
    FIELDS ( OpenDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(securities).

    LOOP AT securities INTO DATA(security).

      IF security-SecurityType = c_security_type_stock.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = security-%tky ) TO failed-security.

      APPEND VALUE #(
      %tky = security-%tky
      %state_area = c_state_area_validate_opendate
      %msg = new_message_with_text(
      severity =  if_abap_behv_message=>severity-error
      text = 'Security Type can be only <STOCK>' ) ) TO reported-security.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
