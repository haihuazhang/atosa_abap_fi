@EndUserText.label: 'Bank Reconciliation Statement - Unmached Bank Stat Items'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_005'
@UI: {
  headerInfo: {
    typeName: 'Bank Statement Item',
    typeNamePlural: 'Bank Statement Items'
  }
}
define custom entity ZR_SFI009
  //  with parameters
  //    parameter_name : parameter_type
{
      @UI.lineItem                : [{ position:  70, label: 'Company Code'  }]
  key CompanyCode                 : abap.char( 4 );
      @UI.lineItem                : [{ position:  80, label: 'House Bank'  }]
  key HouseBank                   : abap.char( 5 );
      @UI.lineItem                : [{ position:  90, label: 'House Bank Account'  }]
  key HouseBankAccount            : abap.char( 5 );
  key BankReconciliationDate      : abap.dats;
      @UI.lineItem                : [{ position: 10 , label: 'Bank Statement'  }]
  key BankStatementShortID        : abap.char( 8 );
      @UI.lineItem                : [{ position: 20 , label: 'Bank Statement Item'  }]
  key BankStatementItem           : abap.char( 5 );
      BankReconciliationMatchType : abap.char( 1 );
      Note                        : abap.char( 255 );
      BankStatement               : abap.char( 5 );
      //      @OData.property.valueControl: 'ValueDate_vc'
      @UI.lineItem                : [{ position: 30 , label: 'Value Date'  }]
      ValueDate                   : abap.dats;
      //      ValueDate_vc                : rap_cp_odata_value_control;
      //      @Semantics.currencyCode     : true
      TransactionCurrency         : abap.cuky;
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      CreditAmountInTransCrcy     : abap.curr( 24, 2 );
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DebitAmountInTransCrcy      : abap.curr( 24, 2 );
      MemoLine                    : abap.char( 1333 );
      AssignmentReference         : abap.char( 18 );
      BankLedgerDocument          : abap.char( 10 );
      FiscalYear                  : abap.char( 4 );
      //      @OData.property.valueControl: 'PostingDate_vc'
      @UI.lineItem                : [{ position: 50 , label: 'Posting Date' }]
      PostingDate                 : abap.dats;
      //      PostingDate_vc              : rap_cp_odata_value_control;
      PaymentTransaction          : abap.char( 3 );
      PaymentExternalTransacType  : abap.char( 27 );
      //      @Semantics.currencyCode     : true
      OriginalCurrency            : abap.cuky;
      @Semantics.amount.currencyCode: 'OriginalCurrency'
      AmountInOriginalCurrency    : abap.curr( 24, 2 );
      DocumentItemText            : abap.char( 50 );
      @UI.lineItem                : [{ position: 40 , label: 'Amount'  }]
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      AmountInTransactionCurrency : abap.curr( 24, 2 );
      PaymentManualTransacType    : abap.char( 4 );
      PartnerBank                 : abap.char( 15 );
      PartnerBankAccount          : abap.char( 18 );
      BusinessPartnerName         : abap.char( 55 );
      @UI.lineItem                : [{ position: 60 , label: 'Bank Statement Posting Rule'  }]
      BankStatementPostingRule : abap.char(4);

}
