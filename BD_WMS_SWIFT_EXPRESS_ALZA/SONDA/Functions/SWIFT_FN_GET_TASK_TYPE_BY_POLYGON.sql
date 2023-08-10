-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Jan-17 @ A-Team Sprint Adeben 
-- Description:			    Funcion que obtiene los codigos de las tareas asignadas a un poligono

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_GET_TASK_TYPE_BY_POLYGON](6182)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_TASK_TYPE_BY_POLYGON]
(
	@POLYGON_ID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @RESULT VARCHAR(MAX) = NULL
	--
	SELECT @RESULT =  ISNULL(@RESULT + '|','')+ [TP].[TASK_TYPE]
	FROM [SONDA].[SWIFT_TASK_BY_POLYGON] [TP]
	WHERE [TP].[POLYGON_ID] = @POLYGON_ID
	--
	RETURN @RESULT
END
