-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	03-12-2015
-- Description:			Selecciona el total del tipo de las tareas filtradas
--                      
/*
-- Ejemplo de Ejecucion:				
				--EXECUTE [SONDA].[SWIFT_SP_GET_TASK_FILTER]
							   @LOGIN = '' usuario
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TASK_FILTER]
	@LOGIN    [varchar](100)
AS
BEGIN


	SELECT  CATEGORIA =
      CASE TASK_TYPE
         WHEN 'SALE' THEN 'Venta'
         WHEN 'PRESALE' THEN 'PreVenta'
         WHEN 'DELIVERY' THEN 'Envío'
         ELSE 'Scouting'
      END
	,COUNT(*) AS TOTAL_TASK_TYPE
	FROM [SONDA].[SWIFT_TASKS]
	WHERE [ASSIGEND_TO] = @LOGIN
	GROUP BY TASK_TYPE
	ORDER BY TASK_TYPE ASC


END
