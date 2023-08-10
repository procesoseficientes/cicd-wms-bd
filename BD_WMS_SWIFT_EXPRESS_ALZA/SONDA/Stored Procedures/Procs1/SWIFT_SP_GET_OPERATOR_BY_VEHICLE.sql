-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		20-05-2016
-- Description:			    Obtiene todos los usuarios relacionados a un vehiculo

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_OPERATOR_BY_VEHICLE]
		--
		EXEC [SONDA].[SWIFT_SP_GET_OPERATOR_BY_VEHICLE]
			@CODE_VEHICLE = '001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_OPERATOR_BY_VEHICLE]
	@CODE_VEHICLE VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[O].[CORRELATIVE]
		,[O].[LOGIN]
		,[O].[NAME_USER]
		,[O].[TYPE_USER]
		,[O].[PASSWORD]
		,[O].[ENTERPRISE]
		,[O].[IMAGE]
		,[O].[RELATED_SELLER]
		,[O].[SELLER_ROUTE]
		,[O].[USER_TYPE]
		,[O].[DEFAULT_WAREHOUSE]
		,[O].[USER_ROLE]
		,[O].[PRESALE_WAREHOUSE]
		,[O].[ROUTE_RETURN_WAREHOUSE]
	FROM [SONDA].[SWIFT_VIEW_OPERATOR] [O]
	INNER JOIN [SONDA].[SWIFT_VEHICLE_X_USER] [VU] ON (
		[O].[LOGIN] = [VU].[LOGIN]
	)
	INNER JOIN [SONDA].[SWIFT_VEHICLES] [V] ON (
		VU.[VEHICLE] = [V].[VEHICLE]
	)
	WHERE @CODE_VEHICLE IS NULL OR [V].[CODE_VEHICLE] = @CODE_VEHICLE
END
