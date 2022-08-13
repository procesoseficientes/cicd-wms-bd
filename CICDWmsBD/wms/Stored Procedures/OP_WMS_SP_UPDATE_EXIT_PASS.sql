-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que actualiza el pase de salida

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [wms].[OP_WMS_SP_UPDATE__EXIT_PASS] 
				
				SELECT @ID
*/
-- =============================================  
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_EXIT_PASS] (@PASS_ID INT
, @CLIENT_CODE VARCHAR(25)
, @CLIENT_NAME VARCHAR(200)
, @ISEMPTY VARCHAR(25)
, @VEHICLE_PLATE VARCHAR(10)
, @VEHICLE_DRIVER VARCHAR(200)
, @VEHICLE_ID INT
, @DRIVER_ID INT
, @AUTORIZED_BY VARCHAR(20)
, @HANDLER VARCHAR(250)
, @TXT VARCHAR(4000)
, @LOADUNLOAD VARCHAR(1)
, @LAST_UPDATED_BY VARCHAR(25)
, @LICENSE_NUMBER VARCHAR(25)
)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    UPDATE [wms].[OP_WMS3PL_PASSES]
    SET [CLIENT_CODE] = @CLIENT_CODE
       ,[CLIENT_NAME] = @CLIENT_NAME

       ,[ISEMPTY] = @ISEMPTY
       ,[VEHICLE_PLATE] = @VEHICLE_PLATE
       ,[VEHICLE_DRIVER] = @VEHICLE_DRIVER
       ,[VEHICLE_ID] = @VEHICLE_ID
       ,[DRIVER_ID] = @DRIVER_ID
       ,[AUTORIZED_BY] = @AUTORIZED_BY
       ,[HANDLER] = @HANDLER       
       ,[TXT] = @TXT
       ,[LOADUNLOAD] = @LOADUNLOAD
       ,[LAST_UPDATED_BY] = @LAST_UPDATED_BY
       ,[LAST_UPDATED] = GETDATE()
    WHERE [PASS_ID] = @PASS_ID;
    --


    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@PASS_ID AS VARCHAR) DbData


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH

END