-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que trae el rol de piloto

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_GET_USER_ROLE  
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_GET_USER_ROLE
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [R].[ROLE_ID]
   ,[R].[ROLE_NAME]
   ,[R].[ROLE_DESCRIPTION]
  FROM [wms].[OP_WMS_ROLES] [R]
  WHERE [R].[ROLE_ID] = 'PILOTO'

END