/********** GENERATED on 02/04/2024 at 13:02:50 by CB9980000010**************/
 @OData.entitySet.name: 'YY1_BankStatement' 
 @OData.entityType.name: 'YY1_BankStatementType' 
 define root abstract entity ZZYY1_BANKSTATEMENT { 
 key BankStatementShortID : abap.numc( 8 ) ; 
 key BankStatementItem : abap.numc( 5 ) ; 
 @Odata.property.valueControl: 'CompanyCode_vc' 
 CompanyCode : abap.char( 4 ) ; 
 CompanyCode_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'HouseBank_vc' 
 HouseBank : abap.char( 5 ) ; 
 HouseBank_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'HouseBankAccount_vc' 
 HouseBankAccount : abap.char( 5 ) ; 
 HouseBankAccount_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'BankStatementDate_vc' 
 BankStatementDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 BankStatementDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'BankStatementPostingRule_vc' 
 BankStatementPostingRule : abap.char( 4 ) ; 
 BankStatementPostingRule_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ValueDate_vc' 
 ValueDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 ValueDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PostingDate_vc' 
 PostingDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 PostingDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TransactionCurrency_vc' 
 @Semantics.currencyCode: true 
 TransactionCurrency : abap.cuky ; 
 TransactionCurrency_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AmountInTransactionCurrency_vc' 
 @Semantics.amount.currencyCode: 'TransactionCurrency' 
 AmountInTransactionCurrency : abap.curr( 24, 3 ) ; 
 AmountInTransactionCurrency_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
