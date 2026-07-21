CLASS lhc_Security DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Security RESULT result.

    CONSTANTS c_status_active
      TYPE zinv_sec_status
      VALUE 'ACTIVE'.

    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Security~SetInitialStatus.

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
  MODIFY ENTITIES OF zinv_r_security in LOCAL MODE
  entity Security
  UPDATE FIELDS ( status )
  WITH VALUE #( FOR key IN keys
    ( %tky = key-%tky
        Status = c_status_active ) ).


  ENDMETHOD.

ENDCLASS.
