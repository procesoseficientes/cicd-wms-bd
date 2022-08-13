-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-18 @ Team REBORN - Sprint Drache
-- Description:	        Sp que le cambia el vehiculo a un manifiesto

-- Modificacion 13-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega parametro de login

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_CHANGE_MANIFEST_VEHICLE @MANIFEST_HEADER_ID = 1170, @VEHICLE_CODE = 26,@LOGIN= 'beto'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CHANGE_MANIFEST_VEHICLE] (
	@MANIFEST_HEADER_ID INT
	,@VEHICLE_CODE INT
	,@LOGIN VARCHAR(50)
) AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DECLARE @PLATE_NUMBER VARCHAR(10)
           ,@PILOT_CODE INT
           ,@IS_STATUS_CREATED INT = 0;

    SELECT
      @IS_STATUS_CREATED = 1
    FROM [wms].[OP_WMS_MANIFEST_HEADER] [M]
    WHERE [M].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
    AND ([M].[STATUS] = 'CREATED' OR [M].[STATUS] = 'CANCELD');

    IF @IS_STATUS_CREATED = 0
    BEGIN
      RAISERROR ('No puede cambiar el vehiculo de un manifiesto ya procesado o cancelado', 16, 1);
    END


    SELECT
      @PLATE_NUMBER = [V].[PLATE_NUMBER]
     ,@PILOT_CODE = [P].[PILOT_CODE]
    FROM [wms].[OP_WMS_VEHICLE] [V]
    INNER JOIN [wms].[OP_WMS_PILOT] [P]
      ON [V].[PILOT_CODE] = [P].[PILOT_CODE]
    WHERE [V].[VEHICLE_CODE] = @VEHICLE_CODE

    UPDATE [wms].[OP_WMS_MANIFEST_HEADER]
    SET 
		[VEHICLE] = @VEHICLE_CODE
       ,[PLATE_NUMBER] = @PLATE_NUMBER
       ,[DRIVER] = @PILOT_CODE
	   ,[LAST_UPDATE] = GETDATE()
	   ,[LAST_UPDATE_BY] = @LOGIN
    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

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