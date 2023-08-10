-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 		5/30/2017 TeamOmikron@Qalisar
-- Description:			SP para insertar log de validacion de depositos

/*

*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_INSERT_DEPOSIT_LOG_EXISTS (@EXISTS_DEPOSIT INT
, @DOC_SERIE VARCHAR(100)
, @DOC_NUM INT
, @CODE_ROUTE VARCHAR(50)
, @POSTED_DATETIME DATETIME
, @XML XML
, @JSON VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    INSERT INTO [SONDA].[SONDA_DEPOSIT_LOG_EXISTS] ([LOG_DATETIME]
    , [EXISTS_DEPOSIT]    
    , [DOC_SERIE]
    , [DOC_NUM]
    , [CODE_ROUTE]    
    , [POSTED_DATETIME]
    , [XML]
    , [JSON])
      VALUES (GETDATE()  -- LOG_DATETIME - datetime
      , @EXISTS_DEPOSIT  -- EXISTS_INVOICE - int      
      , @DOC_SERIE  -- DOC_SERIE - varchar(100)
      , @DOC_NUM  -- DOC_NUM - int
      , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)      
      , @POSTED_DATETIME  -- POSTED_DATETIME - datetime
      , @XML  -- XML - xml
      , @JSON  -- JSON - varchar(max)
      )
  END TRY
  BEGIN CATCH
    DECLARE @MESSAGE VARCHAR(1000) = ERROR_MESSAGE()
    PRINT 'CATCH: ' + @MESSAGE
  END CATCH
END
