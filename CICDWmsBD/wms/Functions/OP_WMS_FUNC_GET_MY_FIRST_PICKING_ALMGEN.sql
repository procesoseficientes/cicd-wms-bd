-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		30-Jan-17 @ A-Team Sprint Bankole
-- Description:			    Funcion que obtiene los datos de la primera linea de la tarea de picking general

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-21 Team ERGON - Sprint EPONA
-- Description:	 Se modifica la forma en que va a obtener la información y lo ordena por ubicación. 

-- Modificacion 9/14/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agregan los campos TONE y CALIBER

-- Modificacion 27-Sep-17 @ Nexus Team Sprint DuckHunt
-- pablo.aguilar
-- Se agrega que filtre por operador

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					-- Se actualiza para que maneje la ubicación de salida en caso de reabastecimiento

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FUNC_GET_MY_FIRST_PICKING_ALMGEN]('LINEA_PICKING_1',286,'7702354251765', '')
		SELECT * FROM [wms].[OP_WMS_TASK_LIST] [T] 
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_MY_FIRST_PICKING_ALMGEN] (@pLOGIN_ID VARCHAR(25),
@pWAVE_ID NUMERIC(18, 0),
@pBARCODE_ID VARCHAR(50), 
@pLOCATION_SPOT_TARGET VARCHAR(25)= ''
)

RETURNS TABLE
AS
  RETURN
  (
  SELECT TOP 1
    [T].[WAVE_PICKING_ID]
   ,[T].[SERIAL_NUMBER]
   ,[T].[CODIGO_POLIZA_SOURCE]
   ,ISNULL([T].[CODIGO_POLIZA_TARGET], '') AS [CODIGO_POLIZA_TARGET]
   ,[T].[MATERIAL_ID]
   ,[T].[BARCODE_ID]
   ,[T].[MATERIAL_NAME]
   ,[T].[MATERIAL_SHORT_NAME]
   ,[L].[CURRENT_LOCATION] LOCATION_SPOT_SOURCE
   ,[T].[LICENSE_ID_SOURCE]
   ,[T].[QUANTITY_ASSIGNED]
   ,[T].[QUANTITY_PENDING]
   ,[T].[QUANTITY_PENDING] QTY_AVAILABLE
   ,[M].[BATCH_REQUESTED]
   ,[M].[CLIENT_OWNER]
   ,(CASE
      WHEN T.[TONE] IS NULL THEN ''
      ELSE T.[TONE]
    END) AS TONE
   ,(CASE
      WHEN T.[CALIBER] IS NULL THEN ''
      ELSE T.[CALIBER]
    END) AS CALIBER
  FROM [wms].[OP_WMS_TASK_LIST] [T]
  INNER JOIN [wms].[OP_WMS_LICENSES] [L]
    ON [L].[LICENSE_ID] = [T].[LICENSE_ID_SOURCE]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
  WHERE [T].[WAVE_PICKING_ID] = @pWAVE_ID
  AND [T].[TASK_ASSIGNEDTO] = @pLOGIN_ID
  AND [T].[BARCODE_ID] = @pBARCODE_ID
  AND [T].[QUANTITY_PENDING] > 0
  AND (ISNULL(@pLOCATION_SPOT_TARGET,'') = '' OR [T].[LOCATION_SPOT_TARGET] = @pLOCATION_SPOT_TARGET)
  ORDER BY [L].[CURRENT_LOCATION] ASC
  )