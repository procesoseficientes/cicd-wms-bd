-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que marca el manifiesto como certificado

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_MARK_MANIFEST_AS_CERTIFIED @CERTIFICATION_HEADER_ID = 1                                                
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_MARK_MANIFEST_AS_CERTIFIED (@MANIFEST_HEADER_ID INT, @CERTIFICATION_HEADER_ID INT, @LAST_UPDATE_BY VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    UPDATE [wms].[OP_WMS_MANIFEST_HEADER] 
    SET
        [STATUS] = 'CERTIFIED'
       ,[LAST_UPDATE] = GETDATE()
       ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY       
    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;


    UPDATE [wms].[OP_WMS_CERTIFICATION_HEADER]
      SET
        [STATUS] = 'COMPLETED'
        ,[LAST_UPDATE] = GETDATE()
       ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY 
    WHERE [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,'0' [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END