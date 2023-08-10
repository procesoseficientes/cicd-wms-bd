-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	06/07/2017    TeamOmikron@Qalisar
-- Description:			Valida si los depositos ya estan posteados

/*

*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATE_DEPOSITS_WERE_POSTED (@XML XML
, @JSON VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @DOCUMENT TABLE (
    [ID] INT
   ,[DOC_SERIE] VARCHAR(100)
   ,[DOC_NUM] INT
   ,[POSTED_DATIME] DATETIME   
   ,[DOC_TYPE] INT
   ,[DOC_ID] INT
   ,[BANK_ID] NVARCHAR(25)
  );
  
  --
  DECLARE @RESULT_VALIDATION TABLE (
    [EXISTS] INT
   ,[ID] INT
   ,[DOC_SERIE] VARCHAR(100)
   ,[DOC_NUM] INT
   ,[DOC_ID] INT
   ,[_ID] VARCHAR(150)
  )
  --
  DECLARE @CODE_ROUTE VARCHAR(50)
         ,@ID INT
         ,@POSTED_DATIME DATETIME
         ,@DETAIL_QTY INT
         ,@DOC_RESOLUTION VARCHAR(100)
         ,@DOC_SERIE VARCHAR(100)
         ,@DOC_NUM INT
         ,@BANK_ID VARCHAR(25)
         ,@DOCUMENT_XML XML
         ,@DOC_TYPE INT
         ,@DOC_ID INT
         ,@_ID VARCHAR(150);

  -- ------------------------------------------------------------------------------------
  -- Obtiene los datos generales de la ruta
  -- ------------------------------------------------------------------------------------
  SELECT
    @CODE_ROUTE = [x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)')
  FROM @xml.[nodes]('/Data') AS [x] ([Rec])


  -- ------------------------------------------------------------------------------------
  -- Obtiene los documentos a validar
  -- ------------------------------------------------------------------------------------
  INSERT INTO @DOCUMENT ([ID]  
  , [DOC_SERIE]
  , [DOC_NUM] 
  , [POSTED_DATIME] 
  , [DOC_TYPE]
  , [DOC_ID]
  , [BANK_ID])
    SELECT
      [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int')      
     ,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(50)')
     , [x].[Rec].[query]('./docNum').[value]('.', 'int')     
     ,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime')    
     , [x].[Rec].[query]('./DocumentType').[value]('.', 'int')
     , [x].[Rec].[query]('./transId').[value]('.', 'int')      
     ,[x].[Rec].[query]('./bankId').[value]('.', 'varchar(25)')    
    FROM @XML.[nodes]('/Data/documents/deposit') AS [x] ([Rec])
  -- ------------------------------------------------------------------------------------
  -- Obtiene los _id de todos los documentos
  -- ------------------------------------------------------------------------------------
  SELECT
    [x].[Rec].query('./_id').value('.', 'varchar(150)') [_ID] INTO [#_ID]
  FROM @XML.nodes('/Data/documents') AS [x] ([Rec]) --



  -- ------------------------------------------------------------------------------------
  -- Ciclo para validar documentos
  -- ------------------------------------------------------------------------------------
  WHILE EXISTS (SELECT TOP 1
        1
      FROM @DOCUMENT)
  BEGIN
    -- ------------------------------------------------------------------------------------
    -- Se toma documento a valdiar
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
      @ID = [ID]
     ,@DOC_SERIE = [DOC_SERIE]
     ,@DOC_NUM = [DOC_NUM]
     ,@POSTED_DATIME = [POSTED_DATIME]
     ,@DOC_TYPE = [DOC_TYPE]
     ,@DOC_ID = [DOC_ID]
     ,@BANK_ID = BANK_ID
    FROM @DOCUMENT
    --
    SELECT TOP 1
      @_ID = [_ID]
    FROM [#_ID]



    -- ------------------------------------------------------------------------------------
    -- Valida si existe orden de venta
    -- ------------------------------------------------------------------------------------
    SELECT
      @DOCUMENT_XML = (SELECT
          [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') IdBo
         ,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(50)') DocSerie
         ,[x].[Rec].[query]('./docNum').[value]('.', 'int') DocNum
         ,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime') PostedDatetime
         ,[x].[Rec].[query]('./bankId').[value]('.', 'varchar(25)') BankId
        FROM @XML.[nodes]('/Data/documents/deposit') AS [x] ([Rec])
        WHERE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') = @ID
        FOR XML PATH ('Deposits'), ROOT ('Data'))


    

    INSERT INTO @RESULT_VALIDATION ([EXISTS], [ID], [DOC_SERIE], [DOC_NUM])
    EXEC [SONDA].[SONDA_SP_VALIDATE_DEPOSIT_IS_POSTED] @DEPOSIT_ID = @ID
                                                      ,@DEPOSIT_ID_HH = @DOC_ID
                                                      ,@DOC_SERIE = @DOC_SERIE
                                                      ,@DOC_NUM = @DOC_NUM
                                                      ,@XML = @DOCUMENT_XML
                                                      ,@JSON = @JSON
                                                      ,@BANK_ID= @BANK_ID

    --
    UPDATE @RESULT_VALIDATION
    SET [DOC_ID] = @DOC_ID
       ,[_ID] = @_ID
    WHERE [DOC_SERIE] = @DOC_SERIE
    AND [DOC_NUM] = @DOC_NUM

    --
    DELETE FROM @DOCUMENT
    WHERE [ID] = @ID
      OR (
      ID IS NULL
      AND @ID IS NULL
      )
    --
    DELETE FROM [#_ID]
    WHERE [_ID] = @_ID
  END
  -- ------------------------------------------------------------------------------------
  -- Envia resultado de validaciones
  -- ------------------------------------------------------------------------------------
  SELECT
    [EXISTS] [RESULT]
   ,[ID] [ID]  
   ,[DOC_SERIE] [DOC_SERIE]
   ,[DOC_NUM] [DOC_NUM]
   ,[DOC_ID] [DOC_ID]
   ,[_ID] [_ID]
  FROM @RESULT_VALIDATION
 
END
