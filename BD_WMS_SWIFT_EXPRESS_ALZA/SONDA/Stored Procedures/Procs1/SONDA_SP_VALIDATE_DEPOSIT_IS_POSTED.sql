-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	14-03-2016
-- Description:			Valida que se encuentre sincronizado el deposito

-- Modificacion 6/16/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- se quito la validacion de la secuencia anterior y siguiente.



/*
-- Ejemplo de Ejecucion:
	USE SWIFT_EXPRESS
GO


DECLARE @RC int
DECLARE @XML xml
DECLARE @JSON varchar(max)

SET @XML = '<Data>
	<documents>
		<_id>CDF57CA0-4F8D-0A9E-B40D-4EEB3C42EEF2</_id>
		<deposit>
			<transId>1</transId>
			<transType>BANK_DEPOSIT</transType>
			<transDateTime>2017-06-06T20:36:54.317Z</transDateTime>
			<bankId>BAM</bankId>
			<accountNum>1549881-125</accountNum>
			<amount>15</amount>
			<postedBy>NL0015@SONDA</postedBy>
			<postedDatetime>2017-06-06T20:36:54.317Z</postedDatetime>
			<posTerminal>GUA0017@ARIUM</posTerminal>
			<gpsUrl></gpsUrl>
			<transRef></transRef>
			<isOffline>0</isOffline>
			<status>0</status>
			<IsPosted>1</IsPosted>
			<image1></image1>
			<docSerie>GUA0032@ARIUM</docSerie>
			<docNum>1</docNum>
			<liquidationId>0</liquidationId>
			<IsPostedAndValidated>0</IsPostedAndValidated>
			<DocumentType>2</DocumentType>
			<DocumentIdBo>182</DocumentIdBo>
		</deposit>
		<docType>0386d1c0-6511-416d-a089-ac9c0366d1c6</docType>
		<_rev>2-7cb2bf5f6fa716a9eabbefe29692c73e</_rev>
	</documents>
	<documents>
		<_id>43BC4517-2CC5-BC00-B923-2ECDAA79CE4D</_id>
		<deposit>
			<transId>2</transId>
			<transType>BANK_DEPOSIT</transType>
			<transDateTime>2017-06-06T20:36:19.178Z</transDateTime>
			<bankId>BAM</bankId>
			<accountNum>1549881-125</accountNum>
			<amount>58</amount>
			<postedBy>NL0015@SONDA</postedBy>
			<postedDatetime>2017-06-06T20:36:19.178Z</postedDatetime>
			<posTerminal>GUA0017@ARIUM</posTerminal>
			<gpsUrl></gpsUrl>
			<transRef></transRef>
			<isOffline>0</isOffline>
			<status>0</status>
			<IsPosted>1</IsPosted>
			<image1></image1>
			<docSerie>GUA0032@ARIUM</docSerie>
			<docNum>2</docNum>
			<liquidationId>0</liquidationId>
			<IsPostedAndValidated>0</IsPostedAndValidated>
			<DocumentType>2</DocumentType>
			<DocumentIdBo>183</DocumentIdBo>
		</deposit>
		<docType>0386d1c0-6511-416d-a089-ac9c0366d1c6</docType>
		<_rev>3-a19e21b3507956920eedf955218e3955</_rev>
	</documents>

</Data>'  
SET @JSON = ''

EXECUTE @RC = [SONDA].SONDA_SP_VALIDATE_DEPOSITS_WERE_POSTED @XML
                                                          ,@JSON
GO
 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATE_DEPOSIT_IS_POSTED (@DEPOSIT_ID INT
, @DEPOSIT_ID_HH INT
, @DOC_SERIE VARCHAR(50)
, @DOC_NUM INT
, @XML XML
, @JSON VARCHAR(MAX)
,@BANK_ID VARCHAR(25)
)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  --
  DECLARE @EXISTS INT = 0
         ,@DEPOSIT_POSTED_DATETIME DATETIME
         ,@POSTED_DATETIME DATETIME
         ,@INSERT INT = 0
         ,@CODE_ROUTE VARCHAR(50)         
         ,@MARK_AS_SEND INT;
  --
  SELECT TOP 1
    @EXISTS = 1
   ,@DEPOSIT_ID = [H].TRANS_ID
  FROM [SONDA].SONDA_DEPOSITS [H] /*WITH(ROWLOCK,XLOCK,HOLDLOCK)*/
  WHERE [H].DOC_SERIE = @DOC_SERIE
  AND [H].DOC_NUM = @DOC_NUM
  AND [H].IS_READY_TO_SEND = 1

  --
  IF (@EXISTS = 1)
  BEGIN
    GOTO EXISTE;
  END
  
  SELECT
    @MARK_AS_SEND = 1
   ,@EXISTS = 1
  FROM [SONDA].SONDA_DEPOSITS sd
  WHERE @DOC_SERIE = sd.DOC_SERIE
  AND @DOC_NUM = sd.DOC_NUM
  AND @BANK_ID = sd.BANK_ID;
  IF (@MARK_AS_SEND = 1)
  BEGIN
  BEGIN TRY
    BEGIN TRAN
    UPDATE [SONDA].SONDA_DEPOSITS
    SET IS_READY_TO_SEND = 1
    WHERE TRANS_ID = @DEPOSIT_ID;
    COMMIT
  END TRY
  BEGIN CATCH
    ROLLBACK
    DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    PRINT 'CATCH: ' + @ERROR
    RAISERROR (@ERROR, 16, 1)
  END CATCH
  END


  --
  IF (@EXISTS = 1)
  BEGIN

  EXISTE:

    PRINT 'Existe'
    --
    INSERT INTO [SONDA].[SONDA_DEPOSIT_LOG_EXISTS] ([LOG_DATETIME]
    , EXISTS_DEPOSIT
    , [DOC_SERIE]
    , [DOC_NUM]
    , [CODE_ROUTE]
    , BANK_ID
    , [POSTED_DATETIME]
    , [SET_NEGATIVE_SEQUENCE]
    , [XML]
    , [JSON])
      VALUES (GETDATE()  -- LOG_DATETIME - datetime
      , @EXISTS  -- EXISTS_SALES_ORDER - int
      , @DOC_SERIE  -- DOC_SERIE - varchar(100)
      , @DOC_NUM  -- DOC_NUM - int
      , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)
      , @BANK_ID  -- CODE_CUSTOMER - varchar(50)
      , GETDATE()  -- POSTED_DATETIME - datetime
      , 0  -- SET_NEGATIVE_SEQUENCE - int
      , @XML, @JSON)

  END
  ELSE
  BEGIN
    PRINT 'No Existe'
    --
    SET @EXISTS = 0
    --
    INSERT INTO [SONDA].[SONDA_DEPOSIT_LOG_EXISTS] ([LOG_DATETIME]
    , EXISTS_DEPOSIT
    , [DOC_SERIE]
    , [DOC_NUM]
    , [CODE_ROUTE]
    , BANK_ID
    , [POSTED_DATETIME]
    , [SET_NEGATIVE_SEQUENCE]
    , [XML]
    , [JSON])
      VALUES (GETDATE()  -- LOG_DATETIME - datetime
      , @EXISTS  -- EXISTS_SALES_ORDER - int
      , @DOC_SERIE  -- DOC_SERIE - varchar(100)
      , @DOC_NUM  -- DOC_NUM - int
      , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)
      , @BANK_ID  -- CODE_CUSTOMER - varchar(50)
      , GETDATE()  -- POSTED_DATETIME - datetime
      , NULL  -- SET_NEGATIVE_SEQUENCE - int
      , @XML, @JSON)
  END


  -- ------------------------------------------------------------------------------------
  -- Muestra resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    @EXISTS AS [RESULT]
   ,@DEPOSIT_ID AS SALES_ORDER_ID
   ,@DOC_SERIE DOC_SERIE
   ,@DOC_NUM DOC_NUM
END
