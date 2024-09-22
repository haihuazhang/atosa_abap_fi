@AbapCatalog.preserveKey: true
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.sqlViewName: 'ZPFIGLACCTBAL'
//@EndUserText.label: 'G/L Account Balance'
//@VDM.viewType: #COMPOSITE
//@VDM.private:true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ClientHandling.algorithm: #SESSION_VARIABLE
@AbapCatalog.buffering.status: #NOT_ALLOWED
@Metadata.ignorePropagatedAnnotations: true 
@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION]

define view ZP_GLAcctBalance 
with parameters
  P_FromPostingDate       : sydate,
  P_ToPostingDate         : sydate      

as select from ZP_GLAcctCreditDebitBalance 
( P_FromPostingDate: $parameters.P_FromPostingDate, P_ToPostingDate: $parameters.P_ToPostingDate ) 
{
key ZP_GLAcctCreditDebitBalance.Ledger as rldnr,
key ZP_GLAcctCreditDebitBalance.CompanyCode as rbukrs,
key ZP_GLAcctCreditDebitBalance.FiscalYear as gjahr,
key ZP_GLAcctCreditDebitBalance.AccountingDocument as belnr,
key ZP_GLAcctCreditDebitBalance.LedgerGLLineItem as docln,
key ZP_GLAcctCreditDebitBalance.SourceLedger as rldnr_pers,

ZP_GLAcctCreditDebitBalance.LedgerFiscalYear as ryear,
//ZP_GLAcctCreditDebitBalance.GLRecordType as rrcty,

///////////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_00  Unified Journal Entry: Transaction, Currencies, Units
///////////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.FinancialTransactionType as rmvct,
ZP_GLAcctCreditDebitBalance.BusinessTransactionType as bttype,
ZP_GLAcctCreditDebitBalance.ReferenceDocumentType as awtyp,
ZP_GLAcctCreditDebitBalance.LogicalSystem as awsys,
ZP_GLAcctCreditDebitBalance.ReferenceDocumentContext as aworg,
ZP_GLAcctCreditDebitBalance.ReferenceDocument as awref,
ZP_GLAcctCreditDebitBalance.ReferenceDocumentItem as awitem,
ZP_GLAcctCreditDebitBalance.ReferenceDocumentItemGroup as awitgrp,
////ZP_GLAcctCreditDebitBalance.SUBTA,
ZP_GLAcctCreditDebitBalance.IsReversal as xreversing,
ZP_GLAcctCreditDebitBalance.IsReversed as xreversed,
////ZP_GLAcctCreditDebitBalance.XTRUEREV,
////ZP_GLAcctCreditDebitBalance.AWTYP_REV,
ZP_GLAcctCreditDebitBalance.ReversalReferenceDocumentCntxt as aworg_rev,
ZP_GLAcctCreditDebitBalance.ReversalReferenceDocument as awref_rev,
////ZP_GLAcctCreditDebitBalance.SUBTA_REV,
ZP_GLAcctCreditDebitBalance.IsSettlement as xsettling,
ZP_GLAcctCreditDebitBalance.IsSettled as xsettled,
ZP_GLAcctCreditDebitBalance.PredecessorReferenceDocType as prec_awtyp,
ZP_GLAcctCreditDebitBalance.PredecessorReferenceDocCntxt as prec_aworg,
ZP_GLAcctCreditDebitBalance.PredecessorReferenceDocument as prec_awref,
ZP_GLAcctCreditDebitBalance.PredecessorReferenceDocItem as prec_awitem,
//ZP_GLAcctCreditDebitBalance.PREC_SUBTA,

ZP_GLAcctCreditDebitBalance.GLAccount as racct,

////////////////////////////////////////////////////////////////////////////////////
// .INCLUDE  ACDOC_SI_GL_ACCAS Unified Journal Entry: G/L additional account assignments
////////////////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.ProfitCenter as prctr,
ZP_GLAcctCreditDebitBalance.FunctionalArea as rfarea,
ZP_GLAcctCreditDebitBalance.BusinessArea as rbusa,
ZP_GLAcctCreditDebitBalance.ControllingArea as kokrs,
ZP_GLAcctCreditDebitBalance.Segment as segment,
ZP_GLAcctCreditDebitBalance.PartnerCostCenter as scntr,
ZP_GLAcctCreditDebitBalance.PartnerProfitCenter as pprctr,
ZP_GLAcctCreditDebitBalance.PartnerFunctionalArea as sfarea,
ZP_GLAcctCreditDebitBalance.PartnerBusinessArea as sbusa,
ZP_GLAcctCreditDebitBalance.PartnerCompany as rassc,
ZP_GLAcctCreditDebitBalance.PartnerSegment as psegment,

/////////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_FIX  Unified Journal Entry: Mandatory fields for G/L
////////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.DebitCreditCode as drcrk,
ZP_GLAcctCreditDebitBalance.FiscalYearVariant as periv,
ZP_GLAcctCreditDebitBalance.FiscalYearPeriod as fiscyearper,
ZP_GLAcctCreditDebitBalance.PostingDate as budat,
//cast( ( case when ZP_GLAcctCreditDebitBalance.IsPeriodBasedBalanceReporting = 'X' then '00000000'
//                                                                                 else ZP_GLAcctCreditDebitBalance.PostingDate
//        end )
//as fis_budat ) as budat,
//ZP_GLAcctCreditDebitBalance.PostingDate as budat,
//ZP_GLAcctCreditDebitBalance.bldat,
ZP_GLAcctCreditDebitBalance.AccountingDocumentType as blart,
ZP_GLAcctCreditDebitBalance.AccountingDocumentItem as buzei,
ZP_GLAcctCreditDebitBalance.AssignmentReference as zuonr,
ZP_GLAcctCreditDebitBalance.PostingKey as bschl,
ZP_GLAcctCreditDebitBalance.AccountingDocumentCategory as bstat,
ZP_GLAcctCreditDebitBalance.TransactionTypeDetermination as ktosl,
ZP_GLAcctCreditDebitBalance.SubLedgerAcctLineItemType as slalittype,
ZP_GLAcctCreditDebitBalance.AccountingDocCreatedByUser as usnam,
//ZP_GLAcctCreditDebitBalance.timestamp,
ZP_GLAcctCreditDebitBalance.EliminationProfitCenter as eprctr,
ZP_GLAcctCreditDebitBalance.OriginObjectType as rhoart,
ZP_GLAcctCreditDebitBalance.GLAccountType as glaccount_type,
ZP_GLAcctCreditDebitBalance.ChartOfAccounts as ktopl,
ZP_GLAcctCreditDebitBalance.AlternativeGLAccount as lokkt,
ZP_GLAcctCreditDebitBalance.CountryChartOfAccounts as ktop2,
ZP_GLAcctCreditDebitBalance.CreationDateTime,

///////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_GEN  Unified Journal Entry: Fields for several subledgers
//////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.InvoiceReference as rebzg,
ZP_GLAcctCreditDebitBalance.InvoiceReferenceFiscalYear as rebzj,
ZP_GLAcctCreditDebitBalance.FollowOnDocumentType as rebzz,
ZP_GLAcctCreditDebitBalance.InvoiceItemReference as rebzt,
ZP_GLAcctCreditDebitBalance.ReferencePurchaseOrderCategory as rbest,
ZP_GLAcctCreditDebitBalance.PurchasingDocument as ebeln,
ZP_GLAcctCreditDebitBalance.PurchasingDocumentItem as ebelp,
ZP_GLAcctCreditDebitBalance.AccountAssignmentNumber as zekkn,
ZP_GLAcctCreditDebitBalance.DocumentItemText as sgtxt,
ZP_GLAcctCreditDebitBalance.Plant as werks,
ZP_GLAcctCreditDebitBalance.Supplier as lifnr,
ZP_GLAcctCreditDebitBalance.Customer as kunnr,

ZP_GLAcctCreditDebitBalance.Product as matnr,
ZP_GLAcctCreditDebitBalance.SoldProduct as  matnr_copa,
ZP_GLAcctCreditDebitBalance.SoldProductGroup as  matkl,
ZP_GLAcctCreditDebitBalance.ProductGroup as matkl_mm,

/////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_FI  Unified Journal Entry: Fields for FI subledgers
/////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.FinancialAccountType as koart,
ZP_GLAcctCreditDebitBalance.SpecialGLCode as umskz,
ZP_GLAcctCreditDebitBalance.TaxCode as mwskz,
ZP_GLAcctCreditDebitBalance.HouseBank as hbkid,
ZP_GLAcctCreditDebitBalance.HouseBankAccount as hktid,
ZP_GLAcctCreditDebitBalance.IsOpenItemManaged as xopvw,
//ZP_GLAcctCreditDebitBalance.augdt,
ZP_GLAcctCreditDebitBalance.ClearingJournalEntry as augbl,
ZP_GLAcctCreditDebitBalance.ClearingJournalEntryFiscalYear as auggj,
//ZP_GLAcctCreditDebitBalance.IsCleared as xaugp,


/////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_FAA  Unified Journal Entry: Fields for Asset Accounting
/////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.AssetDepreciationArea as afabe,
ZP_GLAcctCreditDebitBalance.MasterFixedAsset as anln1,
ZP_GLAcctCreditDebitBalance.FixedAsset as anln2,
ZP_GLAcctCreditDebitBalance.AssetValueDate as bzdat,
ZP_GLAcctCreditDebitBalance.AssetTransactionType as anbwa,
ZP_GLAcctCreditDebitBalance.AssetAcctTransClassfctn as movcat,
ZP_GLAcctCreditDebitBalance.DepreciationFiscalPeriod as depr_period,
ZP_GLAcctCreditDebitBalance.GroupMasterFixedAsset as anlgr,
ZP_GLAcctCreditDebitBalance.GroupFixedAsset as anlgr2,
//ZP_GLAcctCreditDebitBalance.settlement_rule,

//////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_ML Unified Journal Entry: Fields for Material Ledger
//////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.CostEstimate as kalnr,
ZP_GLAcctCreditDebitBalance.InvtrySpecialStockValnType_2 as kzbws,
//ZP_GLAcctCreditDebitBalance.xobew,
ZP_GLAcctCreditDebitBalance.InvtrySpecialStockValnType_2 as sobkz,
ZP_GLAcctCreditDebitBalance.InventorySpclStkSalesDocument as mat_kdauf,
//ZP_GLAcctCreditDebitBalance.InvtrySpclStockWBSElmntExtID,
ZP_GLAcctCreditDebitBalance.InventorySpclStkSalesDocItm as mat_kdpos,
ZP_GLAcctCreditDebitBalance.InvtrySpclStockWBSElmntIntID as mat_pspnr, 
ZP_GLAcctCreditDebitBalance.InvtrySpclStockWBSElmntIntID as mat_ps_posid,
ZP_GLAcctCreditDebitBalance.PartnerWBSElementInternalID,
//ZP_GLAcctCreditDebitBalance.PartnerWBSElementExternalID,
ZP_GLAcctCreditDebitBalance.InventorySpecialStockSupplier as mat_lifnr,
ZP_GLAcctCreditDebitBalance.InventoryValuationType as bwtar,
ZP_GLAcctCreditDebitBalance.ValuationArea as bwkey,

////////////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_CFIN   Unified Journal Entry: Fields for Central Finance
//////////////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.SenderCompanyCode,
ZP_GLAcctCreditDebitBalance.SenderGLAccount as racct_sender,
ZP_GLAcctCreditDebitBalance.SenderAccountAssignment as accas_sender,
ZP_GLAcctCreditDebitBalance.SenderAccountAssignmentType as accasty_sender,

////////////////////////////////////////////////////////////////////////////
//  .INCLUDE  ACDOC_SI_CO  Unified Journal Entry: CO fields
///////////////////////////////////////////////////////////////////////////
//ZP_GLAcctCreditDebitBalance.UtilsProfileConstcyChkGrp as hkgrp,
//ZP_GLAcctCreditDebitBalance.ControllingDebitCreditCode as co_belkz,
ZP_GLAcctCreditDebitBalance.ControllingObjectDebitType as beltp,
ZP_GLAcctCreditDebitBalance.QuantityIsIncomplete as muvflg,
ZP_GLAcctCreditDebitBalance.OffsettingAccount as gkont,
ZP_GLAcctCreditDebitBalance.OffsettingAccountType as gkoar,
ZP_GLAcctCreditDebitBalance.LineItemIsCompleted as erlkz,
ZP_GLAcctCreditDebitBalance.PersonnelNumber as pernr,
ZP_GLAcctCreditDebitBalance.ControllingObjectClass as scope,
ZP_GLAcctCreditDebitBalance.PartnerCompanyCode as pbukrs,
ZP_GLAcctCreditDebitBalance.PartnerControllingObjectClass as pscope,
//ZP_GLAcctCreditDebitBalance.aufnr_org,
ZP_GLAcctCreditDebitBalance.OriginCostCenter as ukostl,
ZP_GLAcctCreditDebitBalance.OriginCostCtrActivityType as ulstar,
ZP_GLAcctCreditDebitBalance.OriginProduct,
ZP_GLAcctCreditDebitBalance.VarianceOriginGLAccount,
ZP_GLAcctCreditDebitBalance.AccountAssignment as accas,
ZP_GLAcctCreditDebitBalance.AccountAssignmentType as accasty,
ZP_GLAcctCreditDebitBalance.ProjectNetwork as nplnr,
ZP_GLAcctCreditDebitBalance.RelatedNetworkActivity as nplnr_vorgn,
ZP_GLAcctCreditDebitBalance.BusinessProcess as prznr,
ZP_GLAcctCreditDebitBalance.CostObject as kstrg,
//ZP_GLAcctCreditDebitBalance.bemot,
ZP_GLAcctCreditDebitBalance.CustomerServiceNotification as qmnum,
ZP_GLAcctCreditDebitBalance.ServiceDocumentType,
ZP_GLAcctCreditDebitBalance.ServiceDocument,
ZP_GLAcctCreditDebitBalance.ServiceDocumentItem,
ZP_GLAcctCreditDebitBalance.PartnerServiceDocumentType,
ZP_GLAcctCreditDebitBalance.PartnerServiceDocument,
ZP_GLAcctCreditDebitBalance.PartnerServiceDocumentItem,
ZP_GLAcctCreditDebitBalance.ServiceContract,
ZP_GLAcctCreditDebitBalance.ServiceContractType,
ZP_GLAcctCreditDebitBalance.ServiceContractItem,
ZP_GLAcctCreditDebitBalance.TimeSheetOvertimeCategory,
ZP_GLAcctCreditDebitBalance.OperatingConcern as erkrs,
ZP_GLAcctCreditDebitBalance.PartnerAccountAssignment as paccas,
ZP_GLAcctCreditDebitBalance.PartnerAccountAssignmentType as paccasty,
ZP_GLAcctCreditDebitBalance.PartnerCostCtrActivityType as plstar,
ZP_GLAcctCreditDebitBalance.PartnerOrder_2 as paufnr,
ZP_GLAcctCreditDebitBalance.PartnerOrder_2,
ZP_GLAcctCreditDebitBalance.PartnerOrderCategory as pautyp,
ZP_GLAcctCreditDebitBalance.PartnerWBSElementInternalID as pps_posid,
ZP_GLAcctCreditDebitBalance.PartnerProjectInternalID as pps_pspid,
ZP_GLAcctCreditDebitBalance.PartnerSalesDocument as pkdauf,
ZP_GLAcctCreditDebitBalance.PartnerSalesDocumentItem as pkdpos,
ZP_GLAcctCreditDebitBalance.PartnerProjectNetwork as pnplnr,
ZP_GLAcctCreditDebitBalance.PartnerProjectNetworkActivity as pnplnr_vorgn,
ZP_GLAcctCreditDebitBalance.PartnerBusinessProcess as pprznr,
ZP_GLAcctCreditDebitBalance.PartnerCostObject as pkstrg,

//////////////////////////////////////////////////////////////////////
//  .INCLUDE  ACDOC_SI_COPA  Unified Journal Entry: CO-PA fields
//////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.BillingDocumentType as fkart,
ZP_GLAcctCreditDebitBalance.SalesOrganization as vkorg,
ZP_GLAcctCreditDebitBalance.DistributionChannel as vtweg,
ZP_GLAcctCreditDebitBalance.OrganizationDivision as spart,
ZP_GLAcctCreditDebitBalance.CustomerGroup as kdgrp,
ZP_GLAcctCreditDebitBalance.CustomerSupplierCountry,
ZP_GLAcctCreditDebitBalance.CustomerSupplierIndustry,
ZP_GLAcctCreditDebitBalance.FinancialServicesProductGroup,
ZP_GLAcctCreditDebitBalance.FinancialServicesBranch,
ZP_GLAcctCreditDebitBalance.FinancialDataSource,


//////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_PS  Unified Journal Entry: Fields for Public Sector
/////////////////////////////////////////////////////////////////////
//ZP_GLAcctCreditDebitBalance.re_bukrs,
//ZP_GLAcctCreditDebitBalance.re_account,
ZP_GLAcctCreditDebitBalance.FinancialManagementArea as fikrs,
ZP_GLAcctCreditDebitBalance.Fund as rfund,
ZP_GLAcctCreditDebitBalance.GrantID as rgrant_nbr,
ZP_GLAcctCreditDebitBalance.BudgetPeriod as rbudget_pd,
ZP_GLAcctCreditDebitBalance.PartnerFund as sfund,
ZP_GLAcctCreditDebitBalance.PartnerGrant as sgrant_nbr,
ZP_GLAcctCreditDebitBalance.PartnerBudgetPeriod as sbudget_pd,

///////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_JVA  Unified Journal Entry: Fields for Joint Venture Accounting
///////////////////////////////////////////////////////////////////////
ZP_GLAcctCreditDebitBalance.JointVenture as vname,
ZP_GLAcctCreditDebitBalance.JointVentureEquityGroup as egrup,
ZP_GLAcctCreditDebitBalance.JointVentureCostRecoveryCode as recid,
//ZP_GLAcctCreditDebitBalance.vptnr,
//ZP_GLAcctCreditDebitBalance.btype,
ZP_GLAcctCreditDebitBalance.JointVentureEquityType as etype,
//ZP_GLAcctCreditDebitBalance.prodper,

///////////////////////////////////////////////////////////////////////
// .INCLUDE ACDOC_SI_RE STRU  0 0 Unified Journal Entry: Fields for Real Estate
///////////////////////////////////////////////////////////////////////
//ZP_GLAcctCreditDebitBalance.swenr,
//ZP_GLAcctCreditDebitBalance.sgenr,
//ZP_GLAcctCreditDebitBalance.sgrnr,
//ZP_GLAcctCreditDebitBalance.smenr,
//ZP_GLAcctCreditDebitBalance.recnnr,
//ZP_GLAcctCreditDebitBalance.snksl,
//ZP_GLAcctCreditDebitBalance.sempsl,
ZP_GLAcctCreditDebitBalance.SettlementReferenceDate as dabrz,
//ZP_GLAcctCreditDebitBalance.pswenr,
//ZP_GLAcctCreditDebitBalance.psgenr,
//ZP_GLAcctCreditDebitBalance.psgrnr,
//ZP_GLAcctCreditDebitBalance.psmenr,
//ZP_GLAcctCreditDebitBalance.precnnr,
//ZP_GLAcctCreditDebitBalance.psnksl,
//ZP_GLAcctCreditDebitBalance.psempsl,
//ZP_GLAcctCreditDebitBalance.pdabrz,

ZP_GLAcctCreditDebitBalance.CostCenter as rcntr,
ZP_GLAcctCreditDebitBalance.CostCtrActivityType as lstar,
ZP_GLAcctCreditDebitBalance.OrderID as aufnr,
ZP_GLAcctCreditDebitBalance.OrderCategory as autyp,
ZP_GLAcctCreditDebitBalance.WBSElementInternalID as ps_psp_pnr,
//ZP_GLAcctCreditDebitBalance.WBSElementExternalID as posid_edit,
ZP_GLAcctCreditDebitBalance.WBSElementInternalID as ps_posid,
ZP_GLAcctCreditDebitBalance.ProjectInternalID as ps_pspid,
ZP_GLAcctCreditDebitBalance.ProjectInternalID as ps_prj_pnr,
//ZP_GLAcctCreditDebitBalance.ProjectExternalID as pspid_edit,
ZP_GLAcctCreditDebitBalance.PartnerProjectInternalID,
//ZP_GLAcctCreditDebitBalance.PartnerProjectExternalID,
ZP_GLAcctCreditDebitBalance.SalesDocument as kdauf,
ZP_GLAcctCreditDebitBalance.SalesDocumentItem as kdpos,

ZP_GLAcctCreditDebitBalance.ClearingDate as augdt,

ZP_GLAcctCreditDebitBalance.ConsolidationUnit,
ZP_GLAcctCreditDebitBalance.PartnerConsolidationUnit,
ZP_GLAcctCreditDebitBalance.Company, 
ZP_GLAcctCreditDebitBalance.ConsolidationChartOfAccounts,
ZP_GLAcctCreditDebitBalance.CnsldtnFinancialStatementItem,
ZP_GLAcctCreditDebitBalance.CnsldtnSubitemCategory,
ZP_GLAcctCreditDebitBalance.CnsldtnSubitem,  
@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.BalanceTransactionCurrency  as rtcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rtcur'} } ZP_GLAcctCreditDebitBalance.AmountInBalanceTransacCrcy  as tsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.TransactionCurrency as rwcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rwcur'} } ZP_GLAcctCreditDebitBalance.AmountInTransactionCurrency as wsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.CompanyCodeCurrency as rhcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rhcur'} } ZP_GLAcctCreditDebitBalance.AmountInCompanyCodeCurrency as hsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.GlobalCurrency as rkcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rkcur'} } ZP_GLAcctCreditDebitBalance.AmountInGlobalCurrency as ksl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FunctionalCurrency as FunctionalCurrency,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} }
ZP_GLAcctCreditDebitBalance.AmountInFunctionalCurrency as AmountInFunctionalCurrency,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency1 as rocur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rocur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency1 as osl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency2 as rvcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rvcur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency2 as vsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency3 as rbcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rbcur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency3 as bsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency4 as rccur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rccur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency4 as csl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency5 as rdcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rdcur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency5 as dsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency6 as recur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'recur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency6 as esl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency7 as rfcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rfcur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency7 as fsl,

