CLASS zzcl_fi_005 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: tt_paiditem TYPE STANDARD TABLE OF zr_pfi008.

    METHODS  get_bank_reconcil_statems      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                      io_response TYPE REF TO if_rap_query_response
                                            RAISING   cx_rap_query_prov_not_impl
                                                      cx_rap_query_provider.

    METHODS  get_unmatched_journalentries      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                         io_response TYPE REF TO if_rap_query_response
                                               RAISING   cx_rap_query_prov_not_impl
                                                         cx_rap_query_provider.

    METHODS  get_unmatched_bankstatementits      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                           io_response TYPE REF TO if_rap_query_response
                                                 RAISING   cx_rap_query_prov_not_impl
                                                           cx_rap_query_provider.


    METHODS get_unmatched_jei_by_asso IMPORTING is_key  TYPE data
                                      EXPORTING et_data TYPE STANDARD TABLE
                                      RAISING   cx_rap_query_prov_not_impl
                                                cx_rap_query_provider.

    METHODS get_unmatched_jei_by_asso_prti IMPORTING is_key  TYPE data
                                           EXPORTING et_data TYPE STANDARD TABLE
                                           RAISING   cx_rap_query_prov_not_impl
                                                     cx_rap_query_provider.

    METHODS get_unmatched_bkis_by_asso IMPORTING is_key  TYPE data
                                       EXPORTING et_data TYPE STANDARD TABLE
                                       RAISING   cx_rap_query_prov_not_impl
                                                 cx_rap_query_provider.





    METHODS get_matched_journalentries  IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                  io_response TYPE REF TO if_rap_query_response
                                        RAISING   cx_rap_query_prov_not_impl
                                                  cx_rap_query_provider.
    METHODS get_matched_bankstatementits  IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                    io_response TYPE REF TO if_rap_query_response
                                          RAISING   cx_rap_query_prov_not_impl
                                                    cx_rap_query_provider.

    METHODS get_all_bankstatemntits IMPORTING io_request TYPE REF TO if_rap_query_request
                                    EXPORTING et_data    TYPE STANDARD TABLE
                                    RAISING   cx_rap_query_prov_not_impl
                                              cx_rap_query_provider.


    METHODS  get_unmatched_incoming_jes      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                       io_response TYPE REF TO if_rap_query_response
                                             RAISING   cx_rap_query_prov_not_impl
                                                       cx_rap_query_provider.

    METHODS  get_unmatched_outgoing_jes      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                       io_response TYPE REF TO if_rap_query_response
                                             RAISING   cx_rap_query_prov_not_impl
                                                       cx_rap_query_provider.

    METHODS  get_matched_incoming_jes      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                     io_response TYPE REF TO if_rap_query_response
                                           RAISING   cx_rap_query_prov_not_impl
                                                     cx_rap_query_provider.

    METHODS  get_matched_outgoing_jes      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                     io_response TYPE REF TO if_rap_query_response
                                           RAISING   cx_rap_query_prov_not_impl
                                                     cx_rap_query_provider.

    METHODS  get_bank_reconcil_statems_prt      IMPORTING io_request  TYPE REF TO if_rap_query_request
                                                          io_response TYPE REF TO if_rap_query_response
                                                RAISING   cx_rap_query_prov_not_impl
                                                          cx_rap_query_provider.
ENDCLASS.



CLASS ZZCL_FI_005 IMPLEMENTATION.


  METHOD get_all_bankstatemntits.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

    DATA:      ls_data TYPE zr_sfi011.
    DATA:
      lt_business_data TYPE TABLE OF zzyy1_bankstatement,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA : lv_BANKRECONCILIATIONDATE TYPE datum.


    DATA:
      lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node_1    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_3    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_4    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_root TYPE REF TO /iwbep/if_cp_filter_node.
* lt_range_COMPANYCODE TYPE RANGE OF <element_name>,
* lt_range_HOUSEBANK TYPE RANGE OF <element_name>.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*          exc     TYPE REF TO cx_rap_query_provider.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.
    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'YY1_API'
                                                     comm_system_id = lo_ca->get_comm_system_id( )
                                                     service_id     = 'YY1_API_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZZFISCM002'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/YY1_BANKSTATEMENT_CDS' ).

        ASSERT lo_http_client IS BOUND.



        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'YY1_BANKSTATEMENT' )->create_request_for_read( ).

        " Create the filter tree
        lo_filter_factory = lo_request->create_filter_factory( ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.

          IF ls_filter-name = 'BANKRECONCILIATIONDATE'.
            LOOP AT ls_filter-range ASSIGNING FIELD-SYMBOL(<fs_range>).
              lv_BANKRECONCILIATIONDATE = <fs_range>-low.

              IF <fs_range>-low IS NOT INITIAL.
                cl_abap_tstmp=>systemtstmp_syst2utc(
                    EXPORTING
                        syst_date = CONV d( <fs_range>-low )
                        syst_time = CONV t( '000000' )
                    IMPORTING
                        utc_tstmp = DATA(lv_tstmp)
                ).
                <fs_range>-low = cl_abap_tstmp=>normalize(
                    EXPORTING
                        tstmp_in = lv_tstmp
                ).
              ENDIF.

              IF <fs_range>-high IS NOT INITIAL.
                cl_abap_tstmp=>systemtstmp_syst2utc(
                    EXPORTING
                        syst_date = CONV d( <fs_range>-high )
                        syst_time = CONV t( '000000' )
                    IMPORTING
                        utc_tstmp = lv_tstmp
                ).
                <fs_range>-high = cl_abap_tstmp=>normalize(
                    EXPORTING
                        tstmp_in = lv_tstmp
                ).
              ENDIF.


            ENDLOOP.
            ls_filter-name = 'BANKSTATEMENTDATE'.

          ENDIF.

          IF lo_filter_node_root IS NOT BOUND.
            lo_filter_node_root = lo_filter_factory->create_by_range( iv_property_path   = ls_filter-name
                                                                    it_range             = ls_filter-range ).
          ELSE.
            lo_filter_node_root->and( lo_filter_factory->create_by_range( iv_property_path     = ls_filter-name
                                                                    it_range             = ls_filter-range ) ).
          ENDIF.
        ENDLOOP.



        IF lo_filter_node_root IS BOUND.
          lo_request->set_filter( lo_filter_node_root ).
        ENDIF.






        zzcl_odata_utils=>get_paging( EXPORTING io_paging = io_request->get_paging(  )
                                      IMPORTING top = DATA(lv_top) skip = DATA(lv_skip) ).
        IF lv_top <> if_rap_query_paging=>page_size_unlimited.
          lo_request->set_top( lv_top )->set_skip( lv_skip ).
        ENDIF.

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).

        TRY .
            LOOP AT lt_business_data INTO DATA(ls_bus_data).
*                append in
*                ls_bus_data
              CLEAR ls_data.
              ls_data = CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate ValueDate PostingDate ).

              ls_data-BankReconciliationDate = lv_BANKRECONCILIATIONDATE.
