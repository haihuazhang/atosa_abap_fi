//@AbapCatalog.sqlViewName: 'ZV_BSANDPLPARKED'
//@AbapCatalog.compiler.compareFilter: true
@Metadata.ignorePropagatedAnnotations: true 
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BS and P&L included Parked Item Query'
@Analytics: { dataCategory: #CUBE } //, dataExtraction.enabled: true }
define view entity ZR_BSANDPLINCLUDEDPARKEDITEM
with parameters
  P_FromPostingDate       : sydate,
  P_ToPostingDate         : sydate
as select from ZI_GLAcctBalanceCube
( P_FromPostingDate: $parameters.P_FromPostingDate, P_ToPostingDate: $parameters.P_ToPostingDate ) 
{
    @ObjectModel.foreignKey.association: '_Ledger'    
    key Ledger,
    @ObjectModel.foreignKey.association: '_CompanyCode'
    key CompanyCode,
    @ObjectModel.foreignKey.association: '_FiscalYear'
    key FiscalYear,
    @ObjectModel.foreignKey.association: '_SourceLedger'
    key SourceLedger,
    @ObjectModel.foreignKey.association: '_JournalEntry'
    key AccountingDocument,
    key LedgerGLLineItem,
    @ObjectModel.foreignKey.association: '_GLAccountFlowType'
    key GLAccountFlowType,
    key FiscalPeriodDate,
    @ObjectModel.foreignKey.association: '_GLAccountInChartOfAccounts'
    GLAccount,
    @ObjectModel.foreignKey.association: '_GLAccountHierarchy'
    GLAccountHierarchy,
    FinancialAccountType,
    AccountAssignment,
    @DefaultAggregation: #SUM
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } 
    AmountInCompanyCodeCurrency as IntmdEndingBalAmtInCoCodeCrcy,
    @DefaultAggregation: #SUM
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } 
    DebitAmountInCoCodeCrcy as GLAcctDebitAmtInCoCodeCrcy,
    @DefaultAggregation: #SUM
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } 
    CreditAmountInCoCodeCrcy as GLAcctCreditAmtInCoCodeCrcy,
    CompanyCodeCurrency,
    '' as ParkedItemFlag,
    
    _Ledger,
    _CompanyCode,
    _FiscalYear,
    _SourceLedger,
    _JournalEntry,
    _GLAccountFlowType,
    @ObjectModel.foreignKey.association: '_ChartOfAccounts'   
    ChartOfAccounts,
    _ChartOfAccounts,
    _GLAccountInChartOfAccounts,
    _GLAccountHierarchy
}
union
select from ZR_PARKEDOPLACCTGDOCGLITEM{
    key Ledger,
    key CompanyCode,
    key FiscalYear,
    key SourceLedger,
    key AccountingDocument,
    key LedgerGLLineItem,
    key GLAccountFlowType,
    key '00000000000' as FiscalPeriodDate,
    GLAccount,
    GLAccountHierarchy,
    FinancialAccountType,
    '' as AccountAssignment,
    cast( 0 as abap.curr( 23,2 )) as IntmdEndingBalAmtInCoCodeCrcy,
    DebitAmountInCoCodeCrcy as GLAcctDebitAmtInCoCodeCrcy,
    CreditAmountInCoCodeCrcy as GLAcctCreditAmtInCoCodeCrcy,
    CompanyCodeCurrency,
    'X' as ParkedItemFlag,
    
    _Ledger,
    _CompanyCode,
    _FiscalYear,
    _SourceLedger,
    _JournalEntry,
    _GLAccountFlowType,
    ChartOfAccounts,
    _ChartOfAccounts,
    _GLAccountInChartOfAccounts,
    _GLAccountHierarchy
}
