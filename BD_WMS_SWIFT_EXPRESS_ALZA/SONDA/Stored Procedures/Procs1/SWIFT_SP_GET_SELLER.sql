-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/28/2016 @ A-TEAM Sprint Balder
-- Description:			Obtiene uno o todos los vendedores 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SELLER]
					@SELLER_CODE = '1'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SELLER](
	@SELLER_CODE VARCHAR(100) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF @SELLER_CODE IS NOT NULL
	BEGIN
		SELECT [SELLER_CODE]
				,[SELLER_NAME]
				,[PHONE1]
				,[PHONE2]
				,[RATED_SELLER]
				,[STATUS]
				,[EMAIL]
				,[ASSIGNED_VEHICLE_CODE]
				,[ASSIGNED_DISTRIBUTION_CENTER]
				,[LAST_UPDATED]
				,[LAST_UPDATED_BY]
		FROM [SONDA].[SWIFT_SELLER]
		WHERE @SELLER_CODE = [SELLER_CODE]
	END
	ELSE
	BEGIN
		SELECT [SELLER_CODE]
				,[SELLER_NAME]
				,[PHONE1]
				,[PHONE2]
				,[RATED_SELLER]
				,[STATUS]
				,[EMAIL]
				,[ASSIGNED_VEHICLE_CODE]
				,[ASSIGNED_DISTRIBUTION_CENTER]
				,[LAST_UPDATED]
				,[LAST_UPDATED_BY]
		FROM [SONDA].[SWIFT_SELLER]
	END
END
