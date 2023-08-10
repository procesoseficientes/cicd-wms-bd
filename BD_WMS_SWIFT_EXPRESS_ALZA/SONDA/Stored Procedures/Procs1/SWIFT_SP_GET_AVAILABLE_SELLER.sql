-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	31-May-17 @ A-TEAM Sprint Jibade 
-- Description:			Obtiene los vendedores que no esten asociados a ningun usuario y si este ya tiene el que tenga tambien

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_AVAILABLE_SELLER]
					@LOGIN = 'ALBERTO@SONDA'
				--
				EXEC [SONDA].[SWIFT_SP_GET_AVAILABLE_SELLER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_AVAILABLE_SELLER](
	@LOGIN VARCHAR(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SELLER TABLE ([SELLER_CODE] VARCHAR(50))
	--
	INSERT INTO @SELLER
	SELECT [S].[SELLER_CODE]
	FROM [SONDA].[SWIFT_SELLER] [S]
	LEFT JOIN [SONDA].[USERS] [U] ON (
		[S].[SELLER_CODE] = [U].[RELATED_SELLER]
		AND [U].[RELATED_SELLER] IS NOT NULL
	)
	WHERE [U].[CORRELATIVE] IS NULL
	--
	IF @LOGIN IS NOT NULL
	BEGIN
		INSERT INTO @SELLER ([SELLER_CODE])
		SELECT TOP 1 [RELATED_SELLER]
		FROM [SONDA].[USERS]
		WHERE [LOGIN] = @LOGIN
	END
	--
	SELECT
		[S].[SELLER_CODE]
		,[S].[SELLER_NAME]
		,[S].[PHONE1]
		,[S].[PHONE2]
		,[S].[RATED_SELLER]
		,[S].[STATUS]
		,[S].[EMAIL]
		,[S].[ASSIGNED_VEHICLE_CODE]
		,[S].[ASSIGNED_DISTRIBUTION_CENTER]
		,[S].[LAST_UPDATED]
		,[S].[LAST_UPDATED_BY]
		,[S].[SALES_OFFICE_ID]
		,[S].[OWNER]
		,[S].[OWNER_ID]
		,[S].[GPS]
	FROM [SONDA].[SWIFT_SELLER] [S]
	INNER JOIN @SELLER [TS] ON ([TS].[SELLER_CODE] = [S].[SELLER_CODE])
END
