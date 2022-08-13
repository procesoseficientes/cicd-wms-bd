-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que inserta el pase de salida

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [wms].[ERP_SP_INSERT_SALES_ORDER_HEADER] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_EXIT_PASS] (@CLIENT_CODE VARCHAR(25)
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
, @CREATED_BY VARCHAR(25)
,@LICENSE_NUMBER VARCHAR(50)
, @TYPE VARCHAR(25)
)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DECLARE @ID INT
    --
    INSERT INTO [wms].[OP_WMS3PL_PASSES] ([CLIENT_CODE]
    , [CLIENT_NAME]
    , [ISEMPTY]
    , [VEHICLE_PLATE]
    , [VEHICLE_DRIVER]
    , [VEHICLE_ID]
    , [DRIVER_ID]
    , [AUTORIZED_BY]
    , [HANDLER]    
    , [TXT]
    , [LOADUNLOAD]
    , [CREATED_BY]
    , [TYPE]
    )
      VALUES (@CLIENT_CODE, @CLIENT_NAME, @ISEMPTY, @VEHICLE_PLATE, @VEHICLE_DRIVER, @VEHICLE_ID, @DRIVER_ID, @AUTORIZED_BY, @HANDLER, @TXT, @LOADUNLOAD, @CREATED_BY, @TYPE);

    SET @ID = SCOPE_IDENTITY()

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@ID AS VARCHAR) DbData


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH

END