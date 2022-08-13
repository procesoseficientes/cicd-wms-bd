-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-11-24 @ Team REBORN - Sprint Nach
-- Description:	        SP de reporte de cumplimiento de entrega

-- Modificacion 03-Jan-18 @ Nexus Team Sprint @IceAge
-- pablo.aguilar
-- Se agregan campo de TaskId, y fecha de asignación. 

-- Modificacion:		henry.rodriguez
-- Fecha:				02-Agosto-2019 G-Force@Estambul
-- Descripcion:			Se agrega propiedad isnull a campos de GPS.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_DELIVERY_COMPLIANCE_REPORT @VEHICLE_CODES = '17|19|21|25' ,@PILOT_CODES = '20', @START_DATE = '2017-10-19 6:50:05 PM' , @END_DATE = '2017-11-10 11:09:53 AM'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DELIVERY_COMPLIANCE_REPORT] (
		@VEHICLE_CODES VARCHAR(MAX) = NULL
		,@PILOT_CODES VARCHAR(MAX) = NULL
		,@START_DATE DATETIME
		,@END_DATE DATETIME
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@EXTERNAL_SOURCE_ID INT
		,@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX);

	CREATE TABLE [#DELIVERY_COMPLIANCE_REPORT] (
		[MANIFEST_HEADER_ID] INT
		,[STATUS] VARCHAR(20)
		,[CREATED_DATE] DATETIME
		,[VEHICLE_CODE] INT
		,[VEHICLE_PLATE_NUMBER] VARCHAR(10)
		,[PILOT_CODE] INT
		,[PILOT_NAME] VARCHAR(501)
		,[PERCENTAGE] DECIMAL(18, 2)
		,[CLIENT_CODE] VARCHAR(150)
		,[CLIENT_NAME] VARCHAR(150)
		,[TASK_STATUS] VARCHAR(10)
		,[PICKING_DEMAND_STATUS] VARCHAR(50)
		,[REASON] VARCHAR(250)
		,[SEQUENCE] INT
		,[EXPECTED_GPS] VARCHAR(100)
		,[POSTED_GPS] VARCHAR(100)
		,[DISTANCE] FLOAT
		,[ACCEPTED_STAMP] DATETIME
		,[COMPLETED_STAMP] DATETIME
		,[DELAY] INT
		,[DOC_NUM] INT
		,[MATERIAL_ID] VARCHAR(50)
		,[MATERIAL_NAME] VARCHAR(200)
		,[QTY_REQUESTED] DECIMAL(18, 4)
		,[QTY_DELIVERED] DECIMAL(18, 6)
		,[DIFFERENCE] DECIMAL(38, 4)
		,[ASSIGNED_STAMP] DATETIME
		,[TASK_ID] INT
		,[DELIVERY_NOTE_ID] INT
	);

	DECLARE	@EXTERNAL_SOURCE TABLE (
			[EXTERNAL_SOURCE_ID] INT
			,[SOURCE_NAME] VARCHAR(50)
			,[DATA_BASE_NAME] VARCHAR(50)
			,[SCHEMA_NAME] VARCHAR(50)
			,[INTERFACE_DATA_BASE_NAME] VARCHAR(50)
		);


	CREATE TABLE [#VEHICLES] (
		[VEHICLE_CODE] INT
		,[VEHICLE_PLATE_NUMBER] VARCHAR(10)
			UNIQUE ([VEHICLE_CODE])
	);

	CREATE TABLE [#PILOTS] (
		[PILOT_CODE] INT
		,[NAME] VARCHAR(250)
		,[LAST_NAME] VARCHAR(250) UNIQUE ([PILOT_CODE])
	);


	INSERT	INTO [#VEHICLES]
	SELECT DISTINCT
		[VS].[VALUE]
		,[V].[PLATE_NUMBER]
	FROM
		[wms].[OP_WMS_FUNC_SPLIT_3](@VEHICLE_CODES, '|') [VS]
	INNER JOIN [wms].[OP_WMS_VEHICLE] [V] ON [VS].[VALUE] = [V].[VEHICLE_CODE];

	INSERT	INTO [#PILOTS]
	SELECT DISTINCT
		[PS].[VALUE]
		,[P].[NAME]
		,[P].[LAST_NAME]
	FROM
		[wms].[OP_WMS_FUNC_SPLIT_3](@PILOT_CODES, '|') [PS]
	INNER JOIN [wms].[OP_WMS_PILOT] [P] ON [PS].[VALUE] = [P].[PILOT_CODE];

	SET @END_DATE = DATEADD(HOUR, 23, @END_DATE);
	SET @END_DATE = DATEADD(MINUTE, 59, @END_DATE);
	SET @END_DATE = DATEADD(SECOND, 59, @END_DATE);
	PRINT CAST(@END_DATE AS VARCHAR);

	CREATE TABLE [#MANIFEST_STATUS_AND_PERCENTAGE] (
		[MANIFEST_HEADER_ID] INT
		,[MANIFEST_PERCENTAGE] NUMERIC(18, 2)
	);
	INSERT	INTO [#MANIFEST_STATUS_AND_PERCENTAGE]
			EXEC [wms].[OP_WMS_SP_GET_MANIFEST_PERCENTAGE_AND_STATUS_BY_DEMAND_PICKING] @VEHICLE_CODES = @VEHICLE_CODES,
				@PILOT_CODES = @PILOT_CODES,
				@START_DATE = @START_DATE,
				@END_DATE = @END_DATE;
  -- ------------------------------------------------------------------------------------
  -- Obtiene las fuentes externas
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @EXTERNAL_SOURCE
	SELECT TOP 1
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME]
		,[ES].[INTERFACE_DATA_BASE_NAME]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	WHERE
		[ES].[EXTERNAL_SOURCE_ID] > 0
		AND [ES].[IS_SONDA_SD] = 1;

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						@EXTERNAL_SOURCE
					WHERE
						[EXTERNAL_SOURCE_ID] > 0 )
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
		FROM
			@EXTERNAL_SOURCE [ES]
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] > 0
		ORDER BY
			[ES].[EXTERNAL_SOURCE_ID];
    --
		PRINT '----> @EXTERNAL_SOURCE_ID: '
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

    -- ------------------------------------------------------------------------------------
    -- Obtiene las ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = '   
