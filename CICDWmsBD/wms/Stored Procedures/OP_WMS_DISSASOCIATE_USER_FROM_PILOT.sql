-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que borra un Piloto

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_DISSASOCIATE_USER_FROM_PILOT @PILOT_CODE = 3 ,@USER_CODE= 'OPER2'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_DISSASOCIATE_USER_FROM_PILOT (@PILOT_CODE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DELETE [wms].[OP_WMS_USER_X_PILOT]
    WHERE [PILOT_CODE] = @PILOT_CODE      

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