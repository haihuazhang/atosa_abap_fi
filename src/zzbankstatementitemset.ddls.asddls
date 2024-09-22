/********** GENERATED on 01/31/2024 at 07:21:53 by CB9980000010**************/
 @OData.entitySet.name: 'BankStatementItemSet' 
 @OData.entityType.name: 'BankStatementItemType' 
 define root abstract entity ZZBANKSTATEMENTITEMSET { 
 key CompanyCode : abap.char( 4 ) ; 
 key HouseBank : abap.char( 5 ) ; 
 key HouseBankAccount : abap.char( 5 ) ; 
 key BankReconciliationDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 key BankStatementShortID : abap.char( 8 ) ; 
 key BankStatementItem : abap.char( 5 ) ; 
 BankReconciliationMatchType : abap.char( 1 ) ; 
 Note : abap.char( 255 ) ; 
 BankStatement : abap.char( 5 ) ; 
 @Odata.property.valueControl: 'ValueDate_vc' 
 ValueDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 ValueDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Semantics.currencyCode: true 
 TransactionCurrency : abap.cuky ; 
 @Semantics.amount.currencyCode: 'TransactionCurrency' 
 CreditAmountInTransCrcy : abap.curr( 24, 3 ) ; 
 @Semantics.amount.currencyCode: 'TransactionCurrency' 
 DebitAmountInTransCrcy : abap.curr( 24, 3 ) ; 
 MemoLine : abap.char( 1333 ) ; 
 AssignmentReference : abap.char( 18 ) ; 
 BankLedgerDocument : abap.char( 10 ) ; 
 FiscalYear : abap.char( 4 ) ; 
 @Odata.property.valueControl: 'PostingDate_vc' 
 PostingDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 PostingDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 PaymentTransaction : abap.char( 3 ) ; 
 PaymentExternalTransacType : abap.char( 27 ) ; 
 @Semantics.currencyCode: true 
 OriginalCurrency : abap.cuky ; 
 @Semantics.amount.currencyCode: 'OriginalCurrency' 
 AmountInOriginalCurrency : abap.curr( 24, 3 ) ; 
 DocumentItemText : abap.char( 50 ) ; 
 @Semantics.amount.currencyCode: 'TransactionCurrency' 
 AmountInTransactionCurrency : abap.curr( 24, 3 ) ; 
 PaymentManualTransacType : abap.char( 4 ) ; 
 PartnerBank : abap.char( 15 ) ; 
 PartnerBankAccount : abap.char( 18 ) ; 
 BusinessPartnerName : abap.char( 55 ) ; 
 
 } 
