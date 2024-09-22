@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Serial Number'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PFI005 as select from I_SerialNumberDeliveryDocument
{
    key Equipment,
    key DeliveryDocument,
    key DeliveryDocumentItem,
    Material,
    SerialNumber,
    /* Associations */
    _DeliveryDocument,
    _DeliveryDocumentItem,
    _Equipment,
    _Product
}
