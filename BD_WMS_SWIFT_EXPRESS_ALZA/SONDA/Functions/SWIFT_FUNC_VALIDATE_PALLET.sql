/*
	-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	13-01-2016
-- Description:			Función que valida que el pallet exista
--						y que el producto coresponda a la tarea
						--
-- Ejemplo de Ejecucion:	
						SELECT [SONDA].[SWIFT_FUNC_VALIDATE_PALLET]('6211','20GE','60')
						--						--
-- =============================================
*/
CREATE FUNCTION [SONDA].[SWIFT_FUNC_VALIDATE_PALLET]
( 
	@TASK_ID INT
	,@SKU VARCHAR(50)
	,@PALLET_ID AS INT
)
RETURNS BIT
	AS
BEGIN

	DECLARE @RESULT BIT = 0
	--
	SELECT TOP 1 @RESULT = 1  
	FROM [SONDA].[SWIFT_PALLET] TP
	INNER JOIN [SONDA].[SWIFT_BATCH] TB ON (
		TP.BATCH_ID = TB.BATCH_ID
		AND TP.TASK_ID = TB.TASK_ID
	)
	WHERE PALLET_ID = @PALLET_ID 
	AND TB.TASK_ID =@TASK_ID
	AND TB.SKU=@SKU
	AND TP.STATUS='PENDING'	
	--
	RETURN @RESULT
 END;
