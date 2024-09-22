@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help of Print Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE ]
@ObjectModel.dataCategory: #VALUE_HELP
define view entity ZR_SFI002T

as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDFI001')
{
 
    @Semantics.language: true
    key language,
    key value_low,
        domain_name,
        value_position,
    @Semantics.text: true
    text
}
