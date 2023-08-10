-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/31/2017 @ A-TEAM Sprint Jibade
-- Description:			Obtiene los clientes/scoutings para ser procesados por el geocoding

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_VALIDATE_CUSTOMER_ACQUISITION_FOR_GEOCODING]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_VALIDATE_CUSTOMER_ACQUISITION_FOR_GEOCODING]
AS
BEGIN
	SET NOCOUNT ON;
	----
	DECLARE @GEOCODING_CUSTOMERS TABLE (
		[CODE_CUSTOMER] VARCHAR(50),
		[GPS] VARCHAR(MAX),
		[LATITUDE] VARCHAR(MAX),
		[LONGITUDE] VARCHAR(MAX),
		[TYPE_CUSTOMER] VARCHAR(50)
	)
	--
	DECLARE @ROWS INT = 0
	-- ------------------------------------------------------------------------------------
	-- Obtiene los scoutings para geocoding
	-- ------------------------------------------------------------------------------------
	--INSERT into @GEOCODING_CUSTOMERS
	--		(
	--			[CODE_CUSTOMER]
	--			,[GPS]
	--			,[LATITUDE]
	--			,[LONGITUDE]
	--			,[TYPE_CUSTOMER]
	--		)
	--EXEC [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_NEW_TO_GEOCODING]
	----
	--SET @ROWS = @@ROWCOUNT
	-- ------------------------------------------------------------------------------------
	-- Si no obtuvo ningun scouting, obtiene las modificaciones de clientes
	-- ------------------------------------------------------------------------------------
	IF(@ROWS = 0)
	BEGIN
		INSERT into @GEOCODING_CUSTOMERS
			(
				[CODE_CUSTOMER]
				,[GPS]
				,[LATITUDE]
				,[LONGITUDE]
				,[TYPE_CUSTOMER]
			)
		EXEC [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_CHANGE_TO_GEOCODING]
	END
	-- ------------------------------------------------------------------------------------
	-- Envia el resultado
	-- ------------------------------------------------------------------------------------
	SELECT [CODE_CUSTOMER]
			,[GPS]
			,[LATITUDE]
			,[LONGITUDE]
			,[TYPE_CUSTOMER] 
	FROM @GEOCODING_CUSTOMERS
END
