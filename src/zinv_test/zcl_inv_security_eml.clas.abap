CLASS zcl_inv_security_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_inv_security_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA test_time TYPE c LENGTH 6.
    test_time = cl_abap_context_info=>get_system_time(  ).

    DATA(test_isin)   = CONV zinv_isin( |DETEST{ test_time }| ).
    DATA(test_ticker) = CONV zinv_ticker( |T{ test_time }| ).

    MODIFY ENTITIES OF zinv_r_security
      ENTITY Security
        CREATE FIELDS (
          ISIN
          Ticker
          SecurityName
          Issuer
          OpenDate
          SecurityType
          Currency
        )
        WITH VALUE #(
          (
            %cid         = 'SECURITY_CREATE_1'
            ISIN         = test_isin
            Ticker       = test_ticker
            SecurityName = 'EML Test Security'
            Issuer       = 'Test Issuer'
            OpenDate     = cl_abap_context_info=>get_system_date( )
            SecurityType = 'STOCK'
            Currency     = 'EUR'
          )
        )
      MAPPED DATA(mapped)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    out->write( |CREATE request completed| ).
    out->write( mapped-Security ).

    IF reported IS NOT INITIAL.
      out->write( |CREATE reported messages:| ).
      out->write( reported ).
    ENDIF.

    IF failed IS NOT INITIAL.
      out->write( |CREATE failed:| ).
      out->write( failed ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES
      RESPONSE OF zinv_r_security
      FAILED DATA(failed_commit)
      REPORTED DATA(reported_commit).

    IF reported_commit IS NOT INITIAL.
      out->write( |COMMIT reported messages:| ).
      out->write( reported_commit ).
    ENDIF.

    IF failed_commit IS NOT INITIAL.
      out->write( |COMMIT failed:| ).
      out->write( failed_commit ).
      RETURN.
    ENDIF.

    IF mapped-Security IS INITIAL.
      out->write( |No mapped Security instance was returned.| ).
      RETURN.
    ENDIF.

    DATA(created_uuid) = mapped-Security[ 1 ]-SecurityUUID.

    READ ENTITIES OF zinv_r_security
      ENTITY Security
        ALL FIELDS
        WITH VALUE #(
          (
            SecurityUUID = created_uuid
          )
        )
      RESULT DATA(securities)
      FAILED DATA(failed_read)
      REPORTED DATA(reported_read).

    IF failed_read IS NOT INITIAL.
      out->write( |READ failed:| ).
      out->write( failed_read ).
      RETURN.
    ENDIF.

    out->write( |Persisted Security:| ).
    out->write( securities ).

  ENDMETHOD.

ENDCLASS.
