﻿
CREATE VIEW [SONDA].[ERP_VIEW_INVOICE_HEADER]
AS
SELECT
	NULL [DocEntry]
 ,null[DocNum]
 ,null[DocType]
 ,null[CANCELED]
 ,null[Handwrtten]
 ,null[Printed]
 ,null[DocStatus]
 ,null[InvntSttus]
 ,null[Transfered]
 ,null[ObjType]
 ,null[DocDate]
 ,null[DocDueDate]
 ,null[CardCode]
 ,null[CardName]
 ,null[Address]
 ,null[NumAtCard]
 ,null[VatPercent]
 ,null[VatSum]
 ,null[VatSumFC]
 ,null[DiscPrcnt]
 ,null[DiscSum]
 ,null[DiscSumFC]
 ,null[DocCur]
 ,null[DocRate]
 ,null[DocTotal]
 ,null[DocTotalFC]
 ,null[PaidToDate]
 ,null[PaidFC]
 ,null[GrosProfit]
 ,null[GrosProfFC]
 ,null[Ref1]
 ,null[Ref2]
 ,null[Comments]
 ,null[JrnlMemo]
 ,null[TransId]
 ,null[ReceiptNum]
 ,null[GroupNum]
 ,null[DocTime]
 ,null[SlpCode]
 ,null[TrnspCode]
 ,null[PartSupply]
 ,null[Confirmed]
 ,null[GrossBase]
 ,null[ImportEnt]
 ,null[CreateTran]
 ,null[SummryType]
 ,null[UpdInvnt]
 ,null[UpdCardBal]
 ,null[Instance]
 ,null[Flags]
 ,null[InvntDirec]
 ,null[CntctCode]
 ,null[ShowSCN]
 ,null[FatherCard]
 ,null[SysRate]
 ,null[CurSource]
 ,null[VatSumSy]
 ,null[DiscSumSy]
 ,null[DocTotalSy]
 ,null[PaidSys]
 ,null[FatherType]
 ,null[GrosProfSy]
 ,null[UpdateDate]
 ,null[IsICT]
 ,null[CreateDate]
 ,null[Volume]
 ,null[VolUnit]
 ,null[Weight]
 ,null[WeightUnit]
 ,null[Series]
 ,null[TaxDate]
 ,null[Filler]
 ,null[DataSource]
 ,null[StampNum]
 ,null[isCrin]
 ,null[FinncPriod]
 ,null[UserSign]
 ,null[selfInv]
 ,null[VatPaid]
 ,null[VatPaidFC]
 ,null[VatPaidSys]
 ,null[UserSign2]
 ,null[WddStatus]
 ,null[draftKey]
 ,null[TotalExpns]
 ,null[TotalExpFC]
 ,null[TotalExpSC]
 ,null[DunnLevel]
 ,null[Address2]
 ,null[LogInstanc]
 ,null[Exported]
 ,null[StationID]
 ,null[Indicator]
 ,null[NetProc]
 ,null[AqcsTax]
 ,null[AqcsTaxFC]
 ,null[AqcsTaxSC]
 ,null[CashDiscPr]
 ,null[CashDiscnt]
 ,null[CashDiscFC]
 ,null[CashDiscSC]
 ,null[ShipToCode]
 ,null[LicTradNum]
 ,null[PaymentRef]
 ,null[WTSum]
 ,null[WTSumFC]
 ,null[WTSumSC]
 ,null[RoundDif]
 ,null[RoundDifFC]
 ,null[RoundDifSy]
 ,null[CheckDigit]
 ,null[Form1099]
 ,null[Box1099]
 ,null[submitted]
 ,null[PoPrss]
 ,null[Rounding]
 ,null[RevisionPo]
 ,null[Segment]
 ,null[ReqDate]
 ,null[CancelDate]
 ,null[PickStatus]
 ,null[Pick]
 ,null[BlockDunn]
 ,null[PeyMethod]
 ,null[PayBlock]
 ,null[PayBlckRef]
 ,null[MaxDscn]
 ,null[Reserve]
 ,null[Max1099]
 ,null[CntrlBnk]
 ,null[PickRmrk]
 ,null[ISRCodLine]
 ,null[ExpAppl]
 ,null[ExpApplFC]
 ,null[ExpApplSC]
 ,null[Project]
 ,null[DeferrTax]
 ,null[LetterNum]
 ,null[FromDate]
 ,null[ToDate]
 ,null[WTApplied]
 ,null[WTAppliedF]
 ,null[BoeReserev]
 ,null[AgentCode]
 ,null[WTAppliedS]
 ,null[EquVatSum]
 ,null[EquVatSumF]
 ,null[EquVatSumS]
 ,null[Installmnt]
 ,null[VATFirst]
 ,null[NnSbAmnt]
 ,null[NnSbAmntSC]
 ,null[NbSbAmntFC]
 ,null[ExepAmnt]
 ,null[ExepAmntSC]
 ,null[ExepAmntFC]
 ,null[VatDate]
 ,null[CorrExt]
 ,null[CorrInv]
 ,null[NCorrInv]
 ,null[CEECFlag]
 ,null[BaseAmnt]
 ,null[BaseAmntSC]
 ,null[BaseAmntFC]
 ,null[CtlAccount]
 ,null[BPLId]
 ,null[BPLName]
 ,null[VATRegNum]
 ,null[TxInvRptNo]
 ,null[TxInvRptDt]
 ,null[KVVATCode]
 ,null[WTDetails]
 ,null[SumAbsId]
 ,null[SumRptDate]
 ,null[PIndicator]
 ,null[ManualNum]
 ,null[UseShpdGd]
 ,null[BaseVtAt]
 ,null[BaseVtAtSC]
 ,null[BaseVtAtFC]
 ,null[NnSbVAt]
 ,null[NnSbVAtSC]
 ,null[NbSbVAtFC]
 ,null[ExptVAt]
 ,null[ExptVAtSC]
 ,null[ExptVAtFC]
 ,null[LYPmtAt]
 ,null[LYPmtAtSC]
 ,null[LYPmtAtFC]
 ,null[ExpAnSum]
 ,null[ExpAnSys]
 ,null[ExpAnFrgn]
 ,null[DocSubType]
 ,null[DpmStatus]
 ,null[DpmAmnt]
 ,null[DpmAmntSC]
 ,null[DpmAmntFC]
 ,null[DpmDrawn]
 ,null[DpmPrcnt]
 ,null[PaidSum]
 ,null[PaidSumFc]
 ,null[PaidSumSc]
 ,null[FolioPref]
 ,null[FolioNum]
 ,null[DpmAppl]
 ,null[DpmApplFc]
 ,null[DpmApplSc]
 ,null[LPgFolioN]
 ,null[Header]
 ,null[Footer]
 ,null[Posted]
 ,null[OwnerCode]
 ,null[BPChCode]
 ,null[BPChCntc]
 ,null[PayToCode]
 ,null[IsPaytoBnk]
 ,null[BnkCntry]
 ,null[BankCode]
 ,null[BnkAccount]
 ,null[BnkBranch]
 ,null[isIns]
 ,null[TrackNo]
 ,null[VersionNum]
 ,null[LangCode]
 ,null[BPNameOW]
 ,null[BillToOW]
 ,null[ShipToOW]
 ,null[RetInvoice]
 ,null[ClsDate]
 ,null[MInvNum]
 ,null[MInvDate]
 ,null[SeqCode]
 ,null[Serial]
 ,null[SeriesStr]
 ,null[SubStr]
 ,null[Model]
 ,null[TaxOnExp]
 ,null[TaxOnExpFc]
 ,null[TaxOnExpSc]
 ,null[TaxOnExAp]
 ,null[TaxOnExApF]
 ,null[TaxOnExApS]
 ,null[LastPmnTyp]
 ,null[LndCstNum]
 ,null[UseCorrVat]
 ,null[BlkCredMmo]
 ,null[OpenForLaC]
 ,null[Excised]
 ,null[ExcRefDate]
 ,null[ExcRmvTime]
 ,null[SrvGpPrcnt]
 ,null[DepositNum]
 ,null[CertNum]
 ,null[DutyStatus]
 ,null[AutoCrtFlw]
 ,null[FlwRefDate]
 ,null[FlwRefNum]
 ,null[VatJENum]
 ,null[DpmVat]
 ,null[DpmVatFc]
 ,null[DpmVatSc]
 ,null[DpmAppVat]
 ,null[DpmAppVatF]
 ,null[DpmAppVatS]
 ,null[InsurOp347]
 ,null[IgnRelDoc]
 ,null[BuildDesc]
 ,null[ResidenNum]
 ,null[Checker]
 ,null[Payee]
 ,null[CopyNumber]
 ,null[SSIExmpt]
 ,null[PQTGrpSer]
 ,null[PQTGrpNum]
 ,null[PQTGrpHW]
 ,null[ReopOriDoc]
 ,null[ReopManCls]
 ,null[DocManClsd]
 ,null[ClosingOpt]
 ,null[SpecDate]
 ,null[Ordered]
 ,null[NTSApprov]
 ,null[NTSWebSite]
 ,null[NTSeTaxNo]
 ,null[NTSApprNo]
 ,null[PayDuMonth]
 ,null[ExtraMonth]
 ,null[ExtraDays]
 ,null[CdcOffset]
 ,null[SignMsg]
 ,null[SignDigest]
 ,null[CertifNum]
 ,null[KeyVersion]
 ,null[EDocGenTyp]
 ,null[ESeries]
 ,null[EDocNum]
 ,null[EDocExpFrm]
 ,null[OnlineQuo]
 ,null[POSEqNum]
 ,null[POSManufSN]
 ,null[POSCashN]
 ,null[EDocStatus]
 ,null[EDocCntnt]
 ,null[EDocProces]
 ,null[EDocErrCod]
 ,null[EDocErrMsg]
 ,null[EDocCancel]
 ,null[EDocTest]
 ,null[EDocPrefix]
 ,null[CUP]
 ,null[CIG]
 ,null[DpmAsDscnt]
 ,null[Attachment]
 ,null[AtcEntry]
 ,null[SupplCode]
 ,null[GTSRlvnt]
 ,null[BaseDisc]
 ,null[BaseDiscSc]
 ,null[BaseDiscFc]
 ,null[BaseDiscPr]
 ,null[CreateTS]
 ,null[UpdateTS]
 ,null[SrvTaxRule]
 ,null[AnnInvDecR]
 ,null[Supplier]
 ,null[Releaser]
 ,null[Receiver]
 ,null[ToWhsCode]
 ,null[AssetDate]
 ,null[Requester]
 ,null[ReqName]
 ,null[Branch]
 ,null[Department]
 ,null[Email]
 ,null[Notify]
 ,null[ReqType]
 ,null[OriginType]
 ,null[IsReuseNum]
 ,null[IsReuseNFN]
 ,null[DocDlvry]
 ,null[PaidDpm]
 ,null[PaidDpmF]
 ,null[PaidDpmS]
 ,null[EnvTypeNFe]
 ,null[AgrNo]
 ,null[IsAlt]
 ,null[AltBaseTyp]
 ,null[AltBaseEnt]
 ,null[AuthCode]
 ,null[StDlvDate]
 ,null[StDlvTime]
 ,null[EndDlvDate]
 ,null[EndDlvTime]
 ,null[VclPlate]
 ,null[ElCoStatus]
 ,null[AtDocType]
 ,null[ElCoMsg]
 ,null[PrintSEPA]
 ,null[FreeChrg]
 ,null[FreeChrgFC]
 ,null[FreeChrgSC]
 ,null[NfeValue]
 ,null[FiscDocNum]
 ,null[RelatedTyp]
 ,null[RelatedEnt]
 ,null[CCDEntry]
 ,null[NfePrntFo]
 ,null[ZrdAbs]
 ,null[POSRcptNo]
 ,null[FoCTax]
 ,null[FoCTaxFC]
 ,null[FoCTaxSC]
 ,null[TpCusPres]
 ,null[ExcDocDate]
 ,null[U_OPER]
 ,null[U_Serie]
--from OPENQUERY([ERP_SERVER],'SELECT * FROM [Prueba].dbo.OINV')