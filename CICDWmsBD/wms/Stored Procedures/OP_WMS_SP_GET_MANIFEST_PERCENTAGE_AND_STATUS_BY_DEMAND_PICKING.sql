-- =============================================
-- Autor:					hector.gonzalez
-- Fecha de Creacion: 		27-11-17 @ A-Team Sprint Nach
-- Description:			    Funcion que obtiene el estado de un manifiesto dependiendo de si sus pickings no quedaron pendientes, esta funcion se hizo ya que no se esta guardando el estado del manifiesto al terminarlo

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_MANIFEST_PERCENTAGE_AND_STATUS_BY_DEMAND_PICKING] @VEHICLE_CODES = '17|19|21|25' ,@PILOT_CODES = '20', @START_DATE = '2017-10-19 6:50:05 PM' , @END_DATE = '2017-11-10 11:09:53 AM'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MANIFEST_PERCENTAGE_AND_STATUS_BY_DEMAND_PICKING] (@VEHICLE_CODES VARCHAR(MAX) = NULL,
@PILOT_CODES VARCHAR(MAX) = NULL, @START_DATE DATETIME, @END_DATE DATETIME)
AS
BEGIN
  DECLARE @MANIFEST_STATUS VARCHAR(20)
         ,@MANIFEST_PERCENTAGE DOUBLE PRECISION
         ,@EXTERNAL_SOURCE_ID INT
         ,@SOURCE_NAME VARCHAR(50)
         ,@DATA_BASE_NAME VARCHAR(50)
         ,@SCHEMA_NAME VARCHAR(50)
         ,@QUERY NVARCHAR(MAX)
         ,@MANIFEST_HEADER_ID INT

  DECLARE @EXTERNAL_SOURCE TABLE (
    [EXTERNAL_SOURCE_ID] INT
   ,[SOURCE_NAME] VARCHAR(50)
   ,[DATA_BASE_NAME] VARCHAR(50)
   ,[SCHEMA_NAME] VARCHAR(50)
   ,[INTERFACE_DATA_BASE_NAME] VARCHAR(50)
  )

  DECLARE @MANIFEST_HEADER TABLE (
    [MANIFEST_HEADER_ID] INT
   ,[DRIVER] INT
   ,[VEHICLE] INT
   ,[STATUS] VARCHAR(50)
   ,[MANIFEST_TYPE] VARCHAR(50)
  )

  DECLARE @TABLE_MANIFEST_PERCENTAGE TABLE (
    [MANIFEST_HEADER_ID] INT
   ,[MANIFEST_PERCENTAGE] NUMERIC(18, 2)
  )


  DECLARE @VEHICLES TABLE (
    VEHICLE_CODE INT
   ,VEHICLE_PLATE_NUMBER VARCHAR(10) UNIQUE (VEHICLE_CODE)
  );

  DECLARE @PILOTS TABLE (
    PILOT_CODE INT
   ,[NAME] VARCHAR(250)
   ,[LAST_NAME] VARCHAR(250) UNIQUE (PILOT_CODE)
  );

  INSERT INTO @VEHICLES
    SELECT DISTINCT
      [VS].[VALUE]
     ,[V].[PLATE_NUMBER]
    FROM [wms].[OP_WMS_FUNC_SPLIT_3](@VEHICLE_CODES, '|') [VS]
    INNER JOIN [wms].[OP_WMS_VEHICLE] [V]
      ON [VS].[VALUE] = [V].[VEHICLE_CODE];

  INSERT INTO @PILOTS
    SELECT DISTINCT
      [PS].[VALUE]
     ,[P].[NAME]
     ,[P].[LAST_NAME]
    FROM [wms].[OP_WMS_FUNC_SPLIT_3](@PILOT_CODES, '|') [PS]
    INNER JOIN [wms].[OP_WMS_PILOT] [P]
      ON [PS].[VALUE] = [P].[PILOT_CODE];

  INSERT INTO @MANIFEST_HEADER
    SELECT
      [MH].[MANIFEST_HEADER_ID]
     ,[MH].[DRIVER]
     ,[MH].[VEHICLE]
     ,[MH].[STATUS]
     ,[MH].[MANIFEST_TYPE]
    FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
    INNER JOIN @VEHICLES V
      ON ([V].[VEHICLE_CODE] = [MH].[VEHICLE]
      OR @VEHICLE_CODES IS NULL
      OR @VEHICLE_CODES = ''
      )
    INNER JOIN @PILOTS P
      ON ([P].[PILOT_CODE] = [MH].[DRIVER]
      OR @PILOT_CODES IS NULL
      OR @PILOT_CODES = ''
      )
    WHERE [MH].[CREATED_DATE] BETWEEN @START_DATE AND @END_DATE
    AND [MH].[STATUS] IN ('ASSIGNED', 'COMPLETED')

  SELECT
    @QUERY = '
        DECLARE @PORCENTAJE DOUBLE PRECISION;	';
  EXEC sp_executesql @QUERY

  WHILE EXISTS (SELECT TOP 1
        1
      FROM @MANIFEST_HEADER
      WHERE [MANIFEST_HEADER_ID] > 0)
  BEGIN

    SELECT
      @MANIFEST_HEADER_ID = [MH].[MANIFEST_HEADER_ID]
     ,@MANIFEST_STATUS = [MH].[STATUS]
    FROM @MANIFEST_HEADER [MH]
    WHERE [MH].[MANIFEST_HEADER_ID] > 0
    ORDER BY [MH].[MANIFEST_HEADER_ID]

    -- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas
    -- ------------------------------------------------------------------------------------
    INSERT INTO @EXTERNAL_SOURCE
      SELECT
        [ES].[EXTERNAL_SOURCE_ID]
       ,[ES].[SOURCE_NAME]
       ,[ES].[DATA_BASE_NAME]
       ,[ES].[SCHEMA_NAME]
       ,[ES].[INTERFACE_DATA_BASE_NAME]
      FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
      WHERE [ES].[EXTERNAL_SOURCE_ID] > 0
      AND [ES].[READ_ERP] = 1;

    WHILE EXISTS (SELECT TOP 1
          1
        FROM @EXTERNAL_SOURCE
        WHERE [EXTERNAL_SOURCE_ID] > 0)
    BEGIN
      -- ------------------------------------------------------------------------------------
      -- Se toma la primera fuente extermna
      -- ------------------------------------------------------------------------------------
      SELECT TOP 1
        @EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
       ,@SOURCE_NAME = [ES].[SOURCE_NAME]
       ,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
       ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
       ,@QUERY = N''
      FROM @EXTERNAL_SOURCE [ES]
      WHERE [ES].[EXTERNAL_SOURCE_ID] > 0
      ORDER BY [ES].[EXTERNAL_SOURCE_ID];
      --
      PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
      PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
      PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
      PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;


      -------------------------------------------------------------------------------------------
      SELECT
        @QUERY = N'          
           DECLARE @PROGRESO DOUBLE PRECISION
                   ,@PICKINGS_TOTAL DOUBLE PRECISION
                   

                   SELECT
                    @PROGRESO = COUNT(*)
                  FROM (SELECT
                    DISTINCT
                      [MD].[PICKING_DEMAND_HEADER_ID]
                     ,[PBY].[PICKING_DEMAND_STATUS]
                    FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
                    INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
                      ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
                    INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_PICKING_DEMAND_BY_TASK] [PBY]
                      ON [MD].[PICKING_DEMAND_HEADER_ID] = [PBY].[PICKING_DEMAND_HEADER_ID]
                    WHERE [MD].[MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + '
                    AND [PBY].[PICKING_DEMAND_STATUS] <> ''PENDING''
                    GROUP BY [MD].[PICKING_DEMAND_HEADER_ID]
                            ,[PBY].[PICKING_DEMAND_STATUS]) X
                  
                  SELECT
                    @PICKINGS_TOTAL = COUNT(*)
                  FROM (SELECT
                    DISTINCT
                      [MD].[PICKING_DEMAND_HEADER_ID]
                     ,[PBY].[PICKING_DEMAND_STATUS]
                    FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
                    INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
                      ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
                    INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_PICKING_DEMAND_BY_TASK] [PBY]
                      ON [MD].[PICKING_DEMAND_HEADER_ID] = [PBY].[PICKING_DEMAND_HEADER_ID]
                    WHERE [MD].[MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + '
                    GROUP BY [MD].[PICKING_DEMAND_HEADER_ID]
                             ,[PBY].[PICKING_DEMAND_STATUS]) Y 
                   
				   IF (@PICKINGS_TOTAL <> 0)
				   BEGIN
						 SET @PORCENTAJE = @PROGRESO / @PICKINGS_TOTAL * 100
				   END
				   ELSE
				   BEGIN 
						SET @PORCENTAJE = 0
					END
      	';
      --
      PRINT '-->% @QUERY: \n' + @QUERY + '%';
      --
      EXEC sp_executesql @QUERY
                        ,N'@PORCENTAJE DOUBLE PRECISION out'
                        ,@MANIFEST_PERCENTAGE OUT
      ------------------------------------------------------------------------------------------

      INSERT INTO @TABLE_MANIFEST_PERCENTAGE ([MANIFEST_HEADER_ID], [MANIFEST_PERCENTAGE])
        VALUES (@MANIFEST_HEADER_ID, @MANIFEST_PERCENTAGE)

      -- ------------------------------------------------------------------------------------
      -- Eleminamos la fuente externa
      -- ------------------------------------------------------------------------------------
      DELETE FROM @EXTERNAL_SOURCE
      WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;

    END


    -- ------------------------------------------------------------------------------------
    -- Eleminamos la fuente externa
    -- ------------------------------------------------------------------------------------
    DELETE FROM @MANIFEST_HEADER
    WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

  END

  SELECT
    [MANIFEST_HEADER_ID]
   ,[MANIFEST_PERCENTAGE]
  FROM @TABLE_MANIFEST_PERCENTAGE
--

END;