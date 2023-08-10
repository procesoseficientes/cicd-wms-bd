-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-12-2015
-- Description:			Obtiene la lista de precios default o por ruta

/*
-- Ejemplo de Ejecucion:
				SELECT [SONDA].[SWIFT_FN_GET_PRICE_LIST](DEFAULT)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_PRICE_LIST]
(
	@CODE_ROUTE VARCHAR(50) = NULL
)
RETURNS VARCHAR(25)
AS
BEGIN
	DECLARE @CODE_PRICE_LIST VARCHAR(25)
	--
	IF @CODE_ROUTE IS NULL
	BEGIN		
		SELECT TOP 1 
			@CODE_PRICE_LIST = p.VALUE
		FROM [SONDA].SWIFT_PARAMETER p
		WHERE 
			p.GROUP_ID='ERP_HARDCODE_VALUES' 
			AND p.PARAMETER_ID='PRICE_LIST'
	END
	--
	RETURN @CODE_PRICE_LIST
END