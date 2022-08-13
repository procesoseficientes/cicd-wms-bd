-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-13 @ Team REBORN - Sprint Drache
-- Description:	        sp que actualiza la cantidad de una etiqueta

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_DELETE_PICKING_LABEL


*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_DELETE_PICKING_LABEL (@LABEL_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    DELETE [wms].[OP_WMS_PICKING_LABELS]
    WHERE [LABEL_ID] = @LABEL_ID

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@LABEL_ID AS VARCHAR) [DbData];


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END