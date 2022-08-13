-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-10 @ Team REBORN - Sprint Drache
-- Description:	        SP que agrega una relacion entre un usuario y un piloto

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_ASSOCIATE_USER_TO_PILOT   @USER_CODE = 'OPER2', @PILOT_CODE = 1, @LAST_UPDATE_BY = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_ASSOCIATE_USER_TO_PILOT (@USER_CODE VARCHAR(25), @PILOT_CODE INT, @LAST_UPDATE_BY VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    DECLARE @ID INT

    INSERT INTO [wms].[OP_WMS_USER_X_PILOT] ([USER_CODE], [PILOT_CODE], [LAST_UPDATE_BY])
      VALUES (@USER_CODE, @PILOT_CODE, @LAST_UPDATE_BY);

    SET @ID = SCOPE_IDENTITY()

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@ID AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,CASE @@error
        WHEN 2627 THEN 'No se puede agregar 2 pilotos a 1 mismo usuario o viceversa'
        WHEN 547 THEN 'El usuario o piloto que desea ingresar no existe'
        ELSE ERROR_MESSAGE()
      END [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END