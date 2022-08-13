-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-23 @ Team ERGON - Sprint ERGON III
-- Description:	 Validar licencia 




/*
-- Ejemplo de Ejecucion:
			
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_IS_VALID_LICENCE](
	@LICENCE_ID AS INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--

  IF NOT EXISTS(SELECT * FROM [wms].[OP_WMS_LICENSES] [L] WHERE [L].[LICENSE_ID] = @LICENCE_ID ) BEGIN  
  	RAISERROR ('Licencia no existe', 16, 1);
    RETURN;
  END
  

  END