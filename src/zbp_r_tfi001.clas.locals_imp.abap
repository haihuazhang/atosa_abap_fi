CLASS lhc_zr_tfi001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tfi001
        RESULT result,

*      setDataPrinted FOR MODIFY
*        IMPORTING keys FOR ACTION zr_tfi001~setDataPrinted,
      createOrUpdateRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tfi001~createOrUpdateRecord,
      setDataConfirmed FOR MODIFY
        IMPORTING keys FOR ACTION zr_tfi001~setDataConfirmed.
ENDCLASS.

CLASS lhc_zr_tfi001 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
*  METHOD setDataConfirmed.
*

*  ENDMETHOD.

*  METHOD setDataPrinted.
*    MODIFY ENTITIES OF zr_tfi001 IN LOCAL MODE
*      ENTITY zr_tfi001
*      UPDATE FIELDS ( Status )
*          WITH VALUE #( FOR key IN keys ( Paymentcompanycode = key-Paymentcompanycode
*                          housebank = key-Housebank
*                          housebankaccount = key-Housebankaccount
*                          paymentmethod = key-Paymentmethod
*                          Outgoingcheque = key-Outgoingcheque
*                          Status = 'PRINTED' ) )
*      MAPPED mapped
*      REPORTED reported
*      FAILED failed.
*  ENDMETHOD.

  METHOD createOrUpdateRecord.
    DATA : lt_create_check TYPE TABLE FOR CREATE zr_tfi001\\zr_tfi001,
           ls_create_check LIKE LINE OF lt_create_check.

    READ ENTITIES OF zr_tfi001 IN LOCAL MODE
        ENTITY zr_tfi001
        ALL FIELDS WITH VALUE #( FOR key IN keys ( PaymentCompanyCode = key-%param-PaymentCompanyCode
                                                   PaymentMethod = key-%param-PaymentMethod
                                                   HouseBank = key-%param-HouseBank
                                                   HouseBankAccount = key-%param-HouseBankAccount
                                                   OutgoingCheque = key-%param-OutgoingCheque
         ) ) RESULT DATA(LT_result).

    SORT lt_result BY PaymentCompanyCode PaymentMethod HouseBank HouseBankAccount OutgoingCheque.


    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY PaymentCompanyCode = <key>-%param-PaymentCompanyCode
                                                           PaymentMethod = <key>-%param-PaymentMethod
                                                           HouseBank = <key>-%param-HouseBank
                                                           HouseBankAccount = <key>-%param-HouseBankAccount
                                                           OutgoingCheque = <key>-%param-OutgoingCheque
                                                           BINARY SEARCH.
      IF sy-subrc NE 0 .
        CLEAR ls_create_check.
        ls_create_check = VALUE #( %cid = <key>-%cid
                                   PaymentCompanyCode = <key>-%param-PaymentCompanyCode
                                                           PaymentMethod = <key>-%param-PaymentMethod
                                                           HouseBank = <key>-%param-HouseBank
                                                           HouseBankAccount = <key>-%param-HouseBankAccount
                                                           OutgoingCheque = <key>-%param-OutgoingCheque
                                                           Status = 'PRINTED'
                                    ).
        APPEND ls_create_check TO lt_create_check.
      ENDIF.
    ENDLOOP.

    IF lines( lt_create_check ) > 0.
      MODIFY ENTITIES OF zr_tfi001 IN LOCAL MODE
          ENTITY zr_tfi001
          CREATE FIELDS ( PaymentCompanyCode PaymentMethod HouseBank HouseBankAccount OutgoingCheque Status )
          WITH lt_create_check
          MAPPED mapped
          REPORTED reported
          FAILED failed.
    ENDIF.

  ENDMETHOD.

  METHOD setDataConfirmed.
    modify entities of zr_tfi001 in local mode
        ENTITY zr_tfi001
        UPDATE FIELDS ( Status )
            WITH VALUE #( FOR key IN keys (
*                            %cid_ref = key-%cid
                            Paymentcompanycode = key-%param-Paymentcompanycode
                            housebank = key-%param-Housebank
                            housebankaccount = key-%param-Housebankaccount
                            paymentmethod = key-%param-Paymentmethod
                            Outgoingcheque = key-%param-Outgoingcheque
                            Status = 'CONFIRMED' ) )
        MAPPED mapped
        REPORTED reported
        FAILED failed.
    endmethod.

ENDCLASS.
