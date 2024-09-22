// Caution:
// --------
//
// As this CDS view is a very complex view und consumes data from the biggest tables of the S/4 HANA system we are forced to restrict access and give usage recommendations. 
// Please read this information carefully!
// 
// Please be informed that SAP offers various possibilities to build views for a balance calculation. 
// This CDS view is only relevant for you if you need a cumulative balances calculation over a sequence of a time dimension. In all other cases please do not use this view.
// Please check instead if the CDS view I_GLAccountYearToDateBalanceC meets your requirement.
// 
// Do not use this CDS view in the following scenarios:
// - As a CDS modelling data source within your own CDS model
// - Any scenario other than an Analytical Query 
// - In a data extraction scenario
// 
// The following section describes how the balance calculation of this CDS view works and what it was designed for:
// 
// A cumulative balance means that the line items of a period are also assigned to the balances of a future period.
// A possible reporting result can be for example:
//
//   GLAccount FiscalPeriod  DebitAmount CreditAmount  EndingBalanceInCoCodeCrcy
//   400000    001           100                       100   
//   400000    002            50                       150   
//   400000    003           100                       250   
//   400000    004                       75            175   
//   400000    005           300                       475   
//  
// To provide this result, the queries being made against this view must include a time dimension, otherwise a query of the GL Account ending balance at the end of period 005 without a time dimension 
// will result in 1150 (100+150+250-175+475) and thus in wrong balances. 
// Therefore the consumption of the CDS view must only be an analytical query with exception aggregation of type #LAST, since this exception aggregation can return the 475 GL Account ending balance 
// at the end of period 005, while native SQL ( Select GLAccount, sum(EndingBalance)… ) will return 1150.     
// 
// Assigning line items of a period to future periods in order to provide a cumulative balance requires high memory and CPU consumption in the HANA database. 
// Therefore, it is not recommended to use this CDS view as a CDS modelling data source within a different CDS model, but to only use it as an analytical provider as it is documented in the 
// @ObjectModel.supportedCapabilities annotation of the CDS view.

