@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TFI001'
@ObjectModel.semanticKey: [ 'Paymentcompanycode', 'Housebank', 'Housebankaccount', 'Paymentmethod', 'Outgoingcheque' ]
define root view entity ZC_TFI001
  provider contract transactional_query
  as projection on ZR_TFI001
{
  key Paymentcompanycode,
  key Housebank,
  key Housebankaccount,
  key Paymentmethod,
  key Outgoingcheque,
  Status,
  LocalLastChangedAt
  
}
