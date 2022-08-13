-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	28-Jun-2019 G-FORCE@Cancun-Swift3PL
-- Description:			Sp que obtiene todoas las credenciales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_CHECKPOINTS_BY_LOGIN]						
					@LOGIN_ID VARCHAR(25) = 'RUDI'
        , @TYPE VARCHAR(25) = 'PC'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CHECKPOINTS_BY_LOGIN](@LOGIN_ID VARCHAR(25)
, @TYPE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;

  -- ----------------------------------------
  -- Declaramos las variables necesarias
  -- ----------------------------------------
  DECLARE @ROL_ID VARCHAR(25)

  -- ----------------------------------------
  -- Obtenemos la 
  -- ----------------------------------------
  SELECT TOP 1
    @ROL_ID = [L].[ROLE_ID]
  FROM [wms].[OP_WMS_LOGINS] [L]
  WHERE @LOGIN_ID = [L].[LOGIN_ID]


  SELECT
    [C].[CHECK_ID]
   ,[C].[CATEGORY]
   ,[C].[DESCRIPTION]
   ,[C].[PARENT]
   ,[C].[ACCESS]
   ,[C].[MPC_1]
   ,[C].[MPC_2]
   ,[C].[MPC_3]
   ,[C].[MPC_4]
   ,[C].[MPC_5]
   ,[C].[TARGET_LOCATION]
   ,[C].[ORDER]
   ,[C].[TYPE]
   ,[C].[PATH_IMAGE]
  FROM [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [RC]
  INNER JOIN [wms].[OP_WMS_CHECKPOINTS] [C]
    ON ([RC].[CHECK_ID] = [C].[CHECK_ID])
  WHERE [RC].[ROLE_ID] = @ROL_ID
  AND [C].[TYPE] = @TYPE
  ORDER BY [C].[ACCESS]
END