//@VDM.lifecycle.contract.type: #PUBLIC_LOCAL_API
@AbapCatalog.preserveKey: true
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.sqlViewName: 'ZIFIGLBALCUBE'
@EndUserText.label: 'G/L Account Balance - Cube'
@Analytics: { dataCategory: #CUBE } //, dataExtraction.enabled: true }
//@VDM.viewType: #COMPOSITE
//@ObjectModel.representativeKey: 'FiscalPeriodDate'
@AccessControl.authorizationCheck: #CHECK
//@Consumption.dbHints:  ['AGGR_TARGET("ACDOCA")','NO_JOIN_THRU_AGGR']                      
@ClientHandling.algorithm: #SESSION_VARIABLE
@AbapCatalog.buffering.status: #NOT_ALLOWED
@Metadata.ignorePropagatedAnnotations: true 
@Metadata.allowExtensions: true
@ObjectModel.usageType.sizeCategory: #XXL
@ObjectModel.usageType.serviceQuality: #D
@ObjectModel.usageType.dataClass: #MIXED
//@AccessControl.personalData.blocking:#REQUIRED
@ObjectModel.supportedCapabilities: [ #ANALYTICAL_PROVIDER ]
@ObjectModel.modelingPattern: #ANALYTICAL_CUBE 

define view ZI_GLAcctBalanceCube
with parameters
  P_FromPostingDate       : sydate,
  P_ToPostingDate         : sydate      

as select from ZI_GLAcctBalance 
( P_FromPostingDate: $parameters.P_FromPostingDate, P_ToPostingDate: $parameters.P_ToPostingDate ) 
as I_GLAcctBalance

//association [1..1] to E_JournalEntryItem            as _Extension                 on $projection.SourceLedger                   = _Extension.SourceLedger
//                                                                                  and $projection.CompanyCode                   = _Extension.CompanyCode
//                                                                                  and $projection.FiscalYear                    = _Extension.FiscalYear
//                                                                                  and $projection.AccountingDocument            = _Extension.AccountingDocument
//                                                                                  and $projection.LedgerGLLineItem              = _Extension.LedgerGLLineItem

association[0..1] to I_GLAccountInChartOfAccounts   as _CorporateGroupAccount     on $projection.CorporateGroupChartOfAccounts  = _CorporateGroupAccount.ChartOfAccounts and 
                                                                                  $projection.CorporateGroupAccount             = _CorporateGroupAccount.GLAccount 

association[0..1] to I_ChartOfAccounts              as _CorporateGroupChartOfAccounts on $projection.CorporateGroupChartOfAccounts         = _CorporateGroupChartOfAccounts.ChartOfAccounts
//association[1..1] to I_CalendarMonth                as _CalendarMonth              on $projection.CalendarMonth                = _CalendarMonth.CalendarMonth
//association[1..1] to I_CalendarQuarter              as _CalendarQuarter            on $projection.CalendarQuarter              = _CalendarQuarter.CalendarQuarter
//association[1..1] to I_YearMonth                    as _CalendarYearMonth          on $projection.CalendarYearMonth            = _CalendarYearMonth.YearMonth 
//association[0..1] to I_WBSElement                   as _WBSElement                 on $projection.WBSElement                   = _WBSElement.WBSElement 
//association [0..1] to I_WBSElementByExternalID      as _WBSElementExternalID        on  $projection.WBSElementExternalID = _WBSElementExternalID.WBSElementExternalID                                                                                        
//association[0..1] to I_WBSElement                   as _InventorySpclStockWBSElement on $projection.InventorySpclStockWBSElement = _InventorySpclStockWBSElement.WBSElement 
//association[0..1] to I_Project                      as _Project                      on $projection.Project = _Project.Project
//association[0..1] to I_ProjectByInternalKey         as _ProjectInternalID            on $projection.ProjectInternalID = _ProjectInternalID.ProjectInternalID 
//association [0..1] to I_ProjectByExternalID         as _ProjectExternalID            on  $projection.ProjectExternalID   = _ProjectExternalID.ProjectExternalID 
//association [0..1] to I_WBSElementBasicData         as _WBSElementBasicData         on  $projection.WBSElementInternalID = _WBSElementBasicData.WBSElementInternalID  
//association [0..1] to I_ProjectBasicData            as _ProjectBasicData            on  $projection.ProjectInternalID = _ProjectBasicData.ProjectInternalID
association [0..1] to I_FiscalPeriodForVariant      as _FiscalPeriodForVariant  on $projection.FiscalYearVariant = _FiscalPeriodForVariant.FiscalYearVariant and
                                                                                   $projection.LedgerFiscalYear  = _FiscalPeriodForVariant.FiscalYear and
                                                                                   $projection.FiscalPeriod      = _FiscalPeriodForVariant.FiscalPeriod
association [0..1] to I_Order                        as _PartnerOrder_2                 on  $projection.PartnerOrder              = _PartnerOrder_2.OrderID   

association [0..1]  to I_AccountAssignmentType    as _AccountAssignmentType            on  $projection.AccountAssignmentType = _AccountAssignmentType.AccountAssignmentType                                                                                    

{
@ObjectModel.foreignKey.association: '_Ledger'      
key Ledger,
@ObjectModel.foreignKey.association: '_CompanyCode'
key CompanyCode,
@ObjectModel.foreignKey.association: '_FiscalYear'
//@Semantics.fiscal.year: true
key FiscalYear,
@ObjectModel.foreignKey.association: '_SourceLedger'
key SourceLedger,
@ObjectModel.foreignKey.association: '_JournalEntry'
key AccountingDocument,
key LedgerGLLineItem,
@ObjectModel.foreignKey.association: '_GLAccountFlowType'
key GLAccountFlowType,
key concat( _FiscalPeriodForVariant.FiscalPeriodEndDate,FiscalPeriod ) as FiscalPeriodDate,

LedgerFiscalYear,
//GLRecordType,

///////////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_00  Unified Journal Entry: Transaction, Currencies, Units
///////////////////////////////////////////////////////////////////////////////
@ObjectModel.foreignKey.association: '_FinancialTransactionType'
FinancialTransactionType,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_BusinessTransactionType'
BusinessTransactionType,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_ReferenceDocumentType'
ReferenceDocumentType,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_LogicalSystem'
LogicalSystem,
ReferenceDocumentContext,
ReferenceDocument,
ReferenceDocumentItem,
ReferenceDocumentItemGroup,
//I_Glacctbalance.SUBTA,
//@Semantics.booleanIndicator 
IsReversal,
//@Semantics.booleanIndicator 
IsReversed,
//I_Glacctbalance.XTRUEREV,
//I_Glacctbalance.AWTYP_REV,
ReversalReferenceDocumentCntxt,
ReversalReferenceDocument,
//I_Glacctbalance.SUBTA_REV,
//@Semantics.booleanIndicator 
IsSettlement,
//@Semantics.booleanIndicator 
IsSettled,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_PredecessorReferenceDocType'
PredecessorReferenceDocType,
PredecessorReferenceDocCntxt,
PredecessorReferenceDocument,
PredecessorReferenceDocItem,
//I_Glacctbalance.PREC_SUBTA,

@ObjectModel.foreignKey.association: '_GLAccountInChartOfAccounts'      
GLAccount,

@ObjectModel.foreignKey.association: '_GLAccountHierarchy'      
GLAccountHierarchy,

////////////////////////////////////////////////////////////////////////////////////
// .INCLUDE  ACDOC_SI_GL_ACCAS Unified Journal Entry: G/L additional account assignments
////////////////////////////////////////////////////////////////////////////////////
@ObjectModel.foreignKey.association: '_ProfitCenter'      
ProfitCenter,
@ObjectModel.foreignKey.association: '_FunctionalArea'      
FunctionalArea,
@ObjectModel.foreignKey.association: '_BusinessArea'      
BusinessArea,
@ObjectModel.foreignKey.association: '_ControllingArea'      
ControllingArea,
@ObjectModel.foreignKey.association: '_Segment'      
Segment,
@ObjectModel.foreignKey.association: '_PartnerCostCenter'      
PartnerCostCenter,
@ObjectModel.foreignKey.association: '_PartnerProfitCenter'      
PartnerProfitCenter,
@ObjectModel.foreignKey.association: '_PartnerFunctionalArea'      
PartnerFunctionalArea,
@ObjectModel.foreignKey.association: '_PartnerBusinessArea'      
PartnerBusinessArea,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_PartnerCompany'
PartnerCompany,
@ObjectModel.foreignKey.association: '_PartnerSegment'     
PartnerSegment,

/////////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_FIX  Unified Journal Entry: Mandatory fields for G/L
////////////////////////////////////////////////////////////////////////////
@ObjectModel.foreignKey.association: '_DebitCreditCode'      
DebitCreditCode,
@ObjectModel.foreignKey.association: '_FiscalYearVariant'
FiscalYearVariant,
FiscalYearPeriod,
//@ObjectModel.foreignKey.association: '_FiscalCalendarDate'      
//PostingDate,
//I_Glacctbalance.bldat,
@ObjectModel.foreignKey.association: '_AccountingDocumentType'      
AccountingDocumentType,
//I_Glacctbalance.buzei,
AssignmentReference,
@ObjectModel.foreignKey.association: '_PostingKey'      
PostingKey,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_AccountingDocumentCategory'
AccountingDocumentCategory,
TransactionTypeDetermination,
SubLedgerAcctLineItemType,
AccountingDocCreatedByUser,
//I_Glacctbalance.timestamp,
@ObjectModel.foreignKey.association: '_EliminationProfitCenter'      
EliminationProfitCenter,
OriginObjectType,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_GLAccountType'
GLAccountType,
@ObjectModel.foreignKey.association: '_ChartOfAccounts'      
ChartOfAccounts,
@ObjectModel.foreignKey.association: '_AlternativeGLAccount'      
AlternativeGLAccount,
@ObjectModel.foreignKey.association: '_CountryChartOfAccounts'
CountryChartOfAccounts,

///////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_GEN  Unified Journal Entry: Fields for several subledgers
//////////////////////////////////////////////////////////////////////////
InvoiceReference,
InvoiceReferenceFiscalYear,
FollowOnDocumentType,
InvoiceItemReference,
ReferencePurchaseOrderCategory,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PurchasingDocument'
PurchasingDocument,
PurchasingDocumentItem,
AccountAssignmentNumber,
@Semantics.text: true
DocumentItemText,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'Product'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'Product'
//@ObjectModel.foreignKey.association: '_Material'      
Material,
@ObjectModel.foreignKey.association: '_Product'
Product, 
@ObjectModel.foreignKey.association: '_Plant'      
Plant,
@ObjectModel.foreignKey.association: '_Supplier'      
Supplier,
@ObjectModel.foreignKey.association: '_Customer'      
Customer,

/////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_FI  Unified Journal Entry: Fields for FI subledgers
/////////////////////////////////////////////////////////////////////////
@ObjectModel.foreignKey.association: '_FinancialAccountType'      
FinancialAccountType,
@ObjectModel.foreignKey.association: '_SpecialGLCode'
SpecialGLCode,
TaxCode,
@ObjectModel.foreignKey.association: '_HouseBank'
HouseBank,
//@ObjectModel.foreignKey.association: '_HouseBankAccount'
HouseBankAccount,
//@Semantics.booleanIndicator 
IsOpenItemManaged,
//I_Glacctbalance.augdt,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'ClearingJournalEntry'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'ClearingJournalEntry'      
//@ObjectModel.foreignKey.association: '_ClearingAccountingDocument'
ClearingAccountingDocument,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'ClearingJournalEntryFiscalYear'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'ClearingJournalEntryFiscalYear'
ClearingDocFiscalYear,
@ObjectModel.foreignKey.association: '_ClearingJrnlEntryFiscalYear'
ClearingJournalEntryFiscalYear,
@ObjectModel.foreignKey.association: '_ClearingJournalEntry'
ClearingJournalEntry, 
//IsCleared,


/////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_FAA  Unified Journal Entry: Fields for Asset Accounting
/////////////////////////////////////////////////////////////////////////
AssetDepreciationArea,
@ObjectModel.foreignKey.association: '_MasterFixedAsset'
MasterFixedAsset,
@ObjectModel.foreignKey.association: '_FixedAsset'
FixedAsset,
AssetValueDate,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_AssetTransactionType'
AssetTransactionType,
AssetAcctTransClassfctn,
DepreciationFiscalPeriod,
@ObjectModel.foreignKey.association: '_GroupMasterFixedAsset'
GroupMasterFixedAsset,
@ObjectModel.foreignKey.association: '_GroupFixedAsset'
GroupFixedAsset,
//I_Glacctbalance.settlement_rule,

//////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_ML Unified Journal Entry: Fields for Material Ledger
//////////////////////////////////////////////////////////////////////////
CostEstimate,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'InvtrySpecialStockValnType_2'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'InvtrySpecialStockValnType_2'          
@ObjectModel.foreignKey.association: '_InventorySpecialStockValnType'
InventorySpecialStockValnType,
@ObjectModel.foreignKey.association: '_InventorySpclStockValnType'      
@Analytics.internalName: #LOCAL
InvtrySpecialStockValnType_2,

//I_Glacctbalance.xobew,
@ObjectModel.foreignKey.association: '_InventorySpecialStockType'
InventorySpecialStockType,
@ObjectModel.foreignKey.association: '_InventorySpclStkSalesDocument'
InventorySpclStkSalesDocument,
@ObjectModel.foreignKey.association: '_InventorySpclStkSalesDocItm'
InventorySpclStkSalesDocItm,
//@ObjectModel.foreignKey.association: '_InvtrySpclStockWBSElmntIntID'
InvtrySpclStockWBSElmntIntID,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_InvtrySpclStockWBSElmntExtID'
//InvtrySpclStockWBSElmntExtID,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'InvtrySpclStockWBSElmntExtID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'InvtrySpclStockWBSElmntExtID'
//@ObjectModel.foreignKey.association: '_InventorySpclStockWBSElement'
//cast(_InvtrySpclStockWBSElmntIntID.WBSElement as mlmat_ps_posid preserving type ) as InventorySpclStockWBSElement,
@ObjectModel.foreignKey.association: '_InventorySpecialStockSupplier'      
InventorySpecialStockSupplier,
@ObjectModel.foreignKey.association: '_InventoryValuationType'
InventoryValuationType,
//@ObjectModel.foreignKey.association: '_Purreqvaluationarea'
ValuationArea,

////////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_CFIN   Unified Journal Entry: Fields for Central Finance
//////////////////////////////////////////////////////////////////////////////
SenderCompanyCode,
SenderGLAccount,
SenderAccountAssignment,
SenderAccountAssignmentType,

////////////////////////////////////////////////////////////////////////////
//  .INCLUDE  ACDOC_SI_CO  Unified Journal Entry: CO fields
///////////////////////////////////////////////////////////////////////////
//UtilsProfileConstcyChkGrp,
//ControllingDebitCreditCode,
ControllingObjectDebitType,
//@Semantics.booleanIndicator 
QuantityIsIncomplete,
@ObjectModel.foreignKey.association: '_OffsettingAccountWithBP'
OffsettingAccount,
@ObjectModel.foreignKey.association: '_OffsettingAccountType'
OffsettingAccountType,
@ObjectModel.foreignKey.association: '_OffsettingChartOfAccounts'
OffsettingChartOfAccounts,
//@Semantics.booleanIndicator 
LineItemIsCompleted,
PersonnelNumber,
@ObjectModel.foreignKey.association: '_ControllingObjectClass'
ControllingObjectClass,
@ObjectModel.foreignKey.association: '_PartnerCompanyCode'
PartnerCompanyCode,
@ObjectModel.foreignKey.association: '_PartnerControllingObjectClass'
PartnerControllingObjectClass,
//I_Glacctbalance.aufnr_org,
@ObjectModel.foreignKey.association: '_OriginCostCenter'
OriginCostCenter,
@ObjectModel.foreignKey.association: '_OriginCostCtrActivityType'
OriginCostCtrActivityType,
OriginProduct,
VarianceOriginGLAccount,
AccountAssignment,
@Analytics.internalName: #LOCAL    
@ObjectModel.foreignKey.association: '_AccountAssignmentType'
AccountAssignmentType,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_ProjectNetwork'
ProjectNetwork,
RelatedNetworkActivity,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_BusinessProcess'
BusinessProcess,
CostObject,
//I_Glacctbalance.bemot,
CustomerServiceNotification,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_OperatingConcern'
OperatingConcern,
PartnerAccountAssignment,
PartnerAccountAssignmentType,
PartnerCostCtrActivityType,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerOrder'
@ObjectModel.foreignKey.association: '_PartnerOrder_2'
PartnerOrder,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_PartnerOrderCategory'
PartnerOrderCategory,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerWBSElement'
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'PartnerWBSElementExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'PartnerWBSElementExternalID'
PartnerWBSElement,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerProject'
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'PartnerProjectExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'PartnerProjectExternalID'
PartnerProject,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_PartnerSalesDocument'
PartnerSalesDocument,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_PartnerSalesDocumentItem'
PartnerSalesDocumentItem,
PartnerProjectNetwork,
PartnerProjectNetworkActivity,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerBusinessProcess'
PartnerBusinessProcess,
PartnerCostObject,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_ServiceDocumentType'
ServiceDocumentType,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_ServiceDocument'
ServiceDocument,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_ServiceDocumentItem'
ServiceDocumentItem,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PartnerServiceDocumentType'
PartnerServiceDocumentType,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PartnerServiceDocument'
PartnerServiceDocument,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PartnerServiceDocumentItem'
PartnerServiceDocumentItem,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_ServiceContractType'
ServiceContractType,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_ServiceContract'
ServiceContract,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_ServiceContractItem'
ServiceContractItem,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_TimeSheetOvertimeCat'
TimeSheetOvertimeCategory,   
//////////////////////////////////////////////////////////////////////
//  .INCLUDE  ACDOC_SI_COPA  Unified Journal Entry: CO-PA fields
//////////////////////////////////////////////////////////////////////
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_BillingDocumentType'
BillingDocumentType,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_SalesOrganization'
SalesOrganization,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_DistributionChannel'
DistributionChannel,
OrganizationDivision,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'SoldProduct'      
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'SoldProduct'
SoldMaterial,
@ObjectModel.foreignKey.association: '_SoldProduct'
SoldProduct, 
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'SoldProductGroup'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'SoldProductGroup'
//@ObjectModel.foreignKey.association: '_MaterialGroup'      
MaterialGroup,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_SoldProductGroup_2'
SoldProductGroup,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'SoldProductGroup'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'SoldProductGroup'
//@ObjectModel.foreignKey.association: '_ProductGroup'
ProductGroup, 
@ObjectModel.foreignKey.association: '_CustomerGroup'      
CustomerGroup,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_CustomerSupplierCountry'      
CustomerSupplierCountry,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_CustomerSupplierIndustry'      
CustomerSupplierIndustry,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_FinServicesProductGroup'      
FinancialServicesProductGroup,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_FinancialServicesBranch'      
FinancialServicesBranch,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_FinancialDataSource'      
FinancialDataSource,

//////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_PS  Unified Journal Entry: Fields for Public Sector
/////////////////////////////////////////////////////////////////////
//I_Glacctbalance.re_bukrs,
//I_Glacctbalance.re_account,

///////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_JVA  Unified Journal Entry: Fields for Joint Venture Accounting
///////////////////////////////////////////////////////////////////////
JointVenture,
JointVentureEquityGroup,
JointVentureCostRecoveryCode,
//I_Glacctbalance.vptnr,
//I_Glacctbalance.btype,
JointVentureEquityType,
//I_Glacctbalance.prodper,

///////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_RE STRU  0 0 Unified Journal Entry: Fields for Real Estate
///////////////////////////////////////////////////////////////////////
//I_Glacctbalance.swenr,
//I_Glacctbalance.sgenr,
//I_Glacctbalance.sgrnr,
//I_Glacctbalance.smenr,
//I_Glacctbalance.recnnr,
//I_Glacctbalance.snksl,
//I_Glacctbalance.sempsl,
SettlementReferenceDate,
//I_Glacctbalance.pswenr,
//I_Glacctbalance.psgenr,
//I_Glacctbalance.psgrnr,
//I_Glacctbalance.psmenr,
//I_Glacctbalance.precnnr,
//I_Glacctbalance.psnksl,
//I_Glacctbalance.psempsl,
//I_Glacctbalance.pdabrz,


@ObjectModel.foreignKey.association: '_CostCenter'      
CostCenter,
CostCtrActivityType,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_Order'
OrderID,
@ObjectModel.foreignKey.association: '_OrderCategory'
OrderCategory,
//@ObjectModel.foreignKey.association: '_WBSElementInternalID'
WBSElementInternalID,
//@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_WBSElementExternalID'
//WBSElementExternalID,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'WBSElementExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'WBSElementExternalID'
//@ObjectModel.foreignKey.association: '_WBSElement'      
//cast( WBSElement as fis_wbs preserving type ) as WBSElement,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerWBSElementBasicData'
PartnerWBSElementInternalID,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerWBSElementExternalID'
//PartnerWBSElementExternalID,
//@ObjectModel.foreignKey.association: '_Project'   
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    'ProjectExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'ProjectExternalID'   
//cast(Project as fis_project preserving type ) as Project, 
//@ObjectModel.foreignKey.association: '_ProjectInternalID'      
I_GLAcctBalance.ProjectInternalID,
//@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_ProjectExternalID'      
//I_GLAcctBalance.ProjectExternalID,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerProjectBasicData'  
I_GLAcctBalance.PartnerProjectInternalID,
//@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerProjectExternalID'  
//I_GLAcctBalance.PartnerProjectExternalID,
@Analytics.internalName: #LOCAL 
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'SalesDocument'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'SalesDocument' 
@ObjectModel.foreignKey.association: '_SalesOrder'
SalesOrder,
@Analytics.internalName: #LOCAL 
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   'SalesDocumentItem'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: 'SalesDocumentItem'   
@ObjectModel.foreignKey.association: '_SalesOrderItem'
SalesOrderItem,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_SalesDocument'
SalesDocument,
@Analytics.internalName: #LOCAL 
@ObjectModel.foreignKey.association: '_SalesDocumentItem'
SalesDocumentItem,

ClearingDate,

@ObjectModel.foreignKey.association: '_ConsolidationUnit'      
ConsolidationUnit,
@ObjectModel.foreignKey.association: '_PartnerConsolidationUnit'  
PartnerConsolidationUnit,
@ObjectModel.foreignKey.association: '_Company'  
Company, 
@ObjectModel.foreignKey.association: '_ConsolidationChartOfAccounts' 
ConsolidationChartOfAccounts,
//@ObjectModel.foreignKey.association: '_CnsldtnFinancialStatementItem' 
CnsldtnFinancialStatementItem,
@ObjectModel.foreignKey.association: '_CnsldtnSubitemCategory' 
CnsldtnSubitemCategory,
@ObjectModel.foreignKey.association: '_CnsldtnSubitem' 
CnsldtnSubitem,  
@ObjectModel.foreignKey.association: '_CorporateGroupChartOfAccounts' 
_ChartOfAccounts.CorporateGroupChartOfAccounts as CorporateGroupChartOfAccounts,
@ObjectModel.foreignKey.association: '_CorporateGroupAccount'      
_GLAccountInChartOfAccounts.CorporateGroupAccount as CorporateGroupAccount,
_GLAccountInChartOfAccounts.IsBalanceSheetAccount,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_BalanceTransactionCurrency'      
BalanceTransactionCurrency,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} } AmountInBalanceTransacCrcy,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_TransactionCurrency'      
TransactionCurrency,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} } AmountInTransactionCurrency,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_CompanyCodeCurrency'      
CompanyCodeCurrency,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } AmountInCompanyCodeCurrency,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_GlobalCurrency'      
GlobalCurrency,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} } AmountInGlobalCurrency,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FunctionalCurrency'      
FunctionalCurrency,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } AmountInFunctionalCurrency,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency1'      
FreeDefinedCurrency1,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} } AmountInFreeDefinedCurrency1,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency2'      
FreeDefinedCurrency2,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} } AmountInFreeDefinedCurrency2,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency3'      
FreeDefinedCurrency3,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} } AmountInFreeDefinedCurrency3,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency4'      
FreeDefinedCurrency4,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} } AmountInFreeDefinedCurrency4,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency5'      
FreeDefinedCurrency5,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} } AmountInFreeDefinedCurrency5,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency6'      
FreeDefinedCurrency6,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} } AmountInFreeDefinedCurrency6,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency7'      
FreeDefinedCurrency7,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} } AmountInFreeDefinedCurrency7,

