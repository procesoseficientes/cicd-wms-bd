-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-03-24 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que devuelve las vistas de Vistas del inventario

-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-05-22 @ Team ERGON - Sprint Sheik
-- Description:	        Se agrego SERIAL_NUMBER Y HANDLE_SERIAL 

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agregaron STATUS_NAME, [BLOCKS_INVENTORY] y COLOR en los 3 if 

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_INVENTORY]  @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY] (@LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @WAREHOUSES TABLE (
    [WAREHOUSE_ID] VARCHAR(25)
   ,[NAME] VARCHAR(50)
   ,[COMMENTS] VARCHAR(150)
   ,[ERP_WAREHOUSE] VARCHAR(50)
   ,[ALLOW_PICKING] NUMERIC
   ,[DEFAULT_RECEPTION_LOCATION] VARCHAR(25)
   ,[SHUNT_NAME] VARCHAR(25)
   ,[WAREHOUSE_WEATHER] VARCHAR(50)
   ,[WAREHOUSE_STATUS] INT
   ,[IS_3PL_WAREHUESE] INT
   ,[WAHREHOUSE_ADDRESS] VARCHAR(250)
   ,[GPS_URL] VARCHAR(100)
   ,[WAREHOUSE_BY_USER_ID] INT
    UNIQUE ([WAREHOUSE_ID])
  );

  DECLARE @VALORIZACION TABLE (
    [LICENSE_ID] NUMERIC
   ,[VALOR_UNITARIO] NUMERIC(36, 6)
   ,[TOTAL_VALOR] NUMERIC(36, 6)
   ,[MATERIAL_ID] VARCHAR(50)
  );


  -- ------------------------------------------------------------------------------------
  -- Obtiene todas las bodegas asociadas a un usuario
  -- ------------------------------------------------------------------------------------

  INSERT INTO @WAREHOUSES
  EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN

  -- ------------------------------------------------------------------------------------
  -- Obtiene la valorizacion
  -- ------------------------------------------------------------------------------------
  INSERT INTO @VALORIZACION
    SELECT
      [V].[LICENSE_ID]
     ,[V].[VALOR_UNITARIO]
     ,[V].[TOTAL_VALOR]
     ,[V].[MATERIAL_ID]
    FROM [wms].[OP_WMS_VIEW_VALORIZACION] [V]
    WHERE [V].[QTY] > 0;



  SELECT
    [IL].[MATERIAL_ID]
   ,[IL].[MATERIAL_NAME]
   ,[L].[CURRENT_WAREHOUSE]
   ,[L].[CURRENT_LOCATION]
   ,CASE [M].[SERIAL_NUMBER_REQUESTS]
      WHEN 1 THEN [MSN].[BATCH]
      ELSE [IL].[BATCH]
    END [BATCH]
   ,CASE [M].[SERIAL_NUMBER_REQUESTS]
      WHEN 1 THEN [MSN].[DATE_EXPIRATION]
      ELSE [IL].[DATE_EXPIRATION]
    END [DATE_EXPIRATION]
   ,[IL].[LICENSE_ID]
   ,[RDH].[CODE_SUPPLIER]
   ,[RDH].[NAME_SUPPLIER]
   ,[IL].[QTY]
   ,[V].[TOTAL_VALOR]
   ,[SML].[STATUS_CODE]
   ,[SML].[STATUS_NAME]
   ,[SML].[COLOR]
   ,[IL].[VIN]
   ,[TCM].[TONE]
   ,[TCM].[CALIBER]
   ,[MSN].[SERIAL]
  FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
  INNER JOIN [wms].[OP_WMS_LICENSES] AS [L]
    ON (
    [IL].[LICENSE_ID] = [L].[LICENSE_ID]
    )
  INNER JOIN @WAREHOUSES [W]
    ON (
    [W].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE] COLLATE database_default
    )
  INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML]
    ON (
    [SML].[STATUS_ID] = [IL].[STATUS_ID]
    )
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON (
    [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
    )
  LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MSN]
    ON (
    [MSN].[LICENSE_ID] = [IL].[LICENSE_ID]
    AND [MSN].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	AND [MSN].[STATUS] > 0
    )
  LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL]
    ON (
    [IL].[LICENSE_ID] = [CIL].[LICENCE_ID]
    AND [IL].[MATERIAL_ID] = [CIL].[MATERIAL_ID]
    )
  LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
    ON (
    [TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
    AND [TCM].[TONE_AND_CALIBER_ID] > 0
    )
  LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL]
    ON (
    [TL].[CODIGO_POLIZA_SOURCE] = [L].[CODIGO_POLIZA]
    AND [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
    )
  LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
    ON (
    [RDH].[TASK_ID] = [TL].[SERIAL_NUMBER]
    AND [RDH].[TASK_ID] > 0
    )
  LEFT JOIN @VALORIZACION [V]
    ON (
    [V].[LICENSE_ID] = [IL].[LICENSE_ID]
    AND [V].[MATERIAL_ID] = [IL].[MATERIAL_ID]
    )
  WHERE [IL].[QTY] > 0
  AND [TL].CANCELED_DATETIME IS NULL
  AND [CIL].[LICENCE_ID] IS NULL
  AND [CIL].[MATERIAL_ID] IS NULL

END