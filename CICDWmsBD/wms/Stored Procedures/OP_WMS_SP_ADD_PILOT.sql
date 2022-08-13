-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-10 @ Team REBORN - Sprint Drache
-- Description:	        SP que agrega un piloto

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_ADD_PILOT]   @NAME = 'Diego'
                                          ,@LAST_NAME = 'AS'
                                          ,@IDENTIFICATION_DOCUMENT_NUMBER = '23292321321651'
                                          ,@LICENSE_NUMBER = '1321312'
                                          ,@LICESE_TYPE = 'A'
                                          ,@LICENSE_EXPIRATION_DATE = '2019-10-10 09:52:29.182'
                                          ,@ADDRESS = 'Coatepeque'
                                          ,@TELEPHONE = '77573573'
                                          ,@MAIL = 'Hector@piloto'
                                          ,@COMMENT = 'el mero mero'
                                          ,@LAST_UPDATE_BY = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_ADD_PILOT (@NAME VARCHAR(250)
, @LAST_NAME VARCHAR(250)
, @IDENTIFICATION_DOCUMENT_NUMBER VARCHAR(50)
, @LICENSE_NUMBER VARCHAR(50)
, @LICESE_TYPE VARCHAR(15)
, @LICENSE_EXPIRATION_DATE DATETIME
, @ADDRESS VARCHAR(250)
, @TELEPHONE VARCHAR(25)
, @MAIL VARCHAR(100) = NULL
, @COMMENT VARCHAR(250) = NULL
, @LAST_UPDATE_BY VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    DECLARE @ID INT

    INSERT INTO [wms].[OP_WMS_PILOT] ([NAME], [LAST_NAME], [IDENTIFICATION_DOCUMENT_NUMBER], [LICENSE_NUMBER], [LICESE_TYPE], [LICENSE_EXPIRATION_DATE], [ADDRESS], [TELEPHONE], [MAIL], [COMMENT], [LAST_UPDATE_BY])
      VALUES (@NAME, @LAST_NAME, @IDENTIFICATION_DOCUMENT_NUMBER, @LICENSE_NUMBER, @LICESE_TYPE, @LICENSE_EXPIRATION_DATE, @ADDRESS, @TELEPHONE, @MAIL, @COMMENT, @LAST_UPDATE_BY);

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
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END