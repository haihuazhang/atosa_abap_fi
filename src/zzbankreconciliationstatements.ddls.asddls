/********** GENERATED on 01/31/2024 at 07:21:54 by CB9980000010**************/
 @OData.entitySet.name: 'BankReconciliationStatementSet' 
 @OData.entityType.name: 'BankReconciliationStatementType' 
 define root abstract entity ZZBANKRECONCILIATIONSTATEMENTS { 
 key CompanyCode : abap.char( 4 ) ; 
 key HouseBank : abap.char( 5 ) ; 
 key HouseBankAccount : abap.char( 5 ) ; 
 key BankReconciliationDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 Ledger : abap.char( 2 ) ; 
 @Semantics.currencyCode: true 
 HouseBankCurrency : abap.cuky ; 
 BankAccount : abap.char( 18 ) ; 
 BankAccountReferenceText : abap.char( 27 ) ; 
 BankName : abap.char( 60 ) ; 
 GLAccount : abap.char( 10 ) ; 
 @Odata.property.valueControl: 'AdjustedGLAcctBalanceAmt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 AdjustedGLAcctBalanceAmt : abap.curr( 24, 3 ) ; 
 AdjustedGLAcctBalanceAmt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AdjustedBkAcctBalanceAmt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 AdjustedBkAcctBalanceAmt : abap.curr( 24, 3 ) ; 
 AdjustedBkAcctBalanceAmt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'BankAcctBalanceAmt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 BankAcctBalanceAmt : abap.curr( 24, 3 ) ; 
 BankAcctBalanceAmt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'GLAcctBalanceAmt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 GLAcctBalanceAmt : abap.curr( 24, 3 ) ; 
 GLAcctBalanceAmt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'UnmatchedIncgBkStmntPayt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 UnmatchedIncgBkStmntPayt : abap.curr( 24, 3 ) ; 
 UnmatchedIncgBkStmntPayt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'UnmatchedOutgBkStmntPayt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 UnmatchedOutgBkStmntPayt : abap.curr( 24, 3 ) ; 
 UnmatchedOutgBkStmntPayt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'UnmatchedIncgJrnlEntrPayt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 UnmatchedIncgJrnlEntrPayt : abap.curr( 24, 3 ) ; 
 UnmatchedIncgJrnlEntrPayt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'UnmatchedOutgJrnlEntrPayt_vc' 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 UnmatchedOutgJrnlEntrPayt : abap.curr( 24, 3 ) ; 
 UnmatchedOutgJrnlEntrPayt_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CreationUserName_vc' 
 CreationUserName : abap.char( 12 ) ; 
 CreationUserName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'UserDescription_vc' 
 UserDescription : abap.char( 80 ) ; 
 UserDescription_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'LastChangeDateTime_vc' 
 LastChangeDateTime : tzntstmpl ; 
 LastChangeDateTime_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 CompanyCodeName : abap.char( 25 ) ; 
 HouseBankAccountDescription : abap.char( 50 ) ; 
 ETAG__ETAG : abap.string( 0 ) ; 
 
 @OData.property.name: 'BankStatementItemSet' 
//A dummy on-condition is required for associations in abstract entities 
//On-condition is not relevant for runtime 
 _BankStatementItemSet : association [0..*] to ZZBANKSTATEMENTITEMSET on 1 = 1; 
 @OData.property.name: 'JournalEntryItemSet' 
//A dummy on-condition is required for associations in abstract entities 
//On-condition is not relevant for runtime 
 _JournalEntryItemSet : association [0..*] to ZZJOURNALENTRYITEMSET on 1 = 1; 
 } 