@Semantics.currencyCode:true
ZP_GLAcctCreditDebitBalance.FreeDefinedCurrency8 as rgcur,
@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rgcur'} } ZP_GLAcctCreditDebitBalance.AmountInFreeDefinedCurrency8 as gsl,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rhcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInCoCodeCrcy as hsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rhcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInCoCodeCrcy as hsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rwcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInTransCrcy as wsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rwcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInTransCrcy as wsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rtcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInBalanceTransCrcy as tsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rtcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInBalanceTransCrcy as tsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rkcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInGlobalCrcy as ksl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rkcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInGlobalCrcy as ksl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFunctionalCrcy as DebitAmountInFunctionalCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFunctionalCrcy as CreditAmountInFunctionalCrcy,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rocur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy1 as osl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rocur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy1 as osl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rvcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy2 as vsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rvcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy2 as vsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rbcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy3 as bsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rbcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy3 as bsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rccur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy4 as csl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rccur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy4 as csl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rdcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy5 as dsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rdcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy5 as dsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'recur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy6 as esl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'recur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy6 as esl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rfcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy7 as fsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rfcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy7 as fsl_credit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rgcur'} } 
ZP_GLAcctCreditDebitBalance.DebitAmountInFreeDefinedCrcy8 as gsl_debit,

@DefaultAggregation: #SUM
@Semantics: { amount : {currencyCode: 'rgcur'} } 
ZP_GLAcctCreditDebitBalance.CreditAmountInFreeDefinedCrcy8 as gsl_credit,

