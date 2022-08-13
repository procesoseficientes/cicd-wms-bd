-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	02-06-217 
-- Description:			Ingresa la tarea para el egreso externo

/*
-- Ejemplo de Ejecucion:
				--
				
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_INSERT_TASK_EXT (  
@WAVE_PICKING_ID DECIMAL 
, @QTY NUMERIC(18, 2)
, @LICENCE_ID NUMERIC
, @MATERIAL_ID VARCHAR(50)
, @LOGIN_ID AS VARCHAR(25)
, @CODIGIO_POLIZA_TARGET VARCHAR(15)
  )
AS
BEGIN
  DECLARE @CODIGO_POLIZA VARCHAR(25)
  , @BARCODE_ID VARCHAR(50)
  , @ALTERNATE_BARCODE VARCHAR(50)
  , @MATERIAL_NAME VARCHAR(200)
  , @CURRENT_WAREHOUSE VARCHAR(25)
  , @CURRENT_LOCATION VARCHAR(25)  
  , @CLIENT_OWNER VARCHAR(25)
  , @CLIENT_NAME VARCHAR(150)
    
  
  
  -----------------------------------------
  --Obtenemos datos de la licencia
  -----------------------------------------
  SELECT TOP 1 
    @CODIGO_POLIZA = [L].[CODIGO_POLIZA]
    ,@CURRENT_WAREHOUSE = [L].[CURRENT_WAREHOUSE] 
    ,@CURRENT_LOCATION = [L].[CURRENT_LOCATION]
    ,@CLIENT_OWNER = [L].[CLIENT_OWNER]    
  FROM [wms].[OP_WMS_LICENSES] [L] 
  WHERE [L].[LICENSE_ID] = @LICENCE_ID

  -----------------------------------------
  --Obtenemos datos del cliente
  -----------------------------------------
  SELECT TOP 1 @CLIENT_NAME = [C].[CLIENT_NAME] FROM [wms].[OP_WMS_VIEW_CLIENTS] [C] WHERE [C].[CLIENT_CODE] = @CLIENT_OWNER
  -----------------------------------------
  --Obtenemos datos del material
  -----------------------------------------
  SELECT TOP 1 
    @BARCODE_ID = [M].[BARCODE_ID] 
    ,@ALTERNATE_BARCODE = [M].[ALTERNATE_BARCODE]
    ,@MATERIAL_NAME = [M].[MATERIAL_NAME]
  FROM [wms].[OP_WMS_MATERIALS] [M] 
  WHERE [M].[MATERIAL_ID] = @MATERIAL_ID

  -----------------------------------------
  --Insertamos la tarea completada
  -----------------------------------------
  INSERT INTO [wms].[OP_WMS_TASK_LIST] (
    [WAVE_PICKING_ID]
  , [TRANS_OWNER]
  , [TASK_TYPE]
  , [TASK_SUBTYPE]
  , [TASK_OWNER]
  , [TASK_ASSIGNEDTO]
  , [TASK_COMMENTS]
  , [ASSIGNED_DATE]
  , [QUANTITY_PENDING]
  , [QUANTITY_ASSIGNED]
  , [CODIGO_POLIZA_SOURCE]
  , [CODIGO_POLIZA_TARGET]
  , [LICENSE_ID_SOURCE]
  , [REGIMEN]
  , [IS_COMPLETED]
  , [IS_DISCRETIONAL]
  , [IS_PAUSED]
  , [IS_CANCELED]
  , [MATERIAL_ID]
  , [BARCODE_ID]
  , [ALTERNATE_BARCODE]
  , [MATERIAL_NAME]
  , [WAREHOUSE_SOURCE]  
  , [LOCATION_SPOT_SOURCE]  
  , [CLIENT_OWNER]
  , [CLIENT_NAME]
  , [ACCEPTED_DATE]
  , [COMPLETED_DATE]  
  , [MATERIAL_SHORT_NAME]
  , [IS_lOCKED] 
     )
    VALUES (
      @WAVE_PICKING_ID
      , 0
      , 'TAREA_PICKING'
      , 'DESPACHO_GENERAL'
      , @LOGIN_ID
      , ''
      , 'OLA DE PICKING #' + CONVERT(VARCHAR(25), @WAVE_PICKING_ID)
      , GETDATE()
      , 0
      , @QTY
      , ''
      , @CODIGIO_POLIZA_TARGET
      , @LICENCE_ID
      , 'GENERAL'
      , 1
      , 0
      , 0
      , 0
      , @MATERIAL_ID
      , @BARCODE_ID
      , @ALTERNATE_BARCODE
      , @MATERIAL_NAME
      , @CURRENT_WAREHOUSE
      , @CURRENT_LOCATION
      , @CLIENT_OWNER
      , @CLIENT_NAME
      , GETDATE()
      , GETDATE()
      , @MATERIAL_NAME
      , 0);
END