@Semantics.currencyCode:true
@ObjectModel.foreignKey.association: '_FreeDefinedCurrency8'      
FreeDefinedCurrency8,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} } AmountInFreeDefinedCurrency8,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } 
DebitAmountInCoCodeCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } 
CreditAmountInCoCodeCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} } 
DebitAmountInTransCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} } 
CreditAmountInTransCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} } 
DebitAmountInBalanceTransCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} } 
CreditAmountInBalanceTransCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} } 
DebitAmountInGlobalCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} } 
CreditAmountInGlobalCrcy,


@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
DebitAmountInFunctionalCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
CreditAmountInFunctionalCrcy,


@DefaultAggregation:#SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} } 
DebitAmountInFreeDefinedCrcy1,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} } 
CreditAmountInFreeDefinedCrcy1,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} } 
DebitAmountInFreeDefinedCrcy2,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} } 
CreditAmountInFreeDefinedCrcy2,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} } 
DebitAmountInFreeDefinedCrcy3,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} } 
CreditAmountInFreeDefinedCrcy3,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} } 
DebitAmountInFreeDefinedCrcy4,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} } 
CreditAmountInFreeDefinedCrcy4,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} } 
DebitAmountInFreeDefinedCrcy5,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} } 
CreditAmountInFreeDefinedCrcy5,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} } 
DebitAmountInFreeDefinedCrcy6,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} } 
CreditAmountInFreeDefinedCrcy6,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} } 
DebitAmountInFreeDefinedCrcy7,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} } 
CreditAmountInFreeDefinedCrcy7,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} } 
DebitAmountInFreeDefinedCrcy8,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} } 
CreditAmountInFreeDefinedCrcy8,

