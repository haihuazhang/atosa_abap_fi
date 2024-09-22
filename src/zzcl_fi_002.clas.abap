CLASS zzcl_fi_002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_FI_002 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA lt_data TYPE TABLE OF zr_sfi001.

    DATA ls_item TYPE zc_sfi003.
    DATA lt_item TYPE TABLE OF zc_sfi003.
    DATA ls_group TYPE zr_sfi001.
    DATA lt_group TYPE TABLE OF zr_sfi001.

    DATA lv_originalamount TYPE i_journalentryitem-amountintransactioncurrency.
    DATA lv_remaining TYPE i_journalentryitem-amountintransactioncurrency.
    DATA lv_sequence TYPE i.

    DATA lr_companycode  TYPE RANGE OF i_journalentry-companycode.
    DATA lr_customer     TYPE RANGE OF i_journalentryitem-customer.
    DATA lr_filtertype  TYPE RANGE OF zr_sfi001-filtertype.
    DATA lr_filterdate TYPE RANGE OF zr_sfi001-filterdate.

    TRY.
        DATA(lt_filters) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'UUID'.
              IF io_request->is_total_numb_of_rec_requested(  ) .
                io_response->set_total_number_of_records( 1 ).
              ENDIF.
              io_response->set_data( lt_data ).
              RETURN.
            WHEN 'COMPANYCODE'.
              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
            WHEN 'CUSTOMER'.
              lr_customer = VALUE #( FOR ls_range IN ls_filter-range ( sign   = ls_range-sign
                                                                       option = ls_range-option
                                                                       low    = |{ ls_range-low ALPHA = IN }|
                                                                       high   = COND #( WHEN ls_range-high IS NOT INITIAL
                                                                                        THEN |{ ls_range-high ALPHA = IN }|
                                                                                        ELSE ls_range-high ) ) ).
            WHEN 'FILTERTYPE'.
              MOVE-CORRESPONDING ls_filter-range TO lr_filtertype.
            WHEN 'FILTERDATE'.
              MOVE-CORRESPONDING ls_filter-range TO lr_filterdate.
          ENDCASE.
        ENDLOOP.

        SELECT *
          FROM zc_sfi003
         WHERE companycode IN @lr_companycode
           AND customer IN @lr_customer
           AND accountingdocumenttype IN ( 'RV','DR','DG' )
           AND postingkey IN ( '01','11' )
*           AND ( ( accountingdocumenttype = 'RV' AND postingkey = '01' ) OR
*                 ( accountingdocumenttype = 'DR' AND postingkey = '01' ) OR
*                 ( accountingdocumenttype = 'DG' AND postingkey = '11' ) )
           AND glaccount = '1200000000'
          INTO TABLE @DATA(lt_invoice).

        IF sy-subrc = 0.
          SORT lt_invoice BY postingdate DESCENDING
                             accountingdocument DESCENDING.
          SELECT *
            FROM zc_sfi003
            FOR ALL ENTRIES IN @lt_invoice
           WHERE assignmentreference = @lt_invoice-assignmentreference
             AND companycode IN @lr_companycode
             AND customer IN @lr_customer
             AND accountingdocumenttype IN ( 'DZ','ZP' )
             AND glaccount = '1200000000'
            INTO TABLE @DATA(lt_payment_document).

          SORT lt_payment_document BY fiscalyear ASCENDING
                                      assignmentreference ASCENDING
                                      postingdate ASCENDING
                                      accountingdocumenttype ASCENDING
                                      accountingdocument ASCENDING
                                      ledgergllineitem ASCENDING.
        ENDIF.

        LOOP AT lt_invoice INTO DATA(ls_invoice).

          CLEAR: lv_originalamount,
                 lv_remaining,
                 lt_group.

*          " RV 01 / DR 01 / DG 11
*          IF ( ls_invoice-accountingdocumenttype = 'RV' AND ls_invoice-postingkey = '01' )
*          OR ( ls_invoice-accountingdocumenttype = 'DR' AND ls_invoice-postingkey = '01' )
*          OR ( ls_invoice-accountingdocumenttype = 'DG' AND ls_invoice-postingkey = '11' ).
          " 记录总金额
          lv_originalamount = ls_invoice-amountintransactioncurrency.
          " 记录结余
          lv_remaining = ls_invoice-amountintransactioncurrency.
