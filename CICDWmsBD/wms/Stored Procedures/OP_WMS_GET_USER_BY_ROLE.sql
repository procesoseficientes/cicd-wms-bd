-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que trae usuarios por el rol 

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_GET_USER_BY_ROLE  @USER_ROLE = 'OPERADOR', @USER_CODE= 'OPER2'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_GET_USER_BY_ROLE (
  @USER_ROLE VARCHAR(25) = 'PILOTO'
  , @USER_CODE VARCHAR(25)= NULL
)
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
   ,[L].[CAN_RELOCATE]
   ,[L].[LINE_POSITION]
   ,[L].[SPOT_COLUMN]
   ,[L].[TERMINAL_IP]
  FROM [wms].[OP_WMS_LOGINS] [L]
  LEFT JOIN [wms].[OP_WMS_USER_X_PILOT] [UXP]
    ON ([L].[LOGIN_ID] = [UXP].[USER_CODE] )
  WHERE [L].[ROLE_ID] = @USER_ROLE
  AND ([UXP].[PILOT_CODE] IS NULL OR ([UXP].[USER_CODE] = @USER_CODE))
  AND [L].[LOGIN_ID] > ''

END