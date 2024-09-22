@EndUserText.label: 'Print CDS of Check Address'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_001'
define custom entity ZR_PFI007
  //  with parameters parameter_name : parameter_type
{
  key PaymentCompanyCode : abap.char(4);
  key HouseBank          : abap.char(5);
  key HouseBankAccount   : abap.char(5);
  key PaymentMethod      : abap.char(1);
  key OutgoingCheque     : abap.char(13);
  key PageNum            : int2;


}
