
/*
	-- =============================================
-- Autor:				dieg.as
-- Fecha de Creacion: 	04-07-2016
-- Description:			Valida si existe una Lista de Precios por Default

-- Ejemplo de Ejecucion:	

	SELECT [SONDA].[SONDA_FUNC_VALIDATE_PRICE_LIST_DEFAULT]
							
-- =============================================
*/
CREATE FUNCTION [SONDA].[SONDA_FUNC_VALIDATE_PRICE_LIST_DEFAULT]
()
RETURNS BIT
AS
BEGIN
	DECLARE @EXIST BIT = 0
	--
	SELECT @EXIST = COUNT(*) 
	FROM [SONDA].[SWIFT_PARAMETER] AS P
	WHERE P.GROUP_ID = 'ERP_HARDCODE_VALUES' 
			AND P.PARAMETER_ID = 'PRICE_LIST'
			AND P.VALUE <> ''
			AND P.VALUE <> 0
	--
	RETURN @EXIST
 END;
