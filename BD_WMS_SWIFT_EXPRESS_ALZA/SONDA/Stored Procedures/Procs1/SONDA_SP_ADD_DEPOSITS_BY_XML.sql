
-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	5/30/2017 TeamOmikron@Qalisar
-- Description:			Procesa todos los depositos de SondaIonic.

/*

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
			<bankId></bankId>
			<accountNum>1549881-125</accountNum>
			<amount>15</amount>
			<postedBy>NL0015@SONDA</postedBy>
			<postedDatetime>2017-06-06T20:36:54.317Z</postedDatetime>
			<posTerminal>GUA0017@ARIUM</posTerminal>
			<gpsUrl>0,0</gpsUrl>
			<transRef>--</transRef>
			<isOffline>0</isOffline>
			<status>0</status>
			<IsPosted>1</IsPosted>
			<image1></image1>
			<docSerie>GUA0032@ARIUM</docSerie>
			<docNum>1</docNum>
			<liquidationId>0</liquidationId>
			<IsPostedAndValidated>0</IsPostedAndValidated>
			<DocumentType>2</DocumentType>
			<DocumentIdBo>0</DocumentIdBo>
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
			<bankId></bankId>
			<accountNum>1549881-125</accountNum>
			<amount>58</amount>
			<postedBy>NL0015@SONDA</postedBy>
			<postedDatetime>2017-06-06T20:36:19.178Z</postedDatetime>
			<posTerminal>GUA0017@ARIUM</posTerminal>
			<gpsUrl>0,0</gpsUrl>
			<transRef>--</transRef>
			<isOffline>0</isOffline>
			<status>0</status>
			<IsPosted>1</IsPosted>
			<image1></image1>
			<docSerie>GUA0032@ARIUM</docSerie>
			<docNum>2</docNum>
			<liquidationId>0</liquidationId>
			<IsPostedAndValidated>0</IsPostedAndValidated>
			<DocumentType>2</DocumentType>
			<DocumentIdBo>0</DocumentIdBo>
		</deposit>
		<docType>0386d1c0-6511-416d-a089-ac9c0366d1c6</docType>
		<_rev>3-a19e21b3507956920eedf955218e3955</_rev>
	</documents>
  <dbuser>USONDA</dbuser>
	<dbuserpass>SONDAServer1237710</dbuserpass>
	<routeid>GUA0017@ARIUM</routeid>
	<uuid>wof72t</uuid>
	<warehouse>V005</warehouse>
</Data>' 
SET @JSON = '' 

EXECUTE @RC = [SONDA].SONDA_SP_ADD_DEPOSITS_BY_XML @XML
                                                ,@JSON
GO

					
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_ADD_DEPOSITS_BY_XML (@XML XML
, @JSON VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @WAREHOUSE VARCHAR(50)
         ,@DEVICE_ID VARCHAR(50)
         ,@LOGIN VARCHAR(50)
         ,@_ID VARCHAR(150)
         ,@DOCUMENT_ID INT
         ,@HEADER_POSTEDDATIME DATETIME
         ,@DOC_SERIE VARCHAR(100)
         ,@DOC_NUM INT
         ,@CODE_ROUTE VARCHAR(50)
         ,@EXISTS INT = 0
         ,@DOC_TYPE INT
         ,@INSERT_ERROR VARCHAR(1000)
         ,@ID_BO INT
         ,@IMAGE VARCHAR(MAX)
         ,@ID INT

  DECLARE @RESULT_VALIDATION TABLE (
    [EXISTS] [INT]
   ,[ID] [INT]
   ,[DOC_SERIE] VARCHAR(100)
   ,[DOC_NUM] INT
  )


  DECLARE @RESULTS TABLE (
    [DOC_ID] INT
   ,[BO_ID] INT
   ,[DOC_SERIE] VARCHAR(100)
   ,[DOC_NUM] INT
   ,[DOC_TYPE] INT
   ,[SUCCESS] INT
   ,[ERROR] VARCHAR(100)
   ,[_ID] VARCHAR(150)
  );


  BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Guarda todos los depósitos a una tabla temporal [#DEPOSITS]
    -- ------------------------------------------------------------------------------------
    SELECT
      [x].[Rec].[query]('./transId').[value]('.', 'int') [TRANS_ID]
     ,[x].[Rec].[query]('./transType').[value]('.', 'varchar(20)') [TRANS_TYPE]
     ,[x].[Rec].[query]('./transDateTime').[value]('.', 'datetime') [TRANS_DATE_TIME]
     ,[x].[Rec].[query]('./bankId').[value]('.', 'varchar(25)') [BANK_ID]
     ,[x].[Rec].[query]('./accountNum').[value]('.', 'varchar(50)') [ACCOUNT_NUM]
     ,[x].[Rec].[query]('./amount').[value]('.', 'money') [AMOUNT]
     ,[x].[Rec].[query]('./postedBy').[value]('.', 'varchar(25)') [POSTED_BY]
     ,[x].[Rec].[query]('./postedDatetime').[value]('.', 'datetime') [POSTED_DATETIME]
     ,[x].[Rec].[query]('./posTerminal').[value]('.', 'varchar(50)') [POS_TERMINAL]
     ,[x].[Rec].[query]('./gpsUrl').[value]('.', 'varchar(150)') [GPS_URL]
     ,[x].[Rec].[query]('./transRef').[value]('.', 'varchar(50)') [TRANS_REF]
     ,[x].[Rec].[query]('./isOffline').[value]('.', 'int') [IS_OFFLINE]
     ,[x].[Rec].[query]('./status').[value]('.', 'int') [STATUS]
     ,[x].[Rec].[query]('./IsPosted').[value]('.', 'int') [IS_POSTED]
     ,[x].[Rec].[query]('./image1').[value]('.', 'varchar(max)') [IMAGE1]
     ,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(100)') DOC_SERIE
     ,[x].[Rec].[query]('./docNum').[value]('.', 'int') DOC_NUM
     ,[x].[Rec].[query]('./liquidationId').[value]('.', 'int') [LIQUIDATION_ID]
     ,[x].[Rec].[query]('./IsPostedAndValidated').[value]('.', 'int') [IS_POSTED_AND_VALIDATED]
     ,[x].[Rec].[query]('./DocumentType').[value]('.', 'int') [DOCUMENT_TYPE]
     ,[x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') [DOCUMENT_ID_BO] INTO [#DEPOSITS]
    FROM @XML.[nodes]('/Data/documents/deposit') AS [x] ([Rec]);




    -- ------------------------------------------------------------------------------------
    -- Obtiene los datos generales de la ruta
    -- ------------------------------------------------------------------------------------
    SELECT
      @WAREHOUSE = [x].[Rec].[query]('./warehouse').[value]('.', 'varchar(50)')
     ,@DEVICE_ID = [x].[Rec].[query]('./uuid').[value]('.', 'varchar(50)')
     ,@LOGIN = [SONDA].[SWIFT_FN_GET_LOGIN_BY_ROUTE]([x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)'))
    FROM @XML.[nodes]('/Data') AS [x] ([Rec]);


    -- ------------------------------------------------------------------------------------
    -- Obtiene los _id de todos los documentos
    -- ------------------------------------------------------------------------------------
    SELECT
      [x].[Rec].query('./_id').value('.', 'varchar(150)') [_ID] INTO [#_ID]
    FROM @XML.nodes('/Data/documents') AS [x] ([Rec])



    -- ------------------------------------------------------------------------------------
    -- Procesa los documentos
    -- ------------------------------------------------------------------------------------
    WHILE EXISTS (SELECT TOP 1
          1
        FROM [#DEPOSITS])
    BEGIN
      SELECT TOP 1
        @DOCUMENT_ID = d.TRANS_ID
       ,@HEADER_POSTEDDATIME = d.POSTED_DATETIME
       ,@CODE_ROUTE = d.POS_TERMINAL
       ,@IMAGE = d.IMAGE1
       ,@DOC_SERIE = d.DOC_SERIE
       ,@DOC_NUM = d.DOC_NUM
       ,@DOC_TYPE = d.DOCUMENT_TYPE
       ,@ID_BO = d.DOCUMENT_ID_BO
      FROM [#DEPOSITS] d

      -- ------------------------------------------------------------------------------------
      -- Obtiene el _id
      -- ------------------------------------------------------------------------------------
      SELECT TOP 1
        @_ID = [_ID]
      FROM [#_ID]


      -- ------------------------------------------------------------------------------------
      -- Valida si existe la orden de venta
      -- ------------------------------------------------------------------------------------
      INSERT INTO @RESULT_VALIDATION
      EXEC [SONDA].[SONDA_SP_VALIDATE_IF_EXISTS_DEPOSIT] @CODE_ROUTE = @CODE_ROUTE
                                                        ,@DOC_SERIE = @DOC_SERIE
                                                        ,@DOC_NUM = @DOC_NUM
                                                        ,@POSTED_DATETIME = @HEADER_POSTEDDATIME
                                                        ,@ID_BO = @ID_BO
                                                        ,@XML = @XML
                                                        ,@JSON = @JSON

      --
      SELECT
        @EXISTS = [R].[EXISTS]
       ,@ID = [R].[ID]
      FROM @RESULT_VALIDATION [R]

      
      --
    
      IF (@EXISTS = 1)
      BEGIN
        PRINT '--> Exist';
        INSERT INTO @RESULTS ([DOC_ID]
        , [BO_ID]
        , [DOC_SERIE]
        , [DOC_NUM]
        , [DOC_TYPE]
        , [SUCCESS]
        , [ERROR]
        , [_ID])
          VALUES (@DOCUMENT_ID  -- DOC_ID - int
          , @ID  -- BO_ID - varchar(100)
          , @DOC_SERIE  -- DOC_SERIE - varchar(100)
          , @DOC_NUM  -- DOC_NUM - int
          , @DOC_TYPE -- DOC_TYPE - int
          , 0, 'Ya existe el deposito con el ID :' + CAST(@ID AS VARCHAR), @_ID)

      END
      ELSE
      BEGIN
      BEGIN TRY
        BEGIN TRAN



        INSERT INTO [SONDA].SONDA_DEPOSITS (TRANS_TYPE, TRANS_DATETIME, BANK_ID, ACCOUNT_NUM, AMOUNT, POSTED_BY, POSTED_DATETIME, POS_TERMINAL, GPS_URL, TRANS_REF, IS_OFFLINE, STATUS, DOC_SERIE, DOC_NUM, LIQUIDATION_ID, IMAGE_1, IS_READY_TO_SEND)
          SELECT
            d.TRANS_TYPE
           ,d.TRANS_DATE_TIME
           ,d.BANK_ID
           ,d.ACCOUNT_NUM
           ,d.AMOUNT
           ,d.POSTED_BY
           ,d.POSTED_DATETIME
           ,d.POS_TERMINAL
           ,d.GPS_URL
           ,d.TRANS_REF
           ,d.IS_OFFLINE
           ,d.STATUS
           ,d.DOC_SERIE
           ,d.DOC_NUM
           ,d.LIQUIDATION_ID
           ,d.IMAGE1
           ,0
          FROM [#DEPOSITS] d
          WHERE d.TRANS_ID = @DOCUMENT_ID;

        --
        SET @ID = SCOPE_IDENTITY()
        

        COMMIT

        INSERT INTO @RESULTS ([DOC_ID]
        , [BO_ID]
        , [DOC_SERIE]
        , [DOC_NUM]
        , [DOC_TYPE]
        , [SUCCESS]
        , [ERROR]
        , [_ID])
          VALUES (@DOCUMENT_ID  -- DOC_ID - int
          , @ID  -- BO_ID - int
          , @DOC_SERIE  -- DOC_SERIE - varchar(100)
          , @DOC_NUM  -- DOC_NUM - int
          , @DOC_TYPE  -- DOC_TYPE - int
          , 1  -- SUCCESS - int
          , NULL  -- ERROR - varchar(100)
          , @_ID)


      END TRY
      BEGIN CATCH
        ROLLBACK
        --
        SET @INSERT_ERROR = ERROR_MESSAGE()
        --
        PRINT 'CATCH de insert: ' + @INSERT_ERROR + ' para deposito: ' + CAST(@DOCUMENT_ID AS VARCHAR(10))
        --
        INSERT INTO @RESULTS ([DOC_ID]
        , [BO_ID]
        , [DOC_SERIE]
        , [DOC_NUM]
        , [DOC_TYPE]
        , [SUCCESS]
        , [ERROR]
        , [_ID])
          VALUES (@DOCUMENT_ID  -- DOC_ID - int
          , NULL  -- BO_ID - int
          , @DOC_SERIE  -- DOC_SERIE - varchar(100)
          , @DOC_NUM  -- DOC_NUM - int
          , @DOC_TYPE  -- DOC_TYPE - int
          , 0  -- SUCCESS - int
          , @INSERT_ERROR  -- ERROR - varchar(100)
          , @_ID)
      END CATCH
      END

      DELETE FROM [#DEPOSITS]
      WHERE [TRANS_ID] = @DOCUMENT_ID;

      DELETE FROM [#_ID]
      WHERE [_ID] = @_ID;
     
      DELETE FROM @RESULT_VALIDATION;
    
    END

   SELECT
     [DOC_ID]
    ,[BO_ID]
    ,[DOC_SERIE]
    ,[DOC_NUM]
    ,[DOC_TYPE]
    ,[SUCCESS]
    ,[ERROR]
    ,[_ID]
   FROM @RESULTS
  END TRY
  BEGIN CATCH
    DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    PRINT 'CATCH: ' + @ERROR
    RAISERROR (@ERROR, 16, 1)
  END CATCH
END
