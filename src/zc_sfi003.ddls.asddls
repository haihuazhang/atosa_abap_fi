@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Journal Entry Item for Payment Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_SFI003
  as select from ZR_SFI003
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key LedgerGLLineItem,
      AccountingDocument_N3,
      AccountingDocumentType,
      DocumentDate,
      PostingDate,
      DocumentReferenceID,
      TransactionCurrency,
      CreatedByUser,
      Supplier,
      Customer,
      AssignmentReference,
      SalesDocument,
      PostingKey,
      GLAccount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      AmountInTransactionCurrency,
      NetDueDate,
      ClearingJournalEntryFiscalYear,
      ClearingJournalEntry,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      OriginalAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      PaidToDate,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      BaeSum,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Remaining,

      _OperationalAcctgDocItem.BillingDocument,
      _BillingDocument.SalesOrganization,
      _SalesRep.Customer                               as SalesRepPartner,
      _SalesRepAddress.AddresseeFullName               as SalesRepPartnerName,

      _Supplier.SupplierName,
      _Customer.CustomerName,

      _ClearingJournalEntry.PostingDate                as ClearingDate,
      _ClearingJournalEntry.AccountingDocCreatedByUser as ClearingByUser,
      _ClearingJournalEntry.AccountingDocumentType     as ClearingJournalEntryType,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _OperationalAcctgDocItem.CashDiscountAmount,

      /* Associations */
      _OperationalAcctgDocItem
}