*          ENDIF.

          READ TABLE lt_payment_document TRANSPORTING NO FIELDS
                                         WITH KEY assignmentreference = ls_invoice-assignmentreference.
          " Payment document doesn't exist
          IF sy-subrc <> 0 OR ls_invoice-assignmentreference IS INITIAL.
            APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
            lv_sequence += 1.
            TRY.
                DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
                " handle exception
            ENDTRY.
            <lfs_data> = VALUE #( uuid                      = lv_uuid
                                  sequence                  = lv_sequence
                                  " RV/DR/DG
                                  companycode               = ls_invoice-companycode
                                  accountingdocumenttype    = ls_invoice-accountingdocumenttype
                                  accountingdocument        = ls_invoice-accountingdocument
                                  assignmentreference       = ls_invoice-assignmentreference
                                  billingdocument           = ls_invoice-billingdocument
                                  customer                  = ls_invoice-customer
                                  customername              = ls_invoice-customername
                                  salesorgnization          = ls_invoice-salesorganization
                                  salesreppartner           = ls_invoice-salesreppartner
                                  salesreppartnername       = ls_invoice-salesreppartnername
                                  customerpo                = ls_invoice-documentreferenceid
                                  postingdate               = ls_invoice-postingdate
                                  netduedate                = ls_invoice-netduedate
                                  originalamount            = lv_originalamount
                                  transactioncurrency       = ls_invoice-transactioncurrency ).

            " 结余不为0 且 ClearingJE 不为空
            IF lv_originalamount IS NOT INITIAL AND ls_invoice-clearingjournalentry IS NOT INITIAL.
              SELECT SINGLE postingkey,
                            cashdiscountamount
                FROM zc_sfi003
               WHERE companycode = @ls_invoice-companycode
                 AND fiscalyear  = @ls_invoice-clearingjournalentryfiscalyear
                 AND accountingdocument = @ls_invoice-clearingjournalentry
                 AND glaccount = '1200000000'
                INTO @DATA(ls_clearing).

              " DZ/ZP
              " 已付总额 = 发票金额 - 结余
              <lfs_data>-paidtodate                = lv_originalamount.
              <lfs_data>-paymentaccdoctype         = ls_invoice-clearingjournalentrytype.
              <lfs_data>-paymentaccountingdocument = ls_invoice-clearingjournalentry.
              <lfs_data>-postingkey                = ls_clearing-postingkey.
              <lfs_data>-paymentdate               = ls_invoice-clearingdate.
              <lfs_data>-baesum                    = lv_originalamount.
*              <lfs_data>-actualreceipt             = lv_originalamount - ls_clearing-cashdiscountamount.
*              <lfs_data>-cashdiscount              = ls_clearing-cashdiscountamount.
              <lfs_data>-paymentbyuser             = ls_invoice-clearingbyuser.
              <lfs_data>-transactioncurrency       = ls_invoice-transactioncurrency.
            ENDIF.

          ELSE.

            LOOP AT lt_payment_document ASSIGNING FIELD-SYMBOL(<lfs_item>)
                                        WHERE assignmentreference = ls_invoice-assignmentreference.
              lv_sequence += 1.

              IF <lfs_item>-postingkey = '06'
              OR <lfs_item>-postingkey = '16'.
                " 本次结余
                <lfs_item>-remaining = <lfs_item>-amountintransactioncurrency.
                " 本次付款
                <lfs_item>-baesum = lv_remaining - <lfs_item>-remaining.
              ENDIF.

              IF <lfs_item>-postingkey = '05'
              OR <lfs_item>-postingkey = '08'.
                " 本次付款
                <lfs_item>-baesum = abs( <lfs_item>-amountintransactioncurrency ) * -1.
                " 本次结余
                <lfs_item>-remaining = lv_remaining - <lfs_item>-baesum.
              ENDIF.

              IF <lfs_item>-postingkey = '15'
              OR <lfs_item>-postingkey = '18'.
                " 本次付款
                <lfs_item>-baesum = abs( <lfs_item>-amountintransactioncurrency ).
                " 本次结余
                <lfs_item>-remaining = lv_remaining - <lfs_item>-baesum.
              ENDIF.

              " 记录结余
              lv_remaining = <lfs_item>-remaining.

              TRY.
                  CLEAR lv_uuid.
                  lv_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                CATCH cx_uuid_error.
                  " handle exception
              ENDTRY.

              APPEND INITIAL LINE TO lt_group ASSIGNING FIELD-SYMBOL(<lfs_group_line>).
              <lfs_group_line> = VALUE #( uuid                      = lv_uuid
                                          sequence                  = lv_sequence
                                          " RV/DR/DG
                                          companycode               = ls_invoice-companycode
                                          accountingdocumenttype    = ls_invoice-accountingdocumenttype
                                          accountingdocument        = ls_invoice-accountingdocument
                                          assignmentreference       = ls_invoice-assignmentreference
                                          billingdocument           = ls_invoice-billingdocument
                                          customer                  = ls_invoice-customer
                                          customername              = ls_invoice-customername
                                          salesorgnization          = ls_invoice-salesorganization
                                          salesreppartner           = ls_invoice-salesreppartner
                                          salesreppartnername       = ls_invoice-salesreppartnername
                                          customerpo                = ls_invoice-documentreferenceid
                                          postingdate               = ls_invoice-postingdate
                                          netduedate                = ls_invoice-netduedate
                                          originalamount            = lv_originalamount
                                          " DZ/ZP
                                          paymentaccdoctype         = <lfs_item>-accountingdocumenttype
                                          paymentaccountingdocument = <lfs_item>-accountingdocument
                                          postingkey                = <lfs_item>-postingkey
                                          paymentdate               = <lfs_item>-postingdate
                                          baesum                    = <lfs_item>-baesum
