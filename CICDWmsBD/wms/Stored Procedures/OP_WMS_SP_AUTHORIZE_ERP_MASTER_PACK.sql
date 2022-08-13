-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que autoriza el envio de un master pack a erp

-- Modificacion:	      rudi.garcia
-- Fecha de Creacion: 	2017-03-17 @ Team ERGON - Sprint ERGON V
-- Description:	        Sp se agreo la validacion de que si esta ya fue enviada a erp no vuelva a actualizar el estado.
/*
-- Ejemplo de Ejecucion:
			EXEC  [OP_WMS_SP_AUTHORIZE_ERP_MASTER_PACK] @MASTER_PACK_HEADER_ID = 3
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AUTHORIZE_ERP_MASTER_PACK] (@MASTER_PACK_HEADER_ID INT, @LAST_UPDATE_BY VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    IF NOT EXISTS (SELECT
        TOP 1
          1
        FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
        WHERE [H].[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID
        AND [H].[IS_POSTED_ERP] = 1)
    BEGIN
      UPDATE [wms].OP_WMS_MASTER_PACK_HEADER
      SET IS_AUTHORIZED = 1
         ,ATTEMPTED_WITH_ERROR = 0
         ,IS_POSTED_ERP = 0
         ,LAST_UPDATED = GETDATE()
         ,LAST_UPDATE_BY = @LAST_UPDATE_BY
      WHERE MASTER_PACK_HEADER_ID = @MASTER_PACK_HEADER_ID
      AND EXPLODED = 1
    END
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH

END