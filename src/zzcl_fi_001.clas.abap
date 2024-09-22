CLASS zzcl_fi_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: tt_paiditem TYPE STANDARD TABLE OF zr_pfi008.
    METHODS get_check_header IMPORTING io_request  TYPE REF TO if_rap_query_request
                                       io_response TYPE REF TO if_rap_query_response
                             RAISING   cx_rap_query_prov_not_impl
                                       cx_rap_query_provider.
    METHODS get_check_header_withpages IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                 io_response TYPE REF TO if_rap_query_response
                                       RAISING   cx_rap_query_prov_not_impl
                                                 cx_rap_query_provider.
    METHODS get_check_paiditem_withpages IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                   io_response TYPE REF TO if_rap_query_response
                                         RAISING   cx_rap_query_prov_not_impl
                                                   cx_rap_query_provider.

    METHODS get_child_expand_or IMPORTING io_tree_node TYPE REF TO if_rap_query_filter_tree_node
                                CHANGING  ct_data      TYPE tt_paiditem .

    METHODS get_child_expand_and IMPORTING io_tree_node TYPE REF TO if_rap_query_filter_tree_node
                                 CHANGING  ct_range     TYPE if_rap_query_filter=>tt_name_range_pairs.

    METHODS get_data_with_and IMPORTING io_tree_node TYPE REF TO if_rap_query_filter_tree_node
                              CHANGING  ct_data      TYPE tt_paiditem .

    METHODS get_range_with_equal IMPORTING io_tree_node TYPE REF TO if_rap_query_filter_tree_node
                                 EXPORTING es_range     TYPE  if_rap_query_filter=>ty_name_range_pairs.

    METHODS get_check_paiditem_withrange IMPORTING it_range TYPE if_rap_query_filter=>tt_name_range_pairs
                                         EXPORTING et_data  TYPE tt_paiditem.


    METHODS calculate_net_amount IMPORTING accountingdocument    TYPE belnr_D
                                           paymentdocument       TYPE belnr_D
                                           fiscalyear            TYPE gjahr
                                           companycode           TYPE bukrs
                                           assignmentreference   TYPE zzefi003
                                           net_amount            TYPE wrbtr_cs
                                 RETURNING VALUE(rv_paid_amount) TYPE wrbtr_cs.
    METHODS get_original_amount IMPORTING accountingdocument        TYPE belnr_D
                                          paymentdocument           TYPE belnr_D
                                          fiscalyear                TYPE gjahr
                                          companycode               TYPE bukrs
                                          assignmentreference       TYPE zzefi003
                                          net_amount                TYPE wrbtr_cs
                                RETURNING VALUE(rv_original_amount) TYPE wrbtr_cs.
ENDCLASS.



CLASS ZZCL_FI_001 IMPLEMENTATION.


  METHOD calculate_net_amount.
    DATA : lv_remaining_amount        TYPE wrbtr_cs,
           lv_original_amount         TYPE wrbtr_cs,
           lv_paid_amount             TYPE wrbtr_cs,
           lv_Accumulated_paid_amount TYPE wrbtr_cs,
           lv_matched                 TYPE abap_boolean,
           lv_clearingjounrnalEntry   TYPE belnr_d.

    SELECT SINGLE AccountingDocumentType
        FROM I_JournalEntry WITH PRIVILEGED ACCESS
        WHERE accountingdocument = @paymentdocument
        INTO @DATA(lv_doc_type).

    IF lv_doc_type = 'KZ' OR lv_doc_type = 'DZ'.

      SELECT item~accountingdocument,
