-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-27 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que marca un master pack fallido

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_MASTER_PACK_AS_FAILED_TO_ERP]
          @MASTER_PACK_HEADER_ID  = 1
          ,@POSTED_RESPONSE = 'Error de sap'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_MASTER_PACK_AS_FAILED_TO_ERP] (@MASTER_PACK_HEADER_ID  INT
, @POSTED_RESPONSE VARCHAR(500))
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY
    
    UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER] 
    SET [LAST_UPDATED] = GETDATE()
       ,[LAST_UPDATE_BY] = 'INTERFACE'
       ,[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
       ,[IS_POSTED_ERP] = -1
       ,[POSTED_ERP] = GETDATE()
       ,[POSTED_RESPONSE] = @POSTED_RESPONSE
       , [IS_AUTHORIZED] = 0
    WHERE [MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID;
    
    
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