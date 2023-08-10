/*
	-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	13-01-2016
-- Description:			Función que valida que el pallet exista
--						y que el producto coresponda a la tarea
						--
-- Ejemplo de Ejecucion:	
						SELECT [SONDA].[SWIFT_FUNC_VALIDATE_TASK]('5219','20GM')
						--						--
-- =============================================
*/
CREATE FUNCTION [SONDA].[SWIFT_FUNC_VALIDATE_TASK]
( 
	@TASK_ID INT
	,@SKU VARCHAR(50)
)
RETURNS BIT
	AS
BEGIN
	DECLARE @RESULT BIT = 0
	--
	SELECT TOP 1 @RESULT = 1  
	FROM [SONDA].[SWIFT_PALLET] TP
	INNER JOIN [SONDA].[SWIFT_BATCH] TB ON (TP.TASK_ID = TB.TASK_ID)
	WHERE TB.TASK_ID =@TASK_ID
	AND TB.SKU=@SKU
	--
	RETURN @RESULT
 END;
