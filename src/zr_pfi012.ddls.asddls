//@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Incoming Payment Item'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_FI_003'
define custom entity ZR_PFI012
{
  key CompanyCode : bukrs;
  key FiscalYear : gjahr;
  key AccountingDocument : belnr_d;
  key LedgerGLLineItem : abap.char(6);
  key BillingNo : belnr_d;
  DocumentDate : bldat;
  DocumentReferenceID : xblnr1;
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  OriginalAmount : abap.curr( 23, 2 );
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  Outstanding : abap.curr( 23, 2 );
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  Paid : abap.curr( 23, 2 );
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  Accumulatedpayment : abap.curr( 23, 2 );
  CompanyCodeCurrency : abap.cuky( 5 );
}
