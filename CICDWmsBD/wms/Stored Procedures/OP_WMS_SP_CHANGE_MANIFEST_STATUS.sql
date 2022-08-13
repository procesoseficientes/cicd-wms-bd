-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-18 @ Team REBORN - Sprint Drache
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_CHANGE_MANIFEST_STATUS @MANIFEST_HEADER_ID =1, @STATUS = 'CANCELED'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_CHANGE_MANIFEST_STATUS (@MANIFEST_HEADER_ID INT, @STATUS VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DECLARE @IS_STATUS_CREATED INT = 0;

    SELECT
      @IS_STATUS_CREATED = 1
    FROM [wms].[OP_WMS_MANIFEST_HEADER] [M]
    WHERE [M].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
    AND [M].[STATUS] = 'CREATED'

    IF @IS_STATUS_CREATED = 0
    BEGIN
      RAISERROR ('No puede cambiar el esado de un manifiesto ya procesado', 16, 1);
    END

    UPDATE [wms].[OP_WMS_MANIFEST_HEADER]
    SET [STATUS] = @STATUS
    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@MANIFEST_HEADER_ID AS VARCHAR) [DbData];


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END