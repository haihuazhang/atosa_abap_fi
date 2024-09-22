@EndUserText.label: 'BRS - Unmached Outgoing GE Items - Print'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_005'

define custom entity ZR_SFI016
  // with parameters parameter_name : parameter_type
{
  key CompanyCode                 : abap.char( 4 );
  key HouseBank                   : abap.char( 5 );
  key HouseBankAccount            : abap.char( 5 );
  key BankReconciliationDate      : abap.dats;
  key FiscalYear                  : gjahr;
  key AccountingDocument          : abap.char( 10 );
  key AccountingDocumentItem      : abap.numc( 3 );
      BankReconciliationMatchType : abap.char( 1 );
      Note                        : abap.char( 255 );
      HouseBankCurrency           : abap.cuky;
      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      DebitAmountInTransCrcy      : abap.curr( 24, 2 );
      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      CreditAmountInTransCrcy     : abap.curr( 24, 2 );

      TransactionCurrency         : abap.cuky;
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      AmountInTransactionCurrency : abap.curr( 24, 2 );

      CompanyCodeCurrency         : abap.cuky;

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency : abap.curr( 24, 2 );


      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      BalanceInTransCrcy : abap.curr( 24, 2 );

      PostingDate                 : abap.dats;

      DocumentItemText            : abap.char( 50 );

      ValueDate                   : abap.dats;

      AssignmentReference         : abap.char( 18 );

      AccountingDocumentType      : abap.char(2);

      Customer                    : zzesd004;

      Supplier                    : lifnr;

      CustomerName                : abap.sstring( 80 );

      SupplierName                : abap.sstring( 80 );
      
      BPCode                      : lifnr;
      BPName                      : abap.sstring( 80 );

      OutgoingCheque              : abap.char(13);

      PaymentMethod               : abap.char(1);
}