ZP_GLAcctCreditDebitBalance.FiscalPeriod as poper,

ZP_GLAcctCreditDebitBalance.OffsettingChartOfAccounts,
ZP_GLAcctCreditDebitBalance.JrnlEntryItemObsoleteReason,

//0 as hsl_end_bal,
//0 as wsl_end_bal,
//0 as tsl_end_bal,
//0 as ksl_end_bal,
//0 as EndingBalanceAmtInFuncnlCrcy,
//0 as osl_end_bal,
//0 as vsl_end_bal,
//0 as bsl_end_bal,
//0 as csl_end_bal,
//0 as dsl_end_bal,
//0 as esl_end_bal,
//0 as fsl_end_bal,
//0 as gsl_end_bal,

cast( 0 as abap.curr( 23,2 )) as hsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as wsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as tsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as ksl_end_bal,
cast( 0 as abap.curr( 23,2 )) as EndingBalanceAmtInFuncnlCrcy,
cast( 0 as abap.curr( 23,2 )) as osl_end_bal,
cast( 0 as abap.curr( 23,2 )) as vsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as bsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as csl_end_bal,
cast( 0 as abap.curr( 23,2 )) as dsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as esl_end_bal,
cast( 0 as abap.curr( 23,2 )) as fsl_end_bal,
cast( 0 as abap.curr( 23,2 )) as gsl_end_bal,

