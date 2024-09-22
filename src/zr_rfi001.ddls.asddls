@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Check CDS'
define root view entity ZR_RFI001
  as select from I_OutgoingCheck as _Check
  //composition of target_data_source_name as _association_name
  association [0..1] to ZR_TFI001       as _PrintRecord   on  _Check.PaymentCompanyCode = _PrintRecord.PaymentCompanyCode
                                                          and _Check.HouseBank          = _PrintRecord.HouseBank
                                                          and _Check.HouseBankAccount   = _PrintRecord.HouseBankAccount
                                                          and _Check.PaymentMethod      = _PrintRecord.PaymentMethod
                                                          and _Check.OutgoingCheque     = _PrintRecord.OutgoingCheque
  association [0..1] to I_PaymentMethod as _PaymentMethod on  _PaymentMethod.PaymentMethod = $projection.PaymentMethod
                                                          and _PaymentMethod.Country       = $projection.Country
  association [0..1] to ZR_SFI002       as _PrintStatus   on  _PrintStatus.value_low = $projection.Status

{
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' }}]
      @ObjectModel.foreignKey.association: '_Company'
  key PaymentCompanyCode,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Housebank', element: 'HouseBank' }}]
      @ObjectModel.foreignKey.association: '_HouseBank'
  key HouseBank,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_HouseBankAccountLinkage', element: 'HouseBankAccount' }}]
  key HouseBankAccount,

      @ObjectModel.foreignKey.association: '_PaymentMethod'
  key PaymentMethod,
  key OutgoingCheque,
      ChequeIsManuallyIssued,
      ChequebookFirstCheque,
      PaymentDocument,
      ChequePaymentDate,
      PaymentCurrency,
      PaidAmountInPaytCurrency,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier', element: 'Supplier' }}]
      @ObjectModel.foreignKey.association: '_Supplier'
      Supplier,
      PayeeTitle,
      PayeeName,
      PayeeAdditionalName,
      PayeePostalCode,
      PayeeCityName,
      PayeeStreet,
      PayeePOBox,
      PayeePOBoxPostalCode,
      PayeePOBoxCityName,
      Country,
      Region,
      //      @ObjectModel.foreignKey.association: '_VoidReason'
      ChequeVoidReason,
      ChequeVoidedDate,
      ChequeVoidedByUser,
      ChequeIsCashed,
      CashDiscountAmount,
      FiscalYear,
      ChequeType,
      //      VoidedChequeUsage,
      ChequeStatus,
      ChequeIssuingType,
      BankName,
      CompanyCodeCountry,
      CompanyCodeName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZR_SFI002', element: 'value_low' }}]
      @ObjectModel.foreignKey.association: '_PrintStatus'
      _PrintRecord.Status as Status,
      /* Associations */
      _Company,
      _Country,
      _HouseBank,
      _Supplier,
      _VoidReason,

      _PrintRecord,
      _PaymentMethod,
      _PrintStatus
      //      _HouseBank // Make association public
}
