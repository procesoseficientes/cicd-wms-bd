-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-09-02 Nexus@CommandAndConquer
-- Description:	 Se cambia @pCheckID  a varchar(50) que es lo que realmente tiene la propiedad 


/*
-- Ejemplo de Ejecucion:
			SELECT  * FROM [wms].[OP_WMS_FUNC_IS_CHECKPOINT_IN_ROLE]('ADMIN', 'CONSULTA_SOLICITUD_DE_TRASLADO')
*/
-- ============================================= 
CREATE FUNCTION [wms].OP_WMS_FUNC_IS_CHECKPOINT_IN_ROLE (@pRoleID VARCHAR(25),
@pCheckID VARCHAR(50))
RETURNS TABLE
AS
  RETURN
  (
  SELECT TOP 1 
    1 AS CHECK_POINT_EXISTS
  FROM [wms].OP_WMS_ROLES_JOIN_CHECKPOINTS
  WHERE ROLE_ID = @pRoleID
  AND CHECK_ID = @pCheckID
  )