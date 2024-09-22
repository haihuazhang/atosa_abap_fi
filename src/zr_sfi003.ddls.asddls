@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Journal Entry Item for Payment Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SFI003
  as select from I_JournalEntry     as _JournalEntry
    inner join   I_JournalEntryItem as _JournalEntryItem on  _JournalEntryItem.CompanyCode        = _JournalEntry.CompanyCode
                                                         and _JournalEntryItem.FiscalYear         = _JournalEntry.FiscalYear
                                                         and _JournalEntryItem.AccountingDocument = _JournalEntry.AccountingDocument

  association [0..1] to I_OperationalAcctgDocItem as _OperationalAcctgDocItem on  _OperationalAcctgDocItem.CompanyCode            = $projection.CompanyCode
                                                                              and _OperationalAcctgDocItem.FiscalYear             = $projection.FiscalYear
                                                                              and _OperationalAcctgDocItem.AccountingDocument     = $projection.AccountingDocument
                                                                              and _OperationalAcctgDocItem.AccountingDocumentItem = $projection.AccountingDocument_N3
  association [0..1] to I_BillingDocument         as _BillingDocument         on  _BillingDocument.BillingDocument = $projection.AssignmentReference

  association [0..1] to I_BillingDocumentPartner  as _SalesRep                on  _SalesRep.BillingDocument = $projection.AssignmentReference
                                                                              and _SalesRep.PartnerFunction = 'Z0'

  association [0..1] to I_Address_2               as _SalesRepAddress         on  _SalesRepAddress.AddressID = $projection.SalesRepAddressID

  association [0..1] to I_Supplier                as _Supplier                on  _Supplier.Supplier = $projection.Supplier
  association [0..1] to I_Customer                as _Customer                on  _Customer.Customer = $projection.Customer

  association [0..1] to I_JournalEntry            as _ClearingJournalEntry    on  _ClearingJournalEntry.CompanyCode        = $projection.CompanyCode
                                                                              and _ClearingJournalEntry.FiscalYear         = $projection.ClearingJournalEntryFiscalYear
                                                                              and _ClearingJournalEntry.AccountingDocument = $projection.ClearingJournalEntry
{

  key _JournalEntry.CompanyCode,
  key _JournalEntry.FiscalYear,
  key _JournalEntry.AccountingDocument,
  key _JournalEntryItem.LedgerGLLineItem,
      cast( substring( _JournalEntryItem.LedgerGLLineItem, 4, 6 ) as abap.numc( 3 )) as AccountingDocument_N3,

      _JournalEntry.AccountingDocumentType,
      _JournalEntry.DocumentDate,
      _JournalEntry.PostingDate,
      _JournalEntry.DocumentReferenceID,
      _JournalEntry.TransactionCurrency,
      _JournalEntry.AccountingDocCreatedByUser                                       as CreatedByUser,

      _JournalEntryItem.Supplier,
      _JournalEntryItem.Customer,
      _JournalEntryItem.AssignmentReference,
      _JournalEntryItem.SalesDocument,
      _JournalEntryItem.PostingKey,
      _JournalEntryItem.GLAccount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _JournalEntryItem.AmountInTransactionCurrency,
      _JournalEntryItem.NetDueDate,

      // Clearing
      _JournalEntryItem.ClearingJournalEntryFiscalYear,
      _JournalEntryItem.ClearingJournalEntry,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( '0.00' as abap.curr( 23, 2 ) )                                           as OriginalAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( '0.00' as abap.curr( 23, 2 ) )                                           as PaidToDate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( '0.00' as abap.curr( 23, 2 ) )                                           as BaeSum,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( '0.00' as abap.curr( 23, 2 ) )                                           as Remaining,

      _OperationalAcctgDocItem,
      _BillingDocument,
      _SalesRep.AddressID                                                            as SalesRepAddressID,
      _SalesRep,
      _SalesRepAddress,
      _Supplier,
      _Customer,
      _ClearingJournalEntry
}
where
       _JournalEntry.IsReversed             <> 'X'
  and  _JournalEntry.IsReversal             <> 'X'
  and(
       _JournalEntry.AccountingDocumentType =  'RV' // AR
    or _JournalEntry.AccountingDocumentType =  'DR' // AR
    or _JournalEntry.AccountingDocumentType =  'DG' // AR
    or _JournalEntry.AccountingDocumentType =  'DZ' // AR Payment

    or _JournalEntry.AccountingDocumentType =  'RE' // AP
    or _JournalEntry.AccountingDocumentType =  'KR' // AP
    or _JournalEntry.AccountingDocumentType =  'KG' // AP
    or _JournalEntry.AccountingDocumentType =  'KZ' // AP Payment

    or _JournalEntry.AccountingDocumentType =  'ZP' // Auto Payment
  )
  and  _JournalEntryItem.Ledger             =  '0L'
  and(
       _JournalEntryItem.GLAccount          =  '1200000000' // AR
    or _JournalEntryItem.GLAccount          =  '2100000000' // AP
  )
