-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-08 @ Team REBORN - Sprint Ramsey
-- Description:	        Sp que valida una etiqueta 

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_VALIDATE_LABEL @LABEL_ID=1255
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LABEL] (@LABEL_ID INT)
AS
    BEGIN
        SET NOCOUNT ON;
  --
        SELECT  [PL].[LABEL_ID]
               ,[PL].[LOGIN_ID]
               ,[PL].[LICENSE_ID]
               ,[PL].[MATERIAL_ID]
               ,[PL].[MATERIAL_NAME]
               ,[PL].[QTY]
               ,[PL].[CODIGO_POLIZA]
               ,[PL].[SOURCE_LOCATION]
               ,[PL].[TARGET_LOCATION]
               ,[PL].[TRANSIT_LOCATION]
               ,[PL].[BATCH]
               ,[PL].[VIN]
               ,[PL].[TONE]
               ,[PL].[CALIBER]
               ,[PL].[SERIAL_NUMBER]
               ,[PL].[STATUS]
               ,[PL].[WEIGHT]
               ,[PL].[WAVE_PICKING_ID]
               ,[PL].[TASK_SUBT_YPE]
               ,[PL].[WAREHOUSE_TARGET]
               ,[PL].[CLIENT_NAME]
               ,[PL].[CLIENT_CODE]
               ,[PL].[STATE_CODE]
               ,[PL].[REGIMEN]
               ,[PL].[TRANSFER_REQUEST_ID]
               ,[PL].[BARCODE]
               ,[PL].[LABEL_STATUS]
        FROM    [wms].[OP_WMS_PICKING_LABELS] [PL]
        WHERE   [PL].[LABEL_ID] = @LABEL_ID;

		 
    END;