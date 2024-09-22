@EndUserText.label: 'Bank Reconciliation Statement - Mached GE Items'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_005'
@UI: {
  headerInfo: {
    typeName: 'Journal Entry Item',
    typeNamePlural: 'Journal Entry Items'
  }
}
define custom entity ZR_SFI010
  // with parameters parameter_name : parameter_type
{
key CompanyCode                 : abap.char( 4 );
  key HouseBank                   : abap.char( 5 );
  key HouseBankAccount            : abap.char( 5 );
  key BankReconciliationDate      : abap.dats;
  key FiscalYear                  : gjahr;
      @UI.lineItem                : [{ position: 10 , label: 'Journal Entry'}]
  key AccountingDocument          : abap.char( 10 );
  key AccountingDocumentItem      : abap.numc( 3 );
      BankReconciliationMatchType : abap.char( 1 );
      Note                        : abap.char( 255 );
      //      @Semantics.currencyCode     : true
      HouseBankCurrency           : abap.cuky;
      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      DebitAmountInTransCrcy      : abap.curr( 24, 2 );
      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      CreditAmountInTransCrcy     : abap.curr( 24, 2 );
      //      @Semantics.currencyCode     : true
      TransactionCurrency         : abap.cuky;
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      AmountInTransactionCurrency : abap.curr( 24, 2 );
      //      @Semantics.currencyCode     : true
      CompanyCodeCurrency         : abap.cuky;
      @UI.lineItem                : [{ position: 30 , label: 'Amount' }]
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency : abap.curr( 24, 2 );
      //      @OData.property.valueControl: 'PostingDate_vc'
      //      PostingDate                 : rap_cp_odata_v2_edm_datetime;
      @UI.lineItem                : [{ position: 100 , label: 'Posting Date' }]
      PostingDate                 : abap.dats;
      //      PostingDate_vc              : rap_cp_odata_value_control;
      DocumentItemText            : abap.char( 50 );
      //      @OData.property.valueControl: 'ValueDate_vc'
      ValueDate                   : abap.dats;
      //      ValueDate                   : rap_cp_odata_v2_edm_datetime;
      //      ValueDate_vc                : rap_cp_odata_value_control;
      AssignmentReference         : abap.char( 18 );

      @UI.lineItem                : [{ position: 20 , label: 'Journal Entry Type'}]
      AccountingDocumentType      : abap.char(2);
      @UI.lineItem                : [{ position: 40 , label: 'Customer' }]
      Customer                    : zzesd004;
      @UI.lineItem                : [{ position: 60 , label: 'Supplier' }]
      Supplier                    : lifnr;
      @UI.lineItem                : [{ position: 50 , label: 'Customer Name' }]
      CustomerName                : abap.sstring( 80 );
      @UI.lineItem                : [{ position: 70 , label: 'Supplier Name' }]
      SupplierName                : abap.sstring( 80 );
      @UI.lineItem                : [{ position: 80 , label: 'Cheque Number' }]
      OutgoingCheque              : abap.char(13);
      @UI.lineItem                : [{ position: 90 , label: 'Payment Method' }]
      PaymentMethod               : abap.char(1);
}
