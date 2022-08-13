-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	13-Mar-2018
-- Description:			SP que obtiene el los datos del login

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_LOGIN] @LOGIN_ID = 'ADMIN'
       ,@LOGIN_ID = '1234'
      
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOGIN] (
  @LOGIN_ID VARCHAR(25)
, @LOGIN_PWD VARCHAR(75)
)
AS
BEGIN
  SET NOCOUNT ON;


  ---------------------------------------------------------------------------------
  -- Obtemos los datos del usuario
  ---------------------------------------------------------------------------------  

  SELECT
    [L].[LOGIN_TYPE]
   ,[L].[LOGIN_ID]
   ,[L].[ENVIRONMENT]
   ,[L].[DEFAULT_WAREHOUSE_ID]
   ,[L].[ROLE_ID]
   ,[L].[IS_LOGGED]
   ,[L].[DISTRIBUTION_CENTER_ID]
   ,[L].[LOGIN_NAME]
   ,[L].[GUI_LAYOUT]
   ,[L].[LAST_LOGGED]
   ,[E].[WS_HOST]
   ,[L].[3PL_WAREHOUSE]
   ,[D].[USER]
   ,[D].[PASSWORD]
  FROM [wms].[OP_WMS_LOGINS] [L]
  INNER JOIN [wms].[OP_SETUP_ENVIRONMENTS] [E]
    ON (
    [E].[ENVIRONMENT_NAME] = [L].ENVIRONMENT
    )
  INNER JOIN [OP_WMS_DOMAINS] [D]
    ON (
    [D].[ID] = [L].[DOMAIN_ID]
    )
  WHERE [E].[PLATFORM] = 'OP_WMS'
  AND [L].[LOGIN_ID] = @LOGIN_ID
  AND [L].[LOGIN_PWD] = @LOGIN_PWD

END;