CLASS lhc_Security DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Security RESULT result.

    CONSTANTS c_status_active
      TYPE zinv_sec_status
      VALUE 'ACTIVE'.

    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~SetInitialStatus.

    METHODS NormalizeIdentifiers FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~NormalizeIdentifiers.

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

ENDCLASS.
