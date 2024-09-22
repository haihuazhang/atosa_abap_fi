@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Item duplicate'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PFI002
  as select from    I_BillingDocumentItem     as _BillDocumentID
    left outer join I_OperationalAcctgDocItem as _AcctgDocItem on _BillDocumentID.BillingDocument = _AcctgDocItem.BillingDocument
    left outer join I_SalesOrder              as _SalesOrder   on _BillDocumentID.SalesDocument = _SalesOrder.SalesOrder
{
  key _BillDocumentID.BillingDocument,
      //    _BillDocumentID.BillingDocumentItem,
      max(_BillDocumentID.SalesDocumentItemCategory) as SalesDocumentItemCategory,
      //    _BillDocumentID.SalesDocumentItemType,
      //    _BillDocumentID.ReturnItemProcessingType,
      //    _BillDocumentID.CreatedByUser,
      //    _BillDocumentID.CreationDate,
      //    _BillDocumentID.CreationTime,
      //    _BillDocumentID.ReferenceLogicalSystem,
      //    _BillDocumentID.OrganizationDivision,
      max(_BillDocumentID.BillToParty)               as BillToParty,
      max(_BillDocumentID.ShipToParty)               as ShipToParty,
      //    _BillDocumentID.Customer
      max(_BillDocumentID.SalesDocument)             as SalesDocument,
      max( _SalesOrder.PurchaseOrderByCustomer)      as PurchaseOrderByCustomer,
      max(_AcctgDocItem.PaymentTerms)                as PaymentTerms,
      max(_AcctgDocItem.NetDueDate)                  as NetDueDate,
      max(_AcctgDocItem.BranchAccount)               as BranchAccount

}
group by
  _BillDocumentID.BillingDocument
