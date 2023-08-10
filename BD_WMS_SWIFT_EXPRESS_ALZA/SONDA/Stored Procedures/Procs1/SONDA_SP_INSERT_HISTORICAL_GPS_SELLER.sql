-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	11/8/2017 @ Reborn - TEAM Sprint Eberhard
-- Description:			SP que agrega el registro del historico del gps de un vendedor

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_INSERT_HISTORICAL_GPS_SELLER]
				@CODE_ROUTE = '46'
				,@GPS = '14.660196, -90.460781'
				,@LONGITUDE = '14.6349149'
				,@LATITUDE = '-90.5068824'
				,@DEVICE_BATTERY_FACTOR = 50
				,@INFORMATION_SOURCE = 'SONDA_CORE'
				-- 
				SELECT * FROM [SONDA].[SONDA_HISTORICAL_GPS_SELLER] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_HISTORICAL_GPS_SELLER](
	@CODE_ROUTE VARCHAR(50)
	,@GPS VARCHAR(250)
	,@LONGITUDE VARCHAR(250)
	,@LATITUDE VARCHAR(250)
	,@DEVICE_BATTERY_FACTOR NUMERIC(18,6)
	,@INFORMATION_SOURCE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SONDA_HISTORICAL_GPS_SELLER]
				(
					[CODE_ROUTE]
					,[GPS]
					,[LONGITUDE]
					,[LATITUDE]
					,[DEVICE_BATTERY_FACTOR]
					,[INFORMATION_SOURCE]
				)
		VALUES
				(
					@CODE_ROUTE
					,@GPS
					,@LONGITUDE
					,@LATITUDE
					,@DEVICE_BATTERY_FACTOR
					,@INFORMATION_SOURCE
				)
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(MAX);
		SET @ERROR = ERROR_MESSAGE();

		EXEC SONDA.[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] 
		@CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
			@LOGIN = @CODE_ROUTE , -- varchar(50)
			@SOURCE_ERROR = 'SONDA_SP_INSERT_HISTORICAL_GPS_SELLER' , -- varchar(250)
			@DOC_RESOLUTION = '' , -- varchar(100)
			@DOC_SERIE = '' , -- varchar(100)
			@DOC_NUM = 0 , -- int
			@MESSAGE_ERROR = @ERROR , -- varchar(max)
			@SEVERITY_CODE = -125-- int
		
	END CATCH
END
