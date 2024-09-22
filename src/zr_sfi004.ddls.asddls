@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Select From I_JournalEntry'
define root view entity ZR_SFI004
  as select from I_JournalEntry
  
  association [0..1] to ZR_PFI013 as _Customer on _Customer.CompanyCode = $projection.CompanyCode
                                              and _Customer.FiscalYear = $projection.FiscalYear
                                              and _Customer.AccountingDocument = $projection.AccountingDocument
{
  @UI.selectionField: [{ position: 1 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }}]
  key CompanyCode,
  @UI.selectionField: [{ position: 2 }]
  @Semantics.calendar.year: true
  key FiscalYear,
  @UI.selectionField: [{ position: 3 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_JournalEntry', element: 'AccountingDocument' }}]
  key AccountingDocument,
  @UI.selectionField: [{ position: 4 }]
  @Consumption.valueHelpDefinition: [ {
         entity                   : { name: 'I_Customer_VH', element: 'Customer' }
      }]
  key _Customer.Customer,
  @UI.selectionField: [{ position: 5 }]
  @Consumption.valueHelpDefinition: [ 
        { entity:  { name:    'I_AccountingDocumentType',
                     element: 'AccountingDocumentType' }
        }]
      AccountingDocumentType,
      DocumentDate,
      PostingDate,
      FiscalPeriod,
      AccountingDocumentCreationDate,
      CreationTime,
      LastManualChangeDate,
      LastAutomaticChangeDate,
      LastChangeDate,
      ExchangeRateDate,
      AccountingDocCreatedByUser,
      TransactionCode,
      IntercompanyTransaction,
      DocumentReferenceID,
      RecurringAccountingDocument,
      ReverseDocument,
      ReverseDocumentFiscalYear,
      AccountingDocumentHeaderText,

      TransactionCurrency,
      //@Aggregation.default: #NOP

      AbsoluteExchangeRate,
      cast(AbsoluteExchangeRate as abap.dec( 9, 5 )) as ExchangeRate,
      ExchRateIsIndirectQuotation,
      EffectiveExchangeRate,

      AccountingDocumentCategory,
      NetAmountIsPosted,
      //frath,
      JrnlEntryIsPostedToPrevPeriod,
      BusinessTransactionType,
      BatchInputSession,
      //dokid,
      //arcid,
      //iblar,
      ReferenceDocumentType,
      OriginalReferenceDocument,

      FinancialManagementArea,

      CompanyCodeCurrency,
      AdditionalCurrency1,
      AdditionalCurrency2,
      ReversalIsPlanned,
      PlannedReversalDate,
      //@Semantics.booleanIndicator
      TaxIsCalculatedAutomatically,
      AdditionalCurrency1Role,
      AdditionalCurrency2Role,
      TaxBaseAmountIsNetAmount,
      SourceCompanyCode,
      LogicalSystem,
      ReferenceDocumentLogicalSystem,
      //@Aggregation.default: #NOP

      TaxAbsoluteExchangeRate,
      cast(TaxAbsoluteExchangeRate as abap.dec( 9, 5 )) as TaxExchangeRate,
      TaxExchRateIsIndirectQuotation,
      TaxEffectiveExchangeRate,

      CtryCrcyTxAbsoluteExchangeRate,

      CtryCrcyTaxEffctvExchangeRate,

      //lotkz,
      //xwvof,
      ReversalReason,
      ParkedByUser,
      ParkingDate,
      ParkingTime,
      Branch,
      NmbrOfPages,
      //@Semantics.booleanIndicator
      IsDiscountDocument,
      Reference1InDocumentHeader,
      Reference2InDocumentHeader,
      InvoiceReceiptDate,
      Ledger,
      LedgerGroup,
      //propmano,
      AlternativeReferenceDocument,
      TaxReportingDate,
      TaxFulfillmentDate,
      AccountingDocumentClass,
      //xsplit,
      //cash_alloc,
      //follow_on,
      //xreorg,
      //subset,
      ExchangeRateType,
      MarketDataAbsoluteExchangeRate,

      MktDataEffectiveExchangeRate,
      //kur2x,
      //kur3x,
      //xmca,
      //resubmission,
      SenderLogicalSystem,
      SenderCompanyCode,
      SenderAccountingDocument,
      SenderFiscalYear,
      ReversalReferenceDocumentCntxt,
      ReversalReferenceDocument,
      //ccins,
      //ccnum,
      LatePaymentReason,
      SalesDocumentCondition,
      //@Semantics.booleanIndicator
      IsReversal,
      //@Semantics.booleanIndicator
      IsReversed,
      GLBusinessTransactionGroup,
      @Analytics.internalName: #LOCAL
      CostAccountingValuationDate,

      TaxCountry,
      JournalEntryLastChangeDateTime,

      // .INCLUDE FAC_BKPF_EXT_GLO  STRU  0 0 Document Header: Extension include for globalisation
      JrnlEntryCntrySpecificRef1,
      JrnlEntryCntrySpecificDate1,
      JrnlEntryCntrySpecificRef2,
      JrnlEntryCntrySpecificDate2,
      JrnlEntryCntrySpecificRef3,
      JrnlEntryCntrySpecificDate3,
      JrnlEntryCntrySpecificRef4,
      JrnlEntryCntrySpecificDate4,
      JrnlEntryCntrySpecificRef5,
      JrnlEntryCntrySpecificDate5,
      JrnlEntryCntrySpecificBP1,
      JrnlEntryCntrySpecificBP2,

      WithholdingTaxReportingDate,

      _CompanyCode,
      _FiscalYear,
      _AccountingDocumentType,
      _CompanyCodeCurrency,
      _TransactionCurrency,
      _AdditionalCurrency1,
      _AdditionalCurrency2,
      _FiscalPeriod,
      _AccountingDocumentCategory,
      _BusinessTransactionType,
      _FinancialManagementArea,
      _ReferenceDocumentType,
      _User,
      _LogicalSystem,
      _RefDocumentLogicalSystem,
      _Ledger,
      _LedgerGroup,
      _AdditionalCurrency1Role,
      _AdditionalCurrency2Role,

      _JournalEntryItem,
      _OperationalAcctgDocItem,
      _AddlLedgerOplAcctgDocItem,


      //--[ GENERATED:012:29JlHNUf7jY4ip7HtmZN9m
      @Consumption.hidden: true
      _AccountingDocumentTypeText,
      @Consumption.hidden: true
      _BusinessTransactionTypeText,
      @Consumption.hidden: true
      _FinancialManagementAreaText,
      @Consumption.hidden: true
      _LedgerText
      // ]--GENERATED
}
