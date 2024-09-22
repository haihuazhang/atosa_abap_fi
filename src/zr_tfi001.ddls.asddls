@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTFI001'
define root view entity ZR_TFI001
  as select from ztfi001
{
  key paymentcompanycode as PaymentCompanyCode,
  key housebank as HouseBank,
  key housebankaccount as HouseBankAccount,
  key paymentmethod as PaymentMethod,
  key outgoingcheque as OutgoingCheque,
  status as Status,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
