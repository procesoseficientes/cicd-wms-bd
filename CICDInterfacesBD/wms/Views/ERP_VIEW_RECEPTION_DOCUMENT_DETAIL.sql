
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 TeamErgon Sprint 1
-- Description:			    Vista que trae el detalle de las recepciones de sap


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-01-18 Team ERGON - Sprint ERGON 1
-- Description:	 Se agrega al select el campo OBJECT_TYPE

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por intercompany

-- Modificacion 12-Jan-18 @ Nexus Team Sprint Ransey
-- alberto.ruiz
-- Se agrega columna [WhsCode]


/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL]
					
*/
-- =============================================
CREATE VIEW [wms].[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL]
AS
SELECT LTRIM([COMP].[CVE_DOC]) AS [SAP_RECEPTION_ID], --DOC_ENTRY
       LTRIM([COMP].[CVE_DOC]) [ERP_DOC],             --DOC_NUM
       LTRIM([COMP].[CVE_CLPV]) AS [PROVIDER_ID],
       [PROV].[NOMBRE] AS [PROVIDER_NAME],
       [D].[CVE_ART] AS [SKU],
       [M].[DESCR] AS [SKU_DESCRIPTION],
       [D].[CANT] AS [QTY],
       22 AS [OBJECT_TYPE],
       [D].[NUM_PAR] AS [LINE_NUM],
       [COMP].[SU_REFER] [COMMENTS],
       [D].[CVE_ART] [MASTER_ID_SKU],
       'ALZA' [OWNER_SKU],
       'ALZA' [OWNER],
      CAST( [COMP].[NUM_ALMA] AS VARCHAR(50) ) [ERP_WAREHOUSE_CODE],
       [M].[UNI_MED] [UNIT],
       [M].[UNI_MED] [UNIT_DESCRIPTION],
	   [COMP].[TIPCAMB] [DOC_RATE],
	   [COMP].[NUM_MONED] [DOC_CURRENCY],
	   [COMP].[TIPCAMB] [DET_RATE],
	   [COMP].[NUM_MONED] [DET_CURRENCY]
FROM [SAE70EMPRESA01].[dbo].[COMPO01] [COMP]
    LEFT JOIN [SAE70EMPRESA01].[dbo].[PAR_COMPO01] [D]
        ON ([D].[CVE_DOC] = [COMP].[CVE_DOC])
    LEFT JOIN [SAE70EMPRESA01].[dbo].[PROV01] [PROV]
        ON [PROV].[CLAVE] = [COMP].[CVE_CLPV]
    LEFT JOIN [SAE70EMPRESA01].[dbo].[INVE01] [M]
        ON [D].[CVE_ART] = [M].[CVE_ART]
WHERE [COMP].[STATUS] = 'E'
AND [COMP].[BLOQ] = 'N'
--AND COMP.[DOC_SIG] IS NULL;
;