*              DATA(lv_BankReconciliationDateshort) = cl_abap_tstmp=>move_to_short(
*                  EXPORTING
*                      tstmp_src = ls_bus_data-BankReconciliationDate
*               ).
*              cl_abap_tstmp=>systemtstmp_utc2syst(
*                  EXPORTING
*                      utc_tstmp = lv_BankReconciliationDateshort
*                  IMPORTING
*                      syst_date = ls_data-BankReconciliationDate
*               ).


              DATA(lv_ValueDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-ValueDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_ValueDateshort
                  IMPORTING
                      syst_date = ls_data-ValueDate
               ).

              DATA(lv_postingdateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-PostingDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_postingdateshort
                  IMPORTING
                      syst_date = ls_data-PostingDate
               ).

              APPEND ls_data TO et_data.
            ENDLOOP.

          CATCH cx_sy_conversion_overflow INTO DATA(lx_overflow).
            DATA(lv_msg) = lx_overflow->get_longtext(  ).
        ENDTRY.

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_remote.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_gateway.


      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lX_HTTP_DEST_PROVIDER_ERROR).
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lX_HTTP_DEST_PROVIDER_ERROR.
    ENDTRY.

  ENDMETHOD.


  METHOD get_bank_reconcil_statems.
*    DATA : lr_companycode            TYPE RANGE OF zr_sfi007-CompanyCode,
*           lr_housebank              TYPE RANGE OF zr_sfi007-HouseBank,
*           lr_housebankaccount       TYPE RANGE OF zr_sfi007-HouseBankAccount,
*           lr_BankReconciliationDate TYPE RANGE OF zr_sfi007-BankReconciliationDate.
    DATA : lt_data TYPE TABLE OF zr_sfi007,
           ls_data TYPE zr_sfi007.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.

*    LOOP AT lt_filters INTO DATA(ls_filter).
*      TRANSLATE ls_filter-name TO UPPER CASE.
*      CASE ls_filter-name.
*        WHEN 'COMPANYCODE'.
*          MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
*        WHEN 'HOUSEBANK'.
*          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
*        WHEN 'HOUSEBANKACCOUNT'.
*          MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
*        WHEN 'BANKRECONCILIATIONDATE'.
*          MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
*      ENDCASE.
*    ENDLOOP.



    DATA:
      lt_business_data TYPE TABLE OF zzbankreconciliationstatements,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA:
      lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node_1    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_3    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_4    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_root TYPE REF TO /iwbep/if_cp_filter_node.
* lt_range_COMPANYCODE TYPE RANGE OF <element_name>,
* lt_range_HOUSEBANK TYPE RANGE OF <element_name>.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*          exc     TYPE REF TO cx_rap_query_provider.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.
    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'YY1_API'
                                                     comm_system_id = lo_ca->get_comm_system_id( )
                                                     service_id     = 'YY1_API_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZZFISCM001'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/API_CN_BANK_RECONCILIAITON_SRV' ).

        ASSERT lo_http_client IS BOUND.



        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'BANKRECONCILIATIONSTATEMENTSET' )->create_request_for_read( ).

        " Create the filter tree
        lo_filter_factory = lo_request->create_filter_factory( ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.

          IF ls_filter-name = 'BANKRECONCILIATIONDATE'.
            LOOP AT ls_filter-range ASSIGNING FIELD-SYMBOL(<fs_range>).

              IF <fs_range>-low IS NOT INITIAL.
                cl_abap_tstmp=>systemtstmp_syst2utc(
                    EXPORTING
                        syst_date = CONV d( <fs_range>-low )
                        syst_time = CONV t( '000000' )
                    IMPORTING
                        utc_tstmp = DATA(lv_tstmp)
                ).
                <fs_range>-low = cl_abap_tstmp=>normalize(
                    EXPORTING
                        tstmp_in = lv_tstmp
                ).
              ENDIF.

              IF <fs_range>-high IS NOT INITIAL.
                cl_abap_tstmp=>systemtstmp_syst2utc(
                    EXPORTING
                        syst_date = CONV d( <fs_range>-high )
                        syst_time = CONV t( '000000' )
                    IMPORTING
                        utc_tstmp = lv_tstmp
                ).
                <fs_range>-high = cl_abap_tstmp=>normalize(
                    EXPORTING
                        tstmp_in = lv_tstmp
                ).
              ENDIF.


            ENDLOOP.
          ENDIF.

          IF lo_filter_node_root IS NOT BOUND.
            lo_filter_node_root = lo_filter_factory->create_by_range( iv_property_path     = ls_filter-name
                                                                    it_range             = ls_filter-range ).
          ELSE.
            lo_filter_node_root->and( lo_filter_factory->create_by_range( iv_property_path     = ls_filter-name
                                                                    it_range             = ls_filter-range ) ).
          ENDIF.
        ENDLOOP.
        IF lo_filter_node_root IS BOUND.
          lo_request->set_filter( lo_filter_node_root ).
        ENDIF.


*        IF lr_companycode IS NOT INITIAL.
*          lo_filter_node_1  = lo_filter_factory->create_by_range( iv_property_path     = 'COMPANYCODE'
*                                                                  it_range             = lr_companycode ).
*        ENDIF.
*        IF lr_housebank IS NOT INITIAL.
*          lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'HOUSEBANK'
*                                                                  it_range             = lr_housebank ).
*        ENDIF.
*        IF lr_housebankaccount IS NOT INITIAL.
*          lo_filter_node_3  = lo_filter_factory->create_by_range( iv_property_path     = 'HOUSEBANKACCOUNT'
*                                                                  it_range             = lr_housebankaccount ).
*        ENDIF.
*        IF lr_bankreconciliationdate IS NOT INITIAL.
*          lo_filter_node_4  = lo_filter_factory->create_by_range( iv_property_path     = 'BANKRECONCILIATIONDATE'
*                                                                  it_range             = lr_bankreconciliationdate ).
*        ENDIF.

*        lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_2 )->and( lo_filter_node_3 )->and( lo_filter_node_4 ).



        zzcl_odata_utils=>get_paging( EXPORTING io_paging = io_request->get_paging(  )
                                      IMPORTING top = DATA(lv_top) skip = DATA(lv_skip) ).
        IF lv_top <> if_rap_query_paging=>page_size_unlimited.
          lo_request->set_top( lv_top )->set_skip( lv_skip ).
        ENDIF.

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        TRY .
*        lt_data = CORRESPONDING #( lt_business_data EXCEPT BankReconciliationDate ).
*        lt_data = VALUE #( for ls_bus_data in lt_business_data (
*            CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate )
*
*         ) ).
            LOOP AT lt_business_data INTO DATA(ls_bus_data).
*                append in
*                ls_bus_data
              CLEAR ls_data.
              ls_data = CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate ).
*               ls_data-BankReconciliationDate = ls_bus_data-BankReconciliationDate.
*               CL_ABAP_DATFM=>
*               CL_ABAP_TIMEFM=>
*                CL_ABAP_UTCLONG
              DATA(lv_BankReconciliationDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-BankReconciliationDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_BankReconciliationDateshort
                  IMPORTING
                      syst_date = ls_data-BankReconciliationDate
               ).
              APPEND ls_data TO lt_data.
            ENDLOOP.

          CATCH cx_sy_conversion_overflow INTO DATA(lx_overflow).
            DATA(lv_msg) = lx_overflow->get_longtext(  ).
        ENDTRY.


        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).



      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_remote.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_gateway.


      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lX_HTTP_DEST_PROVIDER_ERROR).
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lX_HTTP_DEST_PROVIDER_ERROR.

    ENDTRY.


  ENDMETHOD.


  METHOD get_bank_reconcil_statems_prt.
    DATA : lt_data TYPE TABLE OF zr_sfi012,
           ls_data TYPE zr_sfi012.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.




    DATA:
      lt_business_data TYPE TABLE OF zzbankreconciliationstatements,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA:
      lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node_1    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_3    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_4    TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_root TYPE REF TO /iwbep/if_cp_filter_node.
