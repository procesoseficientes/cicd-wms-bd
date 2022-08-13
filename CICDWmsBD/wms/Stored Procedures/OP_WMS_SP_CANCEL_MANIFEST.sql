;
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-18 @ Team REBORN - Sprint Drache
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_CANCEL_MANIFEST @MANIFEST_HEADER_ID =1, @STATUS = 'CANCELED'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_CANCEL_MANIFEST (@MANIFEST_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DECLARE @IS_STATUS_CREATED INT = 0;

    SELECT
      @IS_STATUS_CREATED = 1
    FROM [wms].[OP_WMS_MANIFEST_HEADER] [M]
    WHERE [M].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
    AND ([M].[STATUS] = 'CREATED' OR [M].[STATUS] = 'CANCELED');

    IF @IS_STATUS_CREATED = 0
    BEGIN
      RAISERROR ('No puede cancelar un manifiesto ya procesado o cancelado', 16, 1);
    END

    UPDATE [wms].[OP_WMS_MANIFEST_HEADER] SET
    [STATUS] = 'CANCELED'
    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID


--    INSERT INTO [wms].[OP_WMS_CANCELED_MANIFEST_HEADER]
--      SELECT
--        [MH].[MANIFEST_HEADER_ID]
--       ,[MH].[DRIVER]
--       ,[MH].[VEHICLE]
--       ,[MH].[DISTRIBUTION_CENTER]
--       ,[MH].[CREATED_DATE]
--       ,[MH].[STATUS]
--       ,[MH].[LAST_UPDATE]
--       ,[MH].[LAST_UPDATE_BY]
--       ,[MH].[MANIFEST_TYPE]
--       ,[MH].[TRANSFER_REQUEST_ID]
--       ,[MH].[PLATE_NUMBER]
--      FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
--      WHERE [MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
--
--    INSERT INTO [wms].[OP_WMS_CANCELED_MANIFEST_DETAIL]
--      SELECT
--        [MD].[MANIFEST_DETAIL_ID]
--       ,[MD].[MANIFEST_HEADER_ID]
--       ,[MD].[CODE_ROUTE]
--       ,[MD].[CLIENT_CODE]
--       ,[MD].[WAVE_PICKING_ID]
--       ,[MD].[MATERIAL_ID]
--       ,[MD].[QTY]
--       ,[MD].[STATUS]
--       ,[MD].[LAST_UPDATE]
--       ,[MD].[LAST_UPDATE_BY]
--       ,[MD].[ADDRESS_CUSTOMER]
--       ,[MD].[CLIENT_NAME]
--       ,[MD].[LINE_NUM]
--       ,[MD].[PICKING_DEMAND_HEADER_ID]
--       ,[MD].[STATE_CODE]
--       ,[MD].[CERTIFICATION_TYPE]
--      FROM [wms].[OP_WMS_CANCELED_MANIFEST_DETAIL] [MD]
--      WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID

    DELETE [L]
      FROM [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [L]
      INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
        ON [L].[MANIFEST_DETAIL_ID] = [MD].[MANIFEST_DETAIL_ID]
      INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH]
        ON [MD].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID]
    WHERE [MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID


--    DELETE [wms].[OP_WMS_MANIFEST_DETAIL]
--    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
--
--    DELETE [wms].[OP_WMS_MANIFEST_HEADER]
--    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID


    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@MANIFEST_HEADER_ID AS VARCHAR) [DbData];


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END