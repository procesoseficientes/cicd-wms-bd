-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-07-05 Nexus@SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG
-- Description:	 Inserta en la 


/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = '44'
                                                       ,@LOGIN = 'Sin Usuario'
                                                       ,@SOURCE_ERROR = '123'
                                                       ,@DOC_RESOLUTION = NULL
                                                       ,@DOC_SERIE = 123
                                                       ,@DOC_NUM = 123
                                                       ,@MESSAGE_ERROR = 123
                                                       ,@SEVERITY_CODE = 10

  SELECT * FROM  [SONDA].[SONDA_SERVER_ERROR_LOG]

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] (@CODE_ROUTE VARCHAR(50), @LOGIN VARCHAR(50), @SOURCE_ERROR VARCHAR(250), @DOC_RESOLUTION VARCHAR(100), @DOC_SERIE VARCHAR(100), @DOC_NUM INT, @MESSAGE_ERROR VARCHAR(MAX), @SEVERITY_CODE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @TYPE VARCHAR(20)

  IF @LOGIN = 'Sin Usuario'
  BEGIN
    SET @LOGIN = [SONDA].[SWIFT_FN_GET_LOGIN_BY_ROUTE](@CODE_ROUTE)
  END
  IF @SEVERITY_CODE > -1
  BEGIN
    SET @TYPE = 'ERROR'
  END
  ELSE
  BEGIN
    SET @TYPE = 'INFO'
  END

  INSERT INTO [SONDA].[SONDA_SERVER_ERROR_LOG] ([LOG_DATETIME], [CODE_ROUTE], [LOGIN], [SOURCE_ERROR], [DOC_RESOLUTION], [DOC_SERIE], [DOC_NUM], [MESSAGE_ERROR], [SEVERITY_CODE], [TYPE])
    VALUES (GETDATE(), @CODE_ROUTE, ISNULL(@LOGIN, [SONDA].[SWIFT_FN_GET_LOGIN_BY_ROUTE](@CODE_ROUTE)), @SOURCE_ERROR, @DOC_RESOLUTION, @DOC_SERIE, @DOC_NUM, @MESSAGE_ERROR, @SEVERITY_CODE, @TYPE);

END
