-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-30 @ Team ERGON - Sprint ERGON II
-- Description:	 Obtiene todas las bodegas asociadas a un usuario




/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_ASSOCIATE_DISTRIBUTION_CENTER_WITH_USER] @LOGIN_ID = 'ACAMACHO', @DISTRIBUTION_CENTER = 'C001'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ASSOCIATE_DISTRIBUTION_CENTER_WITH_USER] (@LOGIN_ID VARCHAR(25)
, @DISTRIBUTION_CENTER VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  UPDATE [wms].[OP_WMS_LOGINS]
  SET [DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER
  WHERE LOGIN_ID = @LOGIN_ID;
END