* lt_range_COMPANYCODE TYPE RANGE OF <element_name>,
* lt_range_HOUSEBANK TYPE RANGE OF <element_name>.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*          exc     TYPE REF TO cx_rap_query_provider.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.
    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'YY1_API'
                                                     comm_system_id = lo_ca->get_comm_system_id( )
                                                     service_id     = 'YY1_API_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZZFISCM001'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/API_CN_BANK_RECONCILIAITON_SRV' ).

        ASSERT lo_http_client IS BOUND.



        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'BANKRECONCILIATIONSTATEMENTSET' )->create_request_for_read( ).

        " Create the filter tree
        lo_filter_factory = lo_request->create_filter_factory( ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.

          IF ls_filter-name = 'BANKRECONCILIATIONDATE'.
            LOOP AT ls_filter-range ASSIGNING FIELD-SYMBOL(<fs_range>).

              IF <fs_range>-low IS NOT INITIAL.
                cl_abap_tstmp=>systemtstmp_syst2utc(
                    EXPORTING
                        syst_date = CONV d( <fs_range>-low )
                        syst_time = CONV t( '000000' )
                    IMPORTING
                        utc_tstmp = DATA(lv_tstmp)
                ).
                <fs_range>-low = cl_abap_tstmp=>normalize(
                    EXPORTING
                        tstmp_in = lv_tstmp
                ).
              ENDIF.

              IF <fs_range>-high IS NOT INITIAL.
                cl_abap_tstmp=>systemtstmp_syst2utc(
                    EXPORTING
                        syst_date = CONV d( <fs_range>-high )
                        syst_time = CONV t( '000000' )
                    IMPORTING
                        utc_tstmp = lv_tstmp
                ).
                <fs_range>-high = cl_abap_tstmp=>normalize(
                    EXPORTING
                        tstmp_in = lv_tstmp
                ).
              ENDIF.


            ENDLOOP.
          ENDIF.

          IF lo_filter_node_root IS NOT BOUND.
            lo_filter_node_root = lo_filter_factory->create_by_range( iv_property_path     = ls_filter-name
                                                                    it_range             = ls_filter-range ).
          ELSE.
            lo_filter_node_root->and( lo_filter_factory->create_by_range( iv_property_path     = ls_filter-name
                                                                    it_range             = ls_filter-range ) ).
          ENDIF.
        ENDLOOP.
        IF lo_filter_node_root IS BOUND.
          lo_request->set_filter( lo_filter_node_root ).
        ENDIF.


        zzcl_odata_utils=>get_paging( EXPORTING io_paging = io_request->get_paging(  )
                                      IMPORTING top = DATA(lv_top) skip = DATA(lv_skip) ).
        IF lv_top <> if_rap_query_paging=>page_size_unlimited.
          lo_request->set_top( lv_top )->set_skip( lv_skip ).
        ENDIF.

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        TRY .


            LOOP AT lt_business_data INTO DATA(ls_bus_data).
*                append in
*                ls_bus_data
              CLEAR ls_data.
              ls_data = CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate ).
*               ls_data-BankReconciliationDate = ls_bus_data-BankReconciliationDate.
*               CL_ABAP_DATFM=>
*               CL_ABAP_TIMEFM=>
*                CL_ABAP_UTCLONG
              DATA(lv_BankReconciliationDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-BankReconciliationDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_BankReconciliationDateshort
                  IMPORTING
                      syst_date = ls_data-BankReconciliationDate
               ).
              APPEND ls_data TO lt_data.
            ENDLOOP.

          CATCH cx_sy_conversion_overflow INTO DATA(lx_overflow).
            DATA(lv_msg) = lx_overflow->get_longtext(  ).
        ENDTRY.


        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).



      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_remote.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_gateway.


      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lX_HTTP_DEST_PROVIDER_ERROR).
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lX_HTTP_DEST_PROVIDER_ERROR.

    ENDTRY.
  ENDMETHOD.


  METHOD get_matched_bankstatementits.
    DATA : lt_unmatched_data TYPE TABLE OF zr_sfi009,
           ls_unmatched_data TYPE zr_sfi009.

    DATA : lt_data TYPE TABLE OF zr_sfi011,
           ls_data TYPE zr_sfi011.

    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key                    TYPE ts_key,
      lv_bankreconciliationdate TYPE datum.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
              lv_bankreconciliationdate = ls_filter-range[ 1 ]-low.
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        me->get_unmatched_bkis_by_asso(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_unmatched_data

         ).
        SORT lt_unmatched_data BY BankStatementShortID BankStatementItem.


        "Get All Bank Statements

        me->get_all_bankstatemntits(
            EXPORTING io_request = io_request
            IMPORTING et_data = lt_data

         ).




*        SELECT a~CompanyCode,
*               a~HouseBank ,
*               a~HouseBankAccount,
*               a~BankStatementShortID,
*               b~BankStatementItem           ,
*               b~ValueDate,
*               b~AmountInTransactionCurrency,
*               b~TransactionCurrency,
*               b~PostingDate,
*               b~BankStatementPostingRule
*  FROM I_BankStatement AS a JOIN i_BankStatementItem AS b ON a~BankStatementShortID = b~BankStatementShortID
*  WHERE a~CompanyCode = @ls_key-companycode
*    AND a~HouseBank = @ls_key-housebank
*    AND a~HouseBankAccount = @ls_key-housebankaccount
*    AND a~BankStatementDate = @lv_bankreconciliationdate
*    INTO TABLE @DATA(lt_alllines).
*
*
        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_allline>).
          DATA(lv_index) = sy-tabix.
          READ TABLE lt_unmatched_data TRANSPORTING NO FIELDS WITH KEY BankStatementShortID = <fs_allline>-BankStatementShortID
                                                                       BankStatementItem = <fs_allline>-BankStatementItem
                                                                       BINARY SEARCH.
          IF sy-subrc = 0.

            DELETE lt_data INDEX lv_index.
*            CLEAR ls_data.
*            MOVE-CORRESPONDING <fs_allline> TO ls_data.
*            ls_data-BankReconciliationDate = lv_bankreconciliationdate.
*            APPEND ls_data TO lt_data.
          ENDIF.



        ENDLOOP.








        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).