FiscalPeriod,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} } 
EndingBalanceAmtInCoCodeCrcy,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} } 
EndingBalanceAmtInTransCrcy,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} } 
EndingBalanceAmtInBalTransCrcy,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'GlobalCurrency'} } 
EndingBalanceAmtInGlobalCrcy,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
EndingBalanceAmtInFuncnlCrcy,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency1'} } 
EndingBalAmtInFreeDfndCrcy1,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency2'} } 
EndingBalAmtInFreeDfndCrcy2,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency3'} } 
EndingBalAmtInFreeDfndCrcy3,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency4'} } 
EndingBalAmtInFreeDfndCrcy4,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency5'} } 
EndingBalAmtInFreeDfndCrcy5,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency6'} } 
EndingBalAmtInFreeDfndCrcy6,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency7'} } 
EndingBalAmtInFreeDfndCrcy7,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FreeDefinedCurrency8'} } 
EndingBalAmtInFreeDfndCrcy8,

AccrualObjectType,
AccrualObject,
AccrualSubobject,
AccrualItemType,
@Analytics.internalName: #LOCAL
AccrualObjectLogicalSystem,
@Analytics.internalName: #LOCAL
AccrualReferenceObject,
@Analytics.internalName: #LOCAL
AccrualValueDate,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_CashLedgerCompanyCode'
CashLedgerCompanyCode,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_CashLedgerAccount'
CashLedgerAccount,

