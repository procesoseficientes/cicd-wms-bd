

CREATE PROCEDURE [SONDA].SONDA_SP_ADD_SCOUTING_BY_XML (@XML XML
, @JSON VARCHAR(MAX) = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @TAG_FOR_CUSTOMER TABLE (
    [TAG_COLOR] VARCHAR(8) NULL
   ,[DOC_SERIE] VARCHAR(50) NOT NULL
   ,[DOC_NUM] INT NOT NULL
  );
  --
  DECLARE @CUSTOMER_NEW TABLE (
    [CODE_CUSTOMER_HH] VARCHAR(50) NOT NULL
   ,[DOC_SERIE] VARCHAR(50) NOT NULL
   ,[DOC_NUM] INT NOT NULL
   ,[CODE_ROUTE] VARCHAR(50) NOT NULL
   ,[POSTED_BY] VARCHAR(50) NOT NULL
   ,[POSTED_DATETIME] DATETIME NOT NULL
   ,[CUSTOMER_NAME] VARCHAR(250) NOT NULL
   ,[CUSTOMER_ADDRESS] VARCHAR(250) NULL
   ,[TAX_ID] VARCHAR(50) NULL
   ,[BILLING_NAME] VARCHAR(50) NULL
   ,[BILLING_ADDRESS] VARCHAR(50) NULL
   ,[CONTACT_NAME] VARCHAR(250) NULL
   ,[CONTACT_PHONE] VARCHAR(50) NULL
   ,[GPS] VARCHAR(50) NOT NULL
   ,[LATITUDE] VARCHAR(50) NOT NULL
   ,[LONGITUDE] VARCHAR(50) NOT NULL
   ,[IMAGE_1] VARCHAR(MAX) NULL
   ,[IMAGE_2] VARCHAR(MAX) NULL
   ,[IMAGE_3] VARCHAR(MAX) NULL
   ,[OWNER] VARCHAR(50) NOT NULL
   ,[IS_FROM] VARCHAR(50) NOT NULL
   ,[TAGS_QTY] INT NOT NULL
   ,[SYNC_ID] VARCHAR(250) NULL
  )
  --
  DECLARE @RESULT TABLE (
    [CLIENT_ID_HH] VARCHAR(50) NOT NULL
   ,[CLIENT_ID_BO] VARCHAR(50) NOT NULL
   ,[DOC_SERIE] VARCHAR(50) NOT NULL
   ,[DOC_NUM] INT NOT NULL
   ,[IS_SUCCESSFUL] INT NULL
   ,[MESSAGE] VARCHAR(250) NULL
   ,[_ID] VARCHAR(150) NULL
  )
  --
  DECLARE @CUSTOMER_ID VARCHAR(250) = ''
         ,@CODE_CUSTOMER_HH VARCHAR(250)
         ,@CODE_CUSTOMER_BO VARCHAR(250) = NULL
         ,@SCOUTING_PREFIX VARCHAR(250)
         ,@SCOUTING_SEQUENCE INT
         ,@LOGIN_ID VARCHAR(50)
         ,@CODE_ROUTE VARCHAR(50)
         ,@OWNER VARCHAR(50)
         ,@DOC_SERIE VARCHAR(50)
         ,@DOC_NUM INT
         ,@TAGS_QTY INT
         ,@QTY INT
         ,@SYNC_ID VARCHAR(250)
         ,@EXISTS INT = 0
         ,@POSTED_DATETIME DATETIME
         ,@IS_SUCCESSFUL INT
         ,@MESSAGE VARCHAR(250)
         ,@_ID VARCHAR(150)

  BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene los valores iniciales
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
      @OWNER = COMPANY_ID
     ,@SCOUTING_PREFIX = [SONDA].SWIFT_FN_GET_PARAMETER('SCOUTING', 'CLIENT_PREFIX')
    FROM [SONDA].[SWIFT_COMPANY]

    -- ------------------------------------------------------
    -- Obtiene el LOGIN_ID y el CODE_ROUTE
    -- ------------------------------------------------------
    SELECT
      @LOGIN_ID = x.Rec.query('./loginId').value('.', 'varchar(50)')
     ,@CODE_ROUTE = x.Rec.query('./routeid').value('.', 'varchar(50)')
    FROM @XML.nodes('Data') AS x (Rec)

    -- ------------------------------------------------------------------------------------
    -- Obtiene los _id de todos los documentos
    -- ------------------------------------------------------------------------------------
    SELECT
      [x].[Rec].query('./_id').value('.', 'varchar(150)') [_ID] INTO [#_ID]
    FROM @XML.nodes('/Data/documents') AS [x] ([Rec])


    -- ------------------------------------------------------------------------------------
    -- Obtiene los scouting
    -- ------------------------------------------------------------------------------------
    INSERT INTO @CUSTOMER_NEW ([CODE_CUSTOMER_HH]
    , [DOC_SERIE]
    , [DOC_NUM]
    , [CODE_ROUTE]
    , [POSTED_BY]
    , [POSTED_DATETIME]
    , [CUSTOMER_NAME]
    , [CUSTOMER_ADDRESS]
    , [TAX_ID]
    , [BILLING_NAME]
    , [BILLING_ADDRESS]
    , [CONTACT_NAME]
    , [CONTACT_PHONE]
    , [GPS]
    , [LATITUDE]
    , [LONGITUDE]
    , [IMAGE_1]
    , [IMAGE_2]
    , [IMAGE_3]
    , [OWNER]
    , [IS_FROM]
    , [TAGS_QTY]
    , [SYNC_ID])
      SELECT
        x.Rec.query('./clientHhIdOld').value('.', 'int')
       ,x.Rec.query('./docSerie').value('.', 'varchar(50)')
       ,x.Rec.query('./docNum').value('.', 'int')
       ,@CODE_ROUTE
       ,@LOGIN_ID
       ,x.Rec.query('./postedDatetime').value('.', 'varchar(50)')
       ,x.Rec.query('./clientName').value('.', 'varchar(50)')
       ,x.Rec.query('./address').value('.', 'varchar(max)')
       ,x.Rec.query('./clientTaxId').value('.', 'varchar(50)')
       ,x.Rec.query('./billingName').value('.', 'varchar(250)')
       ,x.Rec.query('./billingAddress').value('.', 'varchar(250)')
       ,x.Rec.query('./contactCustomer').value('.', 'varchar(250)')
       ,x.Rec.query('./contactPhone').value('.', 'varchar(250)')
       ,x.Rec.query('./gps').value('.', 'varchar(max)')
       ,x.Rec.query('./latitude').value('.', 'numeric(18,6)')
       ,x.Rec.query('./longitude').value('.', 'numeric(18,6)')
       ,CASE
          WHEN x.Rec.query('./photo1').value('.', 'varchar(max)') = 'null' THEN NULL
          ELSE x.Rec.query('./photo1').value('.', 'varchar(max)')
        END
       ,CASE
          WHEN x.Rec.query('./photo2').value('.', 'varchar(max)') = 'null' THEN NULL
          ELSE x.Rec.query('./photo2').value('.', 'varchar(max)')
        END
       ,CASE
          WHEN x.Rec.query('./photo3').value('.', 'varchar(max)') = 'null' THEN NULL
          ELSE x.Rec.query('./photo3').value('.', 'varchar(max)')
        END
       ,@OWNER
       ,'SONDA_POS'
       ,x.Rec.query('./tagsQty').value('.', 'int')
       ,x.Rec.query('./syncId').value('.', 'varchar(250)')
      FROM @XML.nodes('Data/documents/scouting') AS x (Rec)

    -- ------------------------------------------------------
    -- Obtiene las Etiquetas Del Cliente
    -- ------------------------------------------------------
    INSERT INTO @TAG_FOR_CUSTOMER ([TAG_COLOR]
    , [DOC_SERIE]
    , [DOC_NUM])
      SELECT
        x.Rec.query('./tagColor').value('.', 'varchar(8)')
       ,x.Rec.query('./docSerieClient').value('.', 'varchar(50)')
       ,x.Rec.query('./docNumClient').value('.', 'int')
      FROM @xml.nodes('/Data/documents/scouting/tags') AS x (Rec)


      


    -- ------------------------------------------------------------------------------------
    -- Se recorre cada scouting
    -- ------------------------------------------------------------------------------------
    WHILE EXISTS (SELECT TOP 1
          1
        FROM @CUSTOMER_NEW)
    BEGIN
      SELECT TOP 1
        @DOC_SERIE = [C].[DOC_SERIE]
       ,@DOC_NUM = [C].[DOC_NUM]
       ,@TAGS_QTY = [C].[TAGS_QTY]
       ,@SYNC_ID = [C].[SYNC_ID]
       ,@CODE_CUSTOMER_HH = [C].[CODE_CUSTOMER_HH]
       ,@EXISTS = 0
       ,@POSTED_DATETIME = [C].[POSTED_DATETIME]
       ,@IS_SUCCESSFUL = 0
       ,@MESSAGE = ''
       ,@QTY = 0
      FROM @CUSTOMER_NEW [C]

      -- ------------------------------------------------------------------------------------
      -- Obtiene el _id
      -- ------------------------------------------------------------------------------------
      SELECT TOP 1
        @_ID = [_ID]
      FROM [#_ID]

--      --
--      PRINT '----> @DOC_SERIE: ' + @DOC_SERIE
--      PRINT '----> @DOC_NUM: ' + CAST(@DOC_NUM AS VARCHAR)
--      PRINT '----> @TAGS_QTY: ' + CAST(@TAGS_QTY AS VARCHAR)
--      PRINT '----> @SYNC_ID: ' + ISNULL(@SYNC_ID, 'ES NULL')

      -- ------------------------------------------------------------------------------------
      -- Valida si existe
      -- ------------------------------------------------------------------------------------
      SELECT TOP 1
        @EXISTS = 1
       ,@CODE_CUSTOMER_BO = [C].[CODE_CUSTOMER]
       ,@IS_SUCCESSFUL = 1
       ,@MESSAGE = 'Ya existe el scouting'
      FROM [SONDA].[SONDA_CUSTOMER_NEW] [C]
      WHERE [C].[DOC_SERIE] = @DOC_SERIE
      AND [C].[DOC_NUM] = @DOC_NUM
      AND [C].[SYNC_ID] = @SYNC_ID
      AND [C].[IS_READY_TO_SEND] = 1
      --
--      PRINT '----> @EXISTS: ' + CAST(@EXISTS AS VARCHAR)
--      PRINT '----> @CODE_CUSTOMER_BO: ' + ISNULL(@CODE_CUSTOMER_BO, 'ES NULL')
--      PRINT '----> @IS_SUCCESSFUL: ' + ISNULL(CAST(@IS_SUCCESSFUL AS VARCHAR), 'ES NULL')
--      PRINT '----> @MESSAGE: ' + ISNULL(@MESSAGE, 'ES NULL')
      --
      IF @EXISTS = 0
      BEGIN
        PRINT '--> NO EXISTE'

        -- ------------------------------------------------------------------------------------
        -- Valida la cantidad de etiqutas
        -- ------------------------------------------------------------------------------------
        SELECT
          @QTY = COUNT(*)
        FROM @TAG_FOR_CUSTOMER [T]
        WHERE [T].[DOC_SERIE] = @DOC_SERIE
        AND [T].[DOC_NUM] = @DOC_NUM
        --
--        PRINT '----> @QTY: ' + CAST(@QTY AS VARCHAR)
        --
        IF @QTY = @TAGS_QTY
        BEGIN
        BEGIN TRY
          BEGIN TRAN
          -- ----------------------------------------------------------------------------------
          -- Obtiene la secuencia de scouting
          -- ----------------------------------------------------------------------------------      
          SELECT
            @SCOUTING_SEQUENCE = NEXT VALUE
            FOR [SONDA].SCOUTING_CLIENT_SEQUENCE

          -- ----------------------------------------------------------------------------------
          -- Se prepara el codigo de scouting
          -- ----------------------------------------------------------------------------------      
          SET @CODE_CUSTOMER_BO = @SCOUTING_PREFIX + CONVERT(VARCHAR(18), @SCOUTING_SEQUENCE)

         
          -- ----------------------------------------------------------------------------------
          -- Se inserta el nuevo cliente
          -- ----------------------------------------------------------------------------------
          INSERT INTO [SONDA].[SONDA_CUSTOMER_NEW] ([CODE_CUSTOMER]
          , [DOC_SERIE]
          , [DOC_NUM]
          , [CODE_ROUTE]
          , [POSTED_BY]
          , [POSTED_DATETIME]
          , [CUSTOMER_NAME]
          , [CUSTOMER_ADDRESS]
          , [TAX_ID]
          , [BILLING_NAME]
          , [BILLING_ADDRESS]
          , [CONTACT_NAME]
          , [CONTACT_PHONE]
          , [GPS]
          , [LATITUDE]
          , [LONGITUDE]
          , [IMAGE_1]
          , [IMAGE_2]
          , [IMAGE_3]
          , [LAST_UPDATE]
          , [LAST_UPDATE_BY]
          , [SYNC_ID]
          , [IS_READY_TO_SEND]
          , [SALES_ORDER_ID_HH]
          , [IS_SENDING]
          , [OWNER]
          , [IS_FROM]
          , [JSON])
            SELECT
              @CODE_CUSTOMER_BO
             ,[C].[DOC_SERIE]
             ,[C].[DOC_NUM]
             ,[C].[CODE_ROUTE]
             ,[C].[POSTED_BY]
             ,[C].[POSTED_DATETIME]
             ,[C].[CUSTOMER_NAME]
             ,[C].[CUSTOMER_ADDRESS]
             ,[C].[TAX_ID]
             ,[C].[BILLING_NAME]
             ,[C].[BILLING_ADDRESS]
             ,[C].[CONTACT_NAME]
             ,[C].[CONTACT_PHONE]
             ,[C].[GPS]
             ,[C].[LATITUDE]
             ,[C].[LONGITUDE]
             ,[C].[IMAGE_1]
             ,[C].[IMAGE_2]
             ,[C].[IMAGE_3]
             ,GETDATE()
             ,[C].[POSTED_BY]
             ,[C].[SYNC_ID]
             ,0 AS IS_READY_TO_SEND
             ,[C].[CODE_CUSTOMER_HH]
             ,0 AS IS_SENDING
             ,[C].[OWNER]
             ,[C].[IS_FROM]
             ,@JSON
            FROM @CUSTOMER_NEW [C]
            WHERE [C].[DOC_SERIE] = @DOC_SERIE
            AND [C].[DOC_NUM] = @DOC_NUM
          --
          SET @CUSTOMER_ID = SCOPE_IDENTITY()

          -- ----------------------------------------------------------------------------------
          -- Se insertan las etiquetas del nuevo cliente
          -- ----------------------------------------------------------------------------------
          INSERT INTO [SONDA].[SONDA_TAG_X_CUSTOMER_NEW] ([TAG_COLOR]
          , [CUSTOMER_ID])
            SELECT
              [T].TAG_COLOR
             ,@CUSTOMER_ID
            FROM @TAG_FOR_CUSTOMER [T]
            WHERE [T].[DOC_SERIE] = @DOC_SERIE
            AND [T].[DOC_NUM] = @DOC_NUM
          --
          COMMIT
          --
          SELECT
            @IS_SUCCESSFUL = 1
           ,@MESSAGE = 'Proceso exitoso'
        END TRY
        BEGIN CATCH
          ROLLBACK
          --
          SELECT
            @IS_SUCCESSFUL = 0
           ,@MESSAGE = ERROR_MESSAGE()
          --
          PRINT 'CATCH INSERT: ' + @MESSAGE
        --
        --RAISERROR (@ERRORTRAN,16,1)
        END CATCH
        END
        ELSE
        BEGIN
          SELECT
            @IS_SUCCESSFUL = 0
           ,@MESSAGE = 'No es igual la cantidad de etiquetas'
        END
      END

     
       
      -- ----------------------------------------------------------------------------------
      -- Agrega el resultado
      -- ----------------------------------------------------------------------------------
      INSERT INTO @RESULT ([CLIENT_ID_HH]
      , [CLIENT_ID_BO]
      , [DOC_SERIE]
      , [DOC_NUM]
      , [IS_SUCCESSFUL]
      , [MESSAGE]
      , [_ID] )
        VALUES (@CODE_CUSTOMER_HH, @CODE_CUSTOMER_BO, @DOC_SERIE, @DOC_NUM, @IS_SUCCESSFUL, @MESSAGE,@_ID)

      -- ------------------------------------------------------------------------------------
      -- Elimina el scouting evaluado
      -- ------------------------------------------------------------------------------------
      DELETE FROM @CUSTOMER_NEW
      WHERE [DOC_SERIE] = @DOC_SERIE
        AND [DOC_NUM] = @DOC_NUM

      DELETE FROM [#_ID]
      WHERE [_ID] = @_ID;
    END

    -- ------------------------------------------------------------------------------------
    -- Muestrea el resultado
    -- ------------------------------------------------------------------------------------
    SELECT
      [R].[CLIENT_ID_HH]
     ,[R].[CLIENT_ID_BO]
     ,[R].[DOC_SERIE]
     ,[R].[DOC_NUM]
     ,[R].[IS_SUCCESSFUL]
     ,[R].[MESSAGE]
     ,[R]._ID
    FROM @RESULT [R]

  END TRY
  BEGIN CATCH
    DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    PRINT 'CATCH: ' + @ERROR
    RAISERROR (@ERROR, 16, 1)
  END CATCH
END
