-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que actualiza un Vehiculo

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega rating, is_active, fill_rate, vehicle_axles e insurance_doc_id
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_VEHICLE] 
											@VEHICLE_CODE = 28
											,@BRAND = 'MITSUBISHI'
											,@LINE = 'MONTERO IO'
											,@MODEL = '2000'
											,@COLOR = 'BLANCA'
											,@CHASSIS_NUMBER = '3216543216'
											,@ENGINE_NUMBER = '2500'
											,@VIN_NUMBER = '69879546ASDF'
											,@PLATE_NUMBER = '987ASD'
											,@TRANSPORT_COMPANY_CODE = 15
											,@WEIGHT = 10
											,@HIGH = 20
											,@WIDTH = 30
											,@DEPTH = 40
											,@VOLUME_FACTOR = 80
											,@LAST_UPDATE_BY = 'RD'
											,@PILOT_CODE = 24
											,@RATING = 5.0
											,@IS_ACTIVE = 1
											,@STATUS = 'DISPONIBLE'
											,@FILL_RATE = 100
											,@VEHICLE_AXLES = 1
											,@INSURANCE_DOC_ID = 46
  
  SELECT * FROM [wms].[OP_WMS_VEHICLE] [owv] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_VEHICLE] (
		@VEHICLE_CODE INT
		,@BRAND VARCHAR(50)
		,@LINE VARCHAR(50)
		,@MODEL VARCHAR(10)
		,@COLOR VARCHAR(25)
		,@CHASSIS_NUMBER VARCHAR(50)
		,@ENGINE_NUMBER VARCHAR(50)
		,@VIN_NUMBER VARCHAR(50) = NULL
		,@PLATE_NUMBER VARCHAR(10)
		,@TRANSPORT_COMPANY_CODE INT = NULL
		,@WEIGHT NUMERIC(18, 2)
		,@HIGH NUMERIC(18, 2)
		,@WIDTH NUMERIC(18, 2)
		,@DEPTH NUMERIC(18, 2)
		,@VOLUME_FACTOR NUMERIC(18, 2)
		,@LAST_UPDATE_BY VARCHAR(25)
		,@PILOT_CODE INT = NULL
		,@RATING DECIMAL(18, 6)
		,@IS_ACTIVE INT
		,@STATUS VARCHAR(50)
		,@FILL_RATE VARCHAR(50)
		,@VEHICLE_AXLES INT
		,@INSURANCE_DOC_ID INT = NULL
		,@AVERAGE_COST_PER_KILOMETER NUMERIC(18, 6)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY

		UPDATE
			[wms].[OP_WMS_VEHICLE]
		SET	
			[BRAND] = @BRAND
			,[LINE] = @LINE
			,[MODEL] = @MODEL
			,[COLOR] = @COLOR
			,[CHASSIS_NUMBER] = @CHASSIS_NUMBER
			,[ENGINE_NUMBER] = @ENGINE_NUMBER
			,[VIN_NUMBER] = @VIN_NUMBER
			,[PLATE_NUMBER] = @PLATE_NUMBER
			,[TRANSPORT_COMPANY_CODE] = @TRANSPORT_COMPANY_CODE
			,[WEIGHT] = @WEIGHT
			,[HIGH] = @HIGH
			,[WIDTH] = @WIDTH
			,[DEPTH] = @DEPTH
			,[VOLUME_FACTOR] = @VOLUME_FACTOR
			,[LAST_UPDATE] = DEFAULT
			,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
			,[PILOT_CODE] = @PILOT_CODE
			,[RATING] = @RATING
			,[IS_ACTIVE] = @IS_ACTIVE
			,[STATUS] = @STATUS
			,[FILL_RATE] = @FILL_RATE
			,[VEHICLE_AXLES] = @VEHICLE_AXLES
			,[INSURANCE_DOC_ID] = @INSURANCE_DOC_ID
			,[AVERAGE_COST_PER_KILOMETER] = @AVERAGE_COST_PER_KILOMETER
		WHERE
			[VEHICLE_CODE] = @VEHICLE_CODE;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@VEHICLE_CODE AS VARCHAR) [DbData];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;


END;