@ObjectModel.foreignKey.association: '_FinancialManagementArea'
@Analytics.internalName: #LOCAL 
FinancialManagementArea,
@Analytics.internalName: #LOCAL
//@ObjectModel.foreignKey.association: '_FundsCenter'
FundsCenter,
@Analytics.internalName: #LOCAL
//@ObjectModel.foreignKey.association: '_FundedProgram'
FundedProgram,

//@ObjectModel.foreignKey.association: '_Fund'
@Analytics.internalName: #LOCAL 
Fund,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_Grant'
GrantID,

//@ObjectModel.foreignKey.association: '_BudgetPeriod'
@Analytics.internalName: #LOCAL 
BudgetPeriod,

//@ObjectModel.foreignKey.association: '_PartnerFund'
@Analytics.internalName: #LOCAL 
PartnerFund,
@Analytics.internalName: #LOCAL 
//@ObjectModel.foreignKey.association: '_PartnerGrant'
PartnerGrant,
@Analytics.internalName: #LOCAL
//@ObjectModel.foreignKey.association: '_PartnerBudgetPeriod'
PartnerBudgetPeriod,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetAccount'
PubSecBudgetAccount,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetAccountCoCode'
PubSecBudgetAccountCoCode,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetCnsmpnDate'
PubSecBudgetCnsmpnDate,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetCnsmpnFsclPeriod'
PubSecBudgetCnsmpnFsclPeriod,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetCnsmpnFsclYear'
PubSecBudgetCnsmpnFsclYear,
@Analytics.internalName: #LOCAL
PubSecBudgetIsRelevant,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetCnsmpnType'
PubSecBudgetCnsmpnType,
@Analytics.internalName: #LOCAL
@ObjectModel.foreignKey.association: '_PubSecBudgetCnsmpnAmtType'
PubSecBudgetCnsmpnAmtType,

