-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Jan-17 @ A-Team Sprint Adeben 
-- Description:			    Funcion que obtiene los codigos de las tareas asignadas a un poligono

/*
-- Ejemplo de Ejecucion:
		SELECT *
		FROM [SONDA].[SWIFT_TASK_BY_POLYGON] [TP]
		WHERE [TP].[POLYGON_ID] = 6182
		--
        SELECT [SONDA].[SWIFT_FUNC_GET_TASK_TYPE_DESCRIPTION_BY_POLYGON](6182)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FUNC_GET_TASK_TYPE_DESCRIPTION_BY_POLYGON]
(
	@POLYGON_ID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @RESULT VARCHAR(MAX) = NULL
	--
	SELECT 
		@RESULT =  ISNULL(@RESULT + '|','') 
				+ CASE [TP].[TASK_TYPE]
					WHEN 'SALE' THEN 'Venta'
					WHEN 'PRESALE' THEN 'Pre Venta'
					WHEN 'DELIVERY' THEN 'Entrega'
					WHEN 'SCOUTING' THEN 'Scouting'
					WHEN 'TAKE_INVENTORY' THEN 'Toma de Inventario'
					ELSE [TP].[TASK_TYPE]
				END
	FROM [SONDA].[SWIFT_TASK_BY_POLYGON] [TP]
	WHERE [TP].[POLYGON_ID] = @POLYGON_ID
	--
	RETURN @RESULT
END
