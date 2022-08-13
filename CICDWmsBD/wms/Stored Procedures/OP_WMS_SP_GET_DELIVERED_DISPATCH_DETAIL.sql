-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-09 @ Team REBORN - Sprint Ramsey
-- Description:	        devuelve el detalle de una entrega despachada

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_DELIVERED_DISPATCH_DETAIL] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DELIVERED_DISPATCH_DETAIL](@DELIVERED_DISPATCH_HEADER_ID INT)
AS
    BEGIN
        SET NOCOUNT ON;
  --

        SELECT  [DD].[DELIVERED_DISPATCH_DETAIL_ID]
               ,[DD].[LABEL_ID]
               ,[DD].[LAST_UPDATE]
               ,[DD].[LAST_UPDATE_BY]
               ,[DD].[DELIVERED_DISPATCH_HEADER_ID]
               ,[PL].[LABEL_ID]
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
        FROM    [wms].[OP_WMS_DELIVERED_DISPATCH_DETAIL] [DD] INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL] ON [PL].[LABEL_ID] = [DD].[LABEL_ID]
        WHERE   [DELIVERED_DISPATCH_HEADER_ID] = @DELIVERED_DISPATCH_HEADER_ID;


    END;