//FlowOfFundsLedgerFiscalYear,

IsStatisticalCostCenter,
IsStatisticalOrder,
IsStatisticalSalesDocument,
WBSIsStatisticalWBSElement,

//_CalendarDate.CalendarYear as CalendarYear,
//@ObjectModel.foreignKey.association: '_CalendarQuarter'
//_CalendarDate.CalendarQuarter as CalendarQuarter,
//_CalendarDate.YearQuarter as CalendarYearQuarter,
//@ObjectModel.foreignKey.association: '_CalendarMonth'
//_CalendarDate.CalendarMonth as CalendarMonth,
//@ObjectModel.foreignKey.association: '_CalendarYearMonth'
//_CalendarDate.YearMonth as CalendarYearMonth,
//_CalendarDate.CalendarWeek as CalendarWeek,
//_CalendarDate.YearWeek as CalendarYearWeek,
_FiscalCalendarDate.FiscalQuarter as FiscalQuarter,
_FiscalCalendarDate.FiscalWeek as FiscalWeek,
_FiscalCalendarDate.FiscalYearQuarter as FiscalYearQuarter,
_FiscalCalendarDate.FiscalYearWeek as FiscalYearWeek,
_FiscalPeriodForVariant.FiscalPeriodStartDate,
_FiscalPeriodForVariant.FiscalPeriodEndDate,