GLAccountAuthorizationGroup,
SupplierBasicAuthorizationGrp,
CustomerBasicAuthorizationGrp,
AcctgDocTypeAuthorizationGroup,
OrderType,
SalesOrderType,
AssetClass,
//FiscalPeriodDate,
AccrualObjectType,
AccrualObject,
AccrualSubobject,
AccrualItemType,
AccrualObjectLogicalSystem,
AccrualReferenceObject,
AccrualValueDate,  

CashLedgerCompanyCode,
CashLedgerAccount,
FundsCenter,
FundedProgram,
Fund,
GrantID,
BudgetPeriod,
PartnerFund,
PartnerGrant,
PartnerBudgetPeriod,
PubSecBudgetAccount,
PubSecBudgetAccountCoCode,
PubSecBudgetCnsmpnDate,
PubSecBudgetCnsmpnFsclPeriod,
PubSecBudgetCnsmpnFsclYear,
PubSecBudgetIsRelevant,
PubSecBudgetCnsmpnType,
PubSecBudgetCnsmpnAmtType,

//FlowOfFundsLedgerFiscalYear,

IsStatisticalCostCenter,
IsStatisticalOrder,
IsStatisticalSalesDocument,
WBSIsStatisticalWBSElement,

// Associations
//_PartnerProjectExternalID,
//_PartnerProjctExtrnalIDText,
//_PartnerWBSElementExternalID,
//_PartnerWBSElemntExtrnalIDText,
_PartnerProjectBasicData,
_PartnerProjectBasicDataText,
_PartnerWBSElementBasicData,
_PartnerWBSElmntBasicDataText,

