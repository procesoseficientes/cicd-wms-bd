-- =============================================
-- Autor:				alberto.ruiz	
-- Fecha de Creacion: 	11-12-2015
-- Description:			Obtiene broadcast por ruta pendientes

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_BROADCAST_BY_ROUTE] @CODE_ROUTE = '001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_BROADCAST_BY_ROUTE]
	@CODE_ROUTE VARCHAR(150)
AS
BEGIN
	SET NOCOUNT ON;
    --
	SELECT 
		B.[ID_BROADCAST]
		,B.[CODE_BROADCAST]
		,B.[SOURCE_TABLE]
		,B.[SOURCE_KEY]
		,B.[SOURCE_VALUE]
		,B.[STATUS]
		,B.[ADDRESS]
		,B.[OPERATION_TYPE]
	FROM [SONDA].[SWIFT_PENDING_BROADCAST] B
	WHERE B.ADDRESS = @CODE_ROUTE
		AND B.STATUS = 'PENDING'
END
