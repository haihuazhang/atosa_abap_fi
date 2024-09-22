@EndUserText.label: 'Outgoing Check CDS'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_RFI001
  as projection on ZR_RFI001
{
  key PaymentCompanyCode,
  key HouseBank,
  key HouseBankAccount,
  key PaymentMethod,
  key OutgoingCheque,
      PaymentDocument,
      Supplier,
      ChequePaymentDate,
      ChequeVoidReason,
      PaymentCurrency,
      PaidAmountInPaytCurrency,
      Status,
      Country,
      Region,
      ChequeStatus,
      _Company,
      _Country,
      _HouseBank,
      _Supplier,
      _VoidReason,

      _PrintRecord,
      _PrintStatus,
      _PaymentMethod
}
