@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_005'
@EndUserText.label: 'Bank Reconciliation Statement - Print'
define custom entity ZR_SFI012

{





  key CompanyCode                 : abap.char( 4);

  key HouseBank                   : abap.char(5);

  key HouseBankAccount            : abap.char(5);

  key BankReconciliationDate      : abap.dats;

      HouseBankAccountDescription : abap.sstring( 50 );

      BankAccount                 : abap.char(18);

      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      BankAcctBalanceAmt          : abap.curr( 24, 2 );

      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      AdjustedBkAcctBalanceAmt    : abap.curr( 24, 2 );

      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      UnmatchedIncgBkStmntPayt    : abap.curr( 24, 2 );

      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      UnmatchedOutgBkStmntPayt    : abap.curr( 24, 2 );


      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      GLAcctBalanceAmt            : abap.curr( 24, 2 );

      @Semantics.amount.currencyCode      : 'HouseBankCurrency'
      AdjustedGLAcctBalanceAmt    : abap.curr( 24, 2 );

      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      UnmatchedIncgJrnlEntrPayt   : abap.curr( 24, 2 );

      @Semantics.amount.currencyCode: 'HouseBankCurrency'
      UnmatchedOutgJrnlEntrPayt   : abap.curr( 24, 2 );

      HouseBankCurrency           : abap.cuky( 5 );



      GLAccount                   : abap.char( 10 );
      @ObjectModel.filter.enabled : false
      _MatchedIncomingGEItems     : association [0..*] to ZR_SFI013 on  $projection.CompanyCode            = _MatchedIncomingGEItems.CompanyCode
                                                                    and $projection.HouseBank              = _MatchedIncomingGEItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _MatchedIncomingGEItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _MatchedIncomingGEItems.BankReconciliationDate;
      @ObjectModel.filter.enabled : false
      _MatchedOutgoingGEItems     : association [0..*] to ZR_SFI014 on  $projection.CompanyCode            = _MatchedOutgoingGEItems.CompanyCode
                                                                    and $projection.HouseBank              = _MatchedOutgoingGEItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _MatchedOutgoingGEItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _MatchedOutgoingGEItems.BankReconciliationDate;
      @ObjectModel.filter.enabled : false
      _UnMatchedIncomingGEItems   : association [0..*] to ZR_SFI015 on  $projection.CompanyCode            = _UnMatchedIncomingGEItems.CompanyCode
                                                                    and $projection.HouseBank              = _UnMatchedIncomingGEItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _UnMatchedIncomingGEItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _UnMatchedIncomingGEItems.BankReconciliationDate;
      @ObjectModel.filter.enabled : false
      _UnMatchedOutgoingGEItems   : association [0..*] to ZR_SFI016 on  $projection.CompanyCode            = _UnMatchedOutgoingGEItems.CompanyCode
                                                                    and $projection.HouseBank              = _UnMatchedOutgoingGEItems.HouseBank
                                                                    and $projection.HouseBankAccount       = _UnMatchedOutgoingGEItems.HouseBankAccount
                                                                    and $projection.BankReconciliationDate = _UnMatchedOutgoingGEItems.BankReconciliationDate;

      //      _UnmatchedJournalEntryItems : association [0..*] to ZR_SFI008 on  $projection.CompanyCode            = _UnmatchedJournalEntryItems.CompanyCode
      //                                                                    and $projection.HouseBank              = _UnmatchedJournalEntryItems.HouseBank
      //                                                                    and $projection.HouseBankAccount       = _UnmatchedJournalEntryItems.HouseBankAccount
      //                                                                    and $projection.BankReconciliationDate = _UnmatchedJournalEntryItems.BankReconciliationDate;
      //
      //      _UnmatchedBankStateItems    : association [0..*] to ZR_SFI009 on  $projection.CompanyCode            = _UnmatchedBankStateItems.CompanyCode
      //                                                                    and $projection.HouseBank              = _UnmatchedBankStateItems.HouseBank
      //                                                                    and $projection.HouseBankAccount       = _UnmatchedBankStateItems.HouseBankAccount
      //                                                                    and $projection.BankReconciliationDate = _UnmatchedBankStateItems.BankReconciliationDate;
      //
      //      _MatchedJournalEntryItems   : association [0..*] to ZR_SFI010 on  $projection.CompanyCode            = _MatchedJournalEntryItems.CompanyCode
      //                                                                    and $projection.HouseBank              = _MatchedJournalEntryItems.HouseBank
      //                                                                    and $projection.HouseBankAccount       = _MatchedJournalEntryItems.HouseBankAccount
      //                                                                    and $projection.BankReconciliationDate = _MatchedJournalEntryItems.BankReconciliationDate;
      //
      //      _MatchedBankStateItems      : association [0..*] to ZR_SFI011 on  $projection.CompanyCode            = _MatchedBankStateItems.CompanyCode
      //                                                                    and $projection.HouseBank              = _MatchedBankStateItems.HouseBank
      //                                                                    and $projection.HouseBankAccount       = _MatchedBankStateItems.HouseBankAccount
      //                                                                    and $projection.BankReconciliationDate = _MatchedBankStateItems.BankReconciliationDate;

}
