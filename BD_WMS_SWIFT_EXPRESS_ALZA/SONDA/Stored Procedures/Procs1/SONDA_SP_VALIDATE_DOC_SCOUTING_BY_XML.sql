
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATE_DOC_SCOUTING_BY_XML (@XML XML
, @JSON VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SCOUTING TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
   ,[DOC_SERIE] VARCHAR(50)
   ,[DOC_NUM] INT
   ,[SYNC_ID] VARCHAR(250)
   ,[POSTED_DATIME] DATETIME
   ,[TAG_QTY] INT
  );
  --
  DECLARE @RESULT_VALIDATION TABLE (
    [EXISTS] [INT]
   ,[ID] [INT]
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[DOC_SERIE] VARCHAR(50)
   ,[DOC_NUM] INT
   ,[_ID] VARCHAR(150)
  )
  --
  DECLARE @CODE_ROUTE VARCHAR(50)
         ,@DOC_SERIE VARCHAR(50)
         ,@DOC_NUM INT
         ,@SYNC_ID VARCHAR(250)
         ,@POSTED_DATIME DATETIME
         ,@TAG_QTY INT
         ,@SCOUTING_XML XML
         ,@CODE_CUSTOMER VARCHAR(50)
         ,@_ID VARCHAR(150);

  -- ------------------------------------------------------------------------------------
  -- Obtiene los datos generales de la ruta
  -- ------------------------------------------------------------------------------------
  SELECT
    @CODE_ROUTE = [x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)')
  FROM @xml.[nodes]('/Data') AS [x] ([Rec])


  -- ------------------------------------------------------------------------------------
  -- Obtiene los _id de todos los documentos
  -- ------------------------------------------------------------------------------------
  SELECT
    [x].[Rec].query('./_id').value('.', 'varchar(150)') [_ID] INTO [#_ID]
  FROM @XML.nodes('/Data/documents') AS [x] ([Rec]) --

  -- ------------------------------------------------------------------------------------
  -- Obtiene los scoutings a validar
  -- ------------------------------------------------------------------------------------
  INSERT INTO @SCOUTING ([CODE_CUSTOMER]
  , [DOC_SERIE]
  , [DOC_NUM]
  , [SYNC_ID]
  , [POSTED_DATIME]
  , [TAG_QTY])
    SELECT
      [x].[Rec].[query]('./clientIdBo').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(50)')
     ,CASE [x].[Rec].[query]('./docNum').[value]('.', 'varchar(50)')
        WHEN '' THEN NULL
        WHEN 'NULL' THEN NULL
        ELSE [x].[Rec].[query]('./docNum').[value]('.', 'int')
      END
     ,[x].[Rec].[query]('./syncId').[value]('.', 'varchar(250)')
     ,[x].[Rec].[query]('./postedDatetime').[value]('.', 'datetime')
     ,CASE [x].[Rec].[query]('./tagsQty').[value]('.', 'varchar(50)')
        WHEN '' THEN NULL
        WHEN 'NULL' THEN NULL
        ELSE [x].[Rec].[query]('./tagsQty').[value]('.', 'int')
      END
    FROM @xml.[nodes]('/Data/documents/scouting') AS [x] ([Rec])
  PRINT ('1')

  -- ------------------------------------------------------------------------------------
  -- Ciclo para validar scoutings
  -- ------------------------------------------------------------------------------------
  WHILE EXISTS (SELECT TOP 1
        1
      FROM @SCOUTING)
  BEGIN
    -- ------------------------------------------------------------------------------------
    -- Se toma factura a valdiar
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
      @DOC_SERIE = [DOC_SERIE]
     ,@DOC_NUM = [DOC_NUM]
     ,@SYNC_ID = [SYNC_ID]
     ,@POSTED_DATIME = [POSTED_DATIME]
     ,@TAG_QTY = [TAG_QTY]
     ,@CODE_CUSTOMER = [CODE_CUSTOMER]
    FROM @SCOUTING
    PRINT ('2')

     --
    SELECT TOP 1
      @_ID = [_ID]
    FROM [#_ID]

    -- ------------------------------------------------------------------------------------
    -- Valida si existe el scouting
    -- ------------------------------------------------------------------------------------
    SELECT
      @SCOUTING_XML = (SELECT
          [x].[Rec].[query]('./clientIdBo').[value]('.', 'varchar(50)') CodeCustomer
         ,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(50)') DocSerie
         ,CASE [x].[Rec].[query]('./docNum').[value]('.', 'varchar(50)')
            WHEN '' THEN NULL
            WHEN 'NULL' THEN NULL
            ELSE [x].[Rec].[query]('./DocNum').[value]('.', 'int')
          END DocNum
         ,[x].[Rec].[query]('./syncId').[value]('.', 'varchar(250)') SyncId
         ,[x].[Rec].[query]('./postedDatetime').[value]('.', 'datetime') PostedDatetime
         ,CASE [x].[Rec].[query]('./tagsQty').[value]('.', 'varchar(50)')
            WHEN '' THEN NULL
            WHEN 'NULL' THEN NULL
            ELSE [x].[Rec].[query]('./TagQty').[value]('.', 'int')
          END TagQty
        FROM @xml.[nodes]('/Data/documents/scouting') AS [x] ([Rec])
        WHERE [x].[Rec].[query]('./clientIdBo').[value]('.', 'VARCHAR(50)') = @CODE_CUSTOMER
        FOR XML PATH ('Scouting'), ROOT ('Data'))
    PRINT ('3')
    --
    INSERT INTO @RESULT_VALIDATION ([EXISTS],ID, CODE_CUSTOMER, DOC_SERIE, DOC_NUM)
    EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SCOUTING] @CODE_ROUTE = @CODE_ROUTE
                                                        , -- varchar(50)
                                                         @CODE_CUSTOMER = @CODE_CUSTOMER
                                                        , -- varchar(50)
                                                         @DOC_SERIE = @DOC_SERIE
                                                        , -- varchar(50)
                                                         @DOC_NUM = @DOC_NUM
                                                        , -- int
                                                         @SYNC_ID = @SYNC_ID
                                                        , -- varchar(250)
                                                         @POSTED_DATIME = @POSTED_DATIME
                                                        , -- datetime
                                                         @TAG_QTY = @TAG_QTY
                                                        , -- int
                                                         @XML = @SCOUTING_XML
                                                        , -- xml
                                                         @JSON = @JSON -- varchar(max)

   --
    UPDATE @RESULT_VALIDATION
    SET [_ID] = @_ID
    WHERE [DOC_SERIE] = @DOC_SERIE
    AND [DOC_NUM] = @DOC_NUM



    -- ------------------------------------------------------------------------------------
    -- Se elimina factura validada
    -- ------------------------------------------------------------------------------------
    DELETE FROM @SCOUTING
    WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
      OR (
      [CODE_CUSTOMER] IS NULL
      AND @CODE_CUSTOMER IS NULL
      )

     --
    DELETE FROM [#_ID]
    WHERE [_ID] = @_ID

  END
  -- ------------------------------------------------------------------------------------
  -- Muestra resultado final
  -- ------------------------------------------------------------------------------------
  SELECT
    [EXISTS]
   ,[ID]
   ,[CODE_CUSTOMER]
   ,[DOC_SERIE]
   ,[DOC_NUM]
   ,[_ID]
  FROM @RESULT_VALIDATION
END