*                                          actualreceipt             = <lfs_item>-baesum - <lfs_item>-cashdiscountamount
*                                          cashdiscount              = <lfs_item>-cashdiscountamount
                                          remaining                 = <lfs_item>-remaining
                                          paymentbyuser             = <lfs_item>-createdbyuser
                                          transactioncurrency       = <lfs_item>-transactioncurrency ).
            ENDLOOP.

            " 最后一条的 结余不为0 且 ClearingJE 不为空
            IF lv_remaining IS NOT INITIAL AND <lfs_item>-clearingjournalentry IS NOT INITIAL.
              APPEND INITIAL LINE TO lt_group ASSIGNING FIELD-SYMBOL(<lfs_new_line>).
              lv_sequence += 1.
              TRY.
                  CLEAR lv_uuid.
                  lv_uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                CATCH cx_uuid_error.
                  " handle exception
              ENDTRY.

              CLEAR ls_clearing.
              SELECT SINGLE postingkey,
                            cashdiscountamount
                FROM zc_sfi003
               WHERE companycode = @ls_invoice-companycode
                 AND fiscalyear  = @<lfs_item>-clearingjournalentryfiscalyear
                 AND accountingdocument = @<lfs_item>-clearingjournalentry
                 AND glaccount = '1200000000'
                INTO @ls_clearing.

              <lfs_new_line> = VALUE #( uuid                      = lv_uuid
                                        sequence                  = lv_sequence
                                        " RV/DR/DG
                                        companycode               = ls_invoice-companycode
                                        accountingdocumenttype    = ls_invoice-accountingdocumenttype
                                        accountingdocument        = ls_invoice-accountingdocument
                                        assignmentreference       = ls_invoice-assignmentreference
                                        billingdocument           = ls_invoice-billingdocument
                                        customer                  = ls_invoice-customer
                                        customername              = ls_invoice-customername
                                        salesorgnization          = ls_invoice-salesorganization
                                        salesreppartner           = ls_invoice-salesreppartner
                                        salesreppartnername       = ls_invoice-salesreppartnername
                                        customerpo                = ls_invoice-documentreferenceid
                                        postingdate               = ls_invoice-postingdate
                                        netduedate                = ls_invoice-netduedate
                                        originalamount            = lv_originalamount
                                        " DZ/ZP
                                        paymentaccdoctype         = <lfs_item>-clearingjournalentrytype
                                        paymentaccountingdocument = <lfs_item>-clearingjournalentry
                                        postingkey                = ls_clearing-postingkey
                                        paymentdate               = <lfs_item>-clearingdate
                                        baesum                    = lv_remaining
*                                        actualreceipt             = lv_remaining - ls_clearing-cashdiscountamount
*                                        cashdiscount              = ls_clearing-cashdiscountamount
                                        paymentbyuser             = <lfs_item>-clearingbyuser
                                        transactioncurrency       = <lfs_item>-transactioncurrency ).
              CLEAR lv_remaining.
            ENDIF.

            CLEAR ls_group.
            " 已付总额 = 发票金额 - 结余
            ls_group-paidtodate = lv_originalamount - lv_remaining.
            MODIFY lt_group FROM ls_group TRANSPORTING paidtodate WHERE assignmentreference = ls_invoice-assignmentreference.

            APPEND LINES OF lt_group TO lt_data.
          ENDIF.

          CLEAR: ls_invoice, ls_clearing.
        ENDLOOP.

        SORT lt_data BY sequence ASCENDING.

        IF lr_filterdate IS NOT INITIAL.
          IF lr_filtertype[ 1 ]-low = 'I'.
            DELETE lt_data WHERE postingdate NOT IN lr_filterdate.
            DELETE lt_data WHERE postingdate IS INITIAL.
          ENDIF.
          IF lr_filtertype[ 1 ]-low = 'P'.
            DELETE lt_data WHERE paymentdate NOT IN lr_filterdate.
            DELETE lt_data WHERE paymentdate IS INITIAL.
          ENDIF.
        ENDIF.

        FIELD-SYMBOLS: <fs_data> TYPE any,
                       <fs_fval> TYPE any.
        DATA lv_index TYPE sy-tabix.
        LOOP AT lt_filters INTO ls_filter.
          TRANSLATE ls_filter-name TO UPPER CASE.        "#EC TRANSLANG
          IF ls_filter-name <> 'CUSTOMER' AND ls_filter-name <> 'FILTERTYPE' AND ls_filter-name <> 'FILTERDATE'.
            LOOP AT lt_data ASSIGNING <fs_data>.
              lv_index = sy-tabix.
              ASSIGN COMPONENT ls_filter-name OF STRUCTURE <fs_data> TO <fs_fval>.
              CHECK sy-subrc EQ 0.
              IF <fs_fval> NOT IN ls_filter-range.
                DELETE lt_data INDEX lv_index.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                   CHANGING  ct_data  = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                  CHANGING  ct_data   = lt_data ).

        io_response->set_data( lt_data ).

      CATCH cx_root.
        " Do Nothing
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
