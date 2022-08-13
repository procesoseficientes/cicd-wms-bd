-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-10 @ Team REBORN - Sprint Drache
-- Description:	        SP que actualiza un piloto

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_PILOT] @PILOT_CODE = 1
                                     ,@NAME = 'Hector Andoni'
                                     ,@LAST_NAME = 'Gonzalez Morfin'
                                     ,@IDENTIFICATION_DOCUMENT_NUMBER = '23292321654'
                                     ,@LICENSE_NUMBER = '123321654'
                                     ,@LICESE_TYPE = 'A'
                                     ,@LICENSE_EXPIRATION_DATE = '2020-10-10 10:16:30.124'
                                     ,@ADDRESS = 'Coate'
                                     ,@TELEPHONE = '7753573'
                                     ,@MAIL = 'hector@piloto'
                                     ,@COMMENT = 'el mero mero' 
                                      , @LAST_UPDATE_BY = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_UPDATE_PILOT (@PILOT_CODE INT
, @NAME VARCHAR(250)
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

    UPDATE [wms].[OP_WMS_PILOT]
    SET [NAME] = @NAME
       ,[LAST_NAME] = @LAST_NAME
       ,[IDENTIFICATION_DOCUMENT_NUMBER] = @IDENTIFICATION_DOCUMENT_NUMBER
       ,[LICENSE_NUMBER] = @LICENSE_NUMBER
       ,[LICESE_TYPE] = @LICESE_TYPE
       ,[LICENSE_EXPIRATION_DATE] = @LICENSE_EXPIRATION_DATE
       ,[ADDRESS] = @ADDRESS
       ,[TELEPHONE] = @TELEPHONE
       ,[MAIL] = @MAIL
       ,[COMMENT] = @COMMENT
       ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PILOT_CODE] = @PILOT_CODE;

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@PILOT_CODE AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;


END