INSERT INTO #DELIVERY_COMPLIANCE_REPORT
    SELECT
      [MH].[MANIFEST_HEADER_ID]
     ,[MH].[STATUS]
     ,[MH].[CREATED_DATE]
     ,[V].[VEHICLE_CODE]
     ,[V].[VEHICLE_PLATE_NUMBER]
     ,[P].[PILOT_CODE]
     ,([P].[LAST_NAME] + '' '' + [P].[NAME]) AS PILOT_NAME
     ,[MSP].[MANIFEST_PERCENTAGE] AS [PERCENTAGE]
     ,[MD].[CLIENT_CODE]
     ,[MD].[CLIENT_NAME]
     ,[T].[TASK_STATUS] AS [TASK_STATUS]
     ,ISNULL([PBT].[PICKING_DEMAND_STATUS], ''N/A'') [PICKING_DEMAND_STATUS]
     ,ISNULL([DC].[REASON_CANCEL], ''N/A'') [REASON]
     ,[T].[TASK_SEQ] AS [SEQUENCE]
     ,[T].[EXPECTED_GPS]
     ,[T].[POSTED_GPS]
     ,[wms].[OP_WMS_FN_CALCULATE_DISTANCE]([T].[EXPECTED_GPS], T.[POSTED_GPS]) AS [DISTANCE]
     ,[T].[ACCEPTED_STAMP]
     ,[T].[COMPLETED_STAMP]
     ,DATEDIFF(mi, [T].[ACCEPTED_STAMP], [T].[COMPLETED_STAMP]) AS [DELAY]
     ,COALESCE([PDH].[ERP_REFERENCE_DOC_NUM], [PDH].[DOC_NUM]) AS [DOC_NUM]
     ,[M].[MATERIAL_ID]
     ,[M].[MATERIAL_NAME]
     ,[PDD].[QTY] AS [QTY_REQUESTED]     
     ,ISNULL([DND].[QTY], 0) AS [QTY_DELIVERED]
     ,[PDD].[QTY] - ISNULL([DND].[QTY], 0) AS [DIFFERENCE]     
	   , MIN([T].[ASSIGNED_STAMP]) [ASSIGNED_STAMP]
	   ,[T].[TASK_ID]
     ,MAX([DNH].[DELIVERY_NOTE_ID]) AS [DELIVERY_NOTE_ID]
    FROM #MANIFEST_STATUS_AND_PERCENTAGE [MSP]
    INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH]      
      ON [MH].[MANIFEST_HEADER_ID] = [MSP].[MANIFEST_HEADER_ID]          
    INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
      ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]   
    INNER JOIN #VEHICLES V
      ON ([V].[VEHICLE_CODE] = [MH].[VEHICLE]
      OR ''' + CAST(@VEHICLE_CODES AS VARCHAR) + ''' IS NULL
      OR ''' + CAST(@VEHICLE_CODES AS VARCHAR) + ''' = ''''
      )
    INNER JOIN #PILOTS P
      ON ([P].[PILOT_CODE] = [MH].[DRIVER]
      OR ''' + CAST(@PILOT_CODES AS VARCHAR) + ''' IS NULL
      OR ''' + CAST(@PILOT_CODES AS VARCHAR)
			+ ''' = ''''
      )
    
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
      ON [PDH].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID]      
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
      ON ([PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID])
    INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
      ON [PDD].[MATERIAL_ID] = [M].[MATERIAL_ID] 
    

    LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[SONDA_DELIVERY_NOTE_DETAIL] [DND]
      ON ([DND].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
      AND [PDD].[MASTER_ID_MATERIAL] = [DND].[CODE_SKU]
      )
    LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[SONDA_DELIVERY_NOTE_HEADER] [DNH]
      ON ([DND].[DELIVERY_NOTE_ID] = [DNH].[DELIVERY_NOTE_ID])
    LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[SONDA_DELIVERY_CANCELED] [DC]
      ON [PDH].[PICKING_DEMAND_HEADER_ID] = [DC].[PICKING_DEMAND_HEADER_ID]
    LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[SONDA_PICKING_DEMAND_BY_TASK] [PBT]
      ON [MD].[PICKING_DEMAND_HEADER_ID] = [PBT].[PICKING_DEMAND_HEADER_ID]
    LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[SWIFT_TASKS] [T]
      ON [PBT].[TASK_ID] = [T].[TASK_ID]
    

    GROUP BY [MH].[MANIFEST_HEADER_ID]
            ,[MH].[STATUS]
            ,[MH].[CREATED_DATE]
			,[T].[TASK_ID]
            ,[V].[VEHICLE_CODE]
            ,[V].[VEHICLE_PLATE_NUMBER]
            ,[P].[PILOT_CODE]
            ,[P].[LAST_NAME]
            ,[P].[NAME]
            ,[MSP].[MANIFEST_PERCENTAGE]
            ,[MD].[CLIENT_CODE]
            ,[MD].[CLIENT_NAME]
            ,[T].[TASK_STATUS]
            ,[DC].[REASON_CANCEL]
            ,[T].[TASK_SEQ]
            ,[PBT].[PICKING_DEMAND_STATUS]
            ,[T].[EXPECTED_GPS]
            ,[T].[POSTED_GPS]
            ,[T].[ACCEPTED_STAMP]
            ,[T].[COMPLETED_STAMP]
            ,COALESCE([PDH].[ERP_REFERENCE_DOC_NUM], [PDH].[DOC_NUM])
            ,[M].[MATERIAL_ID]
            ,[M].[MATERIAL_NAME]            
            ,[PDD].[QTY]
            ,[DND].[QTY]
