-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que borra un registro de las empresas de transporte

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_DELETE_TRANSPORT_COMPANY @TRANSPORT_COMPANY_CODE = 2
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_DELETE_TRANSPORT_COMPANY (@TRANSPORT_COMPANY_CODE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DELETE [wms].[OP_WMS_TRANSPORT_COMPANY]
    WHERE [TRANSPORT_COMPANY_CODE] = @TRANSPORT_COMPANY_CODE;

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@TRANSPORT_COMPANY_CODE AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,CASE @@error
        WHEN 2627 THEN 'Error al insertar empresa de transporte.'
        WHEN 547 THEN 'La empresa de transporte no se puede eliminar ya esta asociada a un vehiculo'
        ELSE ERROR_MESSAGE()
      END [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END