-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que agrega un vehiculo

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega rating, is_active, fill_rate, vehicle_axles e insurance_doc_id

/*
-- Ejemplo de Ejecucion:
  
			EXEC  [wms].[OP_WMS_SP_ADD_VEHICLE] @BRAND = 'MITSUBISHI'
                                     ,@LINE = 'LANCER'
                                     ,@MODEL = '2006'
                                     ,@COLOR = 'AZUL'
                                     ,@CHASSIS_NUMBER = '56543211SGS'
                                     ,@ENGINE_NUMBER = '1500'
                                     ,@VIN_NUMBER = '13211321'
                                     ,@PLATE_NUMBER = '654CST'
                                     ,@TRANSPORT_COMPANY_CODE = 1
                                     ,@WEIGHT = 12
                                     ,@HIGH = 15
                                     ,@WIDTH = 30
                                     ,@DEPTH = 50
                                     ,@VOLUME_FACTOR = 175
                                     ,@LAST_UPDATE_BY = 'ADMIN'
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
CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_VEHICLE] (
		@BRAND VARCHAR(50)
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

		DECLARE	@ID INT;

		INSERT	INTO [wms].[OP_WMS_VEHICLE]
				(
					[BRAND]
					,[LINE]
					,[MODEL]
					,[COLOR]
					,[CHASSIS_NUMBER]
					,[ENGINE_NUMBER]
					,[VIN_NUMBER]
					,[PLATE_NUMBER]
					,[TRANSPORT_COMPANY_CODE]
					,[WEIGHT]
					,[HIGH]
					,[WIDTH]
					,[DEPTH]
					,[VOLUME_FACTOR]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[PILOT_CODE]
					,[RATING]
					,[IS_ACTIVE]
					,[STATUS]
					,[FILL_RATE]
					,[VEHICLE_AXLES]
					,[INSURANCE_DOC_ID]
					,[AVERAGE_COST_PER_KILOMETER]
				)
		VALUES
				(
					@BRAND
					,@LINE
					,@MODEL
					,@COLOR
					,@CHASSIS_NUMBER
					,@ENGINE_NUMBER
					,@VIN_NUMBER
					,@PLATE_NUMBER
					,@TRANSPORT_COMPANY_CODE
					,@WEIGHT
					,@HIGH
					,@WIDTH
					,@DEPTH
					,@VOLUME_FACTOR
					,GETDATE()
					,@LAST_UPDATE_BY
					,@PILOT_CODE
					,@RATING
					,@IS_ACTIVE
					,@STATUS
					,@FILL_RATE
					,@VEHICLE_AXLES
					,@INSURANCE_DOC_ID
					,@AVERAGE_COST_PER_KILOMETER
				);

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
			,CASE @@ERROR
				WHEN 2627
				THEN 'No se puede asignar el mismo piloto a dos vehiculos.'
				WHEN 547
				THEN 'El piloto que desea asignar no existe'
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;
