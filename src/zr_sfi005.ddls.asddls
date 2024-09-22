@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help of Payment Report Filter Type'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZR_SFI005
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDFI002')
{

      @EndUserText.label: 'Type'
      @ObjectModel.text.element: [ 'Text' ]
  key value_low as Type,

      @EndUserText.label: 'Type Description'
      @Semantics.text: true
      text      as Text
}
where
  language = 'E'
