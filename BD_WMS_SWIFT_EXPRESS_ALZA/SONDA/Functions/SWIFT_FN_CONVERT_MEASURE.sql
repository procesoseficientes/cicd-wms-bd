/*
	-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	11-12-2015
-- Description:			Función que convierte la medida de sku a KG e inserta en tabla sku.

-- Ejemplo de Ejecucion:	
							DECLARE 
							@MEASURE_FROM int = 34
							,@MEASURE_TO int = 35
							,@value float = 10000
							,@CONVERTION float = 0

							set @CONVERTION =  [SONDA].[SWIFT_FN_CONVERT_MEASURE] 
							(
							@MEASURE_FROM
							,@MEASURE_TO
							,@VALUE)

							SELECT @CONVERTION as RESULT
-- =============================================
*/

 CREATE FUNCTION [SONDA].[SWIFT_FN_CONVERT_MEASURE]
( 
	@MEASURE_FROM INT
	,@MEASURE_TO INT
	,@VALUE FLOAT
)

RETURNS FLOAT
AS
BEGIN

	DECLARE @CONVERTION FLOAT = 1
	--
	SELECT @CONVERTION = C.CONVERTION_FACTOR
	FROM [SONDA].[SWIFT_UNIT_CONVERTION] C
	WHERE C.MEASURE_UNIT_FROM = @MEASURE_FROM
	AND C.MEASURE_UNIT_TO = @MEASURE_TO
	--
	SET @CONVERTION = @CONVERTION * @VALUE
	--
	RETURN @CONVERTION
 END;
