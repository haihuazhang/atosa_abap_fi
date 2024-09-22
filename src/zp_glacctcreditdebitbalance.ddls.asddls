@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZPFIGLACCTCDBAL'
//@VDM.viewType: #COMPOSITE
//@VDM.private: true
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.usageType.sizeCategory: #XXL
@ObjectModel.usageType.dataClass:  #MIXED
@ObjectModel.usageType.serviceQuality: #D
@AbapCatalog.buffering.status: #NOT_ALLOWED
//@AccessControl.personalData.blocking: #BLOCKED_DATA_EXCLUDED 
@Metadata.ignorePropagatedAnnotations: true
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZP_GLAcctCreditDebitBalance
with parameters
  P_FromPostingDate       : sydate,
  P_ToPostingDate         : sydate  
as select from I_GLAccountLineItem 
//left outer to one join I_TrialBalanceUserParam
//  on I_TrialBalanceUserParam.UserID = $session.user 
//left outer to one join I_YrEndClsgPostingUserParam
//  on I_YrEndClsgPostingUserParam.UserID = $session.user
  inner join I_FiscalPeriodForVariant
on I_GLAccountLineItem.FiscalYearVariant = I_FiscalPeriodForVariant.FiscalYearVariant and
   I_GLAccountLineItem.LedgerFiscalYear = I_FiscalPeriodForVariant.FiscalYear and 
   I_GLAccountLineItem.FiscalPeriod = I_FiscalPeriodForVariant.FiscalPeriod 

//association [0..1] to I_WBSElementByExternalID       as _WBSElementExternalID        on  $projection.WBSElementExternalID = _WBSElementExternalID.WBSElementExternalID
//association [0..1] to I_WBSElementByExternalID       as _WBSElementExternalIDText    on  $projection.WBSElementExternalID = _WBSElementExternalIDText.WBSElementExternalID

//association [0..1] to I_ProjectBasicData             as _ProjectBasicData              on  $projection.ProjectInternalID = _ProjectBasicData.ProjectInternalID
//association [0..1] to I_ProjectBasicData             as _ProjectBasicDataText          on  $projection.ProjectInternalID = _ProjectBasicDataText.ProjectInternalID
//association [0..1] to I_ProjectBasicData             as _PartnerProjectBasicData       on  $projection.PartnerProjectInternalID = _PartnerProjectBasicData.ProjectInternalID
//association [0..1] to I_ProjectBasicData             as _PartnerProjectBasicDataText   on  $projection.PartnerProjectInternalID = _PartnerProjectBasicDataText.ProjectInternalID
    
//association [0..1] to I_WBSElementBasicData          as _WBSElementBasicData           on  $projection.WBSElementInternalID = _WBSElementBasicData.WBSElementInternalID  
//association [0..1] to I_WBSElementBasicData          as _WBSElementBasicDataText       on  $projection.WBSElementInternalID = _WBSElementBasicDataText.WBSElementInternalID 
//association [0..1] to I_WBSElementBasicData          as _PartnerWBSElementBasicData    on  $projection.PartnerWBSElementInternalID = _PartnerWBSElementBasicData.WBSElementInternalID
//association [0..1] to I_WBSElementBasicData          as _PartnerWBSElmntBasicDataText  on  $projection.PartnerWBSElementInternalID = _PartnerWBSElmntBasicDataText.WBSElementInternalID

//association [0..1] to I_WBSElementByExternalID       as _PartnerWBSElementExternalID        on  $projection.PartnerWBSElementExternalID = _PartnerWBSElementExternalID.WBSElementExternalID
//association [0..1] to I_WBSElementByExternalID       as _PartnerWBSElemntExtrnalIDText    on  $projection.PartnerWBSElementExternalID = _PartnerWBSElemntExtrnalIDText.WBSElementExternalID
//
//association [0..1] to I_ProjectByExternalID       as _PartnerProjectExternalID        on  $projection.PartnerProjectExternalID   = _PartnerProjectExternalID.ProjectExternalID  
//association [0..1] to I_ProjectByExternalID       as _PartnerProjctExtrnalIDText    on  $projection.PartnerProjectExternalID   = _PartnerProjctExtrnalIDText.ProjectExternalID 

