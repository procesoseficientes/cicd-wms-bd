-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/12/2017 @ A-TEAM Sprint Adeben 
-- Description:			Obtiene todas las rutas filtradas con por la columna TRADE_AGREEMENT_ID

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ROUTE_BY_TRADE_AGREEMENT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROUTE_BY_TRADE_AGREEMENT](
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [ROUTE]
			,[CODE_ROUTE]
			,[NAME_ROUTE]
			,[GEOREFERENCE_ROUTE]
			,[COMMENT_ROUTE]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			,[IS_ACTIVE_ROUTE]
			,[CODE_COUNTRY]
			,[NAME_COUNTRY]
			,[SELLER_CODE]
			,[TRADE_AGREEMENT_ID] 
	FROM [SONDA].[SWIFT_ROUTES]
	WHERE @TRADE_AGREEMENT_ID = [TRADE_AGREEMENT_ID]
END
