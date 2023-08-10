
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team G-FORCE - Sprint LANGOSTA
-- Description:	 NA

-- Autor:	kevin.guerra
-- Fecha de Creacion: 	25-03-2020 GForce@Paris - Sprint B
-- Description:	 Se agrega el campo [M1].CAMPLIB45 para obtener la subfamilia.

/*
-- Ejemplo de Ejecucion:
			SELECT  * FROM [WMS].VIEW_SKU_ERP
*/
-- =============================================
CREATE VIEW [wms].[VIEW_SKU_ERP]
AS

	  SELECT DISTINCT
       'ALZA' [CLIENT_OWNER],
       'ALZA' + '/' + [m].[CVE_ART] [MATERIAL_ID],
       [m].[CVE_ART] [MATERIAL_ID_SAP],
       CASE
           WHEN [M1].[CAMPLIB29] IS NOT NULL
                AND [M1].[CAMPLIB29] <> '' THEN
               [M1].[CAMPLIB29]
           ELSE
               [m].[CVE_ART]
       END [BARCODE_ID],
       CASE
           WHEN [M1].[CAMPLIB29] IS NULL
                OR [M1].[CAMPLIB29] = '' THEN
               NULL
           ELSE
               [m].[CVE_ART]
       END AS [ALTERNATE_BARCODE],
       [m].[DESCR] [MATERIAL_NAME],
       [m].[DESCR] [SHORT_NAME],
       [m].[VOLUMEN] [VOLUME_FACTOR],
       [m].[LIN_PROD] [MATERIAL_CLASS],
	   [M1].CAMPLIB45 [MATERIAL_SUB_CLASS],
       CAST(0 AS [NUMERIC](18, 4)) [HIGH],
       CAST(0 AS [NUMERIC](18, 4)) [LENGTH],
       CAST(0 AS [NUMERIC](18, 4)) [WIDTH],
       100 [MAX_X_BIN],
       0 [SCAN_BY_ONE],
       0 [REQUIRES_LOGISTICS_INFO],
       CAST([m].[PESO] AS [NUMERIC](18, 4)) [WEIGTH],
       CAST(NULL AS [VARCHAR]) [IMAGE_1],
       CAST(NULL AS [VARCHAR]) [IMAGE_2],
       CAST(NULL AS VARCHAR) [IMAGE_3],
       CURRENT_TIMESTAMP [LAST_UPDATED],
       '[BULK_PROCESS]' [LAST_UPDATED_BY],
       0 [IS_CAR],
       NULL [MT3],
       '0' [BATCH_REQUESTED],
       0 [SERIAL_NUMBER_REQUESTS],
       ISNULL([m].[ULT_COSTO], 0)[ERP_AVERAGE_PRICE],
       1 [INVT],
       '0' [HANDLE_TONE],
       '0' [HANDLE_CALIBER],
       0 [QM],
       [m].[UNI_MED] [BaseUnit],
       [m].[LIN_PROD] [Family]
FROM [SAE70EMPRESA01].[dbo].[INVE01] [m]
    INNER JOIN [SAE70EMPRESA01].[dbo].[INVE_CLIB01] [M1]
        ON [m].[CVE_ART] = [M1].[CVE_PROD]
     

--INNER JOIN [wms].[OP_WMS_COMPANY] [c] ON [c].[CLIENT_CODE] = [m].[WERKS]
