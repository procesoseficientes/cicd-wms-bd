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

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOGIN] (@LOGIN_ID VARCHAR(25)
, @LOGIN_PWD VARCHAR(75))
AS
BEGIN
  SET NOCOUNT ON;


  ---------------------------------------------------------------------------------
  -- Obtemos los datos del usuario
  ---------------------------------------------------------------------------------  
  DECLARE @CLIEN_LICENSE VARCHAR(100)
         ,@DATE_EXPIRED DATE
         ,@TOLERANCIA INT
         ,@USERS_ONLINE INT

  SELECT
    @CLIEN_LICENSE = [VALUE]
  FROM wms.OP_WMS_PARAMETER
  WHERE GROUP_ID = 'LICENSING'
  AND PARAMETER_ID = 'CLIENT_LICENSE'
  SELECT
    @DATE_EXPIRED = [VALUE]
  FROM wms.OP_WMS_PARAMETER
  WHERE GROUP_ID = 'LICENSING'
  AND PARAMETER_ID = 'DATE_EXPIRED'
  SELECT
    @TOLERANCIA = [VALUE]
  FROM wms.OP_WMS_PARAMETER
  WHERE GROUP_ID = 'VALIDATION_LICENSE'
  AND PARAMETER_ID = 'VALIDATION_DAYS'
  SELECT
    @USERS_ONLINE = COUNT(*)
  FROM wms.OP_WMS_LOGINS
  WHERE IS_LOGGED = 1

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
   ,@CLIEN_LICENSE AS CLIENT_LICENSE
   ,@DATE_EXPIRED AS DATE_EXPIRED
   ,@TOLERANCIA AS TOLERANCE
   ,@USERS_ONLINE AS USERS_ONLINE
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