//_InvtrySpclStockWBSElmntBD,
//ZP_GLAcctCreditDebitBalance._InvtrySpclStockWBSElmntExtID,

ZP_GLAcctCreditDebitBalance._ServiceContract,
ZP_GLAcctCreditDebitBalance._ServiceContractItem,
ZP_GLAcctCreditDebitBalance._ServiceContractType,
ZP_GLAcctCreditDebitBalance._TimeSheetOvertimeCat,
ZP_GLAcctCreditDebitBalance._AccrualObjectType,
ZP_GLAcctCreditDebitBalance._AccrualObject,
ZP_GLAcctCreditDebitBalance._AccrualSubobject,
ZP_GLAcctCreditDebitBalance._AccrualItemType ,

ZP_GLAcctCreditDebitBalance._CashLedgerCompanyCode,
ZP_GLAcctCreditDebitBalance._CashLedgerAccount,
ZP_GLAcctCreditDebitBalance._FinancialManagementArea,
ZP_GLAcctCreditDebitBalance._FundsCenter,
ZP_GLAcctCreditDebitBalance._FundedProgram,
ZP_GLAcctCreditDebitBalance._Fund,
//ZP_GLAcctCreditDebitBalance._Grant,
ZP_GLAcctCreditDebitBalance._BudgetPeriod,
ZP_GLAcctCreditDebitBalance._PartnerFund,
//ZP_GLAcctCreditDebitBalance._PartnerGrant,
ZP_GLAcctCreditDebitBalance._PartnerBudgetPeriod,
ZP_GLAcctCreditDebitBalance._PubSecBudgetAccountCoCode,
ZP_GLAcctCreditDebitBalance._PubSecBudgetAccount,
ZP_GLAcctCreditDebitBalance._PubSecBudgetCnsmpnDate,
ZP_GLAcctCreditDebitBalance._PubSecBudgetCnsmpnFsclPeriod,
ZP_GLAcctCreditDebitBalance._PubSecBudgetCnsmpnFsclYear,
ZP_GLAcctCreditDebitBalance._PubSecBudgetCnsmpnType,
ZP_GLAcctCreditDebitBalance._PubSecBudgetCnsmpnAmtType,  
ZP_GLAcctCreditDebitBalance._FunctionalCurrency,

_ConsolidationUnit,
_PartnerConsolidationUnit,
_Company,
_ConsolidationChartOfAccounts,
_CnsldtnFinancialStatementItem,
_CnsldtnSubitemCategory,
_CnsldtnSubitem, 
_CustomerCompany,
_SupplierCompany,
//cast( concat( ZP_GLAcctCreditDebitBalance.FiscalPeriod, ZP_GLAcctCreditDebitBalance.PostingDate ) as FIS_FISCALPERIODDATE ) as FiscalPeriodDate,

cast( '2         ' as abap.char( 10 ) ) as GLAccountFlowType


} //where ZP_GLAcctCreditDebitBalance.PostingDate between $parameters.P_FromPostingDate and $parameters.P_ToPostingDate and ZP_GLAcctCreditDebitBalance.AccountingDocumentCategory <> 'J' 