//association [0..1] to I_ProjectByExternalID         as _ProjectExternalID             on  $projection.ProjectExternalID = _ProjectExternalID.ProjectExternalID
//association [0..1] to I_ProjectByExternalID         as _ProjectExternalIDText         on  $projection.ProjectExternalID = _ProjectExternalIDText.ProjectExternalID


//association [0..1] to I_WBSElementBasicData          as _InvtrySpclStockWBSElmntBD   on  $projection.InvtrySpclStockWBSElmntIntID = _InvtrySpclStockWBSElmntBD.WBSElementInternalID
//association [0..1] to I_WBSElementByExternalID       as _InvtrySpclStockWBSElmntExtID  on  $projection.InvtrySpclStockWBSElmntExtID = _InvtrySpclStockWBSElmntExtID.WBSElementExternalID
{
    //I_GLAccountLineItem 
    key I_GLAccountLineItem.SourceLedger, 
    key I_GLAccountLineItem.CompanyCode, 
    key I_GLAccountLineItem.FiscalYear, 
    key I_GLAccountLineItem.AccountingDocument, 
    key I_GLAccountLineItem.LedgerGLLineItem, 
    key I_GLAccountLineItem.Ledger, 
    I_GLAccountLineItem.LedgerFiscalYear, 
    I_GLAccountLineItem.GLRecordType, 
    I_GLAccountLineItem.ChartOfAccounts, 
    I_GLAccountLineItem.ControllingArea, 
    I_GLAccountLineItem.FinancialTransactionType, 
    I_GLAccountLineItem.BusinessTransactionType, 
    I_GLAccountLineItem.ReferenceDocumentType, 
    I_GLAccountLineItem.LogicalSystem, 
    I_GLAccountLineItem.ReferenceDocumentContext, 
    I_GLAccountLineItem.ReferenceDocument, 
    I_GLAccountLineItem.ReferenceDocumentItem, 
    I_GLAccountLineItem.ReferenceDocumentItemGroup, 
    I_GLAccountLineItem.IsReversal, 
    I_GLAccountLineItem.IsReversed, 
    I_GLAccountLineItem.ReversalReferenceDocumentCntxt, 
    I_GLAccountLineItem.ReversalReferenceDocument, 
    I_GLAccountLineItem.IsSettlement, 
    I_GLAccountLineItem.IsSettled, 
    I_GLAccountLineItem.PredecessorReferenceDocType, 
    I_GLAccountLineItem.PredecessorReferenceDocCntxt, 
    I_GLAccountLineItem.PredecessorReferenceDocument, 
    I_GLAccountLineItem.PredecessorReferenceDocItem, 
    I_GLAccountLineItem.SourceReferenceDocumentType, 
    I_GLAccountLineItem.SourceLogicalSystem, 
    I_GLAccountLineItem.SourceReferenceDocumentCntxt, 
    I_GLAccountLineItem.SourceReferenceDocument, 
    I_GLAccountLineItem.SourceReferenceDocumentItem, 
    I_GLAccountLineItem.SourceReferenceDocSubitem, 
    I_GLAccountLineItem.IsCommitment, 
    I_GLAccountLineItem.JrnlEntryItemObsoleteReason, 
    I_GLAccountLineItem.GLAccount, 
    I_GLAccountLineItem.CostCenter, 
    I_GLAccountLineItem.ProfitCenter, 
    I_GLAccountLineItem.FunctionalArea, 
    I_GLAccountLineItem.BusinessArea, 
    I_GLAccountLineItem.Segment, 
    I_GLAccountLineItem.PartnerCostCenter, 
    I_GLAccountLineItem.PartnerProfitCenter, 
    I_GLAccountLineItem.PartnerFunctionalArea, 
    I_GLAccountLineItem.PartnerBusinessArea, 
    I_GLAccountLineItem.PartnerCompany, 
    I_GLAccountLineItem.PartnerSegment, 
    I_GLAccountLineItem.BalanceTransactionCurrency, 
    I_GLAccountLineItem.AmountInBalanceTransacCrcy, 
    I_GLAccountLineItem.TransactionCurrency, 
    I_GLAccountLineItem.AmountInTransactionCurrency, 
    I_GLAccountLineItem.CompanyCodeCurrency, 
    I_GLAccountLineItem.AmountInCompanyCodeCurrency, 
    I_GLAccountLineItem.GlobalCurrency, 
    I_GLAccountLineItem.AmountInGlobalCurrency, 
    I_GLAccountLineItem.FunctionalCurrency,
    I_GLAccountLineItem.AmountInFunctionalCurrency,
    I_GLAccountLineItem.FreeDefinedCurrency1, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency1, 
    I_GLAccountLineItem.FreeDefinedCurrency2, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency2, 
    I_GLAccountLineItem.FreeDefinedCurrency3, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency3, 
    I_GLAccountLineItem.FreeDefinedCurrency4, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency4, 
    I_GLAccountLineItem.FreeDefinedCurrency5, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency5, 
    I_GLAccountLineItem.FreeDefinedCurrency6, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency6, 
    I_GLAccountLineItem.FreeDefinedCurrency7, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency7, 
    I_GLAccountLineItem.FreeDefinedCurrency8, 
    I_GLAccountLineItem.AmountInFreeDefinedCurrency8, 
    I_GLAccountLineItem.FixedAmountInGlobalCrcy, 
    I_GLAccountLineItem.GrpValnFixedAmtInGlobCrcy, 
    I_GLAccountLineItem.PrftCtrValnFxdAmtInGlobCrcy, 
    I_GLAccountLineItem.TotalPriceVarcInGlobalCrcy, 
    I_GLAccountLineItem.GrpValnTotPrcVarcInGlobCrcy, 
    I_GLAccountLineItem.PrftCtrValnTotPrcVarcInGlbCrcy, 
    I_GLAccountLineItem.FixedPriceVarcInGlobalCrcy, 
    I_GLAccountLineItem.GrpValnFixedPrcVarcInGlobCrcy, 
    I_GLAccountLineItem.PrftCtrValnFxdPrcVarcInGlbCrcy, 
    I_GLAccountLineItem.ControllingObjectCurrency, 
    I_GLAccountLineItem.AmountInObjectCurrency, 
    I_GLAccountLineItem.BaseUnit, 
    I_GLAccountLineItem.Quantity, 
    I_GLAccountLineItem.FixedQuantity, 
    I_GLAccountLineItem.CostSourceUnit, 
    I_GLAccountLineItem.ValuationQuantity, 
    I_GLAccountLineItem.ValuationFixedQuantity, 
    I_GLAccountLineItem.AdditionalQuantity1Unit, 
    I_GLAccountLineItem.AdditionalQuantity1, 
    I_GLAccountLineItem.AdditionalQuantity2Unit, 
    I_GLAccountLineItem.AdditionalQuantity2, 
    I_GLAccountLineItem.AdditionalQuantity3Unit, 
    I_GLAccountLineItem.AdditionalQuantity3, 
    I_GLAccountLineItem.DebitCreditCode, 
    I_GLAccountLineItem.FiscalPeriod, 
    I_GLAccountLineItem.FiscalYearVariant, 
    I_GLAccountLineItem.FiscalYearPeriod, 
    I_GLAccountLineItem.DocumentDate, 
    I_GLAccountLineItem.AccountingDocumentType, 
    I_GLAccountLineItem.AccountingDocumentItem, 
    I_GLAccountLineItem.AssignmentReference, 
    I_GLAccountLineItem.AccountingDocumentCategory, 
    I_GLAccountLineItem.PostingKey, 
    I_GLAccountLineItem.TransactionTypeDetermination, 
    I_GLAccountLineItem.SubLedgerAcctLineItemType, 
    I_GLAccountLineItem.AccountingDocCreatedByUser, 
    I_GLAccountLineItem.LastChangeDateTime, 
    I_GLAccountLineItem.CreationDateTime, 
    I_GLAccountLineItem.CreationDate, 
    I_GLAccountLineItem.EliminationProfitCenter, 
    I_GLAccountLineItem.OriginObjectType, 
    I_GLAccountLineItem.GLAccountType, 
    I_GLAccountLineItem.AlternativeGLAccount, 
    I_GLAccountLineItem.CountryChartOfAccounts, 
    I_GLAccountLineItem.InvoiceReference, 
    I_GLAccountLineItem.InvoiceReferenceFiscalYear, 
    I_GLAccountLineItem.FollowOnDocumentType, 
    I_GLAccountLineItem.InvoiceItemReference, 
    I_GLAccountLineItem.ReferencePurchaseOrderCategory, 
    I_GLAccountLineItem.PurchasingDocument, 
    I_GLAccountLineItem.PurchasingDocumentItem, 
    I_GLAccountLineItem.AccountAssignmentNumber, 
    I_GLAccountLineItem.DocumentItemText, 
//    I_GLAccountLineItem.SalesOrder, 
//    I_GLAccountLineItem.SalesOrderItem, 
    I_GLAccountLineItem.SalesDocument, 
    I_GLAccountLineItem.SalesDocumentItem, 
    I_GLAccountLineItem.Product,
//    I_GLAccountLineItem.Material,

    I_GLAccountLineItem.SoldProduct,
//    I_GLAccountLineItem.SoldMaterial,

    I_GLAccountLineItem.SoldProductGroup,
//    I_GLAccountLineItem.MaterialGroup,

    I_GLAccountLineItem.ProductGroup,
    
    I_GLAccountLineItem.Plant, 
    I_GLAccountLineItem.Supplier, 
    I_GLAccountLineItem.Customer, 
    I_GLAccountLineItem.FinancialAccountType, 
    I_GLAccountLineItem.SpecialGLCode, 
    I_GLAccountLineItem.TaxCode, 
    I_GLAccountLineItem.HouseBank, 
    I_GLAccountLineItem.HouseBankAccount, 
    I_GLAccountLineItem.IsOpenItemManaged, 
    I_GLAccountLineItem.ClearingDate, 
    I_GLAccountLineItem.ClearingJournalEntry, 
    I_GLAccountLineItem.ClearingJournalEntryFiscalYear, 
    I_GLAccountLineItem.AssetDepreciationArea, 
    I_GLAccountLineItem.MasterFixedAsset, 
    I_GLAccountLineItem.FixedAsset, 
    I_GLAccountLineItem.AssetValueDate, 
    I_GLAccountLineItem.AssetTransactionType, 
    I_GLAccountLineItem.AssetAcctTransClassfctn, 
    I_GLAccountLineItem.DepreciationFiscalPeriod, 
    I_GLAccountLineItem.GroupMasterFixedAsset, 
    I_GLAccountLineItem.GroupFixedAsset, 
    I_GLAccountLineItem.CostEstimate, 
    I_GLAccountLineItem.InvtrySpecialStockValnType_2, 
    I_GLAccountLineItem.InventorySpecialStockType, 
    I_GLAccountLineItem.InventorySpclStkSalesDocument, 
    I_GLAccountLineItem.InventorySpclStkSalesDocItm, 
    I_GLAccountLineItem.InvtrySpclStockWBSElmntIntID, 
    //@ObjectModel.foreignKey.association: '_InvtrySpclStockWBSElmntExtID'
    //_InvtrySpclStockWBSElmntBD.WBSElementExternalID as InvtrySpclStockWBSElmntExtID,
//    I_GLAccountLineItem.InventorySpclStockWBSElement, 
    I_GLAccountLineItem.InventorySpecialStockSupplier, 
    I_GLAccountLineItem.InventoryValuationType, 
    I_GLAccountLineItem.ValuationArea, 
    I_GLAccountLineItem.SenderCompanyCode,
    I_GLAccountLineItem.SenderGLAccount, 
    I_GLAccountLineItem.SenderAccountAssignment, 
    I_GLAccountLineItem.SenderAccountAssignmentType, 
    I_GLAccountLineItem.CostOriginGroup, 
    I_GLAccountLineItem.OriginSenderObject, 
    I_GLAccountLineItem.ControllingDebitCreditCode, 
    I_GLAccountLineItem.ControllingObjectDebitType, 
    I_GLAccountLineItem.QuantityIsIncomplete, 
    I_GLAccountLineItem.OffsettingAccount, 
    I_GLAccountLineItem.OffsettingAccountType, 
    I_GLAccountLineItem.OffsettingChartOfAccounts, 
    I_GLAccountLineItem.LineItemIsCompleted, 
    I_GLAccountLineItem.PersonnelNumber, 
    I_GLAccountLineItem.ControllingObjectClass, 
    I_GLAccountLineItem.PartnerCompanyCode, 
    I_GLAccountLineItem.PartnerControllingObjectClass, 
    I_GLAccountLineItem.OriginCostCenter, 
    I_GLAccountLineItem.OriginProfitCenter, 
    I_GLAccountLineItem.OriginCostCtrActivityType, 
    I_GLAccountLineItem.OriginProduct,
    I_GLAccountLineItem.VarianceOriginGLAccount,
    I_GLAccountLineItem.AccountAssignment, 
    I_GLAccountLineItem.AccountAssignmentType, 
    I_GLAccountLineItem.CostCtrActivityType, 
    I_GLAccountLineItem.OrderID, 
    I_GLAccountLineItem.OrderCategory, 
    I_GLAccountLineItem.WBSElementInternalID,
//    @ObjectModel.foreignKey.association: '_PartnerWBSElementBasicData'
    I_GLAccountLineItem.PartnerWBSElementInternalID,
//    @ObjectModel.foreignKey.association: '_WBSElementExternalID'
//    cast( _WBSElementBasicData.WBSElementExternalID as fis_wbsext_no_conv ) as WBSElementExternalID, 
//    @ObjectModel.foreignKey.association: '_PartnerWBSElementExternalID'
//    cast( _PartnerWBSElementBasicData.WBSElementExternalID as fis_partner_wbsext_no_conv ) as PartnerWBSElementExternalID, 
//    I_GLAccountLineItem.WBSElement, 
    I_GLAccountLineItem.ProjectInternalID, 
//    @ObjectModel.foreignKey.association: '_PartnerProjectBasicData'
    I_GLAccountLineItem.PartnerProjectInternalID,
//    cast( _ProjectBasicData.ProjectExternalID  as fis_projectext_no_conv ) as ProjectExternalID,
//    @ObjectModel.foreignKey.association: '_PartnerProjectExternalID'
//    cast( _PartnerProjectBasicData.ProjectExternalID as fis_part_projectext_no_conv ) as PartnerProjectExternalID,
//    I_GLAccountLineItem.Project, 
    I_GLAccountLineItem.OperatingConcern, 
    I_GLAccountLineItem.ProjectNetwork, 
    I_GLAccountLineItem.RelatedNetworkActivity, 
    I_GLAccountLineItem.BusinessProcess, 
    I_GLAccountLineItem.CostObject, 
    I_GLAccountLineItem.CostAnalysisResource, 
    I_GLAccountLineItem.ServiceDocumentType,
    I_GLAccountLineItem.ServiceDocument,
    I_GLAccountLineItem.ServiceDocumentItem,
    I_GLAccountLineItem.ServiceContract,
    I_GLAccountLineItem.ServiceContractType,
    I_GLAccountLineItem.ServiceContractItem,
    I_GLAccountLineItem.PartnerServiceDocumentType,
    I_GLAccountLineItem.PartnerServiceDocument,
    I_GLAccountLineItem.PartnerServiceDocumentItem,
    I_GLAccountLineItem.TimeSheetOvertimeCategory,
    I_GLAccountLineItem.CustomerServiceNotification, 
    I_GLAccountLineItem.PartnerAccountAssignment, 
    I_GLAccountLineItem.PartnerAccountAssignmentType, 
    I_GLAccountLineItem.PartnerCostCtrActivityType, 
//    I_GLAccountLineItem.PartnerOrder, 
    I_GLAccountLineItem.PartnerOrder_2, 
    I_GLAccountLineItem.PartnerOrderCategory, 
//    I_GLAccountLineItem.PartnerWBSElement, 
//    I_GLAccountLineItem.PartnerProject, 
    I_GLAccountLineItem.PartnerSalesDocument, 
    I_GLAccountLineItem.PartnerSalesDocumentItem, 
    I_GLAccountLineItem.PartnerProjectNetwork, 
    I_GLAccountLineItem.PartnerProjectNetworkActivity, 
    I_GLAccountLineItem.PartnerBusinessProcess, 
    I_GLAccountLineItem.PartnerCostObject, 
    I_GLAccountLineItem.BillingDocumentType, 
    I_GLAccountLineItem.SalesOrganization, 
    I_GLAccountLineItem.DistributionChannel, 
    I_GLAccountLineItem.OrganizationDivision, 
    I_GLAccountLineItem.CustomerGroup, 
    I_GLAccountLineItem.CustomerSupplierCountry, 
    I_GLAccountLineItem.CustomerSupplierIndustry, 
    I_GLAccountLineItem.FinancialServicesProductGroup,
    I_GLAccountLineItem.FinancialServicesBranch,
    I_GLAccountLineItem.FinancialDataSource,
    I_GLAccountLineItem.SalesDistrict, 
    I_GLAccountLineItem.BillToParty, 
    I_GLAccountLineItem.ShipToParty, 
    I_GLAccountLineItem.CustomerSupplierCorporateGroup, 
    I_GLAccountLineItem.JointVenture, 
    I_GLAccountLineItem.JointVentureEquityGroup, 
    I_GLAccountLineItem.JointVentureCostRecoveryCode, 
    I_GLAccountLineItem.JointVentureEquityType, 
    I_GLAccountLineItem.SettlementReferenceDate, 
    I_GLAccountLineItem.WorkCenterInternalID, 
    I_GLAccountLineItem.OrderOperation, 
    I_GLAccountLineItem.OrderItem, 
    I_GLAccountLineItem.DebitAmountInCoCodeCrcy, 
    I_GLAccountLineItem.CreditAmountInCoCodeCrcy, 
    I_GLAccountLineItem.DebitAmountInTransCrcy, 
    I_GLAccountLineItem.CreditAmountInTransCrcy, 
    I_GLAccountLineItem.DebitAmountInBalanceTransCrcy, 
    I_GLAccountLineItem.CreditAmountInBalanceTransCrcy, 
    I_GLAccountLineItem.DebitAmountInGlobalCrcy, 
    I_GLAccountLineItem.CreditAmountInGlobalCrcy, 
    I_GLAccountLineItem.DebitAmountInFunctionalCrcy,
    I_GLAccountLineItem.CreditAmountInFunctionalCrcy,
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy1, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy1, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy2, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy2, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy3, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy3, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy4, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy4, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy5, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy5, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy6, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy6, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy7, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy7, 
    I_GLAccountLineItem.DebitAmountInFreeDefinedCrcy8, 
    I_GLAccountLineItem.CreditAmountInFreeDefinedCrcy8, 
    I_GLAccountLineItem.IsStatisticalOrder, 
    I_GLAccountLineItem.IsStatisticalCostCenter, 
    I_GLAccountLineItem.IsStatisticalSalesDocument, 
    I_GLAccountLineItem.WBSIsStatisticalWBSElement, 
    '' as GLAccountAuthorizationGroup, 
    '' as SupplierBasicAuthorizationGrp, 
    '' as CustomerBasicAuthorizationGrp, 
    '' as AcctgDocTypeAuthorizationGroup, 
    '' as OrderType, 
    '' as SalesOrderType,
    I_GLAccountLineItem.AssetClass,
    I_FiscalPeriodForVariant.FiscalPeriodEndDate as PostingDate,
         // Period based reporting 
//    ( case when (I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting is null or I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = '' or I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = 'X') then fiscal_period_end_date 
//         // Daily based reporting and migrated items without posting date
//             when (I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = 'D') and (I_GLAccountLineItem.PostingDate = '00000000') then P_FiscalYearPeriod.fiscal_period_start_date 
//         // Daily based reporting with posting date
//             when (I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = 'D') and (I_GLAccountLineItem.PostingDate <> '00000000') then PostingDate
//         end )
//    as PostingDate,
    //migrated items without posting date (BSTAT = C and MIG_SOURCE = C/U)
//    case when I_GLAccountLineItem.PostingDate = '00000000' then P_FiscalYearPeriod.fiscal_period_start_date
//                                                           else PostingDate
//    end as PostingDate,   
//
//         // Period based reporting 
//    cast( ( case when (I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting is null or I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = '' or I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = 'X') then concat( P_FiscalYearPeriod.fiscal_period_end_date, P_FiscalYearPeriod.fiscal_period  ) 
//         // Daily based reporting and migrated items without posting date
//             when (I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = 'D') and (I_GLAccountLineItem.PostingDate = '00000000') then concat( P_FiscalYearPeriod.fiscal_period_start_date, P_FiscalYearPeriod.fiscal_period  ) 
//         // Daily based reporting with posting date
//             when (I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting = 'D') and (I_GLAccountLineItem.PostingDate <> '00000000') then concat( PostingDate, P_FiscalYearPeriod.fiscal_period  )
//         end )
//    as fis_fiscalperiod_date ) as FiscalPeriodDate,

//    Coalesce( I_TrialBalanceUserParam.IsPeriodBasedBalanceReporting, 'X' )  as IsPeriodBasedBalanceReporting,
    
    I_GLAccountLineItem.AccrualObjectType,
    I_GLAccountLineItem.AccrualObject,
    I_GLAccountLineItem.AccrualSubobject,
    I_GLAccountLineItem.AccrualItemType,
    I_GLAccountLineItem.AccrualObjectLogicalSystem,
    I_GLAccountLineItem.AccrualReferenceObject,
    I_GLAccountLineItem.AccrualValueDate,   
    
    I_GLAccountLineItem.CashLedgerCompanyCode,
    I_GLAccountLineItem.CashLedgerAccount,
    I_GLAccountLineItem.FinancialManagementArea,
    I_GLAccountLineItem.FundsCenter,
    I_GLAccountLineItem.FundedProgram,
    I_GLAccountLineItem.Fund,
    I_GLAccountLineItem.GrantID,
    I_GLAccountLineItem.BudgetPeriod,
    I_GLAccountLineItem.PartnerFund,
    I_GLAccountLineItem.PartnerGrant,
    I_GLAccountLineItem.PartnerBudgetPeriod,
    I_GLAccountLineItem.PubSecBudgetAccount,
    I_GLAccountLineItem.PubSecBudgetAccountCoCode,
    I_GLAccountLineItem.PubSecBudgetCnsmpnDate,
    I_GLAccountLineItem.PubSecBudgetCnsmpnFsclPeriod,
    I_GLAccountLineItem.PubSecBudgetCnsmpnFsclYear,
    I_GLAccountLineItem.PubSecBudgetIsRelevant,
    I_GLAccountLineItem.PubSecBudgetCnsmpnType,
    I_GLAccountLineItem.PubSecBudgetCnsmpnAmtType,
       
    I_GLAccountLineItem.ConsolidationUnit,
    I_GLAccountLineItem.PartnerConsolidationUnit,
    I_GLAccountLineItem.Company, 
    I_GLAccountLineItem.ConsolidationChartOfAccounts,
    I_GLAccountLineItem.CnsldtnFinancialStatementItem,
    I_GLAccountLineItem.CnsldtnSubitemCategory,
    I_GLAccountLineItem.CnsldtnSubitem,  
 
//    cast( LedgerFiscalYear as fis_ryear_flow preserving type ) as FlowOfFundsLedgerFiscalYear,

//    _WBSElementExternalID,
//    _WBSElementExternalIDText,
    I_GLAccountLineItem._ProjectBasicData,
    I_GLAccountLineItem._ProjectBasicDataText,
    I_GLAccountLineItem._WBSElementBasicData,
    I_GLAccountLineItem._WBSElementBasicDataText,
//    _ProjectExternalID,
//    _ProjectExternalIDText,
    
//    _PartnerProjectExternalID,
//    _PartnerProjctExtrnalIDText,
//    _PartnerWBSElementExternalID,
//    _PartnerWBSElemntExtrnalIDText,
    I_GLAccountLineItem._PartnerProjectBasicData,
    I_GLAccountLineItem._PartnerProjectBasicDataText,
    I_GLAccountLineItem._PartnerWBSElementBasicData,
    I_GLAccountLineItem._PartnerWBSElmntBasicDataText,
    
//    _InvtrySpclStockWBSElmntBD,
//    _InvtrySpclStockWBSElmntExtID,
    
    I_GLAccountLineItem._ServiceContract,
    I_GLAccountLineItem._ServiceContractType,
    I_GLAccountLineItem._ServiceContractItem,
    I_GLAccountLineItem._TimeSheetOvertimeCat,
    
    I_GLAccountLineItem._AccrualObjectType,
    I_GLAccountLineItem._AccrualObject,
    I_GLAccountLineItem._AccrualSubobject,
    I_GLAccountLineItem._AccrualItemType,
    
    I_GLAccountLineItem._CashLedgerCompanyCode,
    I_GLAccountLineItem._CashLedgerAccount,
    I_GLAccountLineItem._FinancialManagementArea,
    I_GLAccountLineItem._FundsCenter,
    I_GLAccountLineItem._FundedProgram,
    I_GLAccountLineItem._Fund,
//    _Grant,
    I_GLAccountLineItem._BudgetPeriod,
    I_GLAccountLineItem._PartnerFund,
//    _PartnerGrant,
    I_GLAccountLineItem._PartnerBudgetPeriod,
    I_GLAccountLineItem._PubSecBudgetAccountCoCode,
    I_GLAccountLineItem._PubSecBudgetAccount,
    I_GLAccountLineItem._PubSecBudgetCnsmpnDate,
    I_GLAccountLineItem._PubSecBudgetCnsmpnFsclPeriod,
    I_GLAccountLineItem._PubSecBudgetCnsmpnFsclYear,
    I_GLAccountLineItem._PubSecBudgetCnsmpnType,
    I_GLAccountLineItem._PubSecBudgetCnsmpnAmtType,
    I_GLAccountLineItem._FunctionalCurrency,
    I_GLAccountLineItem._ConsolidationUnit,
    I_GLAccountLineItem._PartnerConsolidationUnit,
    I_GLAccountLineItem._Company,
    I_GLAccountLineItem._ConsolidationChartOfAccounts,
    I_GLAccountLineItem._CnsldtnFinancialStatementItem,
    I_GLAccountLineItem._CnsldtnSubitemCategory,
    I_GLAccountLineItem._CnsldtnSubitem,
    I_GLAccountLineItem._SupplierCompany,
    I_GLAccountLineItem._CustomerCompany  
}
where 
    (
    I_GLAccountLineItem.PostingDate between $parameters.P_FromPostingDate and $parameters.P_ToPostingDate
        and ( 
        // exclude opening/closing postings
                ( I_GLAccountLineItem.GLRecordType <> '5' 
        // exclude BCF  -> not required as Inner Join P_FiscalPeriod removes FiscalPeriod 000 from the result
//                and I_GLAccountLineItem.FiscalPeriod > '000' 
                )
        // or include also closing postings if enabled
            or ( I_GLAccountLineItem.GLRecordType = '5' and
        // and exclude opening posting
                 I_GLAccountLineItem.FiscalPeriod > '000' and                  
                    ( I_GLAccountLineItem.AccountingDocumentCategory = 'J' or I_GLAccountLineItem.AccountingDocumentCategory = 'L' )
                )
            )
    )
//include also migrated items
    or 
    ( 
        I_GLAccountLineItem.PostingDate = '00000000' and 
        I_GLAccountLineItem.FiscalPeriod <> '000' and 
        I_FiscalPeriodForVariant.FiscalPeriodStartDate <= $parameters.P_ToPostingDate and 
        I_FiscalPeriodForVariant.FiscalPeriodStartDate >= $parameters.P_FromPostingDate
    )
