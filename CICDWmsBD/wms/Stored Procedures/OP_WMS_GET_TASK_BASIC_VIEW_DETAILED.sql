-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/18/2018 @ GForce-Team Sprint Capibara???
-- Description:			Obtiene las tareas con su material y cantidades

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_TASK_BASIC_VIEW_DETAILED]
					@START_DATETIME = '2018-05-18 00:00:00',
					@END_DATETIME = '2018-05-18 16:55:04.573', 
					@LOGIN = N'ADMIN',
					@USERS = N'ADMIN|2008|2010|2023|2014|2026|2004|2015|2007|2013|2017|2019|2030|2006|2002|2028|2003|2027|2020|2005|2016|2025|2022|OPER1|2011|2001|2009|2018|2024|2012|2021',
					@TYPES = N'TAREA_ALMACENAJE|TAREA_PICKING|TAREA_REABASTECIMIENTO|TAREA_REUBICACION|TAREA_ACUSE_RECIBO|TAREA_RECEPCION|TAREA_CONTEO_FISICO',
					@CLASS = N'';
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_TASK_BASIC_VIEW_DETAILED] (
		@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
		,@USERS VARCHAR(MAX) = NULL
		,@TYPES VARCHAR(MAX) = NULL
		,@CLASS VARCHAR(MAX) = NULL
		,@LOGIN VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE	@MAX_ATTEMPTS INT = 5;
	--
	DECLARE	@TB_WAREHOUSE TABLE (
			[WAREHOUSE_ID] VARCHAR(25)
			,[USE_PICKING_LINE] INT
		);
	--
	DECLARE	@TB_PRIORITY TABLE (
			[PRIORITY] INT
			,[PRIORITY_DESCRIPTION] VARCHAR(25)
		);
	--
	CREATE TABLE [#CLASS] (
		[CLASS_ID] INT PRIMARY KEY
	);
	-- ------------------------------------------------------------------------------------
	-- Obtiene intentos maximos
	-- ------------------------------------------------------------------------------------
	SELECT
		@MAX_ATTEMPTS = [C].[NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
		[C].[PARAM_TYPE] = 'SISTEMA'
		AND [C].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
		AND [C].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';

	-- ------------------------------------------------------------------------------------
	-- Agrega a los usuarios las opciones 
	-- ------------------------------------------------------------------------------------
	SET @USERS = @USERS + '|Multiple|Sin Asignación|';

	-- ------------------------------------------------------------------------------------
	-- Arma una tabla temporal con los tipos
	-- ------------------------------------------------------------------------------------
	SELECT
		[T].[VALUE] AS [TYPE]
	INTO
		[#TYPES]
	FROM
		[wms].[OP_WMS_FN_SPLIT](@TYPES, '|') [T];

	-- ------------------------------------------------------------------------------------
	-- Arma una tabla temporal con los usuarios
	-- ------------------------------------------------------------------------------------
	SELECT
		[T].[VALUE] AS [login]
		,ISNULL([L].[LOGIN_NAME], [T].[VALUE]) [LOGIN_NAME]
	INTO
		[#USERS]
	FROM
		[wms].[OP_WMS_FN_SPLIT](@USERS, '|') [T]
	LEFT JOIN [wms].[OP_WMS_LOGINS] [L] ON [L].[LOGIN_ID] = [T].[VALUE];

	-- ------------------------------------------------------------------------------------
	-- Inserta las lineas de picking como usuarios
	-- ------------------------------------------------------------------------------------
	INSERT	INTO [#USERS]
	SELECT
		[C].[PARAM_NAME]
		,[C].[PARAM_NAME]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
		[C].[PARAM_TYPE] = 'SISTEMA'
		AND [C].[PARAM_GROUP] = 'LINEAS_PICKING';
	-- ------------------------------------------------------------------------------------
	-- Arma tabla temporal para las clases
	-- ------------------------------------------------------------------------------------
	IF (
		@CLASS = ''
		OR @CLASS IS NULL
		OR @CLASS = '|'
		)
	BEGIN
		INSERT	INTO [#CLASS]
		SELECT
			[CLASS_ID]
		FROM
			[wms].[OP_WMS_CLASS];
	END;
	ELSE
	BEGIN
		INSERT	INTO [#CLASS]
		SELECT
			[C].[VALUE] AS [CLASS_ID]
		FROM
			[wms].[OP_WMS_FN_SPLIT](@CLASS, '|') [C];
	END;
	-- ------------------------------------------------------------------------------------
	-- Se obtine las bodegas asociadas al login enviado
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @TB_WAREHOUSE
			(
				[WAREHOUSE_ID]
				,[USE_PICKING_LINE]
			)
	SELECT
		[WU].[WAREHOUSE_ID]
		,[W].[USE_PICKING_LINE]
	FROM
		[wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
	LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [WU].[WAREHOUSE_ID] = [W].[WAREHOUSE_ID]
	WHERE
		[WU].[LOGIN_ID] = @LOGIN;
	-- ------------------------------------------------------------------------------------
	-- Obtiene las prioridades de la tabla de configuraciones
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @TB_PRIORITY
	SELECT
		[NUMERIC_VALUE]
		,[PARAM_CAPTION]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_GROUP] = 'PRIORITY'
		AND [PARAM_TYPE] = 'SISTEMA';



		-- ------------------------------------------------------------------------------------
	-- Arma el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		*
	INTO
		[#RESULT]
	FROM
		(
		-- ------------------------------------------------------------------------------------
		-- Tareas de Recepcion
		-- ------------------------------------------------------------------------------------
			SELECT
				NULL AS [TASK_ID]
				,[VT].[WAVE_PICKING_ID]
				,[VT].[CLIENT_NAME]
				,[VT].[TASK_TYPE]
				,[VT].[TASK_SUBTYPE]
				,[VT].[TASK_ASSIGNEDTO]
				,[VT].[TASK_COMMENTS]
				,[VT].[REGIMEN]
				,[VT].[IS_PAUSED]
				,[VT].[SERIAL_NUMBER]
				,[VT].[ASSIGNED_DATE]
				,[VT].[ACCEPTED_DATE]
				,[VT].[PICKING_FINISHED_DATE]
				,[VT].[IS_CANCELED]
				,[VT].[QUANTITY_PENDING]
				,[VT].[QUANTITY_ASSIGNED]
				,[VT].[NUMERO_ORDEN_SOURCE]
				,[VT].[NUMERO_ORDEN_TARGET]
				,[VT].[IS_COMPLETED]
				,[VT].[CODIGO_POLIZA_SOURCE]
				,[VT].[CODIGO_POLIZA_TARGET]
				,[VT].[IS_DISCRETIONARY]
				,[VT].[TYPE_PICKING]
				,[VT].[IS_ACCEPTED]
				,ISNULL(DATEDIFF(MINUTE,
									[VT].[ACCEPTED_DATE],
									[VT].[PICKING_FINISHED_DATE]),
						0) AS [TIME]
				,ISNULL([VT].[IS_FROM_ERP], 0) [IS_FROM_ERP]
				,ISNULL([VT].[IS_FROM_SONDA], 0) [IS_FROM_SONDA]
				,CAST([RDH].[DOC_NUM] AS VARCHAR) AS [NO_DOC]
				,[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] [WMS_DOCUMENT_HEADER_ID]
				,[RDH].[DOC_NUM] AS [DOC_ID]
				,[RDH].[ATTEMPTED_WITH_ERROR]
				,ISNULL([RDH].[IS_POSTED_ERP], 0) [IS_POSTED_ERP]
				,CASE	WHEN ISNULL([RDH].[IS_POSTED_ERP], 0) = -1
						THEN 'Fallido'
						WHEN ISNULL([RDH].[IS_POSTED_ERP], 0) = 0
								AND ISNULL([RDH].[IS_AUTHORIZED],
											0) = 1
						THEN 'Autorizada'
						WHEN ISNULL([RDH].[IS_POSTED_ERP], 0) = 0
								AND ISNULL([RDH].[IS_AUTHORIZED],
											0) = 0
						THEN 'Pendiente de Autorización'
						WHEN ISNULL([RDH].[IS_POSTED_ERP], 0) = 1
						THEN 'Enviado'
					END [STATUS_POSTED_ERP]
				,[RDH].[POSTED_ERP]
				,[RDH].[POSTED_RESPONSE]
				,[RDH].[ERP_REFERENCE_DOC_NUM] AS [ERP_REFERENCE]
				,ISNULL([RDH].[IS_AUTHORIZED], 0) [IS_AUTHORIZED]
				,@MAX_ATTEMPTS AS [MAX_ATTEMPTS]
				,'' [LOCATION_SPOT_TARGET]
				,NULL AS [CODE_ROUTE]
				,NULL AS [USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[VT].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,NULL AS [SOURCE_TYPE]
				,NULL [MATERIAL_ID]
				,NULL [MATERIAL_NAME]
				,NULL [QUANTITY_ASSIGNED_TASK]
			FROM
				[wms].[OP_WMS_VIEW_TASK] [VT]
			LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH] ON ([VT].[SERIAL_NUMBER] = [RDH].[TASK_ID])
			LEFT JOIN [#USERS] [U] ON [U].[login] = [VT].[TASK_ASSIGNEDTO]
			LEFT JOIN @TB_PRIORITY [P] ON [VT].[PRIORITY] = [P].[PRIORITY]
			WHERE
				[VT].[ASSIGNED_DATE] BETWEEN @START_DATETIME
										AND	@END_DATETIME
				AND (
						@USERS IS NULL
						OR [U].[login] IS NOT NULL
					)
				AND [VT].[IS_CANCELED] = 0
				AND [VT].[TASK_TYPE] = 'TAREA_RECEPCION'
			UNION

		 -- ------------------------------------------------------------------------------------
		 -- Tareas de Picking
		 -- ------------------------------------------------------------------------------------
			SELECT DISTINCT
				NULL AS [TASK_ID]
				,[VT].[WAVE_PICKING_ID]
				,[VT].[CLIENT_NAME]
				,[VT].[TASK_TYPE]
				,[VT].[TASK_SUBTYPE]
				,[VT].[TASK_ASSIGNEDTO]
				,[VT].[TASK_COMMENTS]
				,[VT].[REGIMEN]
				,[VT].[IS_PAUSED]
				,[VT].[SERIAL_NUMBER]
				,[VT].[ASSIGNED_DATE]
				,[VT].[ACCEPTED_DATE]
				,[VT].[PICKING_FINISHED_DATE]
				,[VT].[IS_CANCELED]
				,SUM([TL].[QUANTITY_PENDING]) [QUANTITY_PENDING]
				,SUM([TL].[QUANTITY_ASSIGNED]) [QUANTITY_ASSIGNED]
				,[VT].[NUMERO_ORDEN_SOURCE]
				,[VT].[NUMERO_ORDEN_TARGET]
				,[VT].[IS_COMPLETED]
				,[VT].[CODIGO_POLIZA_SOURCE]
				,[VT].[CODIGO_POLIZA_TARGET]
				,[VT].[IS_DISCRETIONARY]
				,[VT].[TYPE_PICKING]
				,[VT].[IS_ACCEPTED]
				,ISNULL(DATEDIFF(MINUTE,
									[VT].[ACCEPTED_DATE],
									[VT].[PICKING_FINISHED_DATE]),
						0) AS [TIME]
				,ISNULL([VT].[IS_FROM_ERP], 0) [IS_FROM_ERP]
				,ISNULL([VT].[IS_FROM_SONDA], 0) [IS_FROM_SONDA]
				,CAST([VT].[NO_DOC] AS VARCHAR)
				,[VT].[WMS_DOCUMENT_HEADER_ID]
				,[VT].[DOC_ID]
				,[VT].[ATTEMPTED_WITH_ERROR]
				,[VT].[IS_POSTED_ERP]
				,[VT].[STATUS_POSTED_ERP]
				,[VT].[POSTED_ERP]
				,[VT].[POSTED_RESPONSE]
				,[VT].[ERP_REFERENCE]
				,[VT].[IS_AUTHORIZED]
				,@MAX_ATTEMPTS AS [MAX_ATTEMPTS]
				,'' [LOCATION_SPOT_TARGET]
				,[VT].[CODE_ROUTE]
				,[VT].[USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[VT].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,[VT].[SOURCE_TYPE]
				,[VT].[MATERIAL_ID]
				,[M].[MATERIAL_NAME]
				,SUM([TL].[QUANTITY_ASSIGNED]) [QUANTITY_ASSIGNED_TASK]
			FROM
				[wms].[OP_WMS_VIEW_TASK_PICKING_HEADER_DETAILED] [VT]
			INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [VT].[WAVE_PICKING_ID]
											AND [TL].[MATERIAL_ID] = [VT].[MATERIAL_ID]
			INNER JOIN @TB_WAREHOUSE [W] ON ([W].[WAREHOUSE_ID] = [VT].[WAREHOUSE_SOURCE])
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [VT].[MATERIAL_ID]
			INNER JOIN [#CLASS] [C] ON [C].[CLASS_ID] = CAST([M].[MATERIAL_CLASS] AS INT)
			LEFT JOIN [#USERS] [U] ON [U].[login] = [VT].[TASK_ASSIGNEDTO]
			LEFT JOIN @TB_PRIORITY [P] ON [P].[PRIORITY] = [VT].[PRIORITY]
			WHERE
				[VT].[ASSIGNED_DATE] BETWEEN @START_DATETIME
										AND	@END_DATETIME
				AND (
						@USERS IS NULL
						OR [U].[login] IS NOT NULL
					)
				AND [VT].[IS_CANCELED] = 0
				AND [VT].[TASK_TYPE] = 'TAREA_PICKING'
			GROUP BY
				ISNULL(DATEDIFF(MINUTE, [VT].[ACCEPTED_DATE],
								[VT].[PICKING_FINISHED_DATE]),
						0)
				,ISNULL([VT].[IS_FROM_ERP], 0)
				,ISNULL([VT].[IS_FROM_SONDA], 0)
				,CAST([VT].[NO_DOC] AS VARCHAR)
				,[VT].[WAVE_PICKING_ID]
				,[VT].[CLIENT_NAME]
				,[VT].[TASK_TYPE]
				,[VT].[TASK_SUBTYPE]
				,[VT].[TASK_ASSIGNEDTO]
				,[VT].[TASK_COMMENTS]
				,[VT].[REGIMEN]
				,[VT].[IS_PAUSED]
				,[VT].[SERIAL_NUMBER]
				,[VT].[ASSIGNED_DATE]
				,[VT].[ACCEPTED_DATE]
				,[VT].[PICKING_FINISHED_DATE]
				,[VT].[IS_CANCELED]
				,[VT].[NUMERO_ORDEN_SOURCE]
				,[VT].[NUMERO_ORDEN_TARGET]
				,[VT].[IS_COMPLETED]
				,[VT].[CODIGO_POLIZA_SOURCE]
				,[VT].[CODIGO_POLIZA_TARGET]
				,[VT].[IS_DISCRETIONARY]
				,[VT].[TYPE_PICKING]
				,[VT].[IS_ACCEPTED]
				,[VT].[WMS_DOCUMENT_HEADER_ID]
				,[VT].[DOC_ID]
				,[VT].[ATTEMPTED_WITH_ERROR]
				,[VT].[IS_POSTED_ERP]
				,[VT].[STATUS_POSTED_ERP]
				,[VT].[POSTED_ERP]
				,[VT].[POSTED_RESPONSE]
				,[VT].[ERP_REFERENCE]
				,[VT].[IS_AUTHORIZED]
				,[VT].[CODE_ROUTE]
				,[VT].[USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[VT].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,[VT].[SOURCE_TYPE]
				,[VT].[MATERIAL_ID]
				,[M].[MATERIAL_NAME]
			UNION

		 -- ------------------------------------------------------------------------------------
		 -- Tareas de Conteo Fisico
		 -- ------------------------------------------------------------------------------------
			SELECT DISTINCT
				[T].[TASK_ID]
				,NULL AS [WAVE_PICKING_ID]
				,NULL AS [CLIENT_NAME]
				,[T].[TASK_TYPE]
				,NULL AS [TASK_SUBTYPE]
				,[T].[TASK_ASSIGNED_TO] AS [TASK_ASSIGNEDTO]
				,'TAREA DE CONTEO #'
				+ CAST([T].[TASK_ID] AS VARCHAR) AS [TASK_COMMENTS]
				,[T].[REGIMEN]
				,[T].[IS_PAUSED]
				,[T].[TASK_ID] AS [SERIAL_NUMBER]
				,[T].[ASSIGNED_DATE]
				,[T].[ACCEPTED_DATE]
				,[T].[COMPLETED_DATE] AS [PICKING_FINISHED_DATE]
				,[T].[IS_CANCELED]
				,NULL AS [QUANTITY_PENDING]
				,NULL AS [QUANTITY_ASSIGNED]
				,NULL AS [NUMERO_ORDEN_SOURCE]
				,NULL AS [NUMERO_ORDEN_TARGET]
				,(CASE [T].[IS_COMPLETE]
					WHEN 0 THEN CASE [T].[IS_ACCEPTED]
									WHEN 0 THEN 'INCOMPLETA'
									WHEN 1 THEN 'EN PROCESO'
								END
					ELSE 'COMPLETA'
					END) AS [IS_COMPLETED]
				,NULL AS [CODIGO_POLIZA_SOURCE]
				,NULL AS [CODIGO_POLIZA_TARGET]
				,NULL AS [IS_DISCRETIONARY]
				,NULL AS [TYPE_PICKING]
				,[T].[IS_ACCEPTED]
				,ISNULL(DATEDIFF(MINUTE, [T].[ACCEPTED_DATE],
									[T].[COMPLETED_DATE]), 0) AS [TIME]
				,NULL AS [IS_FROM_ERP]
				,NULL AS [IS_FROM_SONDA]
				,NULL AS [NO_DOC]
				,NULL AS [WMS_DOCUMENT_HEADER_ID]
				,NULL AS [DOC_ID]
				,NULL AS [ATTEMPTED_WITH_ERROR]
				,NULL AS [IS_POSTED_ERP]
				,NULL AS [STATUS_POSTED_ERP]
				,NULL AS [POSTED_ERP]
				,NULL AS [POSTED_RESPONSE]
				,NULL AS [ERP_REFERENCE]
				,NULL [IS_AUTHORIZED]
				,NULL AS [MAX_ATTEMPTS]
				,NULL [LOCATION_SPOT_TARGET]
				,NULL AS [CODE_ROUTE]
				,NULL AS [USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[T].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,NULL AS [SOURCE_TYPE]
				,NULL AS [MATERIAL_ID]
				,NULL AS [MATERIAL_NAME]
				,NULL AS [QUANTITY_ASSIGNED_TASK]
			FROM
				[wms].[OP_WMS_TASK] [T]
			INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [CH] ON [T].[TASK_ID] = [CH].[TASK_ID]
			INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [CD] ON [CH].[PHYSICAL_COUNT_HEADER_ID] = [CD].[PHYSICAL_COUNT_HEADER_ID]
			INNER JOIN [#USERS] [U] ON ([U].[login] = [CD].[ASSIGNED_TO])
			LEFT JOIN @TB_PRIORITY [P] ON [P].[PRIORITY] = [T].[PRIORITY]
			WHERE
				[T].[ASSIGNED_DATE] BETWEEN @START_DATETIME
									AND		@END_DATETIME
				AND [T].[IS_CANCELED] = 0
				AND [T].[TASK_TYPE] = 'TAREA_CONTEO_FISICO'
			UNION

		 -- ------------------------------------------------------------------------------------
		 -- Tareas de Reubicacion
		 -- ------------------------------------------------------------------------------------
			SELECT DISTINCT
				NULL AS [TASK_ID]
				,[VT].[WAVE_PICKING_ID]
				,[VT].[CLIENT_NAME]
				,[VT].[TASK_TYPE]
				,[VT].[TASK_SUBTYPE]
				,[VT].[TASK_ASSIGNEDTO]
				,[VT].[TASK_COMMENTS]
				,[VT].[REGIMEN]
				,[VT].[IS_PAUSED]
				,[VT].[SERIAL_NUMBER]
				,[VT].[ASSIGNED_DATE]
				,[VT].[ACCEPTED_DATE]
				,[VT].[PICKING_FINISHED_DATE]
				,[VT].[IS_CANCELED]
				,[VT].[QUANTITY_PENDING]
				,[VT].[QUANTITY_ASSIGNED]
				,[VT].[NUMERO_ORDEN_SOURCE]
				,[VT].[NUMERO_ORDEN_TARGET]
				,[VT].[IS_COMPLETED]
				,[VT].[CODIGO_POLIZA_SOURCE]
				,[VT].[CODIGO_POLIZA_TARGET]
				,[VT].[IS_DISCRETIONARY]
				,[VT].[TYPE_PICKING]
				,[VT].[IS_ACCEPTED]
				,ISNULL(DATEDIFF(MINUTE,
									[VT].[ACCEPTED_DATE],
									[VT].[PICKING_FINISHED_DATE]),
						0) AS [TIME]
				,ISNULL([VT].[IS_FROM_ERP], 0) [IS_FROM_ERP]
				,ISNULL([VT].[IS_FROM_SONDA], 0) [IS_FROM_SONDA]
				,NULL AS [NO_DOC]
				,NULL AS [WMS_DOCUMENT_HEADER_ID]
				,NULL AS [DOC_ID]
				,0 AS [ATTEMPTED_WITH_ERROR]
				,NULL AS [IS_POSTED_ERP]
				,NULL AS [STATUS_POSTED_ERP]
				,NULL AS [POSTED_ERP]
				,NULL AS [POSTED_RESPONSE]
				,NULL AS [ERP_REFERENCE]
				,NULL [IS_AUTHORIZED]
				,@MAX_ATTEMPTS AS [MAX_ATTEMPTS]
				,'' [LOCATION_SPOT_TARGET]
				,NULL AS [CODE_ROUTE]
				,NULL AS [USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[VT].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,[VT].[SOURCE_TYPE]
				,[VT].[MATERIAL_ID]
				,[M].[MATERIAL_NAME]
				,[VT].[QUANTITY_ASSIGNED] [QUANTITY_ASSIGNED_TASK]
			FROM
				[wms].[OP_WMS_VIEW_TASK_REALLOC_HEADER_DETAILED] [VT]
			INNER JOIN @TB_WAREHOUSE [W] ON ([W].[WAREHOUSE_ID] = [VT].[WAREHOUSE_SOURCE])
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [VT].[MATERIAL_ID]
			INNER JOIN [#CLASS] [C] ON [C].[CLASS_ID] = CAST([M].[MATERIAL_CLASS] AS INT)
			LEFT JOIN [#USERS] [U] ON [U].[login] = [VT].[TASK_ASSIGNEDTO]
			LEFT JOIN @TB_PRIORITY [P] ON [VT].[PRIORITY] = [P].[PRIORITY]
			WHERE
				[VT].[ASSIGNED_DATE] BETWEEN @START_DATETIME
										AND	@END_DATETIME
				AND (
						@USERS IS NULL
						OR [U].[login] IS NOT NULL
					)
				AND [VT].[TASK_TYPE] = 'TAREA_REUBICACION'
				AND [VT].[IS_CANCELED] = 0) AS [T];

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT
		[R].[TASK_ID]
		,[R].[WAVE_PICKING_ID]
		,[R].[CLIENT_NAME]
		,[R].[TASK_TYPE]
		,[R].[TASK_SUBTYPE]
		,[R].[TASK_ASSIGNEDTO]
		,[R].[TASK_COMMENTS]
		,[R].[REGIMEN]
		,[R].[IS_PAUSED]
		,CASE [R].[IS_PAUSED]
			WHEN 0 THEN 'NO'
			WHEN 1 THEN 'SI'
			END [IS_PAUSED_DESCRIPTION]
		,[R].[SERIAL_NUMBER]
		,[R].[ASSIGNED_DATE]
		,[R].[ACCEPTED_DATE]
		,[R].[PICKING_FINISHED_DATE]
		,[R].[IS_CANCELED]
		,[R].[QUANTITY_PENDING]
		,[R].[QUANTITY_ASSIGNED]
		,[R].[NUMERO_ORDEN_SOURCE]
		,[R].[NUMERO_ORDEN_TARGET]
		,[R].[IS_COMPLETED]
		,[R].[CODIGO_POLIZA_SOURCE]
		,[R].[CODIGO_POLIZA_TARGET]
		,CAST([R].[IS_DISCRETIONARY] AS INT) [IS_DISCRETIONARY]
		,[R].[TYPE_PICKING]
		,[R].[IS_ACCEPTED]
		,[R].[TIME]
		,[R].[IS_FROM_ERP]
		,[R].[IS_FROM_SONDA]
		,[R].[WMS_DOCUMENT_HEADER_ID]
		,[R].[DOC_ID]
		,[R].[ATTEMPTED_WITH_ERROR]
		,[R].[IS_POSTED_ERP]
		,[R].[STATUS_POSTED_ERP]
		,[R].[POSTED_ERP]
		,[R].[POSTED_RESPONSE]
		,[R].[ERP_REFERENCE]
		,[R].[IS_AUTHORIZED]
		,CASE [R].[IS_AUTHORIZED]
			WHEN 0 THEN 'NO'
			WHEN 1 THEN 'SI'
			END [IS_AUTHORIZED_DESCRIPTION]
		,[R].[MAX_ATTEMPTS]
		,[R].[LOCATION_SPOT_TARGET]
		,[R].[USE_PICKING_LINE]
		,[R].[LOGIN_NAME]
		,[R].[PRIORITY]
		,[R].[PRIORITY_DESCRIPTION]
		,[R].[SOURCE_TYPE]
		,[R].[MATERIAL_ID]
		,[R].[MATERIAL_NAME]
		,[R].[QUANTITY_ASSIGNED_TASK]
		,[R].[NO_DOC]
	FROM
		[#RESULT] [R]
	LEFT JOIN [#TYPES] [T] ON [R].[TASK_TYPE] = [T].[TYPE]
	WHERE
		(
			@TYPES IS NULL
			OR [T].[TYPE] IS NOT NULL
		);


END;