*      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
*        " Handle remote Exception
*        " It contains details about the problems of your http(s) connection
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_remote.
*
*      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*        " Handle Exception
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_gateway.
*
*
*      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
*        " Handle Exception
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_web_http_client_error.
    ENDTRY.
  ENDMETHOD.


  METHOD get_matched_incoming_jes.
    DATA : lt_unmatched_data TYPE TABLE OF zr_sfi008.
    DATA : lt_data TYPE TABLE OF zr_sfi013,
           ls_data TYPE zr_sfi013.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key                    TYPE ts_key,
      lv_BANKRECONCILIATIONDATE TYPE datum,
      lv_balance                TYPE zr_sfi008-AmountInTransactionCurrency.


    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
              lv_BANKRECONCILIATIONDATE = ls_filter-range[ 1 ]-low.
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        "Get Unmatched entries.
        me->get_unmatched_jei_by_asso(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_unmatched_data

         ).

        SORT lt_unmatched_data BY CompanyCode FiscalYear AccountingDocument AccountingDocumentItem.


        " Get All Journal Entries
        SELECT a~CompanyCode,
               a~AccountingDocument,
               a~FiscalYear,
                a~AccountingDocumentItem,
                a~AccountingDocumentType,
                a~Customer,
                a~Supplier,
                a~PaymentMethod,
                b~CustomerName,
                c~SupplierName,
               a~AmountInCompanyCodeCurrency,
               a~CompanyCodeCurrency,
               a~PostingDate,
               a~HouseBank,
               a~HouseBankAccount
                                FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS AS a
                   LEFT OUTER JOIN I_Customer WITH PRIVILEGED ACCESS AS b ON a~Customer = b~Customer
                   LEFT OUTER JOIN I_Supplier WITH PRIVILEGED ACCESS AS c ON a~Supplier = c~Supplier
*             FOR ALL ENTRIES IN @lt_data
             WHERE
                a~CompanyCode = @ls_key-companycode
*               AND a~FiscalYear = @ls_key-
               AND a~HouseBank = @ls_key-housebank
               AND a~HouseBankAccount = @ls_key-housebankaccount
               AND a~PostingDate <= @lv_BANKRECONCILIATIONDATE
               INTO TABLE @DATA(lt_allline).

        IF lt_allline IS NOT INITIAL.
          SELECT FiscalYear,
                 PaymentCompanyCode,
                 PaymentDocument,
                 OutgoingCheque
                 FROM I_OutgoingCheck WITH PRIVILEGED ACCESS
                 FOR ALL ENTRIES IN @lt_allline
                 WHERE Fiscalyear = @lt_allline-FiscalYear
                   AND PaymentCompanyCode = @lt_allline-CompanyCode
                   AND PaymentDocument = @lt_allline-AccountingDocument
                   AND ChequeStatus <> '20'
                   INTO TABLE @DATA(lt_cheque).
          SORT lt_CHEQUE BY FiscalYear PaymentCompanyCode PaymentDocument.
        ENDIF.

        " Get Matched GL Lines
        LOOP AT lt_allline ASSIGNING FIELD-SYMBOL(<fs_allline>).
          DATA(lv_index) = sy-tabix.
          READ TABLE lt_unmatched_data TRANSPORTING NO FIELDS WITH KEY CompanyCode = <fs_allline>-CompanyCode
                                                                       FiscalYear = <fs_allline>-FiscalYear
                                                                       AccountingDocument = <fs_allline>-AccountingDocument
                                                                       AccountingDocumentItem = <fs_allline>-AccountingDocumentItem
                                                                       BINARY SEARCH.
          IF sy-subrc <> 0.






            CLEAR ls_data.

            IF <fs_allline>-AmountInCompanyCodeCurrency < 0 .
              CONTINUE.
            ELSE.
              ls_data-DebitAmountInTransCrcy = abs( <fs_allline>-AmountInCompanyCodeCurrency ).
            ENDIF.

            lv_balance += ls_data-DebitAmountInTransCrcy.
            ls_data-BalanceInTransCrcy = lv_balance.

            MOVE-CORRESPONDING <fs_allline> TO ls_data.
            ls_data-BankReconciliationDate = lv_bankreconciliationdate.

            IF ls_data-Customer IS NOT INITIAL.
              ls_data-BPCode = ls_data-customer.
              ls_data-BPName = ls_data-CustomerName.
            ELSE.
              ls_data-BPCode = ls_data-Supplier.
              ls_data-BPName = ls_data-SupplierName.
            ENDIF.

            READ TABLE lt_cheque INTO DATA(ls_CHEQUE) WITH KEY FiscalYear = ls_data-FiscalYear
                                                    PaymentCompanyCode = ls_data-CompanyCode
                                                    PaymentDocument = ls_data-AccountingDocument
                                                    BINARY SEARCH.
            IF sy-subrc = 0.
              ls_data-OutgoingCheque = ls_cheque-OutgoingCheque.
            ENDIF.





            APPEND ls_data TO lt_data.
          ENDIF.
        ENDLOOP.








        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).

    ENDTRY.


  ENDMETHOD.


  METHOD get_matched_journalentries.
    DATA : lt_unmatched_data TYPE TABLE OF zr_sfi008.
    DATA : lt_data TYPE TABLE OF zr_sfi010,
           ls_data TYPE zr_sfi010.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key                    TYPE ts_key,
      lv_BANKRECONCILIATIONDATE TYPE datum.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
              lv_BANKRECONCILIATIONDATE = ls_filter-range[ 1 ]-low.
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        "Get Unmatched entries.
        me->get_unmatched_jei_by_asso(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_unmatched_data

         ).

        SORT lt_unmatched_data BY CompanyCode FiscalYear AccountingDocument AccountingDocumentItem.


        " Get All Journal Entries
        SELECT a~CompanyCode,
               a~AccountingDocument,
               a~FiscalYear,
                a~AccountingDocumentItem,
                a~AccountingDocumentType,
                a~Customer,
                a~Supplier,
                a~PaymentMethod,
                b~CustomerName,
                c~SupplierName,
               a~AmountInCompanyCodeCurrency,
               a~CompanyCodeCurrency,
               a~PostingDate,
               a~HouseBank,
               a~HouseBankAccount
                                FROM I_OperationalAcctgDocItem AS a
                   LEFT OUTER JOIN I_Customer AS b ON a~Customer = b~Customer
                   LEFT OUTER JOIN I_Supplier AS c ON a~Supplier = c~Supplier
*             FOR ALL ENTRIES IN @lt_data
             WHERE
                a~CompanyCode = @ls_key-companycode
*               AND a~FiscalYear = @ls_key-
               AND a~HouseBank = @ls_key-housebank
               AND a~HouseBankAccount = @ls_key-housebankaccount
               AND a~PostingDate <= @lv_BANKRECONCILIATIONDATE
               INTO TABLE @DATA(lt_allline).

        IF lt_allline IS NOT INITIAL.
          SELECT FiscalYear,
                 PaymentCompanyCode,
                 PaymentDocument,
                 OutgoingCheque
                 FROM I_OutgoingCheck
                 FOR ALL ENTRIES IN @lt_allline
                 WHERE Fiscalyear = @lt_allline-FiscalYear
                   AND PaymentCompanyCode = @lt_allline-CompanyCode
                   AND PaymentDocument = @lt_allline-AccountingDocument
                   AND ChequeStatus <> '20'
                   INTO TABLE @DATA(lt_cheque).
          SORT lt_CHEQUE BY FiscalYear PaymentCompanyCode PaymentDocument.
        ENDIF.

        " Get Matched GL Lines
        LOOP AT lt_allline ASSIGNING FIELD-SYMBOL(<fs_allline>).
          DATA(lv_index) = sy-tabix.
          READ TABLE lt_unmatched_data TRANSPORTING NO FIELDS WITH KEY CompanyCode = <fs_allline>-CompanyCode
                                                                       FiscalYear = <fs_allline>-FiscalYear
                                                                       AccountingDocument = <fs_allline>-AccountingDocument
                                                                       AccountingDocumentItem = <fs_allline>-AccountingDocumentItem
                                                                       BINARY SEARCH.
          IF sy-subrc <> 0.
