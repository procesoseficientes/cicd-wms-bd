-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	23-Nov-2017 @ Reborn-Team Sprint Nach 
-- Description:			Sp cre obtine los usuario activos por el centro de distribucion

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_ACTIVE_USER_BY_DISTRIBUTION_CENTER]
					@DISTRIBUTION_CENTER = 'BODEGA_01'
				--
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ACTIVE_USER_BY_DISTRIBUTION_CENTER] (
  @DISTRIBUTION_CENTER VARCHAR(200)
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
   ,[L].[EXTERNAL_USER_LOGIN]
   ,[L].[EXTERNAL_NAME_USER]
  FROM [wms].[OP_WMS_LOGINS] AS [L]
  WHERE [L].[LOGIN_STATUS] = 'ACTIVO'
  AND [L].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER
END;