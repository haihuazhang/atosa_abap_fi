@EndUserText.label: 'parameter of print Check'
define abstract entity ZR_PFI010
//  with parameters parameter_name : parameter_type
{
  key PaymentCompanyCode : abap.char(4);
  key HouseBank          : abap.char(5);
  key HouseBankAccount   : abap.char(5);
  key PaymentMethod      : abap.char(1);
  key OutgoingCheque     : abap.char(13);
    
}
