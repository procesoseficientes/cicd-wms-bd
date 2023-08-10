-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	03-12-2015
-- Description:			Selecciona el total del tipo de las tareas filtradas resumidas por ruta
--                      
/*
-- Ejemplo de Ejecucion:				
				--EXECUTE [SONDA].[SWIFT_SP_GET_TASK_REVIEW_BY_ROUTE]
							   @CODE_ROUTE= '001' --codigo ruta
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TASK_REVIEW_BY_ROUTE]
	@CODE_ROUTE   [varchar](100)
AS
BEGIN
	SELECT  
		CASE TASK.TASK_TYPE
			WHEN 'SALE' THEN 'Venta'
			WHEN 'PRESALE' THEN 'PreVenta'
			WHEN 'DELIVERY' THEN 'Entrega'
			ELSE 'Scouting'
		END TASK_TYPE
		,COUNT(*) AS TOTAL_TASK_TYPE
	FROM [SONDA].[SWIFT_TASKS] AS TASK 
	INNER JOIN [SONDA].[USERS] AS USERS ON (USERS.[LOGIN] = TASK.[ASSIGEND_TO])
	WHERE USERS.[SELLER_ROUTE] = @CODE_ROUTE 
		AND TASK.TASK_DATE = CONVERT(DATE,GETDATE())
	GROUP BY TASK.TASK_TYPE
	ORDER BY TASK.TASK_TYPE ASC


END