**                DELETE lt_allline INDEX lv_index.
            CLEAR ls_data.
            MOVE-CORRESPONDING <fs_allline> TO ls_data.
            ls_data-BankReconciliationDate = lv_bankreconciliationdate.

            READ TABLE lt_cheque INTO DATA(ls_CHEQUE) WITH KEY FiscalYear = ls_data-FiscalYear
                                                    PaymentCompanyCode = ls_data-CompanyCode
                                                    PaymentDocument = ls_data-AccountingDocument
                                                    BINARY SEARCH.
            IF sy-subrc = 0.
              ls_data-OutgoingCheque = ls_cheque-OutgoingCheque.
            ENDIF.


            APPEND ls_data TO lt_data.
          ENDIF.



        ENDLOOP.








        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).

    ENDTRY.
  ENDMETHOD.


  METHOD get_matched_outgoing_jes.
    DATA : lt_unmatched_data TYPE TABLE OF zr_sfi008.
    DATA : lt_data TYPE TABLE OF zr_sfi014,
           ls_data TYPE zr_sfi014.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key                    TYPE ts_key,
      lv_BANKRECONCILIATIONDATE TYPE datum,
      lv_balance                TYPE zr_sfi008-AmountInCompanyCodeCurrency.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
              lv_BANKRECONCILIATIONDATE = ls_filter-range[ 1 ]-low.
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        "Get Unmatched entries.
        me->get_unmatched_jei_by_asso(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_unmatched_data

         ).

        SORT lt_unmatched_data BY CompanyCode FiscalYear AccountingDocument AccountingDocumentItem.


        " Get All Journal Entries
        SELECT a~CompanyCode,
               a~AccountingDocument,
               a~FiscalYear,
                a~AccountingDocumentItem,
                a~AccountingDocumentType,
                a~Customer,
                a~Supplier,
                a~PaymentMethod,
                b~CustomerName,
                c~SupplierName,
               a~AmountInCompanyCodeCurrency,
               a~CompanyCodeCurrency,
               a~PostingDate,
               a~HouseBank,
               a~HouseBankAccount
                                FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS AS a
                   LEFT OUTER JOIN I_Customer WITH PRIVILEGED ACCESS AS b ON a~Customer = b~Customer
                   LEFT OUTER JOIN I_Supplier WITH PRIVILEGED ACCESS AS c ON a~Supplier = c~Supplier
*             FOR ALL ENTRIES IN @lt_data
             WHERE
                a~CompanyCode = @ls_key-companycode
*               AND a~FiscalYear = @ls_key-
               AND a~HouseBank = @ls_key-housebank
               AND a~HouseBankAccount = @ls_key-housebankaccount
               AND a~PostingDate <= @lv_BANKRECONCILIATIONDATE
               INTO TABLE @DATA(lt_allline).

        IF lt_allline IS NOT INITIAL.
          SELECT FiscalYear,
                 PaymentCompanyCode,
                 PaymentDocument,
                 OutgoingCheque
                 FROM I_OutgoingCheck WITH PRIVILEGED ACCESS
                 FOR ALL ENTRIES IN @lt_allline
                 WHERE Fiscalyear = @lt_allline-FiscalYear
                   AND PaymentCompanyCode = @lt_allline-CompanyCode
                   AND PaymentDocument = @lt_allline-AccountingDocument
                   AND ChequeStatus <> '20'
                   INTO TABLE @DATA(lt_cheque).
          SORT lt_CHEQUE BY FiscalYear PaymentCompanyCode PaymentDocument.
        ENDIF.

        " Get Matched GL Lines
        LOOP AT lt_allline ASSIGNING FIELD-SYMBOL(<fs_allline>).
          DATA(lv_index) = sy-tabix.
          READ TABLE lt_unmatched_data TRANSPORTING NO FIELDS WITH KEY CompanyCode = <fs_allline>-CompanyCode
                                                                       FiscalYear = <fs_allline>-FiscalYear
                                                                       AccountingDocument = <fs_allline>-AccountingDocument
                                                                       AccountingDocumentItem = <fs_allline>-AccountingDocumentItem
                                                                       BINARY SEARCH.
          IF sy-subrc <> 0.






            CLEAR ls_data.

            IF <fs_allline>-AmountInCompanyCodeCurrency > 0 .
              CONTINUE.
            ELSE.
              ls_data-CreditAmountInTransCrcy = abs( <fs_allline>-AmountInCompanyCodeCurrency ).
            ENDIF.

            lv_balance += ls_data-CreditAmountInTransCrcy.
            ls_data-BalanceInTransCrcy = lv_balance.

            MOVE-CORRESPONDING <fs_allline> TO ls_data.
            ls_data-BankReconciliationDate = lv_bankreconciliationdate.

            IF ls_data-Customer IS NOT INITIAL.
              ls_data-BPCode = ls_data-customer.
              ls_data-BPName = ls_data-CustomerName.
            ELSE.
              ls_data-BPCode = ls_data-Supplier.
              ls_data-BPName = ls_data-SupplierName.
            ENDIF.

            READ TABLE lt_cheque INTO DATA(ls_CHEQUE) WITH KEY FiscalYear = ls_data-FiscalYear
                                                    PaymentCompanyCode = ls_data-CompanyCode
                                                    PaymentDocument = ls_data-AccountingDocument
                                                    BINARY SEARCH.
            IF sy-subrc = 0.
              ls_data-OutgoingCheque = ls_cheque-OutgoingCheque.
            ENDIF.





            APPEND ls_data TO lt_data.
          ENDIF.
        ENDLOOP.








        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).

    ENDTRY.
  ENDMETHOD.


  METHOD get_unmatched_bankstatementits.
    DATA : lt_data TYPE TABLE OF zr_sfi009,
           ls_data TYPE zr_sfi009.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key           TYPE ts_key.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
*              ls_key-housebankaccount =
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        me->get_unmatched_bkis_by_asso(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_data

         ).








        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).


*      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
*        " Handle remote Exception
*        " It contains details about the problems of your http(s) connection
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_remote.
*
*      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*        " Handle Exception
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_gateway.
*
*
*      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
*        " Handle Exception
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_web_http_client_error.

    ENDTRY.

  ENDMETHOD.


  METHOD get_unmatched_bkis_by_asso.
*    DATA : lt_data TYPE TABLE OF zr_sfi008,
    DATA:      ls_data TYPE zr_sfi009.
    DATA:
      lt_business_data TYPE TABLE OF zzbankstatementitemset,
*      ls_key           TYPE ts_key,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.
    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'YY1_API'
                                                     comm_system_id = lo_ca->get_comm_system_id( )
                                                     service_id     = 'YY1_API_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZZFISCM001'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/API_CN_BANK_RECONCILIAITON_SRV' ).

        ASSERT lo_http_client IS BOUND.

        " Navigate to the resource and create a request for the read operation
