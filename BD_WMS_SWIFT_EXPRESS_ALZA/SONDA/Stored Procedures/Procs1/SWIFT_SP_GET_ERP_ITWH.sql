-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-21-2016
-- Description:			obtiene una orden de venta del ERP que esté abierta 

-- Modificado Fecha
		-- anonymous
		-- sin motivo

/*
-- Ejemplo de Ejecucion:
      USE SWIFT_EXPRESS
      GO
      
      DECLARE @RC int
      DECLARE @PICKING_HEADER int
      
      SET @PICKING_HEADER = 0 
      
      EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_ITWH @PICKING_HEADER
      GO
*/
CREATE PROC [SONDA].SWIFT_SP_GET_ERP_ITWH 
@PICKING_HEADER VARCHAR(50)
AS 
DECLARE @SCHEMA VARCHAR(20)='SONDA';
DECLARE @DOC_SAP_RECEPTION VARCHAR(MAX)='-1';
DECLARE @SQL VARCHAR(MAX);


SELECT @DOC_SAP_RECEPTION= ISNULL(DOC_SAP_RECEPTION,'-1') FROM SWIFT_PICKING_HEADER sph
  WHERE sph.PICKING_HEADER= @PICKING_HEADER;


SELECT  @SQL = '	
SELECT     TOP (1) 
so.DocNum as DocNum,
'+@PICKING_HEADER+' AS DocEntry, 
T.CLASSIFICATION_PICKING Classification,
so.CardCode AS CardCode, 
so.CardName AS CardName, 
''N'' AS HandWritten, 
t.last_update AS DocDate, 
so.Comments,
so.DocCur AS DocCur, 
so.DocRate AS DocRate, 
so.DiscPrcnt AS DiscPrcnt, 
so.Address, so.Address2, 
so.ShipToAddressType, 
so.ShipToStreet, 
so.ShipToState, 
so.ShipToCountry,
so.TrnspCode AS TrnspCode, 
so.DocDueDate AS DocDueDate, 
so.SlpCode AS SalesPersonCode, 
''01'' AS Warehouse, 
CAST(NULL AS varchar) AS UEstado2, 
CAST(NULL AS varchar) AS UStatusDespacho, 
CAST(NULL AS varchar) AS UUsuario, 
CAST(NULL AS varchar) AS UFacSerie, 
CAST(NULL AS varchar) AS UFacNit, 
CAST(NULL AS varchar) AS UFacNom, 
CAST(NULL AS varchar) AS UTienda, 
CAST(NULL AS varchar) AS USucursal, 
CAST(NULL AS varchar) AS UTipoDocumento, 
CAST(NULL AS varchar) AS UTotalFlete, 
CAST(NULL AS varchar) AS UTipoPago, 
CAST(NULL AS varchar) AS UCuotas, 
CAST(NULL AS varchar) AS UTotalTarjeta
FROM         ['+@SCHEMA+'].[SWIFT_PICKING_HEADER] AS t INNER JOIN
                          (SELECT     so.DocEntry, so.DocNum, so.DocType, so.CANCELED, so.Handwrtten, so.Printed, so.DocStatus, so.InvntSttus, so.Transfered, so.ObjType, so.DocDate, so.DocDueDate, so.CardCode, 
                                                   so.CardName, so.Address, so.NumAtCard, so.VatPercent, so.VatSum, so.VatSumFC, so.DiscPrcnt, so.DiscSum, so.DiscSumFC, so.DocCur, so.DocRate, so.DocTotal, so.DocTotalFC, 
                                                   so.PaidToDate, so.PaidFC, so.GrosProfit, so.GrosProfFC, so.Ref1, so.Ref2, so.Comments, so.JrnlMemo, so.TransId, so.ReceiptNum, so.GroupNum, so.DocTime, so.SlpCode, 
                                                   so.TrnspCode, so.PartSupply, so.Confirmed, so.GrossBase, so.ImportEnt, so.CreateTran, so.SummryType, so.UpdInvnt, so.UpdCardBal, so.Instance, so.Flags, so.InvntDirec, 
                                                   so.CntctCode, so.ShowSCN, so.FatherCard, so.SysRate, so.CurSource, so.VatSumSy, so.DiscSumSy, so.DocTotalSy, so.PaidSys, so.FatherType, so.GrosProfSy, so.UpdateDate, 
                                                   so.IsICT, so.CreateDate, so.Volume, so.VolUnit, so.Weight, so.WeightUnit, so.Series, so.TaxDate, so.Filler, so.DataSource, so.StampNum, so.isCrin, so.FinncPriod, so.UserSign, 
                                                   so.selfInv, so.VatPaid, so.VatPaidFC, so.VatPaidSys, so.UserSign2, so.WddStatus, so.draftKey, so.TotalExpns, so.TotalExpFC, so.TotalExpSC, so.DunnLevel, so.Address2, 
                                                   so.LogInstanc, so.Exported, so.StationID, so.Indicator, so.NetProc, so.AqcsTax, so.AqcsTaxFC, so.AqcsTaxSC, so.CashDiscPr, so.CashDiscnt, so.CashDiscFC, so.CashDiscSC, 
                                                   so.ShipToCode, so.LicTradNum, so.PaymentRef, so.WTSum, so.WTSumFC, so.WTSumSC, so.RoundDif, so.RoundDifFC, so.RoundDifSy, so.CheckDigit, so.Form1099, so.Box1099, 
                                                   so.submitted, so.PoPrss, so.Rounding, so.RevisionPo, so.Segment, so.ReqDate, so.CancelDate, so.PickStatus, so.Pick, so.BlockDunn, so.PeyMethod, so.PayBlock, so.PayBlckRef, 
                                                   so.MaxDscn, so.Reserve, so.Max1099, so.CntrlBnk, so.PickRmrk, so.ISRCodLine, so.ExpAppl, so.ExpApplFC, so.ExpApplSC, so.Project, so.DeferrTax, so.LetterNum, so.FromDate, 
                                                   so.ToDate, so.WTApplied, so.WTAppliedF, so.BoeReserev, so.AgentCode, so.WTAppliedS, so.EquVatSum, so.EquVatSumF, so.EquVatSumS, so.Installmnt, so.VATFirst, so.NnSbAmnt, 
                                                   so.NnSbAmntSC, so.NbSbAmntFC, so.ExepAmnt, so.ExepAmntSC, so.ExepAmntFC, so.VatDate, so.CorrExt, so.CorrInv, so.NCorrInv, so.CEECFlag, so.BaseAmnt, so.BaseAmntSC, 
                                                   so.BaseAmntFC, so.CtlAccount, so.BPLId, so.BPLName, so.VATRegNum, so.TxInvRptNo, so.TxInvRptDt, so.KVVATCode, so.WTDetails, so.SumAbsId, so.SumRptDate, so.PIndicator, 
                                                   so.ManualNum, so.UseShpdGd, so.BaseVtAt, so.BaseVtAtSC, so.BaseVtAtFC, so.NnSbVAt, so.NnSbVAtSC, so.NbSbVAtFC, so.ExptVAt, so.ExptVAtSC, so.ExptVAtFC, so.LYPmtAt, 
                                                   so.LYPmtAtSC, so.LYPmtAtFC, so.ExpAnSum, so.ExpAnSys, so.ExpAnFrgn, so.DocSubType, so.DpmStatus, so.DpmAmnt, so.DpmAmntSC, so.DpmAmntFC, so.DpmDrawn, so.DpmPrcnt, 
                                                   so.PaidSum, so.PaidSumFc, so.PaidSumSc, so.FolioPref, so.FolioNum, so.DpmAppl, so.DpmApplFc, so.DpmApplSc, so.LPgFolioN, so.Header, so.Footer, so.Posted, so.OwnerCode, 
                                                   so.BPChCode, so.BPChCntc, so.PayToCode, so.IsPaytoBnk, so.BnkCntry, so.BankCode, so.BnkAccount, so.BnkBranch, so.isIns, so.TrackNo, so.VersionNum, so.LangCode, 
                                                   so.BPNameOW, so.BillToOW, so.ShipToOW, so.RetInvoice, so.ClsDate, so.MInvNum, so.MInvDate, so.SeqCode, so.Serial, so.SeriesStr, so.SubStr, so.Model, so.TaxOnExp, 
                                                   so.TaxOnExpFc, so.TaxOnExpSc, so.TaxOnExAp, so.TaxOnExApF, so.TaxOnExApS, so.LastPmnTyp, so.LndCstNum, so.UseCorrVat, so.BlkCredMmo, so.OpenForLaC, so.Excised, 
                                                   so.ExcRefDate, so.ExcRmvTime, so.SrvGpPrcnt, so.DepositNum, so.CertNum, so.DutyStatus, so.AutoCrtFlw, so.FlwRefDate, so.FlwRefNum, so.VatJENum, so.DpmVat, so.DpmVatFc, 
                                                   so.DpmVatSc, so.DpmAppVat, so.DpmAppVatF, so.DpmAppVatS, so.InsurOp347, so.IgnRelDoc, so.BuildDesc, so.ResidenNum, so.Checker, so.Payee, so.CopyNumber, so.SSIExmpt, 
                                                   so.PQTGrpSer, so.PQTGrpNum, so.PQTGrpHW, so.ReopOriDoc, so.ReopManCls, so.DocManClsd, so.ClosingOpt, so.SpecDate, so.Ordered, so.NTSApprov, so.NTSWebSite, 
                                                   so.NTSeTaxNo, so.NTSApprNo, so.PayDuMonth, so.ExtraMonth, so.ExtraDays, so.CdcOffset, so.SignMsg, so.SignDigest, so.CertifNum, so.KeyVersion, so.EDocGenTyp, so.ESeries, 
                                                   so.EDocNum, so.EDocExpFrm, so.OnlineQuo, so.POSEqNum, so.POSManufSN, so.POSCashN, so.EDocStatus, so.EDocCntnt, so.EDocProces, so.EDocErrCod, so.EDocErrMsg, 
                                                   so.EDocCancel, so.EDocTest, so.EDocPrefix, so.CUP, so.CIG, so.DpmAsDscnt, so.Attachment, so.AtcEntry, so.SupplCode, so.GTSRlvnt, so.BaseDisc, so.BaseDiscSc, so.BaseDiscFc, 
                                                   so.BaseDiscPr, so.CreateTS, so.UpdateTS, so.SrvTaxRule, so.AnnInvDecR, so.Supplier, so.Releaser, so.Receiver, so.AgrNo, so.IsAlt, so.AltBaseTyp, so.AltBaseEnt, so.PaidDpm, 
                                                   so.PaidDpmF, so.PaidDpmS, so.U_Guatex UGuatex, so.U_KM UKm, so.Ship_To_Address_Type AS ShipToAddressType, so.Ship_To_Street AS ShipToStreet, so.Ship_To_State AS ShipToState, 
                                                   so.Ship_To_Country AS ShipToCountry
                            FROM 
                            
		(select * from openquery ([ERPSERVER],
		'' 
		
		SELECT
  so.DocEntry, so.DocNum, so.DocType, so.CANCELED, so.Handwrtten, so.Printed, so.DocStatus, so.InvntSttus, so.Transfered, so.ObjType, so.DocDate, so.DocDueDate, so.CardCode, 
                                                   so.CardName, so.Address, so.NumAtCard, so.VatPercent, so.VatSum, so.VatSumFC, so.DiscPrcnt, so.DiscSum, so.DiscSumFC, so.DocCur, so.DocRate, so.DocTotal, so.DocTotalFC, 
                                                   so.PaidToDate, so.PaidFC, so.GrosProfit, so.GrosProfFC, so.Ref1, so.Ref2, so.Comments, so.JrnlMemo, so.TransId, so.ReceiptNum, so.GroupNum, so.DocTime, so.SlpCode, 
                                                   so.TrnspCode, so.PartSupply, so.Confirmed, so.GrossBase, so.ImportEnt, so.CreateTran, so.SummryType, so.UpdInvnt, so.UpdCardBal, so.Instance, so.Flags, so.InvntDirec, 
                                                   so.CntctCode, so.ShowSCN, so.FatherCard, so.SysRate, so.CurSource, so.VatSumSy, so.DiscSumSy, so.DocTotalSy, so.PaidSys, so.FatherType, so.GrosProfSy, so.UpdateDate, 
                                                   so.IsICT, so.CreateDate, so.Volume, so.VolUnit, so.Weight, so.WeightUnit, so.Series, so.TaxDate, so.Filler, so.DataSource, so.StampNum, so.isCrin, so.FinncPriod, so.UserSign, 
                                                   so.selfInv, so.VatPaid, so.VatPaidFC, so.VatPaidSys, so.UserSign2, so.WddStatus, so.draftKey, so.TotalExpns, so.TotalExpFC, so.TotalExpSC, so.DunnLevel, so.Address2, 
                                                   so.LogInstanc, so.Exported, so.StationID, so.Indicator, so.NetProc, so.AqcsTax, so.AqcsTaxFC, so.AqcsTaxSC, so.CashDiscPr, so.CashDiscnt, so.CashDiscFC, so.CashDiscSC, 
                                                   so.ShipToCode, so.LicTradNum, so.PaymentRef, so.WTSum, so.WTSumFC, so.WTSumSC, so.RoundDif, so.RoundDifFC, so.RoundDifSy, so.CheckDigit, so.Form1099, so.Box1099, 
                                                   so.submitted, so.PoPrss, so.Rounding, so.RevisionPo, so.Segment, so.ReqDate, so.CancelDate, so.PickStatus, so.Pick, so.BlockDunn, so.PeyMethod, so.PayBlock, so.PayBlckRef, 
                                                   so.MaxDscn, so.Reserve, so.Max1099, so.CntrlBnk, so.PickRmrk, so.ISRCodLine, so.ExpAppl, so.ExpApplFC, so.ExpApplSC, so.Project, so.DeferrTax, so.LetterNum, so.FromDate, 
                                                   so.ToDate, so.WTApplied, so.WTAppliedF, so.BoeReserev, so.AgentCode, so.WTAppliedS, so.EquVatSum, so.EquVatSumF, so.EquVatSumS, so.Installmnt, so.VATFirst, so.NnSbAmnt, 
                                                   so.NnSbAmntSC, so.NbSbAmntFC, so.ExepAmnt, so.ExepAmntSC, so.ExepAmntFC, so.VatDate, so.CorrExt, so.CorrInv, so.NCorrInv, so.CEECFlag, so.BaseAmnt, so.BaseAmntSC, 
                                                   so.BaseAmntFC, so.CtlAccount, so.BPLId, so.BPLName, so.VATRegNum, so.TxInvRptNo, so.TxInvRptDt, so.KVVATCode, so.WTDetails, so.SumAbsId, so.SumRptDate, so.PIndicator, 
                                                   so.ManualNum, so.UseShpdGd, so.BaseVtAt, so.BaseVtAtSC, so.BaseVtAtFC, so.NnSbVAt, so.NnSbVAtSC, so.NbSbVAtFC, so.ExptVAt, so.ExptVAtSC, so.ExptVAtFC, so.LYPmtAt, 
                                                   so.LYPmtAtSC, so.LYPmtAtFC, so.ExpAnSum, so.ExpAnSys, so.ExpAnFrgn, so.DocSubType, so.DpmStatus, so.DpmAmnt, so.DpmAmntSC, so.DpmAmntFC, so.DpmDrawn, so.DpmPrcnt, 
                                                   so.PaidSum, so.PaidSumFc, so.PaidSumSc, so.FolioPref, so.FolioNum, so.DpmAppl, so.DpmApplFc, so.DpmApplSc, so.LPgFolioN, so.Header, so.Footer, so.Posted, so.OwnerCode, 
                                                   so.BPChCode, so.BPChCntc, so.PayToCode, so.IsPaytoBnk, so.BnkCntry, so.BankCode, so.BnkAccount, so.BnkBranch, so.isIns, so.TrackNo, so.VersionNum, so.LangCode, 
                                                   so.BPNameOW, so.BillToOW, so.ShipToOW, so.RetInvoice, so.ClsDate, so.MInvNum, so.MInvDate, so.SeqCode, so.Serial, so.SeriesStr, so.SubStr, so.Model, so.TaxOnExp, 
                                                   so.TaxOnExpFc, so.TaxOnExpSc, so.TaxOnExAp, so.TaxOnExApF, so.TaxOnExApS, so.LastPmnTyp, so.LndCstNum, so.UseCorrVat, so.BlkCredMmo, so.OpenForLaC, so.Excised, 
                                                   so.ExcRefDate, so.ExcRmvTime, so.SrvGpPrcnt, so.DepositNum, so.CertNum, so.DutyStatus, so.AutoCrtFlw, so.FlwRefDate, so.FlwRefNum, so.VatJENum, so.DpmVat, so.DpmVatFc, 
                                                   so.DpmVatSc, so.DpmAppVat, so.DpmAppVatF, so.DpmAppVatS, so.InsurOp347, so.IgnRelDoc, so.BuildDesc, so.ResidenNum, so.Checker, so.Payee, so.CopyNumber, so.SSIExmpt, 
                                                   so.PQTGrpSer, so.PQTGrpNum, so.PQTGrpHW, so.ReopOriDoc, so.ReopManCls, so.DocManClsd, so.ClosingOpt, so.SpecDate, so.Ordered, so.NTSApprov, so.NTSWebSite, 
                                                   so.NTSeTaxNo, so.NTSApprNo, so.PayDuMonth, so.ExtraMonth, so.ExtraDays, so.CdcOffset, so.SignMsg, so.SignDigest, so.CertifNum, so.KeyVersion, so.EDocGenTyp, so.ESeries, 
                                                   so.EDocNum, so.EDocExpFrm, so.OnlineQuo, so.POSEqNum, so.POSManufSN, so.POSCashN, so.EDocStatus, so.EDocCntnt, so.EDocProces, so.EDocErrCod, so.EDocErrMsg, 
                                                   so.EDocCancel, so.EDocTest, so.EDocPrefix, so.CUP, so.CIG, so.DpmAsDscnt, so.Attachment, so.AtcEntry, so.SupplCode, so.GTSRlvnt, so.BaseDisc, so.BaseDiscSc, so.BaseDiscFc, 
                                                   so.BaseDiscPr, so.CreateTS, so.UpdateTS, so.SrvTaxRule, so.AnnInvDecR, so.Supplier, so.Releaser, so.Receiver, so.AgrNo, so.IsAlt, so.AltBaseTyp, so.AltBaseEnt, so.PaidDpm, 
                                                   so.PaidDpmF, so.PaidDpmS, NULL U_Guatex, NULL U_KM, ae.AddrTypeS AS Ship_To_Address_Type, ae.StreetS AS Ship_To_Street, ae.StateS AS Ship_To_State, 
                                                   ae.CountryS AS Ship_To_Country
FROM  [PRUEBA].dbo.OWTQ AS so  LEFT OUTER JOIN
                                                   [PRUEBA].dbo.WTQ12 AS ae ON ae.DocEntry = so.DocEntry                                                   
			WHERE  (so.DocNum = '+@DOC_SAP_RECEPTION+')  				
		'')) as so  ) AS so ON so.DocNum = t.DOC_SAP_RECEPTION
WHERE     (so.DocStatus = ''O'') AND (so.DocType = ''I'') 
and t.picking_header ='+ @PICKING_HEADER+'
  AND t.CLASSIFICATION_PICKING= 3
';
EXEC(@SQL);
