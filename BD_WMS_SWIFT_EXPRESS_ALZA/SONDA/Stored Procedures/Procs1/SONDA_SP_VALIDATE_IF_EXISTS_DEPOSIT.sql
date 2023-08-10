-- =============================================
-- Autor:				joel.delcompare 
-- Fecha de Creacion: 		5/30/2017 TeamOmikron@Qalisar
-- Description:			Valida si  existe el depósito

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_IF_EXISTS_DEPOSIT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATE_IF_EXISTS_DEPOSIT (@CODE_ROUTE VARCHAR(50)
, @DOC_SERIE VARCHAR(100)
, @DOC_NUM INT
, @POSTED_DATETIME DATETIME
, @ID_BO INT = NULL
, @XML XML
, @JSON VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  --
  DECLARE @EXISTS INT = 0
         ,@ID INT
         ,@INSERT INT = 0
         ,@DETAIL_QTY_IN_DB INT = 0
  --

  SELECT TOP 1
    @EXISTS = 1
   ,@ID = sd.TRANS_ID
  FROM [SONDA].SONDA_DEPOSITS sd WITH (ROWLOCK, XLOCK, HOLDLOCK)
  WHERE sd.POS_TERMINAL = @CODE_ROUTE
  AND sd.DOC_SERIE = @DOC_SERIE
  AND sd.DOC_NUM = @DOC_NUM
  AND sd.IS_READY_TO_SEND = 1
  GROUP BY sd.TRANS_ID;

    -- ------------------------------------------------------------------------------------
  -- Inserta el log
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SONDA_SP_INSERT_DEPOSIT_LOG_EXISTS] @EXISTS_DEPOSIT = @EXISTS
                                                   , -- int                                                   
                                                    @DOC_SERIE = @DOC_SERIE
                                                   , -- varchar(100)
                                                    @DOC_NUM = @DOC_NUM
                                                   , -- int
                                                    @CODE_ROUTE = @CODE_ROUTE
                                                   , -- varchar(50)                                                   
                                                    @POSTED_DATETIME = @POSTED_DATETIME
                                                   , -- datetime
                                                    @XML = @XML
                                                   , -- xml
                                                    @JSON = @JSON -- varchar(max)

  -- ------------------------------------------------------------------------------------
  -- Muestra resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    @EXISTS AS [EXISTS]
   ,@ID AS [ID]  
   ,@DOC_SERIE [DOC_SERIE]
   ,@DOC_NUM [DOC_NUM]
END
