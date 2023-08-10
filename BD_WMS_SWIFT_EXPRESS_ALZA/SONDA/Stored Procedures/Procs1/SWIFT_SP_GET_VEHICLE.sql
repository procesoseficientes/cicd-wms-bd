-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		20-05-2016
-- Description:			    Obtiene todos los vehiculos o uno en especifico

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_VEHICLE]
		--
		EXEC [SONDA].[SWIFT_SP_GET_VEHICLE]
			@CODE_VEHICLE = '001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_VEHICLE]
	@CODE_VEHICLE VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[V].[VEHICLE]
		,[V].[CODE_VEHICLE]
		,[V].[PLATE_VEHICLE]
		,[V].[CLASSIFICATION_VEHICLE]
		,[V].[MAXIMUM_WEIGHT]
		,[V].[BRAND]
		,[V].[UNIT]
		,[V].[LAST_UPDATE]
		,[V].[LAST_UPDATE_BY]
	FROM [SONDA].[SWIFT_VEHICLES] [V]
	WHERE @CODE_VEHICLE IS NULL OR [V].[CODE_VEHICLE] = @CODE_VEHICLE
END
