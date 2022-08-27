﻿CREATE TABLE [wms].[Productos$] (
    [ItemCode]        NVARCHAR (255) NULL,
    [ItemName]        NVARCHAR (255) NULL,
    [FrgnName]        NVARCHAR (255) NULL,
    [ItmsGrpCod]      FLOAT (53)     NULL,
    [CstGrpCode]      FLOAT (53)     NULL,
    [VatGourpSa]      NVARCHAR (255) NULL,
    [CodeBars]        NVARCHAR (255) NULL,
    [VATLiable]       NVARCHAR (255) NULL,
    [PrchseItem]      NVARCHAR (255) NULL,
    [SellItem]        NVARCHAR (255) NULL,
    [InvntItem]       NVARCHAR (255) NULL,
    [OnHand]          FLOAT (53)     NULL,
    [IsCommited]      FLOAT (53)     NULL,
    [OnOrder]         FLOAT (53)     NULL,
    [IncomeAcct]      NVARCHAR (255) NULL,
    [ExmptIncom]      NVARCHAR (255) NULL,
    [MaxLevel]        FLOAT (53)     NULL,
    [DfltWH]          NVARCHAR (255) NULL,
    [CardCode]        NVARCHAR (255) NULL,
    [SuppCatNum]      NVARCHAR (255) NULL,
    [BuyUnitMsr]      NVARCHAR (255) NULL,
    [NumInBuy]        FLOAT (53)     NULL,
    [ReorderQty]      FLOAT (53)     NULL,
    [MinLevel]        FLOAT (53)     NULL,
    [LstEvlPric]      FLOAT (53)     NULL,
    [LstEvlDate]      DATETIME       NULL,
    [CustomPer]       FLOAT (53)     NULL,
    [Canceled]        NVARCHAR (255) NULL,
    [MnufctTime]      NVARCHAR (255) NULL,
    [WholSlsTax]      NVARCHAR (255) NULL,
    [RetilrTax]       NVARCHAR (255) NULL,
    [SpcialDisc]      FLOAT (53)     NULL,
    [DscountCod]      NVARCHAR (255) NULL,
    [TrackSales]      NVARCHAR (255) NULL,
    [SalUnitMsr]      NVARCHAR (255) NULL,
    [NumInSale]       FLOAT (53)     NULL,
    [Consig]          FLOAT (53)     NULL,
    [QueryGroup]      FLOAT (53)     NULL,
    [Counted]         FLOAT (53)     NULL,
    [OpenBlnc]        FLOAT (53)     NULL,
    [EvalSystem]      NVARCHAR (255) NULL,
    [UserSign]        FLOAT (53)     NULL,
    [FREE]            NVARCHAR (255) NULL,
    [PicturName]      NVARCHAR (255) NULL,
    [Transfered]      NVARCHAR (255) NULL,
    [BlncTrnsfr]      NVARCHAR (255) NULL,
    [UserText]        NVARCHAR (255) NULL,
    [SerialNum]       NVARCHAR (255) NULL,
    [CommisPcnt]      FLOAT (53)     NULL,
    [CommisSum]       FLOAT (53)     NULL,
    [CommisGrp]       FLOAT (53)     NULL,
    [TreeType]        NVARCHAR (255) NULL,
    [TreeQty]         FLOAT (53)     NULL,
    [LastPurPrc]      FLOAT (53)     NULL,
    [LastPurCur]      NVARCHAR (255) NULL,
    [LastPurDat]      DATETIME       NULL,
    [ExitCur]         NVARCHAR (255) NULL,
    [ExitPrice]       FLOAT (53)     NULL,
    [ExitWH]          NVARCHAR (255) NULL,
    [AssetItem]       NVARCHAR (255) NULL,
    [WasCounted]      NVARCHAR (255) NULL,
    [ManSerNum]       NVARCHAR (255) NULL,
    [SHeight1]        FLOAT (53)     NULL,
    [SHght1Unit]      NVARCHAR (255) NULL,
    [SHeight2]        FLOAT (53)     NULL,
    [SHght2Unit]      NVARCHAR (255) NULL,
    [SWidth1]         FLOAT (53)     NULL,
    [SWdth1Unit]      NVARCHAR (255) NULL,
    [SWidth2]         FLOAT (53)     NULL,
    [SWdth2Unit]      NVARCHAR (255) NULL,
    [SLength1]        FLOAT (53)     NULL,
    [SLen1Unit]       NVARCHAR (255) NULL,
    [Slength2]        FLOAT (53)     NULL,
    [SLen2Unit]       NVARCHAR (255) NULL,
    [SVolume]         FLOAT (53)     NULL,
    [SVolUnit]        FLOAT (53)     NULL,
    [SWeight1]        FLOAT (53)     NULL,
    [SWght1Unit]      NVARCHAR (255) NULL,
    [SWeight2]        FLOAT (53)     NULL,
    [SWght2Unit]      NVARCHAR (255) NULL,
    [BHeight1]        FLOAT (53)     NULL,
    [BHght1Unit]      NVARCHAR (255) NULL,
    [BHeight2]        FLOAT (53)     NULL,
    [BHght2Unit]      NVARCHAR (255) NULL,
    [BWidth1]         FLOAT (53)     NULL,
    [BWdth1Unit]      NVARCHAR (255) NULL,
    [BWidth2]         FLOAT (53)     NULL,
    [BWdth2Unit]      NVARCHAR (255) NULL,
    [BLength1]        FLOAT (53)     NULL,
    [BLen1Unit]       NVARCHAR (255) NULL,
    [Blength2]        FLOAT (53)     NULL,
    [BLen2Unit]       NVARCHAR (255) NULL,
    [BVolume]         FLOAT (53)     NULL,
    [BVolUnit]        FLOAT (53)     NULL,
    [BWeight1]        FLOAT (53)     NULL,
    [BWght1Unit]      NVARCHAR (255) NULL,
    [BWeight2]        FLOAT (53)     NULL,
    [BWght2Unit]      NVARCHAR (255) NULL,
    [FixCurrCms]      NVARCHAR (255) NULL,
    [FirmCode]        FLOAT (53)     NULL,
    [LstSalDate]      DATETIME       NULL,
    [QryGroup1]       NVARCHAR (255) NULL,
    [QryGroup2]       NVARCHAR (255) NULL,
    [QryGroup3]       NVARCHAR (255) NULL,
    [QryGroup4]       NVARCHAR (255) NULL,
    [QryGroup5]       NVARCHAR (255) NULL,
    [QryGroup6]       NVARCHAR (255) NULL,
    [QryGroup7]       NVARCHAR (255) NULL,
    [QryGroup8]       NVARCHAR (255) NULL,
    [QryGroup9]       NVARCHAR (255) NULL,
    [QryGroup10]      NVARCHAR (255) NULL,
    [QryGroup11]      NVARCHAR (255) NULL,
    [QryGroup12]      NVARCHAR (255) NULL,
    [QryGroup13]      NVARCHAR (255) NULL,
    [QryGroup14]      NVARCHAR (255) NULL,
    [QryGroup15]      NVARCHAR (255) NULL,
    [QryGroup16]      NVARCHAR (255) NULL,
    [QryGroup17]      NVARCHAR (255) NULL,
    [QryGroup18]      NVARCHAR (255) NULL,
    [QryGroup19]      NVARCHAR (255) NULL,
    [QryGroup20]      NVARCHAR (255) NULL,
    [QryGroup21]      NVARCHAR (255) NULL,
    [QryGroup22]      NVARCHAR (255) NULL,
    [QryGroup23]      NVARCHAR (255) NULL,
    [QryGroup24]      NVARCHAR (255) NULL,
    [QryGroup25]      NVARCHAR (255) NULL,
    [QryGroup26]      NVARCHAR (255) NULL,
    [QryGroup27]      NVARCHAR (255) NULL,
    [QryGroup28]      NVARCHAR (255) NULL,
    [QryGroup29]      NVARCHAR (255) NULL,
    [QryGroup30]      NVARCHAR (255) NULL,
    [QryGroup31]      NVARCHAR (255) NULL,
    [QryGroup32]      NVARCHAR (255) NULL,
    [QryGroup33]      NVARCHAR (255) NULL,
    [QryGroup34]      NVARCHAR (255) NULL,
    [QryGroup35]      NVARCHAR (255) NULL,
    [QryGroup36]      NVARCHAR (255) NULL,
    [QryGroup37]      NVARCHAR (255) NULL,
    [QryGroup38]      NVARCHAR (255) NULL,
    [QryGroup39]      NVARCHAR (255) NULL,
    [QryGroup40]      NVARCHAR (255) NULL,
    [QryGroup41]      NVARCHAR (255) NULL,
    [QryGroup42]      NVARCHAR (255) NULL,
    [QryGroup43]      NVARCHAR (255) NULL,
    [QryGroup44]      NVARCHAR (255) NULL,
    [QryGroup45]      NVARCHAR (255) NULL,
    [QryGroup46]      NVARCHAR (255) NULL,
    [QryGroup47]      NVARCHAR (255) NULL,
    [QryGroup48]      NVARCHAR (255) NULL,
    [QryGroup49]      NVARCHAR (255) NULL,
    [QryGroup50]      NVARCHAR (255) NULL,
    [QryGroup51]      NVARCHAR (255) NULL,
    [QryGroup52]      NVARCHAR (255) NULL,
    [QryGroup53]      NVARCHAR (255) NULL,
    [QryGroup54]      NVARCHAR (255) NULL,
    [QryGroup55]      NVARCHAR (255) NULL,
    [QryGroup56]      NVARCHAR (255) NULL,
    [QryGroup57]      NVARCHAR (255) NULL,
    [QryGroup58]      NVARCHAR (255) NULL,
    [QryGroup59]      NVARCHAR (255) NULL,
    [QryGroup60]      NVARCHAR (255) NULL,
    [QryGroup61]      NVARCHAR (255) NULL,
    [QryGroup62]      NVARCHAR (255) NULL,
    [QryGroup63]      NVARCHAR (255) NULL,
    [QryGroup64]      NVARCHAR (255) NULL,
    [CreateDate]      DATETIME       NULL,
    [UpdateDate]      DATETIME       NULL,
    [ExportCode]      NVARCHAR (255) NULL,
    [SalFactor1]      FLOAT (53)     NULL,
    [SalFactor2]      FLOAT (53)     NULL,
    [SalFactor3]      FLOAT (53)     NULL,
    [SalFactor4]      FLOAT (53)     NULL,
    [PurFactor1]      FLOAT (53)     NULL,
    [PurFactor2]      FLOAT (53)     NULL,
    [PurFactor3]      FLOAT (53)     NULL,
    [PurFactor4]      FLOAT (53)     NULL,
    [SalFormula]      NVARCHAR (255) NULL,
    [PurFormula]      NVARCHAR (255) NULL,
    [VatGroupPu]      NVARCHAR (255) NULL,
    [AvgPrice]        FLOAT (53)     NULL,
    [PurPackMsr]      NVARCHAR (255) NULL,
    [PurPackUn]       FLOAT (53)     NULL,
    [SalPackMsr]      NVARCHAR (255) NULL,
    [SalPackUn]       FLOAT (53)     NULL,
    [SCNCounter]      NVARCHAR (255) NULL,
    [ManBtchNum]      NVARCHAR (255) NULL,
    [ManOutOnly]      NVARCHAR (255) NULL,
    [DataSource]      NVARCHAR (255) NULL,
    [validFor]        NVARCHAR (255) NULL,
    [validFrom]       DATETIME       NULL,
    [validTo]         DATETIME       NULL,
    [frozenFor]       NVARCHAR (255) NULL,
    [frozenFrom]      DATETIME       NULL,
    [frozenTo]        DATETIME       NULL,
    [BlockOut]        NVARCHAR (255) NULL,
    [ValidComm]       NVARCHAR (255) NULL,
    [FrozenComm]      NVARCHAR (255) NULL,
    [LogInstanc]      FLOAT (53)     NULL,
    [ObjType]         NVARCHAR (255) NULL,
    [SWW]             NVARCHAR (255) NULL,
    [Deleted]         NVARCHAR (255) NULL,
    [DocEntry]        FLOAT (53)     NULL,
    [ExpensAcct]      NVARCHAR (255) NULL,
    [FrgnInAcct]      NVARCHAR (255) NULL,
    [ShipType]        NVARCHAR (255) NULL,
    [GLMethod]        NVARCHAR (255) NULL,
    [ECInAcct]        NVARCHAR (255) NULL,
    [FrgnExpAcc]      NVARCHAR (255) NULL,
    [ECExpAcc]        NVARCHAR (255) NULL,
    [TaxType]         NVARCHAR (255) NULL,
    [ByWh]            NVARCHAR (255) NULL,
    [WTLiable]        NVARCHAR (255) NULL,
    [ItemType]        NVARCHAR (255) NULL,
    [WarrntTmpl]      NVARCHAR (255) NULL,
    [BaseUnit]        NVARCHAR (255) NULL,
    [CountryOrg]      NVARCHAR (255) NULL,
    [StockValue]      FLOAT (53)     NULL,
    [Phantom]         NVARCHAR (255) NULL,
    [IssueMthd]       NVARCHAR (255) NULL,
    [FREE1]           NVARCHAR (255) NULL,
    [PricingPrc]      FLOAT (53)     NULL,
    [MngMethod]       NVARCHAR (255) NULL,
    [ReorderPnt]      FLOAT (53)     NULL,
    [InvntryUom]      NVARCHAR (255) NULL,
    [PlaningSys]      NVARCHAR (255) NULL,
    [PrcrmntMtd]      NVARCHAR (255) NULL,
    [OrdrIntrvl]      NVARCHAR (255) NULL,
    [OrdrMulti]       FLOAT (53)     NULL,
    [MinOrdrQty]      FLOAT (53)     NULL,
    [LeadTime]        NVARCHAR (255) NULL,
    [IndirctTax]      NVARCHAR (255) NULL,
    [TaxCodeAR]       NVARCHAR (255) NULL,
    [TaxCodeAP]       NVARCHAR (255) NULL,
    [OSvcCode]        NVARCHAR (255) NULL,
    [ISvcCode]        NVARCHAR (255) NULL,
    [ServiceGrp]      NVARCHAR (255) NULL,
    [NCMCode]         NVARCHAR (255) NULL,
    [MatType]         NVARCHAR (255) NULL,
    [MatGrp]          FLOAT (53)     NULL,
    [ProductSrc]      NVARCHAR (255) NULL,
    [U_U_PrecioBruto] FLOAT (53)     NULL,
    [U_AGRUPADOR]     NVARCHAR (255) NULL,
    [U_SoloCampana]   FLOAT (53)     NULL
);
