-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-03 @ Team ERGON - Sprint ERGON II
-- Description:	 

-- Modificacion:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-22 @ Team ERGON - Sprint ERGON III
-- Description:	        Se agregaron tareas de conteo

-- Modificacion:	              rudi.garcia
-- Fecha de Creacion: 	2017-04-20 @ Team ERGON - Sprint epona
-- Description:	        Se agrego '|Multiple|Sin Asignación|'


-- Modificación: pablo.aguilar
-- Fecha de Modificaci[on: 2017-05-04 ErgonTeam@Ganondorf
-- Description:	 Se agrega tarea de reubicación


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-18 Nexus@AgeOfEmpires
-- Description:	 Se agrega el nombre del login 

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
-- pablo.aguilar
-- Se agrega join a documento de picking para authorizar tareas de picking. 

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	28-Nov-17 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego columna [PRIORITY]  

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
-- rodrigo.gomez
-- Se agrega filtro de clases de productos

-- Modificacion 1/26/2018 @ REBORN-Team Sprint Trotzdem
-- rodrigo.gomez
-- Se agrega columna de task_priority y priority_description

-- Modificacion 10-Jul-19 @  G-FORCE Team Sprint Dublin 
-- pablo.aguilar
-- Se modificá para utilizar docnum, doc_entry y erp_doc como varchar

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyectos

--Creado/Modificado por Diego E.	Mayo 25 - 2020
--Hola de Picking, obtener el numero de las Tareas de Recepcion del comentario

/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_GET_TASK_BASIC_VIEW] 
		@START_DATETIME = '2017-05-03 01:00:00',
		@END_DATETIME = '2017-05-04 23:59:00',
		@USERS = 'ACAMACHO|BCORADO|EDGARC|AREYES',
		@TYPES = 'TAREA_PICKING|TAREA_ACUSE_RECIBO|TAREA_REUBICACION|TAREA_REABASTECIMIENTO|TAREA_ALMACENAJE|TAREA_REUBICACION|TAREA_RECEPCION|TAREA_CONTEO_FISICO',
		@LOGIN = 'ADMIN';

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_TASK_BASIC_VIEW_DEM] (
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
  -- Obtiene las ubicaciones de destino de las tareas de recepcion
  -- ------------------------------------------------------------------------------------
	SELECT
		[TL].[SERIAL_NUMBER]
		,CASE	WHEN MAX([T].[TARGET_LOCATION]) IS NULL
				THEN ''
				WHEN MAX([T].[TARGET_LOCATION]) <> MIN([T].[TARGET_LOCATION])
				THEN 'Multiple'
				WHEN MAX([T].[TARGET_LOCATION]) = MIN([T].[TARGET_LOCATION])
				THEN MAX([T].[TARGET_LOCATION])
			END [LOCATION_SPOT_TARGET]
	INTO
		[#LOCATION_TARGET_RECEPTION]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	LEFT JOIN [wms].[OP_WMS_TRANS] [T] ON [TL].[SERIAL_NUMBER] = [T].[TASK_ID]
											AND [T].[STATUS] = 'PROCESSED'
											AND [T].[TRANS_TYPE] = 'INGRESO_GENERAL'
											AND [T].[TRANS_DATE] BETWEEN GETDATE()
											- 30
											AND
											GETDATE()
	WHERE
		[TL].[ASSIGNED_DATE] BETWEEN @START_DATETIME
								AND		@END_DATETIME
		AND [TL].[IS_CANCELED] = 0
		AND [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
	GROUP BY
		[TL].[SERIAL_NUMBER];


  -- ------------------------------------------------------------------------------------
  -- Obtiene las bodegas destino de las reubicaciones
  -- ------------------------------------------------------------------------------------
	SELECT
		[TL].[WAVE_PICKING_ID]
		,CASE	WHEN MAX([TL].[TASK_SUBTYPE]) <> 'ENTREGA_NO_INMEDIATA'
				THEN CASE	WHEN MAX([TL].[LOCATION_SPOT_TARGET]) <> MIN([TL].[LOCATION_SPOT_TARGET])
							THEN 'Multiple'
							WHEN MAX([TL].[LOCATION_SPOT_TARGET]) = MIN([TL].[LOCATION_SPOT_TARGET])
							THEN MAX([TL].[LOCATION_SPOT_TARGET])
						END
				WHEN MAX([L].[CURRENT_LOCATION]) IS NULL
				THEN ''
				WHEN MAX([L].[CURRENT_LOCATION]) <> MIN([L].[CURRENT_LOCATION])
				THEN 'Multiple'
				WHEN MAX([L].[CURRENT_LOCATION]) = MIN([L].[CURRENT_LOCATION])
				THEN MAX([L].[CURRENT_LOCATION])
			END [LOCATION_SPOT_TARGET]
	INTO
		[#LOCATION_TARGET_REALOC]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
	LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON [DH].[PICKING_DEMAND_HEADER_ID] = [L].[PICKING_DEMAND_HEADER_ID]
	WHERE
		[TL].[ASSIGNED_DATE] BETWEEN GETDATE() - 30
								AND		GETDATE()
		AND [TL].[IS_CANCELED] = 0
		AND [TL].[TASK_TYPE] = 'TAREA_REUBICACION'
	GROUP BY
		[TL].[WAVE_PICKING_ID];

  -- ------------------------------------------------------------------------------------
  -- Obtiene las bodegas destino de los pickings
  -- ------------------------------------------------------------------------------------
	SELECT
		[WAVE_PICKING_ID]
		,CASE	WHEN ISNULL(MAX([TH].[TRANSFER_REQUEST_ID]),
							0) <> 0
				THEN MAX([TH].[WAREHOUSE_TO])
				WHEN MAX([TL].[LOCATION_SPOT_TARGET]) <> MIN([TL].[LOCATION_SPOT_TARGET])
				THEN 'Multiple'
				WHEN MAX([TL].[LOCATION_SPOT_TARGET]) = MIN([TL].[LOCATION_SPOT_TARGET])
				THEN MAX([TL].[LOCATION_SPOT_TARGET])
			END [LOCATION_SPOT_TARGET]
	INTO
		[#LOCATION_TARGET_PICKING]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH] ON [TH].[TRANSFER_REQUEST_ID] = [TL].[TRANSFER_REQUEST_ID]
	WHERE
		[TASK_TYPE] = 'TAREA_PICKING'
		AND [ASSIGNED_DATE] BETWEEN @START_DATETIME
							AND		@END_DATETIME
		AND [IS_CANCELED] = 0
	GROUP BY
		[TL].[WAVE_PICKING_ID];

  -- ------------------------------------------------------------------------------------
  -- obtengo el parametro de autorizacion
  -- ------------------------------------------------------------------------------------
	DECLARE	@AUTORIZACION_ENVIO_ERP_TRASLADO VARCHAR(1);
	SELECT TOP 1
		@AUTORIZACION_ENVIO_ERP_TRASLADO = [VALUE]
	FROM
		[wms].[OP_WMS_PARAMETER]
	WHERE
		[PARAMETER_ID] = 'AUTORIZACION_ENVIO_ERP_TRASLADO';

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
				,[VT].[CLIENT_OWNER]
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
				,CAST([RDH].[DOC_NUM] AS VARCHAR) AS [DOC_ID]
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
				,[LTR].[LOCATION_SPOT_TARGET]
				,NULL AS [CODE_ROUTE]
				,NULL AS [USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[VT].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,NULL AS [SOURCE_TYPE]
				,[VT].[CREATE_BY]
				,[VT].[NUMERO_ORDEN_SOURCE] AS [ORDER_NUMBER]
				,[VT].[PROJECT_ID]
				,[VT].[PROJECT_CODE]
				,[VT].[PROJECT_NAME]
				,[VT].[PROJECT_SHORT_NAME]
			FROM
				[wms].[OP_WMS_VIEW_TASK] [VT]
			INNER JOIN [#LOCATION_TARGET_RECEPTION] [LTR] ON [LTR].[SERIAL_NUMBER] = [VT].[SERIAL_NUMBER]
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
				,[T].[CLIENT_OWNER]
				,[VT].[TASK_TYPE]
				,CASE	WHEN [VT].[TASK_SUBTYPE] = 'DESPACHO_WT'
						THEN 'PICKING_WT'
						WHEN [VT].[TASK_SUBTYPE] = 'DESPACHO_GENERAL'
								AND [PDH].[PICKING_DEMAND_HEADER_ID] IS NOT NULL
						THEN 'PICKING' + ISNULL(' - '
											+ [PDH].[TYPE_DEMAND_NAME],
											'')
						WHEN [VT].[TASK_SUBTYPE] = 'DESPACHO_CONSOLIDADO'
						THEN 'PICKING' + ISNULL(' - '
											+ [PDH].[TYPE_DEMAND_NAME],
											'')
						ELSE [VT].[TASK_SUBTYPE]
								+ ISNULL(' - '
											+ [PDH].[TYPE_DEMAND_NAME],
											'')
					END [TASK_SUBTYPE]
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
				,ISNULL(CAST([PDH].[DOC_NUM] AS VARCHAR),
						[PD].[WAVE_PICKING_ID]) AS [NO_DOC]
				,ISNULL([PDH].[PICKING_DEMAND_HEADER_ID],
						[PD].[PICKING_ERP_DOCUMENT_ID]) [WMS_DOCUMENT_HEADER_ID]
				,ISNULL(CASE	WHEN [PDH].[SOURCE_TYPE] = 'WT - ERP'
								THEN CAST([PDH].[DOC_NUM_SEQUENCE] AS VARCHAR)
								ELSE CAST([PDH].[DOC_NUM] AS VARCHAR)
						END, [T].[WAVE_PICKING_ID]) [DOC_ID]
				,ISNULL([PDH].[ATTEMPTED_WITH_ERROR],
						[PD].[ATTEMPTED_WITH_ERROR]) [ATTEMPTED_WITH_ERROR]
				,COALESCE([PDH].[IS_POSTED_ERP],
							[PD].[IS_POSTED_ERP], 0) [IS_POSTED_ERP]
				,CASE	WHEN COALESCE([PDH].[IS_POSTED_ERP],
										[PD].[IS_POSTED_ERP],
										0) = -1
						THEN 'Fallido'
						WHEN COALESCE([PDH].[IS_POSTED_ERP],
										[PD].[IS_POSTED_ERP],
										0) = 0
								AND ISNULL([PDH].[IS_AUTHORIZED],
											0) = 1
						THEN 'Autorizada'
						WHEN COALESCE([PDH].[IS_POSTED_ERP],
										[PD].[IS_POSTED_ERP],
										0) = 0
								AND COALESCE([PDH].[IS_AUTHORIZED],
											[PD].[IS_AUTHORIZED],
											0) = 0
						THEN 'Pendiente de Autorización'
						WHEN COALESCE([PDH].[IS_POSTED_ERP],
										[PD].[IS_POSTED_ERP],
										0) = 1
						THEN 'Enviado'
					END [STATUS_POSTED_ERP]
				,ISNULL([PDH].[POSTED_ERP],
						[PD].[POSTED_ERP]) [POSTED_ERP]
				,ISNULL([PDH].[POSTED_RESPONSE],
						[PD].[POSTED_RESPONSE]) [POSTED_RESPONSE]
				,ISNULL([PDH].[ERP_REFERENCE_DOC_NUM],
						[PD].[ERP_REFERENCE_DOC_NUM]) AS [ERP_REFERENCE]
				,COALESCE([PDH].[IS_AUTHORIZED],
							[PD].[IS_AUTHORIZED], 0) [IS_AUTHORIZED]
				,@MAX_ATTEMPTS AS [MAX_ATTEMPTS]
				,[LTP].[LOCATION_SPOT_TARGET]
				,[PDH].[CODE_ROUTE]
				,CASE	WHEN (
								[W].[USE_PICKING_LINE] = 1
								AND (
										[PDH].[IS_FROM_ERP] = 1
										OR [PDH].[IS_FROM_SONDA] = 1
									)
								) THEN 1
						ELSE 0
					END AS [USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,[VT].[PRIORITY]
				,[P].[PRIORITY_DESCRIPTION]
				,[PDH].[DEMAND_TYPE] AS [SOURCE_TYPE]
				,[VT].[CREATE_BY]
				,CASE	WHEN [PDH].[PICKING_DEMAND_HEADER_ID] IS NULL
						THEN [VT].[NUMERO_ORDEN_TARGET]
						ELSE [VT].[ORDER_NUMBER]
					END AS [ORDER_NUMBER]
				,[VT].[PROJECT_ID]
				,[VT].[PROJECT_CODE]
				,[VT].[PROJECT_NAME]
				,[VT].[PROJECT_SHORT_NAME]
			FROM
				[wms].[OP_WMS_VIEW_TASK_PICKING_HEADER] [VT]
			INNER JOIN @TB_WAREHOUSE [W] ON ([W].[WAREHOUSE_ID] = [VT].[WAREHOUSE_SOURCE])
			INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [VT].[WAVE_PICKING_ID]
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
			INNER JOIN [#CLASS] [C] ON [C].[CLASS_ID] = CAST([M].[MATERIAL_CLASS] AS INT)
			INNER JOIN [#LOCATION_TARGET_PICKING] [LTP] ON [LTP].[WAVE_PICKING_ID] = [VT].[WAVE_PICKING_ID]
			LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON ([VT].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID])
			LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON ([PDH].[TRANSFER_REQUEST_ID] = [TRH].[TRANSFER_REQUEST_ID])
			LEFT JOIN [wms].[OP_WMS_PICKING_ERP_DOCUMENT] [PD] ON [PD].[WAVE_PICKING_ID] = [VT].[WAVE_PICKING_ID]
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
			UNION

    -- ------------------------------------------------------------------------------------
    -- Tareas de Conteo Fisico
    -- ------------------------------------------------------------------------------------
			SELECT DISTINCT
				[T].[TASK_ID]
				,[T].[TASK_ID] AS [WAVE_PICKING_ID]
				,NULL AS [CLIENT_NAME]
				,NULL AS [CLIENT_OWNER]
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
				,[T].[CREATE_BY]
				,NULL AS [ORDER_NUMBER]
				,NULL AS [PROJECT_ID]
				,NULL AS [PROJECT_CODE]
				,NULL AS [PROJECT_NAME]
				,NULL AS [PROJECT_SHORT_NAME]
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
				,[T].[CLIENT_OWNER]
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
				,[LTR].[LOCATION_SPOT_TARGET] [LOCATION_SPOT_TARGET]
				,NULL AS [CODE_ROUTE]
				,NULL AS [USE_PICKING_LINE]
				,[U].[LOGIN_NAME]
				,0 [PRIORITY]
				,'Baja' [PRIORITY_DESCRIPTION]
				,NULL AS [SOURCE_TYPE]
				,[VT].[CREATE_BY]
				,[VT].[ORDER_NUMBER]
				,[VT].[PROJECT_ID]
				,[VT].[PROJECT_CODE]
				,[VT].[PROJECT_NAME]
				,[VT].[PROJECT_SHORT_NAME]
			FROM
				[wms].[OP_WMS_VIEW_TASK_REALLOC_HEADER] [VT]
			INNER JOIN @TB_WAREHOUSE [W] ON ([W].[WAREHOUSE_ID] = [VT].[WAREHOUSE_SOURCE])
			INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [VT].[WAVE_PICKING_ID]
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
			INNER JOIN [#CLASS] [C] ON [C].[CLASS_ID] = CAST([M].[MATERIAL_CLASS] AS INT)
			INNER JOIN [#LOCATION_TARGET_REALOC] [LTR] ON [LTR].[WAVE_PICKING_ID] = [VT].[WAVE_PICKING_ID]
			LEFT JOIN [#USERS] [U] ON [U].[login] = [VT].[TASK_ASSIGNEDTO]
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
		,WAVE_PICKING_ID = ISNULL([R].[WAVE_PICKING_ID], REPLACE([R].[TASK_COMMENTS], 'TAREA DE RECEPCION NO. ', ''))
		,[R].[CLIENT_NAME]
		,[R].[CLIENT_OWNER]
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
		,CASE	WHEN [R].[IS_POSTED_ERP] = 1 THEN 'ENVIADA'
				WHEN [R].[IS_AUTHORIZED] = 0 THEN 'NO'
				WHEN [R].[IS_AUTHORIZED] = 1 THEN 'SI'
			END [IS_AUTHORIZED_DESCRIPTION]
		,[R].[MAX_ATTEMPTS]
		,[R].[LOCATION_SPOT_TARGET]
		,[R].[USE_PICKING_LINE]
		,[R].[LOGIN_NAME]
		,[R].[PRIORITY]
		,[R].[PRIORITY_DESCRIPTION]
		,[R].[SOURCE_TYPE]
		,[R].[CREATE_BY]
		,@AUTORIZACION_ENVIO_ERP_TRASLADO [AUTORIZACION_ENVIO_ERP_TRASLADO]
		,[R].[ORDER_NUMBER]
		,[R].[PROJECT_ID]
		,[R].[PROJECT_CODE]
		,[R].[PROJECT_NAME]
		,[R].[PROJECT_SHORT_NAME]
	FROM
		[#RESULT] [R]
	LEFT JOIN [#TYPES] [T] ON [R].[TASK_TYPE] = [T].[TYPE]
	WHERE
		(
			@TYPES IS NULL
			OR [T].[TYPE] IS NOT NULL
		);

END;