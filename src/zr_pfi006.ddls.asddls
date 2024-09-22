@EndUserText.label: 'Print CDS of Check Header'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_001'
define custom entity ZR_PFI006
  //  with parameters parameter_name : parameter_type
{
  key PaymentCompanyCode       : abap.char(4);
  key HouseBank                : abap.char(5);
  key HouseBankAccount         : abap.char(5);
  key PaymentMethod            : abap.char(1);
  key OutgoingCheque           : abap.char(13);
  key PageNum                  : int2;
      BPReference              : zzesd004;
      @Semantics.amount.currencyCode      : 'Currency'
      AmountPaidLocalCurrency  : wrbtr_cs;
      Currency                 : waers;
      Identification           : abap.char(5);
      @Semantics.amount.currencyCode      : 'Currency'
      PositiveCheckAmount      : wrbtr_cs;
      @Semantics.amount.currencyCode      : 'Currency'
      CashDiscountAmount       : wrbtr_cs;
      @Semantics.amount.currencyCode      : 'Currency'
      NetAmount                : wrbtr_cs;
      RunOn                    : abap.dats;
      SendingCompanyCode       : abap.char(4);
      SeparatePaymentAdvice    : abap.sstring(60);
      CheckNum                 : abap.char(13);
      ExternalFormatAccountNum : abap.char(18);
      HouseBankNo              : abap.char(15);
      Name1Payee               : abap.sstring(100);
      OurBankName              : abap.sstring(100);

      AddressLine0             : abap.sstring(100);
      AddressLine1             : abap.sstring(100);
      AddressLine2             : abap.sstring(100);
      AddressLine3             : abap.sstring(100);
      AddressLine4             : abap.sstring(100);
      AddressLine5             : abap.sstring(100);
      AddressLine6             : abap.sstring(100);
      AddressLine7             : abap.sstring(100);
      AddressLine8             : abap.sstring(100);
      AddressLine9             : abap.sstring(100);



      //      _FormattedAddress       : association [0..1] to ZR_PFI007 on  _FormattedAddress.PaymentCompanyCode = $projection.PaymentCompanyCode
      //                                                                 and _FormattedAddress.HouseBank          = $projection.HouseBank
      //                                                                 and _FormattedAddress.HouseBankAccount   = $projection.HouseBankAccount
      //                                                                 and _FormattedAddress.PaymentMethod      = $projection.PaymentMethod
      //                                                                 and _FormattedAddress.OutgoingCheque     = $projection.OutgoingCheque
      //                                                                 and _FormattedAddress.PageNum            = $projection.PageNum;
      @ObjectModel.filter.enabled: false
      _PaymentPaidItem         : association [0..*] to ZR_PFI008 on  _PaymentPaidItem.PaymentCompanyCode = $projection.PaymentCompanyCode
                                                                 and _PaymentPaidItem.HouseBank          = $projection.HouseBank
                                                                 and _PaymentPaidItem.HouseBankAccount   = $projection.HouseBankAccount
                                                                 and _PaymentPaidItem.PaymentMethod      = $projection.PaymentMethod
                                                                 and _PaymentPaidItem.OutgoingCheque     = $projection.OutgoingCheque
                                                                 and _PaymentPaidItem.PageNum            = $projection.PageNum;
      @ObjectModel.filter.enabled: false
      _PaymentPaidItemCopy     : association [0..*] to ZR_PFI008 on  _PaymentPaidItemCopy.PaymentCompanyCode = $projection.PaymentCompanyCode
                                                                 and _PaymentPaidItemCopy.HouseBank          = $projection.HouseBank
                                                                 and _PaymentPaidItemCopy.HouseBankAccount   = $projection.HouseBankAccount
                                                                 and _PaymentPaidItemCopy.PaymentMethod      = $projection.PaymentMethod
                                                                 and _PaymentPaidItemCopy.OutgoingCheque     = $projection.OutgoingCheque
                                                                 and _PaymentPaidItemCopy.PageNum            = $projection.PageNum;
}
