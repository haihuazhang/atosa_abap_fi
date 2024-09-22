@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Incoming Payment JE deplicate'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PFI013 
    as select from I_JournalEntryItem as _JournalEntryItem
{
    key _JournalEntryItem.CompanyCode,
    key _JournalEntryItem.FiscalYear,
    key _JournalEntryItem.AccountingDocument,
    max(_JournalEntryItem.Customer) as Customer,
    max(_JournalEntryItem.DocumentDate) as DocumentDate
}
where _JournalEntryItem.SourceLedger = '0L'
group by _JournalEntryItem.CompanyCode,
_JournalEntryItem.FiscalYear,
_JournalEntryItem.AccountingDocument
