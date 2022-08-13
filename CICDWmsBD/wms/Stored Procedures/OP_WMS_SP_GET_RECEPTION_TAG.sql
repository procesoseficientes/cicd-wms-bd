-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/30/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Se obtienen los datos para la etiqueta	

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_RECEPTION_TAG]
					@TASK_ID = 476534, 
					@LOGIN = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_TAG] (@TASK_ID INT,
@LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
  TOP 1
    [TL].[TASK_SUBTYPE]
   ,ISNULL([TRH].[WAREHOUSE_FROM], '') [WAREHOUSE_SOURCE]
   ,[L].[LOGIN_NAME]
   ,GETDATE() [DATE_TIME]
   ,ISNULL([TL].[CLIENT_OWNER], '') [CLIENT_CODE]
   ,[TL].[CLIENT_NAME] [CLIENT_NAME]
   ,[TL].[SERIAL_NUMBER] [TASK_ID]
   , [TL].[CODIGO_POLIZA_SOURCE] [CODIGO_POLIZA]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  INNER JOIN [wms].[OP_WMS_LOGINS] [L]
    ON [L].[LOGIN_ID] = @LOGIN
  LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH]
    ON [TRH].[TRANSFER_REQUEST_ID] = [TL].[TRANSFER_REQUEST_ID]
  WHERE [TL].[SERIAL_NUMBER] = @TASK_ID
END