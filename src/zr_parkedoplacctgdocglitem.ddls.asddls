@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parked Account DOC GL Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PARKEDOPLACCTGDOCGLITEM
  as select from I_ParkedOplAcctgDocPyblsItem

  association [0..1] to I_Ledger                     as _Ledger             on  $projection.Ledger = _Ledger.Ledger

  association [0..1] to I_FiscalYearForCompanyCode   as _FiscalYear         on  $projection.FiscalYear  = _FiscalYear.FiscalYear
                                                                            and $projection.CompanyCode = _FiscalYear.CompanyCode

  association [0..1] to I_Ledger                     as _SourceLedger       on  $projection.SourceLedger = _SourceLedger.Ledger

  association [0..1] to I_JournalEntry               as _JournalEntry       on  $projection.CompanyCode        = _JournalEntry.CompanyCode
                                                                            and $projection.FiscalYear         = _JournalEntry.FiscalYear
                                                                            and $projection.AccountingDocument = _JournalEntry.AccountingDocument
  association [0..1] to I_GLAccountFlowType          as _GLAccountFlowType  on  $projection.GLAccountFlowType = _GLAccountFlowType.GLAccountFlowType

  association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountHierarchy on  $projection.ChartOfAccounts    = _GLAccountHierarchy.ChartOfAccounts
                                                                            and $projection.GLAccountHierarchy = _GLAccountHierarchy.GLAccount
{
  key '0L'                     as Ledger,
  key CompanyCode              as CompanyCode,
  key SourceFiscalYear         as FiscalYear,
  key '0L'                     as SourceLedger,
  key SourceAccountingDocument as AccountingDocument,
  key cast(lpad(ParkedAcctgDocPyblsItem,6,'0')as abap.char(6))  as LedgerGLLineItem,
  key CashFlowType             as GLAccountFlowType,
      @ObjectModel.foreignKey.association: '_GLAccountInChartOfAccounts'
      GLAccount,
      @ObjectModel.foreignKey.association: '_GLAccountHierarchy'
      GLAccount                as GLAccountHierarchy,
      FinancialAccountType,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case DebitCreditCode when 'S' then cast( AmountInCompanyCodeCurrency as abap.curr( 23, 2 ))
          else cast( '0' as abap.curr(23,2))
      end                      as DebitAmountInCoCodeCrcy,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case DebitCreditCode when 'H' then cast( AmountInCompanyCodeCurrency as abap.curr(23,2) )
          else cast( '0' as abap.curr( 23, 2 ))
      end                      as CreditAmountInCoCodeCrcy,
      CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      case DebitCreditCode when 'S' then cast( AmountInTransactionCurrency as abap.curr( 23, 2 ))
          else cast( '0' as abap.curr( 23, 2 ))
      end                      as DebitAmountInTransCrcy,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      case DebitCreditCode when 'H' then cast( AmountInTransactionCurrency as abap.curr( 23, 2 ))
          else cast( '0' as abap.curr( 23, 2 ))
      end                      as CreditAmountInTransCrcy,
      TransactionCurrency,
      DueCalculationBaseDate,

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

//define view entity ZR_PARKEDOPLACCTGDOCGLITEM
//  as select from I_ParkedOplAcctgDocGLItem
//  association [0..1] to I_Ledger                     as _Ledger                     on  $projection.Ledger = _Ledger.Ledger
//  association [1]    to I_CompanyCode                as _CompanyCode                on  $projection.CompanyCode = _CompanyCode.CompanyCode
//  association [0..1] to I_FiscalYearForCompanyCode   as _FiscalYear                 on  $projection.FiscalYear  = _FiscalYear.FiscalYear
//                                                                                    and $projection.CompanyCode = _FiscalYear.CompanyCode
//  association [0..1] to I_Ledger                     as _SourceLedger               on  $projection.SourceLedger = _SourceLedger.Ledger
//  association [0..1] to I_JournalEntry               as _JournalEntry               on  $projection.CompanyCode        = _JournalEntry.CompanyCode
//                                                                                    and $projection.FiscalYear         = _JournalEntry.FiscalYear
//                                                                                    and $projection.AccountingDocument = _JournalEntry.AccountingDocument
//  association [0..1] to I_GLAccountFlowType          as _GLAccountFlowType          on  $projection.GLAccountFlowType = _GLAccountFlowType.GLAccountFlowType
//  association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountInChartOfAccounts on  $projection.ChartOfAccounts = _GLAccountInChartOfAccounts.ChartOfAccounts
//                                                                                    and $projection.GLAccount       = _GLAccountInChartOfAccounts.GLAccount
//  association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountHierarchy         on  $projection.ChartOfAccounts = _GLAccountHierarchy.ChartOfAccounts
//                                                                                    and $projection.GLAccountHierarchy = _GLAccountHierarchy.GLAccount
//  association [1]    to I_ChartOfAccounts            as _ChartOfAccounts            on  $projection.ChartOfAccounts = _ChartOfAccounts.ChartOfAccounts
//
//  //    association [0..1] to ZI_GLAcctBalance as _GLAcctBalance on $projection.Ledger = _GLAcctBalance.Ledger and
//  //                                                               $projection.CompanyCode = _GLAcctBalance.CompanyCode and
//  //                                                               $projection.FiscalYear = _GLAcctBalance.FiscalYear and
//  //                                                               $projection.AccountingDocument = _GLAcctBalance.AccountingDocument and
//  //                                                               $projection.SourceLedger = _GLAcctBalance.SourceLedger
//{
//  key '0L'                                                             as Ledger,
//  key SourceCompanyCode                                                as CompanyCode,
//  key SourceFiscalYear                                                 as FiscalYear,
//  key '0L'                                                             as SourceLedger,
//  key SourceAccountingDocument                                         as AccountingDocument,
//  key cast( lpad( ParkedAcctgDocGLAccountItem,6,'0') as abap.char(6) ) as LedgerGLLineItem,
//  key CashFlowType                                                     as GLAccountFlowType,
//      @ObjectModel.foreignKey.association: '_GLAccountInChartOfAccounts'
//      GLAccount,
//      @ObjectModel.foreignKey.association: '_GLAccountHierarchy'
//      GLAccount                                                        as GLAccountHierarchy,
//      FinancialAccountType,
//      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
//      case DebitCreditCode when 'S' then cast( AmountInCompanyCodeCurrency as abap.curr( 23, 2 ))
//          else cast( '0' as abap.curr(23,2))
//      end                                                              as DebitAmountInCoCodeCrcy,
//      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
//      case DebitCreditCode when 'H' then cast( AmountInCompanyCodeCurrency as abap.curr(23,2) )
//          else cast( '0' as abap.curr( 23, 2 ))
//      end                                                              as CreditAmountInCoCodeCrcy,
//      CompanyCodeCurrency,
//      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
//      case DebitCreditCode when 'S' then cast( AmountInTransactionCurrency as abap.curr( 23, 2 ))
//          else cast( '0' as abap.curr( 23, 2 ))
//      end                                                              as DebitAmountInTransCrcy,
//      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
//      case DebitCreditCode when 'H' then cast( AmountInTransactionCurrency as abap.curr( 23, 2 ))
//          else cast( '0' as abap.curr( 23, 2 ))
//      end                                                              as CreditAmountInTransCrcy,
//          AmountInTransactionCurrency,
//      TransactionCurrency,
//          @Semantics: { amount : {currencyCode: 'AdditionalCurrency1'} }
//          AmountInAdditionalCurrency1,
//          AdditionalCurrency1,
//          @Semantics: { amount : {currencyCode: 'AdditionalCurrency2'} }
//          AmountInAdditionalCurrency2,
//          AdditionalCurrency2,
//      DueCalculationBaseDate,
//
//      _Ledger,
//      _CompanyCode,
//      _FiscalYear,
//      _SourceLedger,
//      _JournalEntry,
//      _GLAccountFlowType,
//          _GLAcctBalance,
//      @ObjectModel.foreignKey.association: '_ChartOfAccounts'
//      'YCOA' as ChartOfAccounts,
//      _ChartOfAccounts,
//      _GLAccountInChartOfAccounts,
//      _GLAccountHierarchy
//}
