@EndUserText.label: 'AR Payment Report'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_FI_002'
@UI: {
  headerInfo: {
    typeName: 'Journal Entry',
    typeNamePlural: 'Journal Entry'
  }
}
define custom entity ZR_SFI001
{

      @UI.hidden                : true
  key Uuid                      : sysuuid_x16;

      @UI.lineItem              : [{ hidden: true }]
      @UI.selectionField        : [{ position: 30 }]
      @EndUserText.label        : 'Type'
      @Consumption.filter.mandatory : true
      @Consumption.filter.defaultValue: 'I'
      @Consumption.valueHelpDefinition: [ {
         entity                 : { name: 'ZR_SFI005', element: 'Type' }
      } ]
      FilterType                : abap.char( 1 );

      @UI.lineItem              : [{ hidden: true }]
      @UI.selectionField        : [{ position: 40 }]
      @EndUserText.label        : 'Date'
      @Consumption.filter       : { selectionType: #INTERVAL }
      FilterDate                : abap.dats;

      @UI.lineItem              : [{ position: 10 }]
      @EndUserText.label        : 'Journal Entry Type'
      AccountingDocumentType    : abap.char( 2 );

      @UI.lineItem              : [{ position: 20 }]
      @EndUserText.label        : 'Journal Entry'
      @Consumption.semanticObject   : 'AccountingDocument'
      AccountingDocument        : abap.char( 10 );

      @UI.lineItem              : [{ position: 30 }]
      @EndUserText.label        : 'Assignment'
      AssignmentReference       : abap.char( 18 );

      @UI.lineItem              : [{ position: 40 }]
      @EndUserText.label        : 'Billing Document'
      BillingDocument           : abap.char( 10 );

      @UI.selectionField        : [{ position: 20 }]
      @UI.lineItem              : [{ position: 50 }]
      @Consumption.valueHelpDefinition: [ {
         entity                 : { name: 'I_Customer_VH', element: 'Customer' }
      }]
      @Consumption.semanticObject   : 'Customer'
      Customer                  : abap.char( 10 );

      @UI.lineItem              : [{ position: 60 }]
      @EndUserText.label        : 'Customer Name'
      CustomerName              : abap.char( 80 );

      @UI.lineItem              : [{ position: 70 }]
      @EndUserText.label        : 'Sales Orgnization'
      SalesOrgnization          : abap.char( 4 );

      @UI.lineItem              : [{ position: 80 }]
      @EndUserText.label        : 'Sales Employee'
      @ObjectModel.text.element : [ 'SalesRepPartnerName' ]
      SalesRepPartner           : abap.char( 10 );

      @UI.lineItem              : [{ position: 90 }]
      @EndUserText.label        : 'Customer PO#'
      CustomerPO                : abap.char( 16 );

      @UI.lineItem              : [{ position: 100 }]
      @EndUserText.label        : 'Posting Date'
      PostingDate               : abap.dats;

      @UI.lineItem              : [{ position: 110 }]
      @EndUserText.label        : 'Due Date'
      NetDueDate                : abap.dats;

      @UI.lineItem              : [{ position: 120 }]
      @EndUserText.label        : 'Original Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      OriginalAmount            : abap.curr( 23, 2 );

      @UI.lineItem              : [{ position: 130 }]
      @EndUserText.label        : 'Paid To Date'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      PaidToDate                : abap.curr( 23, 2 );

      @UI.lineItem              : [{ position: 135 }]
      @EndUserText.label        : 'Payment Doc. Type'
      PaymentAccDocType         : abap.char( 2 );

      @UI.lineItem              : [{ position: 140 }]
      @EndUserText.label        : 'Payment Document'
      @Consumption.semanticObject   : 'AccountingDocument'
      @Consumption.semanticObjectMapping.additionalBinding: [{ element: 'AccountingDocument',
                                                               localElement: 'PaymentAccountingDocument' },
                                                             { element: 'AccountingDocumentType',
                                                               localElement: 'PaymentAccDocType' },
                                                             { element: 'PostingDate',
                                                               localElement: 'PaymentDate' }]
      PaymentAccountingDocument : abap.char( 10 );

      @UI.lineItem              : [{ position: 150 }]
      @EndUserText.label        : 'Payment Date'
      PaymentDate               : abap.dats;

      @UI.lineItem              : [{ position: 160 }]
      @EndUserText.label        : 'Payment Amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      BaeSum                    : abap.curr( 23, 2 );

//      @UI.lineItem              : [{ position: 161 }]
//      @EndUserText.label        : 'Actual Receipt'
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      ActualReceipt             : abap.curr( 23, 2 );
//
//      @UI.lineItem              : [{ position: 162 }]
//      @EndUserText.label        : 'Cash Discount'
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      CashDiscount              : abap.curr( 23, 2 );

      @UI.lineItem              : [{ position: 170 }]
      @EndUserText.label        : 'Balance amount'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Remaining                 : abap.curr( 23, 2 );

      @UI.lineItem              : [{ position: 180 }]
      @EndUserText.label        : 'Payment Doc. Create By'
      @ObjectModel.foreignKey.association: '_User'
      PaymentByUser             : abap.char( 12 );

      @UI.selectionField        : [{ position: 10 }]
      @UI.lineItem              : [{ position: 190 }]
      @EndUserText.label        : 'Company Code'
      @Consumption.valueHelpDefinition: [ {
         entity                 : { name: 'I_CompanyCode', element: 'CompanyCode' }
      } ]
      @Consumption.semanticObject   : 'CompanyCode'
      CompanyCode               : abap.char( 4 );

      @EndUserText.label        : 'Sales Document'
      SalesDocument             : abap.char( 10 );

      @EndUserText.label        : 'Posting Key'
      PostingKey                : abap.char( 2 );

      @UI.hidden                : true
      @Semantics.currencyCode   : true
      TransactionCurrency       : abap.cuky( 5 );

      @UI.hidden                : true
      Sequence                  : abap.numc( 10 );

      @UI.hidden                : true
      SalesRepPartnerName       : abap.char( 80 );

      @ObjectModel.sort.enabled : false
      @ObjectModel.filter.enabled   : false
      _User                     : association [0..1] to I_BusinessUserVH on _User.UserID = $projection.PaymentByUser;

}