*             item~accountingdocumentitem,
             head~documentdate,
             item~assignmentreference,
             head~AccountingDocumentType,
             item~PostingKey,
             SUM( item~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
             item~Clearingjournalentry,
             item~fiscalyear,
             item~companycode
             FROM I_JournalEntry WITH PRIVILEGED ACCESS AS head
              JOIN I_journalentryitem WITH PRIVILEGED ACCESS AS Item ON head~accountingdocument = item~accountingdocument
                                                                         AND head~fiscalyear = item~fiscalyear
                                                                         AND head~companycode = item~companycode
             WHERE item~AssignmentReference = @assignmentreference
               AND item~IsReversed = @abap_false
               AND item~IsReversed = @abap_false
               AND item~SourceLedger = '0L'
               AND head~AccountingDocumentType IN ( 'RE','KR','KG', 'RV' , 'DR' , 'DG' )
            GROUP BY item~accountingdocument,
                     head~documentdate,
                     item~assignmentreference,
                     head~AccountingDocumentType,
                     item~PostingKey,
                     item~Clearingjournalentry,
                     item~fiscalyear,
                     item~companycode
               INTO TABLE @DATA(lt_data_invoice).

      SELECT item~accountingdocument,
*             item~accountingdocumentitem,
             head~documentdate,
             item~assignmentreference,
             head~AccountingDocumentType,
             item~PostingKey,
             SUM( item~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
             item~Clearingjournalentry,
             item~fiscalyear,
             item~companycode
             FROM I_JournalEntry WITH PRIVILEGED ACCESS AS head
                JOIN I_journalentryitem WITH PRIVILEGED ACCESS AS Item ON head~accountingdocument = item~accountingdocument
                                                                         AND head~fiscalyear = item~fiscalyear
                                                                         AND head~companycode = item~companycode
             WHERE item~AssignmentReference = @assignmentreference
               AND item~IsReversed = @abap_false
               AND item~IsReversed = @abap_false
               AND item~SourceLedger = '0L'
               AND head~AccountingDocumentType IN ( 'KZ','DZ' )
               GROUP BY item~AccountingDocument,
               head~DocumentDate,
               item~assignmentreference,
               head~AccountingDocumentType,
               item~PostingKey,item~Clearingjournalentry,
               item~fiscalyear,
               item~companycode
               INTO TABLE @DATA(lt_data_paid) .

      SORT lt_data_paid BY DocumentDate AccountingDocument .


      READ TABLE lt_data_invoice ASSIGNING FIELD-SYMBOL(<fs_invoice>) INDEX 1.
      IF sy-subrc = 0.
*      CASE <fs_invoice>-PostingKey.
*        WHEN '31'.
*          lv_remaining_amount = 0 - <fs_invoice>-AmountInCompanyCodeCurrency.
*        WHEN '21'.
        lv_remaining_amount = <fs_invoice>-AmountInCompanyCodeCurrency.
        lv_clearingjounrnalEntry = <fs_invoice>-ClearingJournalEntry.
*      ENDCASE.
*      else.

      ENDIF.

*      IF paymentdocument = <fs_invoice>-AccountingDocument AND fiscalyear = <fs_invoice>-FiscalYear AND companycode = <fs_invoice>-CompanyCode.
*        lv_paid_amount = 0.
*      ELSE.
      "
      LOOP AT lt_data_paid ASSIGNING FIELD-SYMBOL(<fs_paid>).
        lv_clearingjounrnalEntry = <fs_paid>-ClearingJournalEntry.
        CASE <fs_paid>-PostingKey.
          WHEN '36'.
            "把金额写入’remaining(本次结余）', 并从上次结余减去本次结余，得出本次支付
            lv_paid_amount = lv_remaining_amount - <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = <fs_paid>-AmountInCompanyCodeCurrency.

          WHEN '26'.
            "把金额写入’remaining(本次结余）', 并从本次结余减去上次结余，得出本次支付
            lv_paid_amount = lv_remaining_amount - <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = <fs_paid>-AmountInCompanyCodeCurrency.

          WHEN '25' OR '28'.
            lv_paid_amount = 0 - <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = lv_remaining_amount - lv_paid_amount.

          WHEN '35' OR '38'.
            lv_paid_amount = <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = lv_remaining_amount - lv_paid_amount.

          WHEN '06'.
            lv_paid_amount = lv_remaining_amount - <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = <fs_paid>-AmountInCompanyCodeCurrency.

          WHEN '16'.
            lv_paid_amount = lv_remaining_amount - ( 0 - <fs_paid>-AmountInCompanyCodeCurrency ).
            lv_remaining_amount = 0 - <fs_paid>-AmountInCompanyCodeCurrency.

          WHEN '15' OR '18'.
            lv_paid_amount = <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = lv_remaining_amount - lv_paid_amount.

          WHEN '05' OR '08'.
            lv_paid_amount = 0 - <fs_paid>-AmountInCompanyCodeCurrency.
            lv_remaining_amount = lv_remaining_amount - lv_paid_amount.

        ENDCASE.

        IF <fs_paid>-AccountingDocument = paymentdocument AND <fs_paid>-FiscalYear = fiscalyear AND <fs_paid>-CompanyCode = companycode.
          lv_matched = abap_true.
          EXIT.

        ENDIF.
      ENDLOOP.

      "找不到payment document
      IF lv_matched = abap_false.
        IF lv_remaining_amount <> 0.
          IF lv_clearingjounrnalEntry <> space.
            IF lv_clearingjounrnalEntry = paymentdocument.
              lv_paid_amount = lv_remaining_amount.
              lv_remaining_amount = 0.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

*      ENDIF.

      rv_paid_amount = lv_paid_amount.
    ELSE.
      rv_paid_amount = net_amount.

    ENDIF.

  ENDMETHOD.


  METHOD get_check_header.

*    DATA: lt_funcs TYPE TABLE OF zzr_dtimp_func.
*    DATA(lo_package) = xco_cp_abap_repository=>package->for( 'ZZDATAIMPORT' ).

    DATA : lt_data TYPE TABLE OF zr_pfi009,
           ls_data TYPE zr_pfi009.

    DATA : lr_PaymentCompanyCode   TYPE RANGE OF I_Outgoingcheck-PaymentCompanyCode.
    DATA : lr_HouseBank   TYPE RANGE OF I_Outgoingcheck-HouseBank.
    DATA : lr_HouseBankAccount   TYPE RANGE OF I_Outgoingcheck-HouseBankAccount.
    DATA : lr_PaymentMethod   TYPE RANGE OF I_Outgoingcheck-PaymentMethod.
    DATA : lr_OutgoingCheque   TYPE RANGE OF I_Outgoingcheck-OutgoingCheque.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'PAYMENTCOMPANYCODE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_PaymentCompanyCode.
        WHEN 'HOUSEBANK'.
          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
        WHEN 'HOUSEBANKACCOUNT'.
          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
        WHEN 'PAYMENTMETHOD'.
          MOVE-CORRESPONDING ls_filter-range TO lr_PaymentMethod.
        WHEN 'OUTGOINGCHEQUE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_OutgoingCheque.

      ENDCASE.

    ENDLOOP.


    SELECT * FROM I_OutgoingCheck
    WITH PRIVILEGED ACCESS
    WHERE PaymentCompanyCode IN @lr_PaymentCompanyCode
      AND HouseBank IN @lr_HouseBank
      AND HouseBankAccount IN @lr_HouseBankAccount
      AND PaymentMethod IN @lr_PaymentMethod
      AND OutgoingCheque IN @lr_OutgoingCheque
    INTO TABLE @DATA(lt_outgoingcheck).


    LOOP AT lt_outgoingcheck INTO DATA(ls_outgoingcheck).
      CLEAR ls_data.
      MOVE-CORRESPONDING ls_outgoingcheck TO ls_data.
      ls_data-RunOn = ls_outgoingcheck-ChequePaymentDate.
      ls_data-SendingCompanyCode = ls_data-PaymentCompanyCode.
      APPEND ls_data TO lt_data.
    ENDLOOP.


    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

    io_response->set_data( lt_data ).


  ENDMETHOD.


  METHOD get_check_header_withpages.


    DATA : lt_data TYPE TABLE OF zr_pfi006,
           ls_data TYPE zr_pfi006.

    DATA : lr_PaymentCompanyCode   TYPE RANGE OF I_Outgoingcheck-PaymentCompanyCode.
    DATA : lr_HouseBank   TYPE RANGE OF I_Outgoingcheck-HouseBank.
    DATA : lr_HouseBankAccount   TYPE RANGE OF I_Outgoingcheck-HouseBankAccount.
    DATA : lr_PaymentMethod   TYPE RANGE OF I_Outgoingcheck-PaymentMethod.
    DATA : lr_OutgoingCheque   TYPE RANGE OF I_Outgoingcheck-OutgoingCheque.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    LOOP AT lt_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'PAYMENTCOMPANYCODE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_PaymentCompanyCode.
        WHEN 'HOUSEBANK'.
          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
        WHEN 'HOUSEBANKACCOUNT'.
          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
        WHEN 'PAYMENTMETHOD'.
          MOVE-CORRESPONDING ls_filter-range TO lr_PaymentMethod.
        WHEN 'OUTGOINGCHEQUE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_OutgoingCheque.

      ENDCASE.

    ENDLOOP.

    SELECT * FROM I_OutgoingCheck
    WITH PRIVILEGED ACCESS
    WHERE PaymentCompanyCode IN @lr_PaymentCompanyCode
      AND HouseBank IN @lr_HouseBank
      AND HouseBankAccount IN @lr_HouseBankAccount
      AND PaymentMethod IN @lr_PaymentMethod
      AND OutgoingCheque IN @lr_OutgoingCheque
    INTO TABLE @DATA(lt_outgoingcheck).

    CLEAR ls_data.
    LOOP AT lt_outgoingcheck INTO DATA(ls_outgoingcheck).

      MOVE-CORRESPONDING ls_outgoingcheck TO ls_data.
      ls_data-BPReference = ls_outgoingcheck-Supplier.
      ls_data-AmountPaidLocalCurrency = ls_outgoingcheck-PaidAmountInPaytCurrency.

      SELECT SINGLE currency
        FROM i_companycode
              WITH PRIVILEGED ACCESS
        WHERE companycode = @ls_data-PaymentCompanyCode
        INTO @ls_data-Currency.

*      Identification                      : abap.char(5);
      ls_data-PositiveCheckAmount = abs( ls_data-AmountPaidLocalCurrency ).
      ls_data-CashDiscountAmount = abs( ls_outgoingcheck-CashDiscountAmount ).
      ls_data-NetAmount = ls_data-AmountPaidLocalCurrency - ls_data-CashDiscountAmount.

      ls_data-RunOn = ls_outgoingcheck-ChequePaymentDate.
      ls_data-SendingCompanyCode = ls_data-PaymentCompanyCode.
*      SeparatePaymentAdvice: abap.sstring(60);
      ls_data-CheckNum = ls_data-OutgoingCheque.
      SELECT SINGLE BankNumber,
                    BankAccount
            FROM I_HouseBankAccountLinkage
                  WITH PRIVILEGED ACCESS
           WHERE CompanyCode = @ls_outgoingcheck-PaymentCompanyCode
             AND HouseBank = @ls_outgoingcheck-HouseBank
             AND HouseBankAccount = @ls_outgoingcheck-HouseBankAccount
             INTO ( @ls_data-HouseBankNo , @ls_Data-ExternalFormatAccountNum ).

      "Name1Payee
      ls_data-Name1Payee = ls_outgoingcheck-PayeeName.
      ls_data-OurBankName = ls_outgoingcheck-BankName.


      " AddressLine
      SELECT SINGLE BusinessPartnerName1,
                    BusinessPartnerName3,
                    StreetName,
                    BPAddrStreetName,
                    CityName,
                    PostalCode,
                    region,
                    Country
            FROM i_Supplier
                  WITH PRIVILEGED ACCESS
            WHERE Supplier = @ls_outgoingcheck-Supplier
            INTO @DATA(ls_supplier).

      " Get Customer
      IF ls_outgoingcheck-Supplier IS INITIAL.
        SELECT SINGLE BusinessPartnerName1,
                      BusinessPartnerName3,
                      StreetName,
                      CityName,
                      PostalCode,
                      region,
                      Country
              FROM i_Customer
                    WITH PRIVILEGED ACCESS
              WHERE Customer = @ls_outgoingcheck-Supplier
              INTO @ls_supplier.

      ENDIF.

      ls_data-AddressLine0 = ls_supplier-BusinessPartnerName1.
      ls_data-AddressLine1 = ls_supplier-BusinessPartnerName1.
      ls_data-AddressLine2 = ls_supplier-BusinessPartnerName3.
*      ls_data-AddressLine3 = ls_supplier-StreetName.
      ls_data-AddressLine3 = ls_supplier-BPAddrStreetName.
      CONCATENATE ls_supplier-CityName ls_supplier-region ls_supplier-PostalCode INTO ls_data-AddressLine4 SEPARATED BY space.


      "Pagination
      SELECT COUNT( * )
          FROM i_operationalacctgdocitem
                WITH PRIVILEGED ACCESS
           WHERE ClearingJournalEntry = @ls_outgoingcheck-PaymentDocument
             AND ClearingJournalEntryFiscalYear = @ls_outgoingcheck-FiscalYear
             AND CompanyCode = @ls_outgoingcheck-PaymentCompanyCode
             AND AccountingDocument <> @ls_outgoingcheck-PaymentDocument
        INTO @DATA(lv_lines).

      DATA : lv_pages TYPE int2.
      IF lv_lines MOD 10 > 0.
        lv_pages = lv_lines DIV 10 + 1.
      ELSE.
        lv_pages = lv_lines DIV 10 .
      ENDIF.

      DO lv_pages TIMES.
        ls_data-PageNum += 1.
        APPEND ls_data TO lt_data.
      ENDDO.


      CLEAR : ls_supplier, lv_pages , lv_lines, ls_outgoingcheck , ls_data.
    ENDLOOP.


    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

    io_response->set_data( lt_data ).


  ENDMETHOD.


  METHOD get_check_paiditem_withpages.

    DATA Lt_Data TYPE TABLE OF zr_pfi008.

    DATA(lo_filter) = io_request->get_filter(  ).
**    io_request->
*    data(lt_parameters) = io_request->get_parameters(  ).
*    data(ls_search_expression) = io_request->get_search_expression(  ).
*    data(lv_sql) = lo_filter->get_as_sql_string(  ).
    DATA(lo_filter_tree) = lo_filter->get_as_tree(  ).
    DATA(lo_root_filter) = lo_filter_tree->get_root_node(  ).

*lo_root_filter->get_type(  )

    get_child_expand_or(
        EXPORTING io_tree_node = lo_root_filter
        CHANGING ct_data = lt_data
     ).




*    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

    io_response->set_data( lt_data ).


  ENDMETHOD.


  METHOD get_check_paiditem_withrange.
    DATA : lt_data TYPE TABLE OF zr_pfi008,
           ls_data TYPE zr_pfi008.

    DATA : lr_PaymentCompanyCode   TYPE RANGE OF I_Outgoingcheck-PaymentCompanyCode.
    DATA : lr_HouseBank   TYPE RANGE OF I_Outgoingcheck-HouseBank.
    DATA : lr_HouseBankAccount   TYPE RANGE OF I_Outgoingcheck-HouseBankAccount.
    DATA : lr_PaymentMethod   TYPE RANGE OF I_Outgoingcheck-PaymentMethod.
    DATA : lr_OutgoingCheque   TYPE RANGE OF I_Outgoingcheck-OutgoingCheque.

    DATA : lr_pagenum TYPE RANGE OF int2.

    LOOP AT it_range INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'PAYMENTCOMPANYCODE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_PaymentCompanyCode.
        WHEN 'HOUSEBANK'.
          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
        WHEN 'HOUSEBANKACCOUNT'.
          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
        WHEN 'PAYMENTMETHOD'.
          MOVE-CORRESPONDING ls_filter-range TO lr_PaymentMethod.
        WHEN 'OUTGOINGCHEQUE'.
          MOVE-CORRESPONDING ls_filter-range TO lr_OutgoingCheque.
        WHEN 'PAGENUM'.
          MOVE-CORRESPONDING ls_filter-range TO lr_pagenum.

      ENDCASE.

    ENDLOOP.

    SELECT a~PaymentCompanyCode,
           a~HouseBank,
           a~HouseBankAccount,
           a~PaymentMethod,
           a~OutgoingCheque,
           b~OriginalReferenceDocument,
           b~DocumentDate,
           b~Reference3IDByBusinessPartner,
           b~AmountInCompanyCodeCurrency,
           b~CashDiscountAmtInCoCodeCrcy,
           c~DocumentReferenceID,
           b~documentitemtext,
           b~assignmentreference,
           b~accountingdocument,
           b~fiscalyear,
           b~companycode,
           b~accountingdocumentitem,
           a~paymentdocument
             FROM I_OutgoingCheck
                       WITH PRIVILEGED ACCESS
             AS a JOIN i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS b
                                        ON a~PaymentDocument = b~ClearingJournalEntry
                                       AND a~FiscalYear = b~ClearingJournalEntryFiscalYear
                                       AND a~PaymentCompanyCode = b~CompanyCode
                                       AND a~PaymentDocument <> b~AccountingDocument
                  JOIN i_JournalEntry WITH PRIVILEGED ACCESS AS c
                                        ON  c~CompanyCode        = b~CompanyCode
                                       AND c~FiscalYear         = b~FiscalYear
                                       AND c~AccountingDocument = b~AccountingDocument

            WHERE a~PaymentCompanyCode IN @lr_PaymentCompanyCode
              AND a~HouseBank IN @lr_HouseBank
              AND a~HouseBankAccount IN @lr_HouseBankAccount
              AND a~PaymentMethod IN @lr_PaymentMethod
              AND a~OutgoingCheque IN @lr_OutgoingCheque
              INTO TABLE @DATA(lt_paidItem).

    "部分支付
    IF lt_paidItem IS INITIAL.
      SELECT a~PaymentCompanyCode,
         a~HouseBank,
         a~HouseBankAccount,
         a~PaymentMethod,
         a~OutgoingCheque,
         b~OriginalReferenceDocument,
         b~DocumentDate,
         b~Reference3IDByBusinessPartner,
         b~AmountInCompanyCodeCurrency,
         b~CashDiscountAmtInCoCodeCrcy,
         c~DocumentReferenceID,
         b~documentitemtext,
         b~assignmentreference,
         b~accountingdocument,
         b~fiscalyear,
         b~companycode,
         b~accountingdocumentitem,
         a~paymentdocument
           FROM I_OutgoingCheck
                     WITH PRIVILEGED ACCESS
           AS a JOIN i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS b
                                      ON a~PaymentDocument = b~AccountingDocument
                                     AND a~FiscalYear = b~ClearingJournalEntryFiscalYear
                                     AND a~PaymentCompanyCode = b~CompanyCode
*                                     AND a~PaymentDocument <> b~AccountingDocument
                JOIN i_JournalEntry WITH PRIVILEGED ACCESS AS c
                                      ON  c~CompanyCode        = b~CompanyCode
                                     AND c~FiscalYear         = b~FiscalYear
                                     AND c~AccountingDocument = b~AccountingDocument

          WHERE a~PaymentCompanyCode IN @lr_PaymentCompanyCode
            AND a~HouseBank IN @lr_HouseBank
            AND a~HouseBankAccount IN @lr_HouseBankAccount
            AND a~PaymentMethod IN @lr_PaymentMethod
            AND a~OutgoingCheque IN @lr_OutgoingCheque
            INTO TABLE @lt_paidItem.
    ENDIF.


    SELECT companycode,
           currency
           FROM I_Companycode
                     WITH PRIVILEGED ACCESS
           WHERE CompanyCode IN @lr_paymentcompanycode
           INTO TABLE @DATA(LT_companycode).
    SORT LT_companycode BY CompanyCode.


    DATA(lt_paid_item_H) = lt_paiditem.
    SORT lt_paid_item_H BY PaymentCompanyCode HouseBank HouseBankAccount PaymentMethod OutgoingCheque.
    DELETE ADJACENT DUPLICATES FROM lt_paid_item_h COMPARING PaymentCompanyCode HouseBank HouseBankAccount PaymentMethod OutgoingCheque.

    DATA : lv_count TYPE int2.
    LOOP AT lt_paid_item_h INTO DATA(ls_h).
      CLEAR : ls_data , lv_count.
      ls_data-PageNum = 1.
      LOOP AT lt_paidItem INTO DATA(ls_paiditem).
        lv_count += 1.
        IF lv_count > 10.
          ls_data-PageNum += 1.
          lv_count = 1.
        ENDIF.
        MOVE-CORRESPONDING ls_paiditem TO ls_data.
*        ls_data-ReferenceToPaidDocument = ls_paiditem-OriginalReferenceDocument(10).
**        ls_data-ReferenceToPaidDocument = ls_paiditem-DocumentReferenceID.
        ls_data-ReferenceToPaidDocument = ls_paiditem-DocumentItemText.

*        ls_data-AmountLocalCurrency = abs( ls_paiditem-AmountInCompanyCodeCurrency ).
*        ls_data-AmountLocalCurrency = ls_paiditem-AmountInCompanyCodeCurrency.
        ls_data-AmountLocalCurrency = get_original_amount( accountingdocument = ls_paiditem-AccountingDocument
                              assignmentreference = ls_paiditem-AssignmentReference
                              companycode = ls_paiditem-CompanyCode
                              fiscalyear = ls_paiditem-FiscalYear
                              paymentdocument = ls_paiditem-PaymentDocument
                              net_amount = CONV wrbtr_cs( ls_paiditem-AmountInCompanyCodeCurrency ) ).

*        ls_data-DiscountLocalCurrency = abs( ls_paiditem-CashDiscountAmtInCoCodeCrcy ).
        ls_data-DiscountLocalCurrency = ls_paiditem-CashDiscountAmtInCoCodeCrcy.
*        ls_data-NetAmountLocalCurrency = ls_data-AmountLocalCurrency - ls_data-DiscountLocalCurrency.

        ls_data-NetAmountLocalCurrency  = calculate_net_amount( accountingdocument = ls_paiditem-AccountingDocument
                              assignmentreference = ls_paiditem-AssignmentReference
                              companycode = ls_paiditem-CompanyCode
                              fiscalyear = ls_paiditem-FiscalYear
                              paymentdocument = ls_paiditem-PaymentDocument
                              net_amount = CONV wrbtr_cs( ls_paiditem-AmountInCompanyCodeCurrency ) ).
        ls_data-NetAmountLocalCurrency -= ls_data-DiscountLocalCurrency.


        ls_data-DocumentDate = ls_paiditem-DocumentDate.
        ls_data-BPReferenceKey3 = ls_paiditem-Reference3IDByBusinessPartner.
*        ls_data-LocalCurrency =
        READ TABLE LT_companycode INTO DATA(ls_companycode) WITH KEY CompanyCode = ls_paiditem-PaymentCompanyCode
                                                                     BINARY SEARCH.
        IF sy-subrc = 0.
          ls_data-LocalCurrency = ls_companycode-Currency.
        ENDIF.
        APPEND ls_data TO lt_data.
      ENDLOOP.
    ENDLOOP.

    DELETE lt_data WHERE PageNum NOT IN lr_pagenum.
    et_data = lt_data.

  ENDMETHOD.


  METHOD get_child_expand_and.
    DATA(lv_child_type) = io_tree_node->get_type(  ).

    CASE lv_child_type.
      WHEN  if_rap_query_filter_tree_types=>node_types-equals.
        get_range_with_equal(
            EXPORTING io_tree_node = io_tree_node
            IMPORTING es_range = DATA(ls_range)
        ).

        APPEND ls_range TO ct_range.
      WHEN if_rap_query_filter_tree_types=>node_types-logical_and.

        DATA(lt_children) = io_tree_node->get_children(  ).
        LOOP AT lt_children INTO DATA(lo_child).
          get_child_expand_and(
                  EXPORTING io_tree_node = lo_child
                  CHANGING ct_range = ct_range
           ).
        ENDLOOP.
    ENDCASE.

  ENDMETHOD.


  METHOD get_child_expand_or.
    DATA(lv_type) = io_tree_node->get_type(  ).
*     lv_type
    IF lv_type = if_rap_query_filter_tree_types=>node_types-logical_or.
      DATA(lt_children) = io_tree_node->get_children(  ).
      LOOP AT lt_children INTO DATA(lo_child).
        me->get_child_expand_or(
                EXPORTING
                    io_tree_node = lo_child
                CHANGING
                    ct_data = ct_data

        ).
      ENDLOOP.
    ELSE.
      " Proces
      me->get_data_with_and(
            EXPORTING
                io_tree_node = io_tree_node
            CHANGING
                ct_Data = ct_data
       ).
    ENDIF.
  ENDMETHOD.


  METHOD get_data_with_and.
    DATA : lt_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
*           lo_data   TYPE REF TO data.
    DATA : lt_data TYPE tt_paiditem.


    DATA(lt_children) = io_tree_node->get_children(  ).
    LOOP AT lt_children INTO DATA(lo_child).
      get_child_expand_and(
          EXPORTING io_tree_node = lo_child
          CHANGING ct_range = lt_ranges
       ).
    ENDLOOP.

    " Get Data with sub expanded ranges.
*    CREATE DATA lo_data TYPE STANDARD TABLE.
    get_check_paiditem_withrange(
        EXPORTING it_range = lt_ranges
        IMPORTING et_data = lt_data
     ).
    APPEND LINES OF lt_data TO ct_data.
  ENDMETHOD.


  METHOD get_original_amount.
    DATA : lv_remaining_amount        TYPE wrbtr_cs,
           lv_original_amount         TYPE wrbtr_cs,
           lv_paid_amount             TYPE wrbtr_cs,
           lv_Accumulated_paid_amount TYPE wrbtr_cs,
           lv_matched                 TYPE abap_boolean,
           lv_clearingjounrnalEntry   TYPE belnr_d.

    SELECT SINGLE AccountingDocumentType
        FROM I_JournalEntry WITH PRIVILEGED ACCESS
        WHERE accountingdocument = @paymentdocument
        INTO @DATA(lv_doc_type).

    IF lv_doc_type = 'KZ' OR lv_doc_type = 'DZ'.

      SELECT item~accountingdocument,
*             item~accountingdocumentitem,
             head~documentdate,
             item~assignmentreference,
             head~AccountingDocumentType,
             item~PostingKey,
             SUM( item~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
             item~Clearingjournalentry,
             item~fiscalyear,
             item~companycode
             FROM I_JournalEntry WITH PRIVILEGED ACCESS AS head
              JOIN I_journalentryitem WITH PRIVILEGED ACCESS AS Item ON head~accountingdocument = item~accountingdocument
                                                                         AND head~fiscalyear = item~fiscalyear
                                                                         AND head~companycode = item~companycode
             WHERE item~AssignmentReference = @assignmentreference
               AND item~IsReversed = @abap_false
               AND item~IsReversed = @abap_false
               AND item~SourceLedger = '0L'
               AND head~AccountingDocumentType IN ( 'RE','KR','KG', 'RV' , 'DR' , 'DG' )
            GROUP BY item~accountingdocument,
                     head~documentdate,
                     item~assignmentreference,
                     head~AccountingDocumentType,
                     item~PostingKey,
                     item~Clearingjournalentry,
                     item~fiscalyear,
                     item~companycode
               INTO TABLE @DATA(lt_data_invoice).

      SELECT item~accountingdocument,
*             item~accountingdocumentitem,
             head~documentdate,
             item~assignmentreference,
             head~AccountingDocumentType,
             item~PostingKey,
             SUM( item~AmountInCompanyCodeCurrency ) AS AmountInCompanyCodeCurrency,
             item~Clearingjournalentry,
             item~fiscalyear,
             item~companycode
             FROM I_JournalEntry WITH PRIVILEGED ACCESS AS head
                JOIN I_journalentryitem WITH PRIVILEGED ACCESS AS Item ON head~accountingdocument = item~accountingdocument
                                                                         AND head~fiscalyear = item~fiscalyear
                                                                         AND head~companycode = item~companycode
             WHERE item~AssignmentReference = @assignmentreference
               AND item~IsReversed = @abap_false
               AND item~IsReversed = @abap_false
               AND item~SourceLedger = '0L'
               AND head~AccountingDocumentType IN ( 'KZ','DZ' )
               GROUP BY item~AccountingDocument,
               head~DocumentDate,
               item~assignmentreference,
               head~AccountingDocumentType,
               item~PostingKey,item~Clearingjournalentry,
               item~fiscalyear,
               item~companycode
               INTO TABLE @DATA(lt_data_paid) .

      SORT lt_data_paid BY DocumentDate AccountingDocument .


      READ TABLE lt_data_invoice ASSIGNING FIELD-SYMBOL(<fs_invoice>) INDEX 1.
      IF sy-subrc = 0.
*      CASE <fs_invoice>-PostingKey.
*        WHEN '31'.
*          lv_remaining_amount = 0 - <fs_invoice>-AmountInCompanyCodeCurrency.
*        WHEN '21'.
*        lv_remaining_amount = <fs_invoice>-AmountInCompanyCodeCurrency.
*        lv_clearingjounrnalEntry = <fs_invoice>-ClearingJournalEntry.

*      ENDCASE.
*      else.
        rv_original_amount = <fs_invoice>-AmountInCompanyCodeCurrency.

      ENDIF.


    ELSE.
      rv_original_amount = net_amount.

    ENDIF.
  ENDMETHOD.


  METHOD get_range_with_equal.
    DATA : ls_range TYPE if_rap_query_filter=>ty_name_range_pairs.
    APPEND INITIAL LINE TO ls_range-range.
    DATA(lt_children) = io_tree_node->get_children( ).
    LOOP AT lt_children INTO DATA(lo_child).
      DATA(lv_child_type) = lo_child->get_type(  ).
      CASE lv_child_type.
        WHEN if_rap_query_filter_tree_types=>node_types-identifier.
          Ls_range-name = lo_child->get_value(  )->*.
        WHEN if_rap_query_filter_tree_types=>node_types-value.
          ls_range-range[ 1 ]-low = lo_child->get_value(  )->*.
          ls_range-range[ 1 ]-sign = 'I'.
          ls_range-range[ 1 ]-option = 'EQ'.
      ENDCASE.
    ENDLOOP.
    es_range = ls_range.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZR_PFI009'.
            get_check_header( io_request = io_request io_response = io_response ).

          WHEN 'ZR_PFI006'.
            get_check_header_withpages( io_request = io_request io_response = io_response ).

          WHEN 'ZR_PFI008'.
            get_check_paiditem_withpages( io_request = io_request io_response = io_response ).

        ENDCASE.

      CATCH cx_rap_query_provider.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