*        lo_request = lo_client_proxy->create_resource_for_entity_set( 'JOURNALENTRYITEMSET' )->create_request_for_read( ).
        DATA(lo_entityset) = lo_client_proxy->create_resource_for_entity_set( 'BANKRECONCILIATIONSTATEMENTSET' ).
        DATA(lo_entity) = lo_entityset->navigate_with_key( is_key_data = is_key ).
        DATA(lo_nav_list_resource) = lo_entity->navigate_to_many( '_BANKSTATEMENTITEMSET' ).
        lo_request = lo_nav_list_resource->create_request_for_read(  ).




        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        TRY .
            LOOP AT lt_business_data INTO DATA(ls_bus_data).
*                append in
*                ls_bus_data
              CLEAR ls_data.
              ls_data = CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate ValueDate PostingDate ).

              DATA(lv_BankReconciliationDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-BankReconciliationDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_BankReconciliationDateshort
                  IMPORTING
                      syst_date = ls_data-BankReconciliationDate
               ).


              DATA(lv_ValueDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-ValueDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_ValueDateshort
                  IMPORTING
                      syst_date = ls_data-ValueDate
               ).

              DATA(lv_postingdateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-PostingDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_postingdateshort
                  IMPORTING
                      syst_date = ls_data-PostingDate
               ).

              APPEND ls_data TO et_data.
            ENDLOOP.

          CATCH cx_sy_conversion_overflow INTO DATA(lx_overflow).
            DATA(lv_msg) = lx_overflow->get_longtext(  ).
        ENDTRY.


      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_remote.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_gateway.


      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lX_HTTP_DEST_PROVIDER_ERROR).
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lX_HTTP_DEST_PROVIDER_ERROR.

    ENDTRY.

  ENDMETHOD.


  METHOD get_unmatched_incoming_jes.
    DATA : lt_data TYPE TABLE OF zr_sfi015,
           ls_data TYPE zr_sfi015.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key     TYPE ts_key,
      lv_balance TYPE zr_sfi015-AmountInCompanyCodeCurrency.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
*              ls_key-housebankaccount =
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        me->get_unmatched_jei_by_asso_prti(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_data

         ).

        DELETE lt_data WHERE AmountInTransactionCurrency < 0.

        IF lines( lt_data ) > 0.
          SELECT a~CompanyCode,
                 a~AccountingDocument,
                 a~FiscalYear,
                 a~AccountingDocumentItem,
                 a~AccountingDocumentType,
                 a~Customer,
                 a~Supplier,
                 a~PaymentMethod,
                 b~CustomerName,
                 c~SupplierName
                 FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS AS a
                    LEFT OUTER JOIN I_Customer WITH PRIVILEGED ACCESS AS b ON a~Customer = b~Customer
                    LEFT OUTER JOIN I_Supplier WITH PRIVILEGED ACCESS AS c ON a~Supplier = c~Supplier
              FOR ALL ENTRIES IN @lt_data
              WHERE a~AccountingDocument = @lt_data-AccountingDocument
                AND a~CompanyCode = @lt_data-CompanyCode
                AND a~FiscalYear = @lt_data-FiscalYear
                AND a~AccountingDocumentItem =  @lt_data-AccountingDocumentItem
                INTO TABLE @DATA(lt_glline).
          SORT lt_glline BY CompanyCode FiscalYear AccountingDocument AccountingDocumentItem.

          SELECT FiscalYear,
                 PaymentCompanyCode,
                 PaymentDocument,
                 OutgoingCheque
                 FROM I_OutgoingCheck WITH PRIVILEGED ACCESS
                 FOR ALL ENTRIES IN @lt_data
                 WHERE Fiscalyear = @lt_data-FiscalYear
                   AND PaymentCompanyCode = @lt_data-CompanyCode
                   AND PaymentDocument = @lt_data-AccountingDocument
                   AND ChequeStatus <> '20'
                   INTO TABLE @DATA(lt_cheque).
          SORT lt_CHEQUE BY FiscalYear PaymentCompanyCode PaymentDocument.


          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
            READ TABLE lt_glline INTO DATA(ls_glline) WITH KEY CompanyCode = <fs_data>-CompanyCode
                                                               FiscalYear = <fs_data>-FiscalYear
                                                               AccountingDocument = <fs_data>-AccountingDocument
                                                               AccountingDocumentItem = <fs_data>-AccountingDocumentItem
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_data>-AccountingDocumentType = ls_glline-AccountingDocumentType.
              <fs_data>-Customer = ls_glline-Customer.
              <fs_data>-Supplier = ls_glline-Supplier.
              <fs_data>-PaymentMethod = ls_glline-PaymentMethod.
              <fs_data>-CustomerName = ls_glline-CustomerName.
              <fs_data>-SupplierName = ls_glline-SupplierName.


              IF <fs_data>-Customer IS NOT INITIAL.
                <fs_data>-BPCode = <fs_data>-customer.
                <fs_data>-BPName = <fs_data>-CustomerName.
              ELSE.
                <fs_data>-BPCode = <fs_data>-Supplier.
                <fs_data>-BPName = <fs_data>-SupplierName.
              ENDIF.

              <fs_data>-DebitAmountInTransCrcy = abs( <fs_data>-AmountInTransactionCurrency ).
              lv_balance += <fs_data>-DebitAmountInTransCrcy.
              <fs_data>-BalanceInTransCrcy = lv_balance.

*               ls_data-AccountingDocumentType = ls_glline-AccountingDocumentType.
            ENDIF.

            READ TABLE lt_cheque INTO DATA(ls_CHEQUE) WITH KEY FiscalYear = <fs_Data>-FiscalYear
                                                               PaymentCompanyCode = <fs_Data>-CompanyCode
                                                               PaymentDocument = <fs_Data>-AccountingDocument
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_Data>-OutgoingCheque = ls_cheque-OutgoingCheque.
            ENDIF.
          ENDLOOP.
        ENDIF.






        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).


    ENDTRY.


  ENDMETHOD.


  METHOD get_unmatched_jei_by_asso.
*    DATA : lt_data TYPE TABLE OF zr_sfi008,
    DATA:      ls_data TYPE zr_sfi008.
    DATA:
      lt_business_data TYPE TABLE OF zzjournalentryitemset,
*      ls_key           TYPE ts_key,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.
    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'YY1_API'
                                                     comm_system_id = lo_ca->get_comm_system_id( )
                                                     service_id     = 'YY1_API_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZZFISCM001'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/API_CN_BANK_RECONCILIAITON_SRV' ).

        ASSERT lo_http_client IS BOUND.

        " Navigate to the resource and create a request for the read operation
*        lo_request = lo_client_proxy->create_resource_for_entity_set( 'JOURNALENTRYITEMSET' )->create_request_for_read( ).
        DATA(lo_entityset) = lo_client_proxy->create_resource_for_entity_set( 'BANKRECONCILIATIONSTATEMENTSET' ).
        DATA(lo_entity) = lo_entityset->navigate_with_key( is_key_data = is_key ).
        DATA(lo_nav_list_resource) = lo_entity->navigate_to_many( '_JOURNALENTRYITEMSET' ).
        lo_request = lo_nav_list_resource->create_request_for_read(  ).




        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        TRY .
            LOOP AT lt_business_data INTO DATA(ls_bus_data).
