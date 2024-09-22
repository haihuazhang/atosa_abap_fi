@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Incoming Payment'
define root view entity ZR_PFI011 
    as select from I_JournalEntry as _JournalEntry
    
    inner join ZR_PFI013 as _Header on _Header.CompanyCode = _JournalEntry.CompanyCode
    and _Header.FiscalYear = _JournalEntry.FiscalYear
    and _Header.AccountingDocument = _JournalEntry.AccountingDocument
    
    association [0..1] to I_Customer as _Customer on _Header.Customer = _Customer.Customer
    
    association [0..*] to ZR_PFI012 as _PaymentsItem on _PaymentsItem.CompanyCode = $projection.CompanyCode
                                                    and _PaymentsItem.FiscalYear = $projection.FiscalYear
                                                    and _PaymentsItem.AccountingDocument = $projection.AccountingDocument
    association [0..*] to ZR_PFI014 as _ChequeItem on _ChequeItem.CompanyCode = $projection.CompanyCode
                                                  and _ChequeItem.FiscalYear = $projection.FiscalYear
                                                  and _ChequeItem.AccountingDocument = $projection.AccountingDocument
{
    key cast(_JournalEntry.CompanyCode as abap.char( 4 )) as CompanyCode,
    key _JournalEntry.FiscalYear,
    key cast(_JournalEntry.AccountingDocument as abap.char( 10 )) as AccountingDocument,
    _Header.DocumentDate,
    _Header.Customer,
    _Customer.OrganizationBPName1,
    _Customer.StreetName,
    concat_with_space(_Customer.CityName,_Customer.PostalCode,1) as CityPostal,
    _Customer.Country,
    _PaymentsItem,
    _ChequeItem
}
