-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Consulta de operadores asignados a CD.




/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER] @DISTRIBUTION_CENTER  = 'C001' 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER] (@DISTRIBUTION_CENTER VARCHAR(200))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [L].[LOGIN_ID]
   ,[L].[ROLE_ID]
   ,[L].[LOGIN_NAME]
   ,[L].[LOGIN_TYPE]
   ,[L].[LOGIN_STATUS]
   ,[L].[LOGIN_PWD]
   ,[L].[LOGIN_PWD_ALTERNATE]
   ,[L].[LICENSE_SERIAL]
   ,[L].[ENVIRONMENT]
   ,[L].[GUI_LAYOUT]
   ,[L].[IS_LOGGED]
   ,[L].[LAST_LOGGED]
   ,[L].[DEFAULT_WAREHOUSE_ID]
   ,[L].[CONSOLIDATION_TERMINAL]
   ,[L].[GENERATE_TASKS]
   ,[L].[LOADING_GATE]
   ,[L].[LINE_ID]
   ,[L].[3PL_WAREHOUSE]
   ,[L].[EMAIL]
   ,[L].[AUTHORIZER]
   ,[L].[IS_EXTERNAL]
   ,[L].[RELATED_CLIENT]
   ,[L].[NOTIFY_LETTER_QUOTA]
   ,[L].[DISTRIBUTION_CENTER_ID]
  FROM [wms].[OP_WMS_LOGINS] [L]
  WHERE [L].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER
  AND UPPER(ROLE_ID) LIKE 'OPERADOR%'
  AND LOGIN_STATUS = 'ACTIVO'
  ORDER BY LOGIN_NAME
END