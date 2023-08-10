-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/28/2016 @ A-TEAM Sprint Balder 
-- Description:			retorna los registros de la tabla SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ACCESS_WAREHOUSE_BY_USER]
					@LOGIN = 'rudi@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ACCESS_WAREHOUSE_BY_USER](
	@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @CORRELATIVE INT = (SELECT CORRELATIVE FROM [SONDA].[USERS] WHERE @LOGIN = [LOGIN])

	SELECT	[USER_CORRELATIVE]
			,[CODE_WAREHOUSE]
	FROM [SONDA].[SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS]
	WHERE [USER_CORRELATIVE] = @CORRELATIVE
END
