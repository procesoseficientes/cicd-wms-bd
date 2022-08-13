-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-13 @ Team ERGON - Sprint ERGON III
-- Description:	        Sp que hace un insert a la tabla [OP_WMS_MANIFEST_HEADER]

-- Modificacion 8/28/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agregan columnas MANIFEST_TYPE y TRANSFER_REQUEST_ID

-- Modificacion 10/18/2017 @ Reborn - Team Sprint Drache
-- diego.as
-- Se agrega select para obtener el codigo del piloto en base al codigo del vehiculo
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_MANIFEST_HEADER] 
				@DRIVER = 'HECTOR'
				,@VEHICLE = 'YARIS_123'
				,@LAST_UPDATE_BY = 'YO'
				,@MANIFEST_TYPE = 'SALES_ORDER'
				,@TRANSFER_REQUEST_ID = NULL
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_MANIFEST_HEADER] (@DRIVER VARCHAR(50) = NULL
, @VEHICLE VARCHAR(50)
, @LAST_UPDATE_BY VARCHAR(50)
, @MANIFEST_TYPE VARCHAR(50)
, @TRANSFER_REQUEST_ID INT = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DECLARE @DISTRIBUTION_CENTER VARCHAR(50)
           ,@TRANSFER_ID INT
           ,@PILOT_CODE INT
           ,@PLATE_NUMBER VARCHAR(10)
		   ,@CAI VARCHAR(100)
		   ,@CAI_SERIE VARCHAR(100)
		   ,@CAI_NUMERO VARCHAR(100)
		   ,@CAI_RANGO_INICIAL FLOAT
		   ,@CAI_RANGO_FINAL FLOAT
		   ,@CAI_FECHA_VENCIMIENTO DATE
		   ;

    --
    SELECT
      @PILOT_CODE = V.PILOT_CODE
     ,@PLATE_NUMBER = [V].[PLATE_NUMBER]
    FROM [wms].[OP_WMS_VEHICLE] AS V
    WHERE V.[VEHICLE_CODE] = CAST(@VEHICLE AS INT)
    --
    SELECT
      @DISTRIBUTION_CENTER = [L].[DISTRIBUTION_CENTER_ID]
    FROM [wms].[OP_WMS_LOGINS] [L]
    WHERE [L].[LOGIN_ID] = @LAST_UPDATE_BY;
    
    SELECT @TRANSFER_ID = [TRANSFER_REQUEST_ID],
		@CAI = CAI,
		@CAI_SERIE=CAI_SERIE,
		@CAI_NUMERO=CAI_NUMERO,
		@CAI_RANGO_INICIAL=CAI_RANGO_INICIAL,
		@CAI_RANGO_FINAL=CAI_RANGO_FINAL,
		@CAI_FECHA_VENCIMIENTO=CAI_FECHA_VENCIMIENTO
    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
    WHERE @TRANSFER_REQUEST_ID = [TRANSFER_REQUEST_ID] AND [DEMAND_TYPE] = 'TRANSFER_REQUEST'
    --
    INSERT [wms].[OP_WMS_MANIFEST_HEADER] 
	(
		[DRIVER]
		, [VEHICLE]
		, [DISTRIBUTION_CENTER]
		, [CREATED_DATE]
		, [STATUS]
		, [LAST_UPDATE]
		, [LAST_UPDATE_BY]
		, [MANIFEST_TYPE]
		, [TRANSFER_REQUEST_ID]
		, [PLATE_NUMBER]
		, [CAI]
		, CAI_SERIE
		, CAI_NUMERO
		, CAI_RANGO_INICIAL
		, CAI_RANGO_FINAL
		, CAI_FECHA_VENCIMIENTO
	)
	VALUES 
	(
		CASE 
			WHEN @PILOT_CODE IS NULL THEN '' 
			ELSE CAST(@PILOT_CODE AS VARCHAR) 
			END
		,@VEHICLE
		,@DISTRIBUTION_CENTER
		,GETDATE()
		,DEFAULT
		,GETDATE()
		,@LAST_UPDATE_BY
		,@MANIFEST_TYPE
		,CASE WHEN @TRANSFER_REQUEST_ID = 0 THEN NULL 
			ELSE @TRANSFER_REQUEST_ID 
			END
		,@PLATE_NUMBER
		,@CAI
		,@CAI_SERIE
		,@CAI_NUMERO
		,@CAI_RANGO_INICIAL
		,@CAI_RANGO_FINAL
		,@CAI_FECHA_VENCIMIENTO
	);

    DECLARE @DOC_ID INT = SCOPE_IDENTITY();


    IF @@error <> 0
    BEGIN

      SELECT
        -1 AS [Resultado]
       ,ERROR_MESSAGE() [Mensaje]
       ,@@error [Codigo]
       ,'0' [DbData];

    END;
    ELSE
    BEGIN
      SELECT
        1 AS [Resultado]
       ,'Proceso Exitoso' [Mensaje]
       ,0 [Codigo]
       ,CAST(@DOC_ID AS VARCHAR) [DbData];
    END;


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;


END;