';
		PRINT @QUERY;

		EXEC [sp_executesql] @QUERY;

    -- ------------------------------------------------------------------------------------
    -- Eleminamos la fuente externa
    -- ------------------------------------------------------------------------------------
		DELETE FROM
			@EXTERNAL_SOURCE
		WHERE
			[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
	END;


	SELECT
		[MANIFEST_HEADER_ID]
		,[STATUS]
		,[CREATED_DATE]
		,[VEHICLE_CODE]
		,[VEHICLE_PLATE_NUMBER]
		,[PILOT_CODE]
		,[PILOT_NAME]
		,[PERCENTAGE]
		,[CLIENT_CODE]
		,[CLIENT_NAME]
		,[TASK_STATUS]
		,[PICKING_DEMAND_STATUS]
		,[REASON]
		,[SEQUENCE]
		,ISNULL([EXPECTED_GPS], '0,0') [EXPECTED_GPS]
		,ISNULL([POSTED_GPS], '0,0') [POSTED_GPS]
		,[DISTANCE]
		,[ACCEPTED_STAMP]
		,[COMPLETED_STAMP]
		,[DELAY]
		,[DOC_NUM]
		,[MATERIAL_ID]
		,[MATERIAL_NAME]
		,[QTY_REQUESTED]
		,[QTY_DELIVERED]
		,[DIFFERENCE]
		,[ASSIGNED_STAMP]
		,[TASK_ID]
		,[DELIVERY_NOTE_ID]
	FROM
		[#DELIVERY_COMPLIANCE_REPORT];

END;