/********** GENERATED on 01/31/2024 at 07:21:54 by CB9980000010**************/
 @OData.entitySet.name: 'JournalEntryItemSet' 
 @OData.entityType.name: 'JournalEntryItemType' 
 define root abstract entity ZZJOURNALENTRYITEMSET { 
 key CompanyCode : abap.char( 4 ) ; 
 key HouseBank : abap.char( 5 ) ; 
 key HouseBankAccount : abap.char( 5 ) ; 
 key BankReconciliationDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 key FiscalYear : abap.char( 4 ) ; 
 key AccountingDocument : abap.char( 10 ) ; 
 key AccountingDocumentItem : abap.char( 6 ) ; 
 BankReconciliationMatchType : abap.char( 1 ) ; 
 Note : abap.char( 255 ) ; 
 @Semantics.currencyCode: true 
 HouseBankCurrency : abap.cuky ; 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 DebitAmountInTransCrcy : abap.curr( 24, 3 ) ; 
 @Semantics.amount.currencyCode: 'HouseBankCurrency' 
 CreditAmountInTransCrcy : abap.curr( 24, 3 ) ; 
 @Semantics.currencyCode: true 
 TransactionCurrency : abap.cuky ; 
 @Semantics.amount.currencyCode: 'TransactionCurrency' 
 AmountInTransactionCurrency : abap.curr( 24, 3 ) ; 
 @Semantics.currencyCode: true 
 CompanyCodeCurrency : abap.cuky ; 
 @Semantics.amount.currencyCode: 'CompanyCodeCurrency' 
 AmountInCompanyCodeCurrency : abap.curr( 24, 3 ) ; 
 @Odata.property.valueControl: 'PostingDate_vc' 
 PostingDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 PostingDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 DocumentItemText : abap.char( 50 ) ; 
 @Odata.property.valueControl: 'ValueDate_vc' 
 ValueDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 ValueDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 AssignmentReference : abap.char( 18 ) ; 
 
 } 
