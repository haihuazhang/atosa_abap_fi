@EndUserText.label: 'Print CDS of Check Paid Item'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_001'
define custom entity ZR_PFI008
  //  with parameters parameter_name : parameter_type
{
  key PaymentCompanyCode : abap.char(4);
  key HouseBank          : abap.char(5);
  key HouseBankAccount   : abap.char(5);
  key PaymentMethod      : abap.char(1);
  key OutgoingCheque     : abap.char(13);
  key PageNum : int2;
  key ReferenceToPaidDocument : abap.char(16);
  @Semantics.amount.currencyCode      : 'LocalCurrency'
  NetAmountLocalCurrency : wrbtr_cs;
  DocumentDate : abap.dats;
  @Semantics.amount.currencyCode      : 'LocalCurrency'
  DiscountLocalCurrency : wrbtr_cs;
  LocalCurrency : waers;
  BPReferenceKey3: abap.sstring(20);
  @Semantics.amount.currencyCode      : 'LocalCurrency'
  AmountLocalCurrency: wrbtr_cs;


}
