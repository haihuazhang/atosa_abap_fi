CLASS zzcl_fi_003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_payments_items IMPORTING io_request  TYPE REF TO if_rap_query_request
                                         io_response TYPE REF TO if_rap_query_response
                               RAISING   cx_rap_query_prov_not_impl
                                         cx_rap_query_provider.
ENDCLASS.



CLASS ZZCL_FI_003 IMPLEMENTATION.


  METHOD get_payments_items.
    DATA: lt_results TYPE TABLE OF zr_pfi012.

    DATA: lv_outstanding(12) TYPE p DECIMALS 2,
          lv_paid(12)        TYPE p DECIMALS 2,
          lv_accumulated_paid(12)  TYPE p DECIMALS 2.

    DATA: lv_balance_this(12) TYPE p DECIMALS 2,
          lv_balance_last(12) TYPE p DECIMALS 2,
          lv_payment_this(12) TYPE p DECIMALS 2,
          lv_payment_last(12) TYPE p DECIMALS 2.

    TYPES: BEGIN OF ty_calcu,
            customer                    TYPE c LENGTH 10,
            assignmentreference         TYPE c LENGTH 18,
            accountingdocument          TYPE c LENGTH 10,
            documentdate                TYPE sy-datum,
            accountingdocumenttype      TYPE c LENGTH 2,
            postingkey                  TYPE c LENGTH 2,
            amountincompanycodecurrency TYPE p LENGTH 12 DECIMALS 2,
            clearingjournalentry        TYPE c LENGTH 10,
            original_amount             TYPE p LENGTH 12 DECIMALS 2,
            balance_amount              TYPE p LENGTH 12 DECIMALS 2,
            paid_amount                 TYPE p LENGTH 12 DECIMALS 2,
            accu_paid                   TYPE p LENGTH 12 DECIMALS 2,
           END OF ty_calcu.

    DATA lt_calcu TYPE TABLE OF ty_calcu.

    DATA lr_companycode TYPE RANGE OF i_journalentry-companycode.
    DATA lr_fiscalyear TYPE RANGE OF i_journalentry-FiscalYear.
    DATA lr_accountingdocument TYPE RANGE OF i_journalentry-AccountingDocument.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
      WHEN 'COMPANYCODE'.
        MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
      WHEN 'FISCALYEAR'.
        MOVE-CORRESPONDING ls_filter-range TO lr_fiscalyear.
      WHEN 'ACCOUNTINGDOCUMENT'.
        MOVE-CORRESPONDING ls_filter-range TO lr_accountingdocument.
      ENDCASE.
    ENDLOOP.

    SELECT
        _journalentryitem~fiscalyear,
        _journalentryitem~accountingdocument,
        _journalentryitem~ledgergllineitem,
        _journalentryitem~clearingjournalentry,
        _journalentryitem~ClearingJournalEntryFiscalYear,
        _journalentryitem~assignmentreference,
        _journalentryitem~customer,
        _journalentryitem~companycode,
        _journalentryitem~documentdate,
        _journalentry~documentreferenceid
    FROM i_journalentryitem WITH PRIVILEGED ACCESS AS _journalentryitem
    INNER JOIN i_journalentry WITH PRIVILEGED ACCESS AS _journalentry
    ON _journalentry~companycode = _journalentryitem~companycode
        AND _journalentry~fiscalyear = _journalentryitem~fiscalyear
        AND _journalentry~accountingdocument = _journalentryitem~clearingjournalentry
    WHERE _journalentryitem~sourceledger = '0L'
        AND _journalentryitem~assignmentreference <> ''
        AND _journalentryitem~CompanyCode IN @lr_companycode
        AND _journalentryitem~FiscalYear IN @lr_fiscalyear
        AND _journalentryitem~clearingjournalentry IN @lr_accountingdocument
    UNION
    SELECT
        _journalentryitem~fiscalyear,
        _journalentryitem~accountingdocument,
        _journalentryitem~ledgergllineitem,
        _journalentryitem~accountingdocument as clearingjournalentry,
        _journalentryitem~fiscalyear as ClearingJournalEntryFiscalYear,
        _journalentryitem~assignmentreference,
        _journalentryitem~customer,
        _journalentryitem~companycode,
        _journalentryitem~documentdate,
        _journalentry~documentreferenceid
    FROM i_journalentryitem WITH PRIVILEGED ACCESS AS _journalentryitem
    INNER JOIN i_journalentry WITH PRIVILEGED ACCESS AS _journalentry
    ON _journalentry~companycode = _journalentryitem~companycode
        AND _journalentry~fiscalyear = _journalentryitem~fiscalyear
        AND _journalentry~accountingdocument = _journalentryitem~AccountingDocument
    WHERE _journalentryitem~sourceledger = '0L'
        AND _journalentryitem~assignmentreference <> ''
        AND _journalentryitem~CompanyCode IN @lr_companycode
        AND _journalentryitem~FiscalYear IN @lr_fiscalyear
        AND _journalentryitem~AccountingDocument IN @lr_accountingdocument
    INTO TABLE @DATA(lt_clearing_entries).

    SORT lt_clearing_entries BY companycode fiscalyear accountingdocument ledgergllineitem.
    DELETE ADJACENT DUPLICATES FROM lt_clearing_entries COMPARING companycode fiscalyear accountingdocument ledgergllineitem.

    LOOP AT lt_clearing_entries ASSIGNING FIELD-SYMBOL(<wa>)
        GROUP BY ( customer = <wa>-customer
                   companycode = <wa>-companycode
                   assignmentreference = <wa>-assignmentreference )
    ASSIGNING FIELD-SYMBOL(<fs_group>).

        LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_clearing_entries>).
        SELECT
          _journalentryitem~customer,
          _journalentryitem~companycode,
          _journalentryitem~assignmentreference,
          _journalentryitem~accountingdocument,
          _journalentryitem~documentdate,
          _billingdocument~billingdocumentdate,
          _journalentry~documentreferenceid,
          _journalentry~originalreferencedocument,
          _journalentryitem~accountingdocumenttype,
          _journalentryitem~postingkey,
          _journalentryitem~amountincompanycodecurrency,
          _journalentryitem~clearingjournalentry,
          _journalentryitem~ClearingJournalEntryFiscalYear
        FROM i_journalentryitem WITH PRIVILEGED ACCESS AS _journalentryitem
        INNER JOIN i_journalentry WITH PRIVILEGED ACCESS AS _journalentry
        ON _journalentry~companycode = _journalentryitem~companycode
            AND _journalentry~fiscalyear = _journalentryitem~fiscalyear
            AND _journalentry~accountingdocument = _journalentryitem~accountingdocument
        LEFT JOIN i_billingdocument WITH PRIVILEGED ACCESS AS _billingdocument
        ON _billingdocument~billingdocument = _journalentry~originalreferencedocument
        WHERE _journalentryitem~assignmentreference = @<fs_clearing_entries>-AssignmentReference
          AND _journalentryitem~Customer = @<fs_clearing_entries>-Customer
          AND _journalentryitem~CompanyCode = @<fs_clearing_entries>-CompanyCode
          AND ( _journalentryitem~IsReversed <> 'X'
          OR _journalentryitem~IsReversal <> 'X' )
          AND _journalentryitem~sourceledger = '0L'
        ORDER BY _journalentryitem~accountingdocument,_journalentryitem~documentdate
        INTO TABLE @DATA(lt_data).

        IF lines( lt_data ) = 0.
            CONTINUE.
        ENDIF.

        SELECT SINGLE amountincompanycodecurrency
        FROM @lt_data AS ld
        WHERE ( accountingdocumenttype IN ( 'RV','DR' ) AND postingkey = '01' )
           OR ( accountingdocumenttype = 'DG' AND postingkey = '11' )
        INTO @DATA(lv_original_amount).


        SELECT *
        FROM @lt_data AS ld
        WHERE accountingdocumenttype NOT IN ( 'RV','DR','DG' )
        ORDER BY accountingdocument,documentdate
        INTO TABLE @DATA(lt_other).

        CLEAR: lv_outstanding,lv_paid,lv_accumulated_paid,lv_balance_this,lv_balance_last,
               lv_payment_this,lv_payment_last.

        LOOP AT lt_other ASSIGNING FIELD-SYMBOL(<fs_other>).
            IF sy-tabix = 1.
                lv_balance_last = lv_original_amount.
                lv_payment_last = 0.
                lv_accumulated_paid = 0.
            ENDIF.

            CASE <fs_other>-PostingKey.
            WHEN '06'.
                lv_balance_this = <fs_other>-amountincompanycodecurrency.
                lv_payment_this = lv_balance_last - lv_balance_this.
            WHEN '16'.
                lv_balance_this = <fs_other>-amountincompanycodecurrency.
                lv_payment_this = lv_balance_last - lv_balance_this.
            WHEN '15' OR '18'.
                lv_payment_this = -1 * <fs_other>-amountincompanycodecurrency.
                lv_balance_this = lv_balance_last - lv_payment_this.
            WHEN '05' OR '08'.
                lv_payment_this = -1 * <fs_other>-amountincompanycodecurrency.
                lv_balance_this = lv_balance_last - lv_payment_this.
            ENDCASE.

            lv_balance_last = lv_balance_this.
            lv_accumulated_paid += lv_payment_this.

            APPEND VALUE ty_calcu( customer = <fs_other>-Customer
                                   assignmentreference = <fs_other>-AssignmentReference
                                   accountingdocument = <fs_other>-AccountingDocument
                                   documentdate = <fs_other>-DocumentDate
                                   accountingdocumenttype = <fs_other>-AccountingDocumentType
                                   postingkey = <fs_other>-PostingKey
                                   amountincompanycodecurrency = <fs_other>-AmountInCompanyCodeCurrency
                                   clearingjournalentry = <fs_other>-ClearingJournalEntry
                                   original_amount = lv_original_amount
                                   balance_amount = lv_balance_this
                                   paid_amount = lv_payment_this
                                   accu_paid = lv_accumulated_paid
                                    ) TO lt_calcu.
        ENDLOOP.

        IF lv_balance_this = 0.
            lv_accumulated_paid = lv_original_amount.
        ELSEIF <fs_other>-ClearingJournalEntry = ''.
            lv_accumulated_paid = lv_original_amount - lv_balance_this.
        ELSE.
            SELECT SINGLE
              _journalentryitem~customer,
              _journalentryitem~assignmentreference,
              _journalentryitem~accountingdocument,
              _journalentryitem~documentdate,
              _journalentryitem~accountingdocumenttype,
              _journalentryitem~postingkey,
              _journalentryitem~amountincompanycodecurrency,
              _journalentryitem~clearingjournalentry
            FROM i_journalentryitem WITH PRIVILEGED ACCESS AS _journalentryitem
            WHERE _journalentryitem~accountingdocument = @<fs_other>-ClearingJournalEntry
              AND _journalentryitem~ClearingJournalEntryFiscalYear = @<fs_other>-ClearingJournalEntryFiscalYear
              AND _journalentryitem~GLAccount = '1200000000'
            INTO @DATA(ls_end).

            CASE <fs_other>-PostingKey.
            WHEN '06'.
                lv_balance_this = <fs_other>-amountincompanycodecurrency.
                lv_payment_this = lv_balance_last - lv_balance_this.
            WHEN '16'.
                lv_balance_this = <fs_other>-amountincompanycodecurrency.
                lv_payment_this = lv_balance_last - lv_balance_this.
            WHEN '15' OR '18'.
                lv_payment_this = -1 * <fs_other>-amountincompanycodecurrency.
                lv_balance_this = lv_balance_last - lv_payment_this.
            WHEN '05' OR '08'.
                lv_payment_this = -1 * <fs_other>-amountincompanycodecurrency.
                lv_balance_this = lv_balance_last - lv_payment_this.
            ENDCASE.

            lv_accumulated_paid += lv_payment_this.

            APPEND VALUE ty_calcu( customer = ls_end-Customer
                                   assignmentreference = ls_end-AssignmentReference
                                   accountingdocument = ls_end-AccountingDocument
                                   documentdate = ls_end-DocumentDate
                                   accountingdocumenttype = ls_end-AccountingDocumentType
                                   postingkey = ls_end-PostingKey
                                   amountincompanycodecurrency = ls_end-AmountInCompanyCodeCurrency
                                   clearingjournalentry = ls_end-ClearingJournalEntry
                                   original_amount = lv_original_amount
                                   balance_amount = lv_balance_this
                                   paid_amount = lv_payment_this
                                   accu_paid = lv_accumulated_paid
                                    ) TO lt_calcu.
        ENDIF.

        SELECT *
        FROM @lt_calcu AS lc
        WHERE accountingdocument <= @<fs_clearing_entries>-ClearingJournalEntry
        INTO TABLE @DATA(lt_result).

            READ TABLE lt_calcu ASSIGNING FIELD-SYMBOL(<fs_calcu>) INDEX lines( lt_result ).
            IF sy-subrc = 0.
                SELECT SINGLE *
                FROM @lt_data AS ld
                WHERE accountingdocumenttype = 'DR'
                INTO @DATA(ls_dr).

                IF sy-subrc = 0.
                    APPEND VALUE zr_pfi012( CompanyCode = <fs_clearing_entries>-CompanyCode
                                        FiscalYear = <fs_clearing_entries>-ClearingJournalEntryFiscalYear
                                        AccountingDocument = <fs_clearing_entries>-ClearingJournalEntry
                                        LedgerGLLineItem = <fs_clearing_entries>-LedgerGLLineItem
                                        BillingNo = ls_dr-AccountingDocument
                                        DocumentDate = ls_dr-DocumentDate
                                        DocumentReferenceID = ls_dr-DocumentReferenceID
                                        OriginalAmount = lv_original_amount
                                        Outstanding = <fs_calcu>-balance_amount
                                        Paid = <fs_calcu>-paid_amount
                                        Accumulatedpayment = <fs_calcu>-accu_paid ) TO lt_results.
                ENDIF.

                SELECT SINGLE *
                FROM @lt_data AS ld
                WHERE accountingdocumenttype = 'RV'
                INTO @DATA(ls_rv).

                IF sy-subrc = 0.
                    APPEND VALUE zr_pfi012( CompanyCode = <fs_clearing_entries>-CompanyCode
                                        FiscalYear = <fs_clearing_entries>-ClearingJournalEntryFiscalYear
                                        AccountingDocument = <fs_clearing_entries>-ClearingJournalEntry
                                        LedgerGLLineItem = <fs_clearing_entries>-LedgerGLLineItem
                                        BillingNo = ls_rv-originalreferencedocument
                                        DocumentDate = ls_rv-billingdocumentdate
                                        DocumentReferenceID = ls_rv-DocumentReferenceID
                                        OriginalAmount = lv_original_amount
                                        Outstanding = <fs_calcu>-balance_amount
                                        Paid = <fs_calcu>-paid_amount
                                        Accumulatedpayment = <fs_calcu>-accu_paid ) TO lt_results.
                ENDIF.

                SELECT SINGLE *
                FROM @lt_data AS ld
                WHERE accountingdocumenttype = 'DG'
                INTO @DATA(ls_dg).

                IF sy-subrc = 0.
                    APPEND VALUE zr_pfi012( CompanyCode = <fs_clearing_entries>-CompanyCode
                                        FiscalYear = <fs_clearing_entries>-ClearingJournalEntryFiscalYear
                                        AccountingDocument = <fs_clearing_entries>-ClearingJournalEntry
                                        LedgerGLLineItem = <fs_clearing_entries>-LedgerGLLineItem
                                        BillingNo = ls_dg-AccountingDocument
                                        DocumentDate = ls_dg-DocumentDate
                                        DocumentReferenceID = ls_dg-DocumentReferenceID
                                        OriginalAmount = lv_original_amount
                                        Outstanding = <fs_calcu>-balance_amount
                                        Paid = <fs_calcu>-paid_amount
                                        Accumulatedpayment = <fs_calcu>-accu_paid ) TO lt_results.
                ENDIF.
            ENDIF.

        CLEAR lt_calcu.

        ENDLOOP.
    ENDLOOP.

    SORT lt_results BY CompanyCode FiscalYear AccountingDocument BillingNo.
    DELETE ADJACENT DUPLICATES FROM lt_results COMPARING CompanyCode FiscalYear AccountingDocument BillingNo.

    io_response->set_data( lt_results ).

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).
          WHEN 'ZR_PFI012'.
            get_payments_items( io_request = io_request io_response = io_response ).
        ENDCASE.
      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