_CompanyCode,
_JournalEntry,
_FiscalYear,
_ControllingArea,
_BalanceTransactionCurrency,
_TransactionCurrency,
_CompanyCodeCurrency,
_GlobalCurrency,
_FunctionalCurrency,
_FreeDefinedCurrency1,
_FreeDefinedCurrency2,
_FreeDefinedCurrency3,
_FreeDefinedCurrency4,
_FreeDefinedCurrency5,
_FreeDefinedCurrency6,
_FreeDefinedCurrency7,
_FreeDefinedCurrency8,
_Segment,
_PartnerSegment,
_ProfitCenter,
_CurrentProfitCenter,
_PartnerProfitCenter,
_CostCenter,
_CurrentCostCenter,
_PartnerCostCenter,
_AccountAssignmentType,
_BusinessArea,
_PartnerBusinessArea,
_FunctionalArea,
_PartnerFunctionalArea,
_GLAccountInChartOfAccounts,
_GLAccountHierarchy,
_ChartOfAccounts,
_GLAccountInCompanyCode,
_AccountingDocumentType,
_FinancialAccountType,
_DebitCreditCode, 
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_Product'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_Product'
//_Material,
_Product,
_Plant,
_Ledger,
_CustomerGroup,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_SoldProductGroup_2'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_SoldProductGroup_2'
//_MaterialGroup,
_SoldProductGroup_2,
//_ProductGroup_2, 
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_ProductGroup_2'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_ProductGroup_2'
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_SoldProductGroup_2'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_SoldProductGroup_2'
//_ProductGroup,
_Customer,
_Supplier,
//_CalendarDate,
_SourceLedger,  
_PostingKey,
_EliminationProfitCenter,
_InventorySpecialStockSupplier,
_AlternativeGLAccount,  
_CorporateGroupAccount,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_SalesDocument'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_SalesDocument'
_SalesOrder,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_SalesDocumentItem'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_SalesDocumentItem'
_SalesOrderItem,
_SalesDocument,
_SalesDocumentItem,
_InternalOrder,
_Order,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_PersonWorkAgreement_1'
//@VDM.lifecycle.status:     #DEPRECATED
//@VDM.lifecycle.successor:  '_PersonWorkAgreement_1'
//_Employment,
_PersonWorkAgreement_1,
_FinancialTransactionType,
_BusinessTransactionType,
_ReferenceDocumentType,
_PredecessorReferenceDocType,
_PartnerCompanyCode,
_AccountingDocumentCategory,
_User,
_GLAccountType,
_OffsettingAccountType,
_OffsettingChartOfAccounts,
_OffsettingAccount,
_OffsettingAccountWithBP,
_SenderGLAccount,
_CountryChartOfAccounts,
//_PurchasingDocument,
//_PurchasingDocumentItem,
_SpecialGLCode,
//_TaxCode,
_HouseBank,
_ClearingJrnlEntryFiscalYear,
_ClearingJournalEntry,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_ClearingJournalEntry'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_ClearingJournalEntry'
//_ClearingAccountingDocument,
_MasterFixedAsset,
_FixedAsset,
_GroupMasterFixedAsset,
_GroupFixedAsset,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_InventorySpclStockValnType'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_InventorySpclStockValnType'
_InventorySpecialStockValnType,
_InventorySpclStockValnType,
_InventorySpecialStockType,
_InventorySpclStkSalesDocument,
_InventorySpclStkSalesDocItm,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_InvtrySpclStkWBSElmntBscData'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor:  '_InvtrySpclStkWBSElmntBscData'
//_InvtrySpclStockWBSElmntIntID,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_InvtrySpclStockWBSElmntExtID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor:  '_InvtrySpclStockWBSElmntExtID'
//_InventorySpclStockWBSElement,
//_InvtrySpclStkWBSElmntBscData,
_InventoryValuationType,
_ControllingObjectClass,
_PartnerControllingObjectClass,
_OriginCostCenter,
_CostCtrActivityType,
_OriginCostCtrActivityType,
_OrderCategory,
//_RelatedNetworkActivity,
//_PartnerProjectNetworkActivity,
      