*                append in
*                ls_bus_data
              CLEAR ls_data.
              ls_data = CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate ValueDate PostingDate ).

              DATA(lv_BankReconciliationDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-BankReconciliationDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_BankReconciliationDateshort
                  IMPORTING
                      syst_date = ls_data-BankReconciliationDate
               ).


              DATA(lv_ValueDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-ValueDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_ValueDateshort
                  IMPORTING
                      syst_date = ls_data-ValueDate
               ).

              DATA(lv_postingdateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-PostingDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_postingdateshort
                  IMPORTING
                      syst_date = ls_data-PostingDate
               ).

              APPEND ls_data TO et_data.
            ENDLOOP.

          CATCH cx_sy_conversion_overflow INTO DATA(lx_overflow).
            DATA(lv_msg) = lx_overflow->get_longtext(  ).
        ENDTRY.


      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_remote.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_gateway.


      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lX_HTTP_DEST_PROVIDER_ERROR).
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lX_HTTP_DEST_PROVIDER_ERROR.

    ENDTRY.

  ENDMETHOD.


  METHOD get_unmatched_jei_by_asso_prti.
    DATA:      ls_data TYPE zr_sfi015.
    DATA:
      lt_business_data TYPE TABLE OF zzjournalentryitemset,
*      ls_key           TYPE ts_key,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.
    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'YY1_API'
                                                     comm_system_id = lo_ca->get_comm_system_id( )
                                                     service_id     = 'YY1_API_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZZFISCM001'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/API_CN_BANK_RECONCILIAITON_SRV' ).

        ASSERT lo_http_client IS BOUND.

        " Navigate to the resource and create a request for the read operation
*        lo_request = lo_client_proxy->create_resource_for_entity_set( 'JOURNALENTRYITEMSET' )->create_request_for_read( ).
        DATA(lo_entityset) = lo_client_proxy->create_resource_for_entity_set( 'BANKRECONCILIATIONSTATEMENTSET' ).
        DATA(lo_entity) = lo_entityset->navigate_with_key( is_key_data = is_key ).
        DATA(lo_nav_list_resource) = lo_entity->navigate_to_many( '_JOURNALENTRYITEMSET' ).
        lo_request = lo_nav_list_resource->create_request_for_read(  ).




        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        TRY .
            LOOP AT lt_business_data INTO DATA(ls_bus_data).
*                append in
*                ls_bus_data
              CLEAR ls_data.
              ls_data = CORRESPONDING #( ls_bus_data EXCEPT BankReconciliationDate ValueDate PostingDate ).

              DATA(lv_BankReconciliationDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-BankReconciliationDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_BankReconciliationDateshort
                  IMPORTING
                      syst_date = ls_data-BankReconciliationDate
               ).


              DATA(lv_ValueDateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-ValueDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_ValueDateshort
                  IMPORTING
                      syst_date = ls_data-ValueDate
               ).

              DATA(lv_postingdateshort) = cl_abap_tstmp=>move_to_short(
                  EXPORTING
                      tstmp_src = ls_bus_data-PostingDate
               ).
              cl_abap_tstmp=>systemtstmp_utc2syst(
                  EXPORTING
                      utc_tstmp = lv_postingdateshort
                  IMPORTING
                      syst_date = ls_data-PostingDate
               ).

              APPEND ls_data TO et_data.
            ENDLOOP.

          CATCH cx_sy_conversion_overflow INTO DATA(lx_overflow).
            DATA(lv_msg) = lx_overflow->get_longtext(  ).
        ENDTRY.


      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_remote.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_gateway.


      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lx_web_http_client_error.

      CATCH cx_http_dest_provider_error INTO DATA(lX_HTTP_DEST_PROVIDER_ERROR).
        RAISE EXCEPTION TYPE zcx_rap_query_provider
          EXPORTING
            previous = lX_HTTP_DEST_PROVIDER_ERROR.
    ENDTRY.
  ENDMETHOD.


  METHOD get_unmatched_journalentries.

    DATA : lt_data TYPE TABLE OF zr_sfi008,
           ls_data TYPE zr_sfi008.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key           TYPE ts_key.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
*              ls_key-housebankaccount =
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        me->get_unmatched_jei_by_asso(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_data

         ).


        IF lines( lt_data ) > 0.
          SELECT a~CompanyCode,
                 a~AccountingDocument,
                 a~FiscalYear,
                 a~AccountingDocumentItem,
                 a~AccountingDocumentType,
                 a~Customer,
                 a~Supplier,
                 a~PaymentMethod,
                 b~CustomerName,
                 c~SupplierName
                 FROM I_OperationalAcctgDocItem AS a
                    LEFT OUTER JOIN I_Customer AS b ON a~Customer = b~Customer
                    LEFT OUTER JOIN I_Supplier AS c ON a~Supplier = c~Supplier
              FOR ALL ENTRIES IN @lt_data
              WHERE a~AccountingDocument = @lt_data-AccountingDocument
                AND a~CompanyCode = @lt_data-CompanyCode
                AND a~FiscalYear = @lt_data-FiscalYear
                AND a~AccountingDocumentItem =  @lt_data-AccountingDocumentItem
                INTO TABLE @DATA(lt_glline).
          SORT lt_glline BY CompanyCode FiscalYear AccountingDocument AccountingDocumentItem.

          SELECT FiscalYear,
                 PaymentCompanyCode,
                 PaymentDocument,
                 OutgoingCheque
                 FROM I_OutgoingCheck
                 FOR ALL ENTRIES IN @lt_data
                 WHERE Fiscalyear = @lt_data-FiscalYear
                   AND PaymentCompanyCode = @lt_data-CompanyCode
                   AND PaymentDocument = @lt_data-AccountingDocument
                   AND ChequeStatus <> '20'
                   INTO TABLE @DATA(lt_cheque).
          SORT lt_CHEQUE BY FiscalYear PaymentCompanyCode PaymentDocument.


          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
            READ TABLE lt_glline INTO DATA(ls_glline) WITH KEY CompanyCode = <fs_data>-CompanyCode
                                                               FiscalYear = <fs_data>-FiscalYear
                                                               AccountingDocument = <fs_data>-AccountingDocument
                                                               AccountingDocumentItem = <fs_data>-AccountingDocumentItem
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_data>-AccountingDocumentType = ls_glline-AccountingDocumentType.
              <fs_data>-Customer = ls_glline-Customer.
              <fs_data>-Supplier = ls_glline-Supplier.
              <fs_data>-PaymentMethod = ls_glline-PaymentMethod.
              <fs_data>-CustomerName = ls_glline-CustomerName.
              <fs_data>-SupplierName = ls_glline-SupplierName.
*               ls_data-AccountingDocumentType = ls_glline-AccountingDocumentType.
            ENDIF.

            READ TABLE lt_cheque INTO DATA(ls_CHEQUE) WITH KEY FiscalYear = <fs_Data>-FiscalYear
                                                               PaymentCompanyCode = <fs_Data>-CompanyCode
                                                               PaymentDocument = <fs_Data>-AccountingDocument
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_Data>-OutgoingCheque = ls_cheque-OutgoingCheque.
            ENDIF.
          ENDLOOP.
        ENDIF.






        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).


