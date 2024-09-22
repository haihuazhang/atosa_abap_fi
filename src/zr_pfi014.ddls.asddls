@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Incoming Payment Item Cheque'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PFI014
    as select from I_JournalEntryItem as _JournalEntryItem
    
    association [0..1] to I_JournalEntry as _JournalEntry
    on _JournalEntry.CompanyCode = _JournalEntryItem.CompanyCode
    and _JournalEntry.FiscalYear = _JournalEntryItem.FiscalYear
    and _JournalEntry.AccountingDocument = _JournalEntryItem.AccountingDocument
    
{
    key cast(_JournalEntryItem.CompanyCode as abap.char( 4 )) as CompanyCode,
    key _JournalEntryItem.FiscalYear,
    key cast(_JournalEntryItem.AccountingDocument as abap.char( 10 )) as AccountingDocument,
    _JournalEntryItem.DocumentDate,
    _JournalEntry.DocumentReferenceID,
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    sum(_JournalEntryItem.AmountInCompanyCodeCurrency) as AmountInCompanyCodeCurrency,
    _JournalEntryItem.CompanyCodeCurrency
}
where _JournalEntryItem.SourceLedger = '0L'
  and _JournalEntryItem.GLAccountType = 'C'
group by CompanyCode,FiscalYear,AccountingDocument,DocumentDate,
         _JournalEntry.DocumentReferenceID,CompanyCodeCurrency
