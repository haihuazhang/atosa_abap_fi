@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_005'
@EndUserText.label: 'Bank Reconciliation Statement'
@UI: {
  headerInfo: {
    typeName: 'Bank Reconciliation Statement',
    typeNamePlural: 'Bank Reconciliation Statements'
  }
}
define custom entity ZR_SFI007

{


      @UI.facet                   : [

      {
      id                          : 'idIdentification',
      type                        : #IDENTIFICATION_REFERENCE,
      label                       : 'Bank Reconciliation Statement',
      position                    : 10
      }
      //      {
      //        id                        : 'UnmatchedJournalEntryItems',
      //        purpose                   : #STANDARD,
      //        type                      : #LINEITEM_REFERENCE,
      //        label                     : 'Unmatched Journal Entry Items',
      //        position                  : 20,
      //        targetElement             : '_UnmatchedJournalEntryItems'
      //      },
      //      {
      //        id                        : 'UnmatchedBankStateItems',
      //        purpose                   : #STANDARD,
      //        type                      : #LINEITEM_REFERENCE,
      //        label                     : 'Unmatched Bank Statement Items',
      //        position                  : 30,
      //        targetElement             : '_UnmatchedBankStateItems'
      //      },
      //      {
      //        id                        : 'MatchedJournalEntryItems',
      //        purpose                   : #STANDARD,
      //        type                      : #LINEITEM_REFERENCE,
      //        label                     : 'Matched Journal Entry Items',
      //        position                  : 40,
      //        targetElement             : '_MatchedJournalEntryItems'
      //      },
      //      {
      //        id                        : 'MatchedBankStateItems',
      //        purpose                   : #STANDARD,
      //        type                      : #LINEITEM_REFERENCE,
      //        label                     : 'Matched Bank Statement Items',
      //        position                  : 40,
      //        targetElement             : '_MatchedBankStateItems'
      //      }
       ]


      @UI.selectionField          : [{ position: 10 }]
      @UI.lineItem                : [{
        position                  : 10,
        label                     : 'Company Code'
      }]
      @UI.identification          : [{ position: 10, label: 'Company Code'}]
  key CompanyCode                 : abap.char( 4);
      @UI.selectionField          : [{ position: 20 }]
      @UI.lineItem                : [{
            position              : 20,
            label                 : 'House Bank'
      }]
      @UI.identification          : [{ position: 20 ,label: 'House Bank'}]
  key HouseBank                   : abap.char(5);
      @UI.selectionField          : [{ position: 30 }]
      @UI.lineItem                : [{
            position              : 30,
            label                 : 'House Bank Account'
      }]
      @UI.identification          : [{ position: 30 ,label: 'House Bank Account'}]
  key HouseBankAccount            : abap.char(5);
      @UI.selectionField          : [{ position: 40 }]
      @UI.lineItem                : [{
            position              : 40,
            label                 : 'Reconciliation Date'
      }]
      @UI.identification          : [{ position: 40,label: 'Reconciliation Date' }]
  key BankReconciliationDate      : abap.dats;
      @UI.selectionField          : [{ position: 50 }]
      @UI.lineItem                : [{
            position              : 50,
            label                 : 'Account Description'
      }]
      HouseBankAccountDescription : abap.sstring( 50 );
      @UI.lineItem                : [{
            position              : 60,
            label                 : 'Bank Account Number'
      }]
      BankAccount                 : abap.char(18);
      @UI.lineItem                : [{
            position              : 70,
            label                 : 'Bank Account Balance'
      }]
      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      BankAcctBalanceAmt          : abap.curr( 24, 2 );
      @UI.lineItem                : [{
            position              : 80,
            label                 : 'G/L Account Balance'
      }]
      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      GLAcctBalanceAmt            : abap.curr( 24, 2 );
      HouseBankCurrency           : abap.cuky( 5 );
      @UI.lineItem                : [{
      position                    : 90,
      label                       : 'Adjusted Bank Account Balance'
      }]
      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      AdjustedBkAcctBalanceAmt    : abap.curr( 24, 2 );
      @UI.lineItem                : [{
      position                    : 100,
      label                       : 'Adjusted G/L Account Balance'
      }]
      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      AdjustedGLAcctBalanceAmt    : abap.curr( 24, 2 );
      @ObjectModel.filter.enabled : false
      _UnmatchedJournalEntryItems : association [0..*] to ZR_SFI008 on  $projection.CompanyCode            = _UnmatchedJournalEntryItems.CompanyCode
                                                                    and $projection.HouseBank              = _UnmatchedJournalEntryItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _UnmatchedJournalEntryItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _UnmatchedJournalEntryItems.BankReconciliationDate;
      @ObjectModel.filter.enabled : false
      _UnmatchedBankStateItems    : association [0..*] to ZR_SFI009 on  $projection.CompanyCode            = _UnmatchedBankStateItems.CompanyCode
                                                                    and $projection.HouseBank              = _UnmatchedBankStateItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _UnmatchedBankStateItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _UnmatchedBankStateItems.BankReconciliationDate;
      @ObjectModel.filter.enabled : false
      _MatchedJournalEntryItems   : association [0..*] to ZR_SFI010 on  $projection.CompanyCode            = _MatchedJournalEntryItems.CompanyCode
                                                                    and $projection.HouseBank              = _MatchedJournalEntryItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _MatchedJournalEntryItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _MatchedJournalEntryItems.BankReconciliationDate;

      @ObjectModel.filter.enabled : false
      _MatchedBankStateItems      : association [0..*] to ZR_SFI011 on  $projection.CompanyCode            = _MatchedBankStateItems.CompanyCode
                                                                    and $projection.HouseBank              = _MatchedBankStateItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _MatchedBankStateItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _MatchedBankStateItems.BankReconciliationDate;

}