//union all select from P_GLAcctBalance1
//( P_FromPostingDate: $parameters.P_FromPostingDate, P_ToPostingDate: $parameters.P_ToPostingDate ) 
//
//{
//key P_GLAcctBalance1.rldnr,
//key P_GLAcctBalance1.rbukrs,
//key P_GLAcctBalance1.gjahr,
//key P_GLAcctBalance1.belnr,
//key P_GLAcctBalance1.docln,
//key P_GLAcctBalance1.rldnr_pers,
//
//P_GLAcctBalance1.ryear,
////P_GLAcctBalance1.rrcty,
//
/////////////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_00  Unified Journal Entry: Transaction, Currencies, Units
/////////////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.rmvct,
//P_GLAcctBalance1.bttype,
//P_GLAcctBalance1.awtyp,
//P_GLAcctBalance1.awsys,
//P_GLAcctBalance1.aworg,
//P_GLAcctBalance1.awref,
//P_GLAcctBalance1.awitem,
//P_GLAcctBalance1.awitgrp,
////P_GLAcctBalance1.subta,
//P_GLAcctBalance1.xreversing,
//P_GLAcctBalance1.xreversed,
////P_GLAcctBalance1.xtruerev,
////P_GLAcctBalance1.awtyp_rev,
//P_GLAcctBalance1.aworg_rev,
//P_GLAcctBalance1.awref_rev,
////P_GLAcctBalance1.subta_rev,
//P_GLAcctBalance1.xsettling,
//P_GLAcctBalance1.xsettled,
//P_GLAcctBalance1.prec_awtyp,
//P_GLAcctBalance1.prec_aworg,
//P_GLAcctBalance1.prec_awref,
//P_GLAcctBalance1.prec_awitem,
////P_GLAcctBalance1.prec_subta,
//
//P_GLAcctBalance1.racct,
//
//////////////////////////////////////////////////////////////////////////////////////
//// .INCLUDE  ACDOC_SI_GL_ACCAS Unified Journal Entry: G/L additional account assignments
//////////////////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.prctr,
//P_GLAcctBalance1.rfarea,
//P_GLAcctBalance1.rbusa,
//P_GLAcctBalance1.kokrs,
//P_GLAcctBalance1.segment,
//P_GLAcctBalance1.scntr,
//P_GLAcctBalance1.pprctr,
//P_GLAcctBalance1.sfarea,
//P_GLAcctBalance1.sbusa,
//P_GLAcctBalance1.rassc,
//P_GLAcctBalance1.psegment,
//
///////////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_FIX  Unified Journal Entry: Mandatory fields for G/L
//////////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.drcrk,
//P_GLAcctBalance1.periv,
//P_GLAcctBalance1.fiscyearper,
////P_GLAcctBalance1.budat,
////cast( ( case when P_GLAcctBalance1.IsPeriodBasedBalanceReporting = 'X' then '00000000'
////                                                                       else P_GLAcctBalance1.budat
////        end )
////as fis_budat ) as budat,
//P_GLAcctBalance1.budat,
////P_GLAcctBalance1.bldat,
//P_GLAcctBalance1.blart,
//P_GLAcctBalance1.buzei,
//P_GLAcctBalance1.zuonr,
//P_GLAcctBalance1.bschl,
//P_GLAcctBalance1.bstat,
//P_GLAcctBalance1.ktosl,
//P_GLAcctBalance1.slalittype,
//P_GLAcctBalance1.usnam,
////P_GLAcctBalance1.timestamp,
//P_GLAcctBalance1.eprctr,
//P_GLAcctBalance1.rhoart,
//P_GLAcctBalance1.glaccount_type,
//P_GLAcctBalance1.ktopl,
//P_GLAcctBalance1.lokkt,
//P_GLAcctBalance1.ktop2,
//P_GLAcctBalance1.CreationDateTime,
//
/////////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_GEN  Unified Journal Entry: Fields for several subledgers
////////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.rebzg,
//P_GLAcctBalance1.rebzj,
//P_GLAcctBalance1.rebzz,
//P_GLAcctBalance1.rebzt,
//P_GLAcctBalance1.rbest,
//P_GLAcctBalance1.ebeln,
//P_GLAcctBalance1.ebelp,
//P_GLAcctBalance1.zekkn,
//P_GLAcctBalance1.sgtxt,
////P_GLAcctBalance1.matnr,
//P_GLAcctBalance1.werks,
//P_GLAcctBalance1.lifnr,
//P_GLAcctBalance1.kunnr,
//
//P_GLAcctBalance1.matnr,
//P_GLAcctBalance1.matnr_copa,
//P_GLAcctBalance1.matkl,
//P_GLAcctBalance1.matkl_mm,
//
///////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_FI  Unified Journal Entry: Fields for FI subledgers
///////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.koart,
//P_GLAcctBalance1.umskz,
//P_GLAcctBalance1.mwskz,
//P_GLAcctBalance1.hbkid,
//P_GLAcctBalance1.hktid,
//P_GLAcctBalance1.xopvw,
////P_GLAcctBalance1.augdt,
//P_GLAcctBalance1.augbl,
//P_GLAcctBalance1.auggj,
////P_GLAcctBalance1.xaugp,
//
//
///////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_FAA  Unified Journal Entry: Fields for Asset Accounting
///////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.afabe,
//P_GLAcctBalance1.anln1,
//P_GLAcctBalance1.anln2,
//P_GLAcctBalance1.bzdat,
//P_GLAcctBalance1.anbwa,
//P_GLAcctBalance1.movcat,
//P_GLAcctBalance1.depr_period,
//P_GLAcctBalance1.anlgr,
//P_GLAcctBalance1.anlgr2,
////P_GLAcctBalance1.settlement_rule,
//
////////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_ML Unified Journal Entry: Fields for Material Ledger
////////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.kalnr, 
//P_GLAcctBalance1.kzbws,
////P_GLAcctBalance1.xobew,
//P_GLAcctBalance1.sobkz,
//P_GLAcctBalance1.mat_kdauf,
//P_GLAcctBalance1.InvtrySpclStockWBSElmntExtID,
//P_GLAcctBalance1.mat_kdpos,
//P_GLAcctBalance1.mat_pspnr, 
//P_GLAcctBalance1.mat_ps_posid,
//P_GLAcctBalance1.PartnerWBSElementInternalID,
//P_GLAcctBalance1.PartnerWBSElementExternalID,
//P_GLAcctBalance1.mat_lifnr,
//P_GLAcctBalance1.bwtar,
//P_GLAcctBalance1.bwkey,
//
//////////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_CFIN   Unified Journal Entry: Fields for Central Finance
////////////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.SenderCompanyCode,
//P_GLAcctBalance1.racct_sender,
//P_GLAcctBalance1.accas_sender,
//P_GLAcctBalance1.accasty_sender,
//
//////////////////////////////////////////////////////////////////////////////
////  .INCLUDE  ACDOC_SI_CO  Unified Journal Entry: CO fields
/////////////////////////////////////////////////////////////////////////////
////P_GLAcctBalance1.hkgrp,
////P_GLAcctBalance1.co_belkz,
//P_GLAcctBalance1.beltp,
//P_GLAcctBalance1.muvflg,
//P_GLAcctBalance1.gkont,
//P_GLAcctBalance1.gkoar,
//P_GLAcctBalance1.erlkz,
//P_GLAcctBalance1.pernr,
//P_GLAcctBalance1.scope,
//P_GLAcctBalance1.pbukrs,
//P_GLAcctBalance1.pscope,
////P_GLAcctBalance1.aufnr_org,
//P_GLAcctBalance1.ukostl,
//P_GLAcctBalance1.ulstar,
//P_GLAcctBalance1.OriginProduct,
//P_GLAcctBalance1.VarianceOriginGLAccount,
//P_GLAcctBalance1.accas,
//P_GLAcctBalance1.accasty,
//P_GLAcctBalance1.nplnr,
//P_GLAcctBalance1.nplnr_vorgn,
//P_GLAcctBalance1.prznr,
//P_GLAcctBalance1.kstrg,
////P_GLAcctBalance1.bemot,
//P_GLAcctBalance1.qmnum,
//P_GLAcctBalance1.ServiceDocumentType,
//P_GLAcctBalance1.ServiceDocument,
//P_GLAcctBalance1.ServiceDocumentItem,
//P_GLAcctBalance1.PartnerServiceDocumentType,
//P_GLAcctBalance1.PartnerServiceDocument,
//P_GLAcctBalance1.PartnerServiceDocumentItem,
//P_GLAcctBalance1.ServiceContract,
//P_GLAcctBalance1.ServiceContractType,
//P_GLAcctBalance1.ServiceContractItem,
//P_GLAcctBalance1.TimeSheetOvertimeCategory,
//P_GLAcctBalance1.erkrs,
//P_GLAcctBalance1.paccas,
//P_GLAcctBalance1.paccasty,
//P_GLAcctBalance1.plstar,
//P_GLAcctBalance1.paufnr,
//P_GLAcctBalance1.PartnerOrder_2,
//P_GLAcctBalance1.pautyp,
//P_GLAcctBalance1.pps_posid,
//P_GLAcctBalance1.pps_pspid,
//P_GLAcctBalance1.pkdauf,
//P_GLAcctBalance1.pkdpos,
//P_GLAcctBalance1.pnplnr,
//P_GLAcctBalance1.pnplnr_vorgn,
//P_GLAcctBalance1.pprznr,
//P_GLAcctBalance1.pkstrg,
//
//
////////////////////////////////////////////////////////////////////////
////  .INCLUDE  ACDOC_SI_COPA  Unified Journal Entry: CO-PA fields
////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.fkart,
//P_GLAcctBalance1.vkorg,
//P_GLAcctBalance1.vtweg,
//P_GLAcctBalance1.spart,
//P_GLAcctBalance1.kdgrp,
//P_GLAcctBalance1.CustomerSupplierCountry,
//P_GLAcctBalance1.CustomerSupplierIndustry,
//P_GLAcctBalance1.FinancialServicesProductGroup,
//P_GLAcctBalance1.FinancialServicesBranch,
//P_GLAcctBalance1.FinancialDataSource,
//
////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_PS  Unified Journal Entry: Fields for Public Sector
///////////////////////////////////////////////////////////////////////
////P_GLAcctBalance1.re_bukrs,
////P_GLAcctBalance1.re_account,
//P_GLAcctBalance1.fikrs,
//P_GLAcctBalance1.rfund,
//P_GLAcctBalance1.rgrant_nbr,
//P_GLAcctBalance1.rbudget_pd,
//P_GLAcctBalance1.sfund,
//P_GLAcctBalance1.sgrant_nbr,
//P_GLAcctBalance1.sbudget_pd,
//
/////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_JVA  Unified Journal Entry: Fields for Joint Venture Accounting
/////////////////////////////////////////////////////////////////////////
//P_GLAcctBalance1.vname,
//P_GLAcctBalance1.egrup,
//P_GLAcctBalance1.recid,
////P_GLAcctBalance1.vptnr,
////P_GLAcctBalance1.btype,
//P_GLAcctBalance1.etype,
////P_GLAcctBalance1.prodper,
//
/////////////////////////////////////////////////////////////////////////
//// .INCLUDE ACDOC_SI_RE STRU  0 0 Unified Journal Entry: Fields for Real Estate
/////////////////////////////////////////////////////////////////////////
////P_GLAcctBalance1.swenr,
////P_GLAcctBalance1.sgenr,
////P_GLAcctBalance1.sgrnr,
////P_GLAcctBalance1.smenr,
////P_GLAcctBalance1.recnnr,
////P_GLAcctBalance1.snksl,
////P_GLAcctBalance1.sempsl,
//P_GLAcctBalance1.dabrz,
////P_GLAcctBalance1.pswenr,
////P_GLAcctBalance1.psgenr,
////P_GLAcctBalance1.psgrnr,
////P_GLAcctBalance1.psmenr,
////P_GLAcctBalance1.precnnr,
////P_GLAcctBalance1.psnksl,
////P_GLAcctBalance1.psempsl,
////P_GLAcctBalance1.pdabrz,
//
//
//P_GLAcctBalance1.rcntr,
//P_GLAcctBalance1.lstar,
//P_GLAcctBalance1.aufnr,
//P_GLAcctBalance1.autyp,
//P_GLAcctBalance1.ps_psp_pnr,
//P_GLAcctBalance1.posid_edit,
//P_GLAcctBalance1.ps_posid,
//P_GLAcctBalance1.ps_pspid,
//P_GLAcctBalance1.ps_prj_pnr,
//P_GLAcctBalance1.pspid_edit,
//P_GLAcctBalance1.PartnerProjectInternalID,
//P_GLAcctBalance1.PartnerProjectExternalID,
//P_GLAcctBalance1.kdauf,
//P_GLAcctBalance1.kdpos,
//
//P_GLAcctBalance1.augdt,
//
//
//P_GLAcctBalance1.ConsolidationUnit,
//P_GLAcctBalance1.PartnerConsolidationUnit,
//P_GLAcctBalance1.Company, 
//P_GLAcctBalance1.ConsolidationChartOfAccounts,
//P_GLAcctBalance1.CnsldtnFinancialStatementItem,
//P_GLAcctBalance1.CnsldtnSubitemCategory,
//P_GLAcctBalance1.CnsldtnSubitem,  
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rtcur as rtcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rtcur'} } cast( 0 as vlcur12 ) as tsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rwcur as rwcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rwcur'} } cast( 0 as vlcur12 ) as wsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rhcur as rhcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rhcur'} } cast( 0 as vlcur12 ) as hsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rkcur as rkcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rkcur'} } cast( 0 as vlcur12 ) as ksl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.FunctionalCurrency as FunctionalCurrency,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } cast( 0 as fis_vfccur12 ) as AmountInFunctionalCurrency,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rocur as rocur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rocur'} } cast( 0 as vlcur12 ) as osl, //cast( cast( 0 as abap.curr( 23,2)) as vlcur12 preserving type ) as osl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rvcur as rvcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rvcur'} } cast( 0 as vlcur12 ) as vsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rbcur as rbcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rbcur'} } cast( 0 as vlcur12 ) as bsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rccur as rccur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rccur'} } cast( 0 as vlcur12 ) as csl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rdcur as rdcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rdcur'} } cast( 0 as vlcur12 ) as dsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.recur as recur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'recur'} } cast( 0 as vlcur12 ) as esl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rfcur as rfcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rfcur'} } cast( 0 as vlcur12 ) as fsl,
//
//@Semantics.currencyCode:true
//P_GLAcctBalance1.rgcur as rgcur,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rgcur'} } cast( 0 as vlcur12 ) as gsl,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rhcur'} } 
//P_GLAcctBalance1.hsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rhcur'} } 
//P_GLAcctBalance1.hsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rwcur'} } 
//P_GLAcctBalance1.wsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rwcur'} } 
//P_GLAcctBalance1.wsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rtcur'} } 
//P_GLAcctBalance1.tsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rtcur'} } 
//P_GLAcctBalance1.tsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rkcur'} } 
//P_GLAcctBalance1.ksl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rkcur'} } 
//P_GLAcctBalance1.ksl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
//P_GLAcctBalance1.DebitAmountInFunctionalCrcy,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
//P_GLAcctBalance1.CreditAmountInFunctionalCrcy,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rocur'} } 
//P_GLAcctBalance1.osl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rocur'} } 
//P_GLAcctBalance1.osl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rvcur'} } 
//P_GLAcctBalance1.vsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rvcur'} } 
//P_GLAcctBalance1.vsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rbcur'} } 
//P_GLAcctBalance1.bsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rbcur'} } 
//P_GLAcctBalance1.bsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rccur'} } 
//P_GLAcctBalance1.csl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rccur'} } 
//P_GLAcctBalance1.csl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rdcur'} } 
//P_GLAcctBalance1.dsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rdcur'} } 
//P_GLAcctBalance1.dsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'recur'} } 
//P_GLAcctBalance1.esl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'recur'} } 
//P_GLAcctBalance1.esl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rfcur'} } 
//P_GLAcctBalance1.fsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rfcur'} } 
//P_GLAcctBalance1.fsl_credit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rgcur'} } 
//P_GLAcctBalance1.gsl_debit,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rgcur'} } 
//P_GLAcctBalance1.gsl_credit,
//
//P_GLAcctBalance1.poper,
//
//P_GLAcctBalance1.OffsettingChartOfAccounts,
//P_GLAcctBalance1.JrnlEntryItemObsoleteReason,
//
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rhcur'} } 
//P_GLAcctBalance1.hsl_end_bal,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rwcur'} } 
//P_GLAcctBalance1.wsl_end_bal,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rtcur'} } 
//P_GLAcctBalance1.tsl_end_bal,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rkcur'} } 
//P_GLAcctBalance1.ksl_end_bal,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'FunctionalCurrency'} } 
//P_GLAcctBalance1.EndingBalanceAmtInFuncnlCrcy,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rocur'} } 
//P_GLAcctBalance1.osl_end_bal,
//@DefaultAggregation: #SUM
//@Semantics: { amount : {currencyCode: 'rvcur'} } 
//P_GLAcctBalance1.vsl_end_bal,
//@DefaultAggregation:#SUM
//@Semantics: { amount : {currencyCode: 'rbcur'} } 
//P_GLAcctBalance1.bsl_end_bal,
//@DefaultAggregation:#SUM
//@Semantics: { amount : {currencyCode: 'rccur'} } 
//P_GLAcctBalance1.csl_end_bal,
//@DefaultAggregation:#SUM
//@Semantics: { amount : {currencyCode: 'rdcur'} } 
//P_GLAcctBalance1.dsl_end_bal,
//@DefaultAggregation:#SUM
//@Semantics: { amount : {currencyCode: 'recur'} } 
//P_GLAcctBalance1.esl_end_bal,
//@DefaultAggregation:#SUM
//@Semantics: { amount : {currencyCode: 'rfcur'} } 
//P_GLAcctBalance1.fsl_end_bal,
//@DefaultAggregation:#SUM
//@Semantics: { amount : {currencyCode: 'rgcur'} } 
//P_GLAcctBalance1.gsl_end_bal,
//
//
//cast( '    ' as brgru preserving type ) as GLAccountAuthorizationGroup,
//cast( '    ' as brgru preserving type ) as SupplierBasicAuthorizationGrp,
//cast( '    ' as brgru preserving type ) as CustomerBasicAuthorizationGrp,
//cast( '    ' as brgru preserving type ) as AcctgDocTypeAuthorizationGroup,
//cast( '    ' as aufart preserving type ) as OrderType,
//cast( '    ' as auart preserving type ) as SalesOrderType,
////cast( '' as anlkl) as AssetClass,     
//AssetClass,
//
//P_GLAcctBalance1.FiscalPeriodDate,
//AccrualObjectType,
//AccrualObject,
//AccrualSubobject,
//AccrualItemType,
//AccrualObjectLogicalSystem,
//AccrualReferenceObject,
//AccrualValueDate,  
//CashLedgerCompanyCode,
//CashLedgerAccount,
//FundsCenter,
//FundedProgram,
//Fund,
//GrantID,
//BudgetPeriod,
//PartnerFund,
//PartnerGrant,
//PartnerBudgetPeriod,
//PubSecBudgetAccount,
//PubSecBudgetAccountCoCode,
//PubSecBudgetCnsmpnDate,
//PubSecBudgetCnsmpnFsclPeriod,
//PubSecBudgetCnsmpnFsclYear,
//PubSecBudgetIsRelevant,
//PubSecBudgetCnsmpnType,
//PubSecBudgetCnsmpnAmtType,
//
//FlowOfFundsLedgerFiscalYear,
//
//IsStatisticalCostCenter,
//IsStatisticalOrder,
//IsStatisticalSalesDocument,
//WBSIsStatisticalWBSElement,
//
//// Associations
////_PartnerProjectExternalID,
////_PartnerProjctExtrnalIDText,
////_PartnerWBSElementExternalID,
////_PartnerWBSElemntExtrnalIDText,
////_PartnerProjectBasicData,
////_PartnerProjectBasicDataText,
////_PartnerWBSElementBasicData,
////_PartnerWBSElmntBasicDataText,
//
////_InvtrySpclStockWBSElmntBD,
////P_GLAcctBalance1._InvtrySpclStockWBSElmntExtID,
//
////P_GLAcctBalance1._ServiceContract,
////P_GLAcctBalance1._ServiceContractItem,
////P_GLAcctBalance1._ServiceContractType,
////P_GLAcctBalance1._TimeSheetOvertimeCat,
//
////P_GLAcctBalance1._AccrualObjectType,
////P_GLAcctBalance1._AccrualObject,
////P_GLAcctBalance1._AccrualSubobject,
////P_GLAcctBalance1._AccrualItemType, 
//
////_CashLedgerCompanyCode,
////_CashLedgerAccount,
////_FinancialManagementArea,
////_FundsCenter,
////_FundedProgram,
////_Fund,
////_Grant,
////_BudgetPeriod,
////_PartnerFund,
////_PartnerGrant,
////_PartnerBudgetPeriod,
////_PubSecBudgetAccountCoCode,
////_PubSecBudgetAccount,
////_PubSecBudgetCnsmpnDate,
////_PubSecBudgetCnsmpnFsclPeriod,
////_PubSecBudgetCnsmpnFsclYear,
////_PubSecBudgetCnsmpnType,
////_PubSecBudgetCnsmpnAmtType,  
////_FunctionalCurrency,
////_ConsolidationUnit,
////_PartnerConsolidationUnit,
////_Company,
////_ConsolidationChartOfAccounts,
////_CnsldtnFinancialStatementItem,
////_CnsldtnSubitemCategory,
////_CnsldtnSubitem, 
////_CustomerCompany,
////_SupplierCompany,
//cast( '3         ' as fis_glaccount_flow_type preserving type ) as GLAccountFlowType
//}
//where P_GLAcctBalance1.budat between $parameters.P_FromPostingDate and $parameters.P_ToPostingDate      
//where P_GLAcctBalance1.budat >= $parameters.P_FromPostingDate         
  
  
 