//_BusinessProcess,
_PartnerCostCtrActivityType,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   '_PartnerOrder_2'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_PartnerOrder_2'
_PartnerOrder,
_PartnerOrder_2,
_PartnerOrderCategory,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   '_PartnerWBSElementExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_PartnerWBSElementExternalID'
//_PartnerWBSElement,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   '_PartnerProjectExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_PartnerProjectExternalID'
//_PartnerProject,
_PartnerSalesDocument,
_PartnerSalesDocumentItem,
//_PartnerBusinessProcess,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   '_WBSElementExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_WBSElementExternalID'
//_WBSElement,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   '_WBSElementBasicData'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_WBSElementBasicData'
//_WBSElementInternalID,
//_WBSElementExternalID,    
//_WBSElementBasicData,                   
_BillingDocumentType,
      
_SalesOrganization,
_DistributionChannel,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_SoldProduct'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_SoldProduct'  
//_SoldMaterial,
_SoldProduct,    
      
      
_MovementCategory,
_AssetTransactionType,
      
      
//_HouseBankAccount,
      
//_LogicalSystem,
      
_OperatingConcern,
      
_PartnerCompany,
      
//_ProjectNetwork,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:   '_ProjectExternalID'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_ProjectExternalID'
//_Project,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_ProjectBasicData'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_ProjectBasicData'
//_ProjectInternalID,

//_ProjectExternalID,
 
// _ProjectBasicData,              
      
//_PurReqValuationArea,

_FiscalCalendarDate,

_CorporateGroupChartOfAccounts,

_FiscalYearVariant,

//_CalendarMonth,

//_CalendarQuarter,

//_CalendarYearMonth,

_ServiceDocumentType,

_ServiceDocument,

_ServiceDocumentItem,

_PartnerServiceDocumentType,

_PartnerServiceDocument,

_PartnerServiceDocumentItem,
_ServiceContract,
_ServiceContractType,
_ServiceContractItem,
_TimeSheetOvertimeCat,
//_PartnerProjectExternalID,
//_PartnerProjctExtrnalIDText,
//_PartnerWBSElementExternalID,
//_PartnerWBSElemntExtrnalIDText,
_PartnerProjectBasicData,
_PartnerProjectBasicDataText,
_PartnerWBSElementBasicData,
_PartnerWBSElmntBasicDataText,
//@API.element.releaseState: #DEPRECATED
//@API.element.successor:    '_InvtrySpclStkWBSElmntBscData'
//@VDM.lifecycle.status:    #DEPRECATED
//@VDM.lifecycle.successor: '_InvtrySpclStkWBSElmntBscData'  
//_InvtrySpclStockWBSElmntBD,
//_InvtrySpclStockWBSElmntExtID,

_AccrualObjectType,
//_AccrualObject,
//_AccrualSubobject,
_AccrualItemType, 

_GLAccountFlowType,
_FiscalPeriodForVariant,
_CashLedgerCompanyCode,
_CashLedgerAccount,
_FinancialManagementArea,
_FundsCenter,
_FundedProgram,
_Fund,
//_Grant,
_BudgetPeriod,
_PartnerFund,
//_PartnerGrant,
_PartnerBudgetPeriod,
_PubSecBudgetAccountCoCode,
_PubSecBudgetAccount,
_PubSecBudgetCnsmpnDate,
_PubSecBudgetCnsmpnFsclPeriod,
_PubSecBudgetCnsmpnFsclYear,
_PubSecBudgetCnsmpnType,
_PubSecBudgetCnsmpnAmtType,   
  
_ConsolidationUnit,
_PartnerConsolidationUnit,
_Company,
_ConsolidationChartOfAccounts,
_CnsldtnFinancialStatementItem,
_CnsldtnSubitemCategory,
_CnsldtnSubitem,

_LedgerCompanyCodeCrcyRoles,
//_CustomerCompany,
//_SupplierCompany,

_FinServicesProductGroup, 
_FinancialServicesBranch, 
_FinancialDataSource,     
_CustomerSupplierIndustry,
_CustomerSupplierCountry, 

// Just for Authorization Check!!! DO NOT USE!!! WILL BE DEPRECATED!!!
      GLAccountAuthorizationGroup,
      SupplierBasicAuthorizationGrp,
      CustomerBasicAuthorizationGrp,
      AcctgDocTypeAuthorizationGroup,
      OrderType,
      SalesOrderType,
      AssetClass   

}   
