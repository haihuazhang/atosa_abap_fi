@EndUserText.label: 'Print CDS of Check Header '
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_001'
define custom entity ZR_PFI009
  //  with parameters parameter_name : parameter_type
{
  key PaymentCompanyCode : abap.char(4);
  key HouseBank          : abap.char(5);
  key HouseBankAccount   : abap.char(5);
  key PaymentMethod      : abap.char(1);
  key OutgoingCheque     : abap.char(13);
      RunOn              : abap.dats;
      SendingCompanyCode : abap.char(4);
      @ObjectModel.filter.enabled: false
      _PaymentData       : association [0..*] to ZR_PFI006 on  _PaymentData.PaymentCompanyCode = $projection.PaymentCompanyCode
                                                           and _PaymentData.HouseBank          = $projection.HouseBank
                                                           and _PaymentData.HouseBankAccount   = $projection.HouseBankAccount
                                                           and _PaymentData.PaymentMethod      = $projection.PaymentMethod
                                                           and _PaymentData.OutgoingCheque     = $projection.OutgoingCheque;

}
