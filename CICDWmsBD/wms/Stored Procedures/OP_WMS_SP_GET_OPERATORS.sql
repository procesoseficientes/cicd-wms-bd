-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 @ Team ERGON - Sprint ERGON 1
-- Description:	        Consulta los operadores activos

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_OPERATORS 
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_OPERATORS 
AS
BEGIN
  SET NOCOUNT ON;
--
  SELECT
  *
FROM [wms].OP_WMS_LOGINS
WHERE UPPER(ROLE_ID) LIKE 'OPERADOR%'
AND LOGIN_STATUS = 'ACTIVO'
ORDER BY LOGIN_NAME

END