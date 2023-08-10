-- =============================================
-- Autor:				alberto.ruiz	
-- Fecha de Creacion: 	03-12-2015
-- Description:			Actualiza el si es activa o no la ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ROUTE_CHANGE_ACTIVE] @CODE_ROUTE = 'ALBERTO@SONDA' ,@IS_ACTIVE_ROUTE = 1
				--
				EXEC [SONDA].[SWIFT_SP_ROUTE_CHANGE_ACTIVE] @CODE_ROUTE = 'ALBERTO@SONDA' ,@IS_ACTIVE_ROUTE = 0
				--
				SELECT * FROM [SONDA].[SWIFT_ROUTES] WHERE CODE_ROUTE = 'ALBERTO@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ROUTE_CHANGE_ACTIVE]
	@CODE_ROUTE VARCHAR(50)
	,@IS_ACTIVE_ROUTE INT
AS
BEGIN
	SET NOCOUNT ON;
    --
	UPDATE [SONDA].[SWIFT_ROUTES]
	SET IS_ACTIVE_ROUTE = @IS_ACTIVE_ROUTE
	WHERE CODE_ROUTE = @CODE_ROUTE
END
