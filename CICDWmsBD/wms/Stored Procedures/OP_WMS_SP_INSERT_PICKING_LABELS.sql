-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-13 @ Team REBORN - Sprint Drache
-- Description:	        SP que inserta etiquetas de picking

-- Modificacion 1/12/2018 @ Reborn-Team Sprint Ramsey
					-- diego.as
					-- Se agrega insercion de WAVE_PICKING_ID

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_INSERT_PICKING_LABELS   

*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_INSERT_PICKING_LABELS (@LOGIN_ID VARCHAR(25)
, @WAVE_PICKING_ID INT
, @CLIENT_CODE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    DECLARE @ID INT
           ,@SEVERAL_STATES INT
           ,@STATE_CODE INT = NULL
           ,@REGIMEN VARCHAR(50)
           ,@SEVERAL_CLIENTS INT
           ,@CLIENT_NAME VARCHAR(150);

    SELECT
      @REGIMEN = [TL].[REGIMEN]
    FROM [wms].[OP_WMS_TASK_LIST] [TL]
    LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TR]
      ON [TL].[TRANSFER_REQUEST_ID] = [TR].[TRANSFER_REQUEST_ID]
    WHERE [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID

    SELECT
      @SEVERAL_CLIENTS = COUNT(*)
    FROM (SELECT
        [PDH].[CLIENT_CODE]
      FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
      WHERE [PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
      GROUP BY [PDH].[CLIENT_CODE]) X

    IF @SEVERAL_CLIENTS = 1
    BEGIN
      SELECT
        @CLIENT_CODE = [PDH].[CLIENT_CODE]
      FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
      WHERE [PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
    END

    SELECT
      @CLIENT_NAME = [C].[CLIENT_NAME]
    FROM [wms].[OP_WMS_VIEW_CLIENTS] [C]
    WHERE [C].[CLIENT_CODE] = @CLIENT_CODE

    SELECT
      @SEVERAL_STATES = COUNT(*)
    FROM (SELECT
        [PDH].[STATE_CODE]
      FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
      WHERE [PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
      GROUP BY [PDH].[STATE_CODE]) X

    IF (@SEVERAL_STATES = 1)
    BEGIN
      SELECT
        @STATE_CODE = [PDH].[STATE_CODE]
      FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
      WHERE [PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
    END

    INSERT INTO [wms].[OP_WMS_PICKING_LABELS] ([LOGIN_ID], [CLIENT_CODE], [STATE_CODE], [REGIMEN], [CLIENT_NAME], [WAVE_PICKING_ID])
      VALUES (@LOGIN_ID, @CLIENT_CODE, @STATE_CODE, @REGIMEN, @CLIENT_NAME, @WAVE_PICKING_ID);

    SET @ID = SCOPE_IDENTITY();

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@ID AS VARCHAR) [DbData];


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END