*      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
*        " Handle remote Exception
*        " It contains details about the problems of your http(s) connection
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_remote.
*
*      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*        " Handle Exception
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_gateway.
*
*
*      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
*        " Handle Exception
*        RAISE EXCEPTION TYPE zcx_rap_query_provider
*          EXPORTING
*            previous = lx_web_http_client_error.


    ENDTRY.
  ENDMETHOD.


  METHOD get_unmatched_outgoing_jes.
    DATA : lt_data TYPE TABLE OF zr_sfi015,
           ls_data TYPE zr_sfi015.
    DATA(lo_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.


    TYPES : BEGIN OF ts_key,
              CompanyCode            TYPE zzbankreconciliationstatements-CompanyCode,
              HouseBank              TYPE zzbankreconciliationstatements-HouseBank,
              HouseBankAccount       TYPE zzbankreconciliationstatements-HouseBankAccount,
              BankReconciliationDate TYPE zzbankreconciliationstatements-BankReconciliationDate,
            END OF ts_key.

    DATA:
      ls_key     TYPE ts_key,
      lv_balance TYPE zr_sfi015-AmountInCompanyCodeCurrency.




    TRY.

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
              ls_key-companycode = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANK'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBank.
              ls_key-housebank = ls_filter-range[ 1 ]-low.
            WHEN 'HOUSEBANKACCOUNT'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_HouseBankAccount.
              ls_key-housebankaccount = ls_filter-range[ 1 ]-low.
            WHEN 'BANKRECONCILIATIONDATE'.
*              MOVE-CORRESPONDING ls_filter-range TO lr_BankReconciliationDate.
*              ls_key-housebankaccount =
              cl_abap_tstmp=>systemtstmp_syst2utc(
                EXPORTING
                    syst_date = CONV d( ls_filter-range[ 1 ]-low )
                    syst_time = CONV t( '000000' )
                IMPORTING
                    utc_tstmp = DATA(lv_tstmp)
              ).
              ls_key-bankreconciliationdate = cl_abap_tstmp=>normalize(
                  EXPORTING
                      tstmp_in = lv_tstmp
              ).
          ENDCASE.
        ENDLOOP.


        me->get_unmatched_jei_by_asso_prti(
            EXPORTING is_key = ls_key
            IMPORTING et_data = lt_data

         ).

        DELETE lt_data WHERE AmountInTransactionCurrency > 0.

        IF lines( lt_data ) > 0.
          SELECT a~CompanyCode,
                 a~AccountingDocument,
                 a~FiscalYear,
                 a~AccountingDocumentItem,
                 a~AccountingDocumentType,
                 a~Customer,
                 a~Supplier,
                 a~PaymentMethod,
                 b~CustomerName,
                 c~SupplierName
                 FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS AS a
                    LEFT OUTER JOIN I_Customer WITH PRIVILEGED ACCESS AS b ON a~Customer = b~Customer
                    LEFT OUTER JOIN I_Supplier WITH PRIVILEGED ACCESS AS c ON a~Supplier = c~Supplier
              FOR ALL ENTRIES IN @lt_data
              WHERE a~AccountingDocument = @lt_data-AccountingDocument
                AND a~CompanyCode = @lt_data-CompanyCode
                AND a~FiscalYear = @lt_data-FiscalYear
                AND a~AccountingDocumentItem =  @lt_data-AccountingDocumentItem
                INTO TABLE @DATA(lt_glline).
          SORT lt_glline BY CompanyCode FiscalYear AccountingDocument AccountingDocumentItem.

          SELECT FiscalYear,
                 PaymentCompanyCode,
                 PaymentDocument,
                 OutgoingCheque
                 FROM I_OutgoingCheck WITH PRIVILEGED ACCESS
                 FOR ALL ENTRIES IN @lt_data
                 WHERE Fiscalyear = @lt_data-FiscalYear
                   AND PaymentCompanyCode = @lt_data-CompanyCode
                   AND PaymentDocument = @lt_data-AccountingDocument
                   AND ChequeStatus <> '20'
                   INTO TABLE @DATA(lt_cheque).
          SORT lt_CHEQUE BY FiscalYear PaymentCompanyCode PaymentDocument.


          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
            READ TABLE lt_glline INTO DATA(ls_glline) WITH KEY CompanyCode = <fs_data>-CompanyCode
                                                               FiscalYear = <fs_data>-FiscalYear
                                                               AccountingDocument = <fs_data>-AccountingDocument
                                                               AccountingDocumentItem = <fs_data>-AccountingDocumentItem
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_data>-AccountingDocumentType = ls_glline-AccountingDocumentType.
              <fs_data>-Customer = ls_glline-Customer.
              <fs_data>-Supplier = ls_glline-Supplier.
              <fs_data>-PaymentMethod = ls_glline-PaymentMethod.
              <fs_data>-CustomerName = ls_glline-CustomerName.
              <fs_data>-SupplierName = ls_glline-SupplierName.


              IF <fs_data>-Customer IS NOT INITIAL.
                <fs_data>-BPCode = <fs_data>-customer.
                <fs_data>-BPName = <fs_data>-CustomerName.
              ELSE.
                <fs_data>-BPCode = <fs_data>-Supplier.
                <fs_data>-BPName = <fs_data>-SupplierName.
              ENDIF.

              <fs_data>-CreditAmountInTransCrcy = abs( <fs_data>-AmountInTransactionCurrency ).
              lv_balance += <fs_data>-CreditAmountInTransCrcy.
              <fs_data>-BalanceInTransCrcy = lv_balance.

*               ls_data-AccountingDocumentType = ls_glline-AccountingDocumentType.
            ENDIF.

            READ TABLE lt_cheque INTO DATA(ls_CHEQUE) WITH KEY FiscalYear = <fs_Data>-FiscalYear
                                                               PaymentCompanyCode = <fs_Data>-CompanyCode
                                                               PaymentDocument = <fs_Data>-AccountingDocument
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_Data>-OutgoingCheque = ls_cheque-OutgoingCheque.
            ENDIF.
          ENDLOOP.
        ENDIF.






        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

        io_response->set_data( lt_data ).
    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
*    TRY.
    CASE io_request->get_entity_id( ).

      WHEN 'ZR_SFI007'. "Bank Reconciliation Statements
        get_bank_reconcil_statems( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI008'. "Unmatched JE Items
        get_unmatched_journalentries( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI009'. "Unmatched Bank Statement Items
        get_unmatched_bankstatementits( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI010'. "Matched JE Items
        get_matched_journalentries( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI011'. "Matched Bank Statement Items
        get_matched_bankstatementits( io_request = io_request io_response = io_response ).

*        get_unmatched_bankstatementits( io_request = io_request io_response = io_response ).
      WHEN 'ZR_SFI012'. "Bank Reconciliation Statements
        get_bank_reconcil_statems_prt( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI013'.
        get_matched_incoming_jes( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI014'.
        get_matched_outgoing_jes( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI015'.
        get_unmatched_incoming_jes( io_request = io_request io_response = io_response ).

      WHEN 'ZR_SFI016'.
        get_unmatched_outgoing_jes( io_request = io_request io_response = io_response ).

    ENDCASE.

*      CATCH cx_rap_query_provider.
*    ENDTRY.
  ENDMETHOD.
ENDCLASS.
