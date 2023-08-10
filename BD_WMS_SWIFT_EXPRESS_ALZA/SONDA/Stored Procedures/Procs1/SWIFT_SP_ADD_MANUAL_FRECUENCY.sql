-- =============================================
-- Description:			Inserta registros manuales desde un excel y verifica si inserta los registros no existentes en las tablas SWIFT_FREQUENCY y SWIFT_FREQUENCY_X_CUSTOMER
--						o si inserta los registros no existentes y actualiza los registros existentes. 
-- Modificacion:		Christian Hernandez 
-- Fecha de modificacion:7/19/2018 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_MANUAL_FRECUENCY] 
					@TRADE_AGREEMENT_ID = 1
*/
-- =============================================
CREATE PROCEDURE SONDA.SWIFT_SP_ADD_MANUAL_FRECUENCY (@XML XML
, @UPDATE_AND_INSERT INT
, @REFERENCE_SOURCE VARCHAR(20)
, @LOGIN_ID AS VARCHAR(50)) WITH RECOMPILE
AS
BEGIN TRY

  -- -------------------------------------------------------------------------------
  -- Tabla para mostrar el resultado de procesos
  -- -------------------------------------------------------------------------------
  DECLARE @TABLE_RESULT TABLE (
    [Resultado] INT
   ,[Mensaje] VARCHAR(250)
  );
  -- -------------------------------------------------------------------------------
  -- Tabla que almacena la informacion proporcionada por el documento de EXCEL
  -- -------------------------------------------------------------------------------
  DECLARE @TABLE_FRECUENCY TABLE (
    [CODE_FREQUENCY] VARCHAR(50)
   ,[SELLER_CODE] VARCHAR(50)
   ,[SELLER_NAME] VARCHAR(50)
   ,[CUSTOMER_CODE] VARCHAR(50)
   ,[TYPE_TASK] VARCHAR(50)
   ,[MONDAY] INT
   ,[TUESDAY] INT
   ,[WEDNESDAY] INT
   ,[THURSDAY] INT
   ,[FRIDAY] INT
   ,[SATURDAY] INT
   ,[SUNDAY] INT
   ,[FREQUENCY_WEEKS] INT
   ,[LAST_WEEK] DATE
   ,[LAST_UPDATE] DATETIME
   ,[LAST_UPDATE_BY] VARCHAR(50)
   ,[PRIORITY] INT
   ,[IS_BY_POLIGON] INT
   ,[CODE_ROUTE] VARCHAR(50)
  );

  -- -------------------------------------------------------------------------------
  -- Tabla para almacenar las diferentes frecuencias que se insertaran
  -- -------------------------------------------------------------------------------

  DECLARE @FREQUENCY_TO_INSERT TABLE (
    [ID] INT IDENTITY (1, 1)
   ,[CODE_FREQUENCY] VARCHAR(MAX)
  );
  -- -------------------------------------------------------------------------------
  -- Tabla que almacena los vendedores a procesar
  -- -------------------------------------------------------------------------------
  DECLARE @TABLE_SELLER TABLE (
    [SELLER_CODE] VARCHAR(50)
   ,[SELLER_NAME] VARCHAR(50)
  );

  -- -------------------------------------------------------------------------------
  -- Tabla que almacena la frecuencia por cliente a ser procesada
  -- -------------------------------------------------------------------------------
  DECLARE @TABLE_FRECUENCY_X_CUSTOMER TABLE (
    [ID_FRECUENCY] INT
   ,[CUSTOMER_CODE] VARCHAR(50)
   ,[PRIORITY] INT
   ,[LAST_WEEK_VISITED] DATE
  );

  -- -----------------------------------------------------------------------------------------------------------------
  -- Tabla que almacena las combinaciones de datos no existentes, las cuales deben insertarse
  -- sera utilizada cuando @UPDATE_AND_INSERT es distinto de 1
  -- -----------------------------------------------------------------------------------------------------------------
  DECLARE @UNEXISTING_COMBINATION TABLE (
    [ID] INT IDENTITY (1, 1)
   ,[CODE_FREQUENCY] VARCHAR(MAX)
  );


  -- -----------------------------------------------------------------------------------------------------------------
  -- Tabla que almacena las combinaciones de datos existentes, las cuales deben solamente actualizarse
  -- sera utilizada cuando @UPDATE_AND_INSERT es distinto de 1
  -- -----------------------------------------------------------------------------------------------------------------
  DECLARE @EXISTING_COMBINATION TABLE (
    [ID] INT IDENTITY (1, 1)
   ,[ID_FREQUENCY] INT
   ,[CODE_FREQUENCY] VARCHAR(MAX)
  );

  PRINT ('OBTIENE VALORES DESDE XML ' + CAST(GETDATE() AS VARCHAR));
  -- -------------------------------------------------------------------------------
  -- Obtenemos los datos que se enviaron desde el BO
  -- -------------------------------------------------------------------------------
  INSERT INTO @TABLE_FRECUENCY ([CODE_FREQUENCY]
  , [SELLER_CODE]
  , [SELLER_NAME]
  , [CUSTOMER_CODE]
  , [TYPE_TASK]
  , [MONDAY]
  , [TUESDAY]
  , [WEDNESDAY]
  , [THURSDAY]
  , [FRIDAY]
  , [SATURDAY]
  , [SUNDAY]
  , [FREQUENCY_WEEKS]
  , [LAST_WEEK]
  , [LAST_UPDATE]
  , [LAST_UPDATE_BY]
  , [PRIORITY]
  , [IS_BY_POLIGON])
    SELECT
      [x].[Rec].[query]('./CODE_FREQUENCY').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./SELLER_CODE').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./SELLER_NAME').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./CODE_CUSTOMER').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./TYPE_TASK').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./MONDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./TUESDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./WEDNESDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./THURSDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./FRIDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./SATURDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./SUNDAY').[value]('.', 'int')
     ,[x].[Rec].[query]('./FREQUENCY_WEEKS').[value]('.', 'int')
     ,[x].[Rec].[query]('./LAST_WEEK_VISITED').[value]('.', 'date')
     ,[x].[Rec].[query]('./LAST_UPDATED').[value]('.', 'datetime')
     ,[x].[Rec].[query]('./LAST_UPDATED_BY').[value]('.', 'varchar(50)')
     ,[x].[Rec].[query]('./PRIORITY').[value]('.', 'int')
     ,[x].[Rec].[query]('./IS_BY_POLIGON').[value]('.', 'int')
    FROM @XML.[nodes]('ArrayOfFrecuencia/Frecuencia') AS [x] ([Rec]);


  PRINT ('OBTIENE VENDEDORES ' + CAST(GETDATE() AS VARCHAR));
  -- ----------------------------------------------------------------------------
  -- Se obtienen los vendedores de los cuales se actualizaran o insertaran rutas
  -- ----------------------------------------------------------------------------
  INSERT INTO @TABLE_SELLER ([SELLER_CODE]
  , [SELLER_NAME])
    SELECT DISTINCT
      [F].[SELLER_CODE]
     ,[S].[SELLER_NAME]
    FROM @TABLE_FRECUENCY [F]
    LEFT JOIN [SONDA].[SWIFT_SELLER] [S]
      ON ([F].[SELLER_CODE] = [S].[SELLER_CODE]);


  PRINT ('ACTUALIZA O INSERTAMOS LAS RUTAS ' + CAST(GETDATE() AS VARCHAR));
  -- ------------------------------------------------------
  -- Se actualiza o se inserta las ruta.
  -- ------------------------------------------------------
  MERGE [SONDA].[SWIFT_ROUTES] AS [R]
  USING @TABLE_SELLER [F]
  ON ([R].[CODE_ROUTE] = [F].[SELLER_CODE])
  WHEN MATCHED
    THEN UPDATE
      SET [NAME_ROUTE] = [F].[SELLER_NAME]
         ,[SELLER_CODE] = [F].[SELLER_CODE]
         ,[LAST_UPDATE] = GETDATE()
         ,[LAST_UPDATE_BY] = @LOGIN_ID
  WHEN NOT MATCHED BY TARGET
    THEN INSERT ([CODE_ROUTE], [NAME_ROUTE], [SELLER_CODE], [LAST_UPDATE], [LAST_UPDATE_BY])
        VALUES ([F].[SELLER_CODE], [F].[SELLER_NAME], [F].[SELLER_CODE], GETDATE(), @LOGIN_ID);


  PRINT ('ACTUALIZA PERMISOS PARA LAS RUTAS ' + CAST(GETDATE() AS VARCHAR));
  -- ------------------------------------------------------
  -- Se actualiza o se inserta los permisos para la ruta.
  -- ------------------------------------------------------
  MERGE [SONDA].[SWIFT_ROUTE_BY_USER] AS [RU]
  USING @TABLE_SELLER [F]
  ON ([RU].[CODE_ROUTE] = [F].[SELLER_CODE])
  WHEN MATCHED
    THEN UPDATE
      SET [RU].[LOGIN] = @LOGIN_ID
  WHEN NOT MATCHED BY TARGET
    THEN INSERT ([LOGIN], [CODE_ROUTE])
        VALUES (@LOGIN_ID, [F].[SELLER_CODE]);



  PRINT ('GENERA LAS FRECUENCIAS ' + CAST(GETDATE() AS VARCHAR));
  -- -----------------------------------
  -- Generamos el codigo de frecuencia.
  -- -----------------------------------
  UPDATE [TF]
  SET [TF].[CODE_FREQUENCY] = [TYPE_TASK]
      + [TF].[SELLER_CODE]
      + CAST([SUNDAY] AS VARCHAR(1)) + CAST([MONDAY] AS VARCHAR(1))
      + CAST([TUESDAY] AS VARCHAR(1)) + CAST([WEDNESDAY] AS VARCHAR(1))
      + CAST([THURSDAY] AS VARCHAR(1)) + CAST([FRIDAY] AS VARCHAR(1))
      + CAST([SATURDAY] AS VARCHAR(1))
      + CAST([FREQUENCY_WEEKS] AS VARCHAR(1))
     ,[TF].[CODE_ROUTE] = [TF].[SELLER_CODE]
  FROM @TABLE_FRECUENCY AS [TF]


  PRINT ('OBTIENE FRECUENCIAS A PROCESAR ' + CAST(GETDATE() AS VARCHAR));
  -- ----------------------------------------------------------------------
  -- Obtenemos los codigos de las frecuencias que deseamos procesar
  -- ----------------------------------------------------------------------
  INSERT @FREQUENCY_TO_INSERT ([CODE_FREQUENCY])
    SELECT DISTINCT
      [F].[CODE_FREQUENCY]
    FROM @TABLE_FRECUENCY AS [F]
    WHERE [F].[CODE_FREQUENCY] <> '';


  IF @UPDATE_AND_INSERT = 1
  BEGIN
    PRINT ('poligon data has been cleaned');
    -- -----------------------------------------------------------------------------------------------------------------------------
    -- Quitamos la asociacion de poligonos a las frecuencias que coincidan con la informacion enviada en el documento de EXCEL
    -- -----------------------------------------------------------------------------------------------------------------------------
    UPDATE [PBR]
    SET [PBR].[ID_FREQUENCY] = NULL
    FROM [SONDA].[SWIFT_POLYGON_BY_ROUTE] AS [PBR]
    INNER JOIN [SONDA].[SWIFT_FREQUENCY] AS [F]
      ON [F].[ID_FREQUENCY] = [PBR].[ID_FREQUENCY]
    INNER JOIN @FREQUENCY_TO_INSERT AS [FI]
      ON [FI].[CODE_FREQUENCY] = [F].[CODE_FREQUENCY]
    WHERE [FI].[ID] > 0;

    PRINT ('frequency by customer data has been cleaned');
    -- -----------------------------------------------------------------------------------------------------------------------------
    -- Quitamos la asociacion de clientes a las frecuencias que coincidan con la informacion enviada en el documento de EXCEL
    -- -----------------------------------------------------------------------------------------------------------------------------
    DELETE [FC]
      FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] AS [FC]
      INNER JOIN [SONDA].[SWIFT_FREQUENCY] AS [F]
        ON [F].[ID_FREQUENCY] = [FC].[ID_FREQUENCY]
      INNER JOIN @TABLE_SELLER [TS]
        ON (
        [F].[CODE_ROUTE] = [TS].[SELLER_CODE]
        )
    WHERE [F].[ID_FREQUENCY] > 0;

    PRINT ('frequency data has been cleaned');
    -- -----------------------------------------------------------------------------------------------------------------------------
    -- Quitamos la asociacion de frecuencias que coincidan con la informacion enviada en el documento de EXCEL
    -- -----------------------------------------------------------------------------------------------------------------------------
    DELETE [F]
      FROM [SONDA].[SWIFT_FREQUENCY] AS [F]
      INNER JOIN @FREQUENCY_TO_INSERT [FI]
        ON ([FI].[CODE_FREQUENCY] = [F].[CODE_FREQUENCY])
    WHERE [FI].[ID] > 0;

    PRINT ('data of frequencies has been cleaned');
    -- -----------------------------------------------
    -- Insertamos las nuevas frequencias generadas
    -- -----------------------------------------------
    INSERT INTO [SONDA].[SWIFT_FREQUENCY] ([CODE_FREQUENCY]
    , [SUNDAY]
    , [MONDAY]
    , [TUESDAY]
    , [WEDNESDAY]
    , [THURSDAY]
    , [FRIDAY]
    , [SATURDAY]
    , [FREQUENCY_WEEKS]
    , [LAST_WEEK_VISITED]
    , [LAST_UPDATED]
    , [LAST_UPDATED_BY]
    , [CODE_ROUTE]
    , [TYPE_TASK]
    , [REFERENCE_SOURCE]
    , [IS_BY_POLIGON])
      SELECT
      DISTINCT
        [TF].[CODE_FREQUENCY]
       ,MAX([TF].[SUNDAY])
       ,MAX([TF].[MONDAY])
       ,MAX([TF].[TUESDAY])
       ,MAX([TF].[WEDNESDAY])
       ,MAX([TF].[THURSDAY])
       ,MAX([TF].[FRIDAY])
       ,MAX([TF].[SATURDAY])
       ,MAX([TF].[FREQUENCY_WEEKS])
       ,MAX([TF].[LAST_WEEK])
       ,GETDATE()
       ,@LOGIN_ID
       ,MAX([TF].[CODE_ROUTE])
       ,MAX([TF].[TYPE_TASK])
       ,@REFERENCE_SOURCE AS [REFERENCE_SOURCE]
       ,MAX([TF].[IS_BY_POLIGON])
      FROM @TABLE_FRECUENCY [TF]
      INNER JOIN @FREQUENCY_TO_INSERT AS [FI]
        ON [FI].[CODE_FREQUENCY] = [TF].[CODE_FREQUENCY]
      WHERE [FI].[ID] > 0
      GROUP BY [TF].[CODE_FREQUENCY]


    -- ----------------------------------------------------------------------
    -- Llenamos la tabla temporal de frecuencia por cliente
    -- ----------------------------------------------------------------------
    INSERT INTO @TABLE_FRECUENCY_X_CUSTOMER ([ID_FRECUENCY]
    , [CUSTOMER_CODE]
    , [PRIORITY]
    , [LAST_WEEK_VISITED])
      SELECT
        [SF].[ID_FREQUENCY]
       ,[TF].[CUSTOMER_CODE]
       ,[TF].[PRIORITY]
       ,[TF].[LAST_WEEK]
      FROM @TABLE_FRECUENCY [TF]
      INNER JOIN [SONDA].[SWIFT_FREQUENCY] [SF]
        ON [SF].[CODE_FREQUENCY] = [TF].[CODE_FREQUENCY];

    -- --------------------------------------------------------
    -- Insertamos las nuevas frequencias por cliente generadas
    -- --------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] ([ID_FREQUENCY]
    , [CODE_CUSTOMER]
    , [PRIORITY]
    , [LAST_WEEK_VISITED])
      SELECT
        [TFC].[ID_FRECUENCY]
       ,[TFC].[CUSTOMER_CODE]
       ,[TFC].[PRIORITY]
       ,[TFC].[LAST_WEEK_VISITED]
      FROM @TABLE_FRECUENCY_X_CUSTOMER [TFC];

  END
  ELSE
  BEGIN
    PRINT ('PROCESA LOS DATOS GENERADOS ' + CAST(GETDATE() AS VARCHAR));
    -- -----------------------------------------------------------------------------------------------------------------
    -- Obtenemos las combinaciones de datos existentes, las cuales deben solamente actualizarse
    -- -----------------------------------------------------------------------------------------------------------------
    INSERT INTO @EXISTING_COMBINATION ([ID_FREQUENCY]
    , [CODE_FREQUENCY])
      SELECT
      DISTINCT
        [F].[ID_FREQUENCY]
       ,[TF].[CODE_FREQUENCY]
      FROM @TABLE_FRECUENCY AS [TF]
      INNER JOIN [SONDA].[SWIFT_FREQUENCY] [F]
        ON (
        [TF].[CODE_FREQUENCY] = [F].[CODE_FREQUENCY]
        )

    -- -----------------------------------------------------------------------------------------------------------------
    -- Obtenemos las combinaciones de datos no existentes, las cuales deben insertarse
    -- -----------------------------------------------------------------------------------------------------------------
    INSERT INTO @UNEXISTING_COMBINATION ([CODE_FREQUENCY])
      SELECT
        [FI].[CODE_FREQUENCY]
      FROM @FREQUENCY_TO_INSERT AS [FI]
      WHERE [FI].[CODE_FREQUENCY] NOT IN (SELECT
          [CODE_FREQUENCY]
        FROM @EXISTING_COMBINATION
        WHERE [ID] > 0);


    -- -----------------------------------------------------------------------------------------------------------------
    -- Actualizamos las prioridades los clientes que existan de las combinaciones existentes
    -- -----------------------------------------------------------------------------------------------------------------
    UPDATE [FC]
    SET [FC].[PRIORITY] = [TF].[PRIORITY]
       ,[FC].[LAST_WEEK_VISITED] = [TF].[LAST_WEEK]
    FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] AS [FC]
    INNER JOIN @EXISTING_COMBINATION AS [EC]
      ON [EC].[ID_FREQUENCY] = [FC].[ID_FREQUENCY]
    INNER JOIN @TABLE_FRECUENCY AS [TF]
      ON [TF].[CODE_FREQUENCY] = [EC].[CODE_FREQUENCY]
      AND [TF].[CUSTOMER_CODE] = [FC].[CODE_CUSTOMER]
    WHERE [EC].[ID] > 0;

    -- -----------------------------------------------------------------------------------------------------------------
    -- Insertamos los clientes que no existan de las combinaciones existentes
    -- -----------------------------------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] ([ID_FREQUENCY]
    , [CODE_CUSTOMER]
    , [PRIORITY]
    , [LAST_WEEK_VISITED])
      SELECT
        [EC].[ID_FREQUENCY]
       ,[TF].[CUSTOMER_CODE]
       ,[TF].[PRIORITY]
       ,[TF].[LAST_WEEK]
      FROM @TABLE_FRECUENCY AS [TF]
      INNER JOIN @EXISTING_COMBINATION AS [EC]
        ON [EC].[CODE_FREQUENCY] = [TF].[CODE_FREQUENCY]
      LEFT JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] AS [FC]
        ON [FC].[ID_FREQUENCY] = [EC].[ID_FREQUENCY]
        AND [FC].[CODE_CUSTOMER] = [TF].[CUSTOMER_CODE]
      WHERE [FC].[ID_FREQUENCY] IS NULL;

    -- -----------------------------------------------------------------------------------------------------------------
    -- Actualizamos las FRECUENCIAS que existan de las combinaciones existentes
    -- -----------------------------------------------------------------------------------------------------------------
    UPDATE [F]
    SET [F].[LAST_WEEK_VISITED] = [TF].[LAST_WEEK]
       ,[F].[LAST_UPDATED] = GETDATE()
       ,[F].[LAST_UPDATED_BY] = @LOGIN_ID
    FROM [SONDA].[SWIFT_FREQUENCY] AS [F]
    INNER JOIN @EXISTING_COMBINATION AS [EC]
      ON [EC].[ID_FREQUENCY] = [F].[ID_FREQUENCY]
      AND [EC].[CODE_FREQUENCY] = [F].[CODE_FREQUENCY]
    INNER JOIN @TABLE_FRECUENCY AS [TF]
      ON [EC].[CODE_FREQUENCY] = [TF].[CODE_FREQUENCY]
    WHERE [EC].[ID] > 0;

    -- -----------------------------------------------
    -- Insertamos las nuevas frequencias generadas
    -- -----------------------------------------------
    INSERT INTO [SONDA].[SWIFT_FREQUENCY] ([CODE_FREQUENCY]
    , [SUNDAY]
    , [MONDAY]
    , [TUESDAY]
    , [WEDNESDAY]
    , [THURSDAY]
    , [FRIDAY]
    , [SATURDAY]
    , [FREQUENCY_WEEKS]
    , [LAST_WEEK_VISITED]
    , [LAST_UPDATED]
    , [LAST_UPDATED_BY]
    , [CODE_ROUTE]
    , [TYPE_TASK]
    , [REFERENCE_SOURCE]
    , [IS_BY_POLIGON])
      SELECT
        [TF].[CODE_FREQUENCY]
       ,MAX([TF].[SUNDAY])
       ,MAX([TF].[MONDAY])
       ,MAX([TF].[TUESDAY])
       ,MAX([TF].[WEDNESDAY])
       ,MAX([TF].[THURSDAY])
       ,MAX([TF].[FRIDAY])
       ,MAX([TF].[SATURDAY])
       ,MAX([TF].[FREQUENCY_WEEKS])
       ,MAX([TF].[LAST_WEEK])
       ,GETDATE()
       ,@LOGIN_ID
       ,MAX([TF].[CODE_ROUTE])
       ,MAX([TF].[TYPE_TASK])
       ,@REFERENCE_SOURCE AS [REFERENCE_SOURCE]
       ,MAX([TF].[IS_BY_POLIGON])
      FROM @TABLE_FRECUENCY [TF]
      INNER JOIN @UNEXISTING_COMBINATION AS [FI]
        ON [FI].[CODE_FREQUENCY] = [TF].[CODE_FREQUENCY]
      WHERE [FI].[ID] > 0
      GROUP BY [TF].[CODE_FREQUENCY]

    -- ----------------------------------------------------------------------
    -- Llenamos la tabla temporal de frecuencia por cliente
    -- ----------------------------------------------------------------------
    INSERT INTO @TABLE_FRECUENCY_X_CUSTOMER ([ID_FRECUENCY]
    , [CUSTOMER_CODE]
    , [PRIORITY]
    , [LAST_WEEK_VISITED])
      SELECT
        [SF].[ID_FREQUENCY]
       ,[TF].[CUSTOMER_CODE]
       ,[TF].[PRIORITY]
       ,[TF].[LAST_WEEK]
      FROM @TABLE_FRECUENCY [TF]
      INNER JOIN @UNEXISTING_COMBINATION AS [UC]
        ON [UC].[CODE_FREQUENCY] = [TF].[CODE_FREQUENCY]
      INNER JOIN [SONDA].[SWIFT_FREQUENCY] [SF]
        ON [SF].[CODE_FREQUENCY] = [UC].[CODE_FREQUENCY]
      WHERE [UC].[ID] > 0;

    -- --------------------------------------------------------
    -- Insertamos las nuevas frequencias por cliente generadas
    -- --------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] ([ID_FREQUENCY]
    , [CODE_CUSTOMER]
    , [PRIORITY]
    , [LAST_WEEK_VISITED])
      SELECT
        [TFC].[ID_FRECUENCY]
       ,[TFC].[CUSTOMER_CODE]
       ,[TFC].[PRIORITY]
       ,[TFC].[LAST_WEEK_VISITED]
      FROM @TABLE_FRECUENCY_X_CUSTOMER [TFC];

  END

  UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT]
  SET [LAST_UPDATE] = GETDATE()
     ,[LAST_UPDATE_BY] = @LOGIN_ID

END TRY
BEGIN CATCH
  -- -----------------------------------------------------------------------------------
  -- Si sucede algun error en el proceso agregamos dicho error a la tabla de resultados
  -- -----------------------------------------------------------------------------------
  INSERT INTO @TABLE_RESULT ([Resultado]
  , [Mensaje])
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje];
END CATCH;
  SELECT
    [Resultado]
   ,[Mensaje]
  FROM @TABLE_RESULT;
