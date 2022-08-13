-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/7/2018 @ GFORCE-Team Sprint dinosaurio@l3w 
-- Description:			obtiene inv por materiales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INV_X_SKU]
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_INV_X_SKU (@BARCODE_ID VARCHAR(100)
, @LOGIN VARCHAR(25) = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [A].[PK_LINE]
   ,[A].[LICENSE_ID]
   ,[A].[MATERIAL_ID]
   ,[A].[MATERIAL_NAME]
   ,[A].[QTY]
   ,[A].[VOLUME_FACTOR]
   ,[A].[WEIGTH]
   ,[A].[SERIAL_NUMBER]
   ,[A].[COMMENTS]
   ,[A].[LAST_UPDATED]
   ,[A].[LAST_UPDATED_BY]
   ,[A].[BARCODE_ID]
   ,[A].[TERMS_OF_TRADE]
   ,[A].[STATUS]
   ,[A].[CREATED_DATE]
   ,[A].[DATE_EXPIRATION]
   ,CASE
      WHEN [T].[TONE_AND_CALIBER_ID] IS NOT NULL THEN 'T: ' + ISNULL([T].[TONE], '') + '  C: '
        + ISNULL([T].[CALIBER], '')
      ELSE [A].[BATCH]
    END [BATCH]
   ,[A].[ENTERED_QTY]
   ,[A].[VIN]
   ,[A].[HANDLE_SERIAL]
   ,[A].[IS_EXTERNAL_INVENTORY]
   ,[A].[IS_BLOCKED]
   ,[A].[BLOCKED_STATUS]
   ,[A].[STATUS_ID]
   ,[A].[TONE_AND_CALIBER_ID]
   ,[A].[LOCKED_BY_INTERFACES]
   ,[B].[LICENSE_ID]
   ,[B].[CLIENT_OWNER]
   ,[B].[CODIGO_POLIZA]
   ,[B].[CURRENT_WAREHOUSE]
   ,[B].[CURRENT_LOCATION] + ' | '
    + [wms].[OP_WMS_FN_SPLIT_COLUMNS]([A].[MATERIAL_ID],
    2, '/') [CURRENT_LOCATION]
   ,[B].[LAST_LOCATION]
   ,[B].[LAST_UPDATED]
   ,[B].[LAST_UPDATED_BY]
   ,[B].[STATUS]
   ,[B].[REGIMEN]
   ,[B].[CREATED_DATE]
   ,[B].[USED_MT2]
   ,[B].[CODIGO_POLIZA_RECTIFICACION]
   ,([wms].[OP_WMS_FN_SPLIT_COLUMNS]([A].[MATERIAL_ID],
    2, '/') + ' '
    + [A].[MATERIAL_NAME]) AS [MATERIAL_NAME_EXTENDED]
   ,CASE [M].[IS_MASTER_PACK]
      WHEN 1 THEN 'Es Master Pack'
      ELSE ''
    END AS [IS_MASTER_PACK]
  FROM [wms].[OP_WMS_INV_X_LICENSE] [A]
  INNER JOIN [wms].[OP_WMS_LICENSES] [B]
    ON ([B].[LICENSE_ID] = [A].[LICENSE_ID])
  LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [T]
    ON [T].[TONE_AND_CALIBER_ID] = [A].[TONE_AND_CALIBER_ID]
  INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
    ON [S].[LOCATION_SPOT] = [B].[CURRENT_LOCATION]
  INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [W]
    ON [W].[WAREHOUSE_ID] = [S].[WAREHOUSE_PARENT]
    AND @LOGIN = [W].[LOGIN_ID]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON ([M].[MATERIAL_ID] = [A].[MATERIAL_ID])
  WHERE [A].[MATERIAL_ID] = (SELECT TOP (1)
      [MATERIAL_ID]
    FROM [wms].[OP_WMS_MATERIALS]
    WHERE (
    [BARCODE_ID] = @BARCODE_ID
    OR [ALTERNATE_BARCODE] = @BARCODE_ID
    )
    AND [CLIENT_OWNER] = [B].[CLIENT_OWNER])
  AND [A].[QTY] > 0
  ORDER BY ISNULL([A].[DATE_EXPIRATION],
  CAST('2099/01/01' AS DATETIME)) ASC;
END;