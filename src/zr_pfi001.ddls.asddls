@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice'
define root view entity ZR_PFI001
  as select from I_BillingDocument as _BillingDocument
    join         ZR_PFI002         as _BillingDocID on _BillingDocument.BillingDocument = _BillingDocID.BillingDocument

  association [1..1] to ZR_PFI004 as _BillToParty         on $projection.BillToParty = _BillToParty.Customer
  association [1..1] to ZR_PFI004 as _ShipToParty         on $projection.ShipToParty = _ShipToParty.Customer
  association [0..*] to ZR_PFI003  as _BillingDocumentItem on $projection.BillingDocument = _BillingDocumentItem.BillingDocument
  //    association [0..*] to I_SerialNumberDeliveryDocument as _SerialNumberDeliveryDocument on _BillingDocumentItem.ReferenceSDDocument = _SerialNumberDeliveryDocument.DeliveryDocument
  //                                                                                         and _BillingDocumentItem.ReferenceSDDocumentItem = _SerialNumberDeliveryDocument.DeliveryDocumentItem
  //composition of target_data_source_name as _association_name
{

  key _BillingDocument.BillingDocument,
      _BillingDocument.BillingDocumentDate,
      //      @
      _BillingDocID.BillToParty,
      cast( _BillingDocID.ShipToParty as abap.char( 10 ) )   as ShipToParty,
      cast(_BillingDocument.PayerParty as abap.char( 10 )  ) as PayerParty,
      _BillingDocID.SalesDocument,
      _BillingDocID.PurchaseOrderByCustomer,
      _BillingDocID.PaymentTerms,
      _BillingDocID.NetDueDate,
      _BillingDocID.BranchAccount,
      _BillingDocument.SalesOrganization,

      _BillToParty,
      _ShipToParty,
      _BillingDocumentItem
      //    _BillingDocumentItem._ReferenceDeliveryDocumentItem.
      //    _BillingDocument.SalesOrganization,

}
