-- =============================================
-- Autor:					hector.gonzalez
-- Fecha de Creacion: 		11-05-2016
-- Description:			    Función que devuelve la cantidad ingresada con los decimales parametrizados y redondeado con la funcion de redondeo parametrizada en la tabla SWIFT_PARAMETER

-- Modificacion 23-06-2016
					-- alberto.ruiz
					-- Se corrigio funcion para que no retornara la variable tipo money y que retornara el valor correcto

/*
-- Ejemplo de Ejecucion:
		--
		SELECT * FROM [SONDA].[SWIFT_PARAMETER] WHERE [GROUP_ID] = 'CALCULATION_RULES'
		--
        SELECT
			123.5555555
			,[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER](123.5555555)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER] (@IN_VALUE NUMERIC(18, 6))
RETURNS SQL_VARIANT
AS
BEGIN
	DECLARE
		@OUT_VALUE DECIMAL(18, 6)
		,@DEFAULT_DISPLAY_DECIMALS INT
		,@DISPLAY_DECIMALS_ROUND_TYPE VARCHAR(50);

	-- ------------------------------------------------
	-- Se obtienen los parametros necesarios
	-- ------------------------------------------------
	SET @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS'); 
	SET @DISPLAY_DECIMALS_ROUND_TYPE = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DISPLAY_DECIMALS_ROUND_TYPE'); 

	-- ------------------------------------------------
	-- -------------------------------------------------
	SET @OUT_VALUE = CASE	
		WHEN @DISPLAY_DECIMALS_ROUND_TYPE = 'ROUND' THEN ROUND(@IN_VALUE, @DEFAULT_DISPLAY_DECIMALS)
		WHEN @DISPLAY_DECIMALS_ROUND_TYPE = 'TRUNC' THEN ROUND(@IN_VALUE, @DEFAULT_DISPLAY_DECIMALS,1)
		WHEN @DISPLAY_DECIMALS_ROUND_TYPE = 'FLOOR' THEN FLOOR(@IN_VALUE)
		WHEN @DISPLAY_DECIMALS_ROUND_TYPE = 'CEILING' THEN CEILING(@IN_VALUE)
		ELSE @IN_VALUE
	END;

	RETURN STR(@OUT_VALUE,18,@DEFAULT_DISPLAY_DECIMALS);
END;
