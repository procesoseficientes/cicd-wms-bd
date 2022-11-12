-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		21-Aug-2018 G-Force@Humana
-- Description:			    Sp que registra el despacho genereal

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181010 GForce@Langosta
-- Description:	        se modifica para que cuando tenga que buscar licencia tome en cuenta el operador.

-- Modificacion 10-Jul-19 @  G-FORCE Team Sprint Dublin 
					-- pablo.aguilar
					-- Se modificá para detener ejecución en caso ya este operada la linea. 

-- Modificacion:		henry.rodriguez
-- Fecha:				18-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrega validacion cuando maneja proyecto, rebaja el inventario reservado del material
--						se agregaron los campos Project_id, Project_code, project_name y Project_short_name en tabla OP_WMS_TRANS

-- Modificacion:		henry.rodriguez
-- Fecha:				25-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrega validacion cuando se cambia la licencia de picking y maneja proyecto, inserta log de inventario reservado..

-- Modificacion:		marvin.solares
-- Fecha:				06-Ago-2019 G-Force@Dublin
-- Bug 31091: No muestra los movimientos en el proyectos realizados desde la demanda de despacho en otra bodega.
-- Descripcion:			Se resuelve bug de escenario cuando licencia no esta amarrada al proyecto al crear la demanda de despacho

-- Modificacion:		henry.rodriguez
-- Fecha:				09-Agosto-2019 G-Force@Estambul
-- Bug 31212: no se logra crear manifiesto
-- Descripcion:			Se agrega validacion cuando es un picking maneja proyecto y la licencia no tiene asociado un proyecto.

-- Modificacion:		marvin.solares
-- Fecha:				13-Agosto-2019 G-Force@FlorencioVarela
-- Bug 31375:			Al momento de despachar licencia que no estan en el proyecto se duplican
-- Descripcion:			Se corrige bug que duplica el registro insertado en el inventario reservado para el proyecto

-- Modificacion:		Elder Lucas
-- Fecha:				19-Mayo-2021
-- Descripcion:			Se agrega validación de estado de material para la Task list al momento de ingresar, manejo de estados en cambios de licencia

-- Modificacion:		Elder Lucas
-- Fecha:				6 de octubre 2022
-- Descripcion:			Se agrega campo de DOC_ID_SOURCE a la TASK_LIST para usarse en el envio de ordenes consolidadas a SAE

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_DISPATCH_BY_REGIME_GENERAL_OLD] (
		@pLOGIN_ID VARCHAR(25)
		,@pCLIENT_OWNER VARCHAR(25)
		,@pMATERIAL_ID VARCHAR(50)
		,@pMATERIAL_BARCODE VARCHAR(25)
		,@pSOURCE_LICENSE NUMERIC(18, 0)
		,@pSOURCE_LOCATION VARCHAR(25)
		,@pQUANTITY_UNITS NUMERIC(18, 4)
		,@pCODIGO_POLIZA VARCHAR(25)
		,@pWAVE_PICKING_ID NUMERIC(18, 0)
		,@pSERIAL_NUMBER NUMERIC(18, 0)
		,@pTipoUbicacion VARCHAR(25)
		,@pMt2 NUMERIC(18, 2)
		,@pRESULT VARCHAR(300) OUTPUT
		,@pTASK_ID NUMERIC(18, 0) = NULL
		,@LICENSE_DISPATCH_ID INT = 0
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@ErrorCode INT
		,@pTASK_IS_PAUSED INT
		,@pTASK_IS_CANCELED INT
		,@pSKUQtyPending NUMERIC(18, 0)
		,@pMATERIAL_ID_LOCAL VARCHAR(50)
		,@pCLIENT_ID_LOCAL VARCHAR(50)
		,@CLIENT_NAME VARCHAR(100)
		,@pINV_AVAILABLE NUMERIC(18, 4)
		,@IS_FROM_SONDA INT
		,@BATCH VARCHAR(50)
		,@DATE_EXPIRATION DATETIME
		,@HANDLE_SERIAL INT
		,@IS_MASTER_PACK INT
		,@TERMS_OF_TRADE VARCHAR(50)
		,@LOGIN_NAME VARCHAR(50)
		,@WAREHOUSE_PARENT VARCHAR(50)
		,@SOURCE_TYPE VARCHAR(50)
		,@TRANSFER_REQUEST_ID INT
		,@TRANS_SUBTYPE VARCHAR(50)
		,@QTY_AVAILABLE_NEW_LICENSE NUMERIC(18, 4)
		,@HANDLE_BATCH INT
		,@ALTERNATE_BARCODE VARCHAR(25)
		,@MATERIAL_NAME VARCHAR(200)
		,@UPDATE_LICENSE INT = 0
		,@VIN VARCHAR(40)
		,@PROJECT_ID_LICENSE UNIQUEIDENTIFIER = NULL
		,@PROJECT_CODE VARCHAR(50)
		,@PROJECT_NAME VARCHAR(150)
		,@PROJECT_SHORT_NAME VARCHAR(25)
		,@CLIENT_CODE VARCHAR(25)
		,@PK_LINE INTEGER
		,@QTY_LICENSE NUMERIC(18, 4)
		,@pSTATUS_CODE VARCHAR(100)
		,@LICENSE_BELONG_TO_WAVE_PICKING AS INT = 1
		,@PROJECT_ID_TASK UNIQUEIDENTIFIER = NULL;

	DECLARE	@AVAILABLE_PICKING_LICENSE TABLE (
			[LICENSE_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[QTY_AVAILABLE] DECIMAL(38, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[SPOT_TYPE] VARCHAR(25)
			,[USED_MT2] NUMERIC(18, 2)
			,[TASK_SUBTYPE] VARCHAR(25)
			,[IS_DISCRETIONARY] INT
			,[QUANTITY_PENDING] NUMERIC(18, 4)
			,[SERIAL_NUMBER_REQUESTS] NUMERIC
		);

	BEGIN TRY
		BEGIN TRANSACTION;

    ---------------------------------------------------------------------------------
    -- ASIGNA VALORES A VARIABLES 
    ---------------------------------------------------------------------------------
		if(@pLOGIN_ID is not null) return;

		SELECT TOP 1
			@LOGIN_NAME = [D].[LOGIN_NAME]
		FROM
			[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID) [D];


		SELECT TOP 1
			@pCLIENT_ID_LOCAL = [L].[CLIENT_OWNER]
			,@CLIENT_NAME = [C].[CLIENT_NAME]
			,@CLIENT_CODE = [C].[CLIENT_CODE]
		FROM
			[wms].[OP_WMS_LICENSES] [L]
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [C].[CLIENT_CODE] = [L].[CLIENT_OWNER]
		WHERE
			[L].[LICENSE_ID] = @pSOURCE_LICENSE;

		SELECT TOP 1
			@pMATERIAL_ID_LOCAL = [MATERIAL_ID]
			,@HANDLE_SERIAL = ISNULL([M].[SERIAL_NUMBER_REQUESTS],
										0)
			,@IS_MASTER_PACK = ISNULL([M].[IS_MASTER_PACK],
										0)
			,@HANDLE_BATCH = ISNULL([M].[BATCH_REQUESTED], 0)
			,@ALTERNATE_BARCODE = [M].[ALTERNATE_BARCODE]
			,@MATERIAL_NAME = [M].[MATERIAL_NAME]
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		WHERE
			(
				[M].[BARCODE_ID] = @pMATERIAL_BARCODE
				OR [M].[ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
			)
			AND [M].[CLIENT_OWNER] = @pCLIENT_ID_LOCAL;

		SELECT
			@PROJECT_ID_TASK = MAX([TL].[PROJECT_ID])
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
			AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;


		SELECT TOP 1
			@pINV_AVAILABLE = [IL].[QTY]
			,@BATCH = [IL].[BATCH]
			,@DATE_EXPIRATION = [IL].[DATE_EXPIRATION]
			,@TERMS_OF_TRADE = [IL].[TERMS_OF_TRADE]
			,@VIN = [IL].[VIN]
			,@PROJECT_ID_LICENSE = [IL].[PROJECT_ID]
			,@PK_LINE = [IL].[PK_LINE]
			,@QTY_LICENSE = [IL].[QTY]
			,@pSTATUS_CODE = [SML].[STATUS_CODE]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON (
											[IL].[LICENSE_ID] = [SML].[LICENSE_ID]
											AND [IL].[STATUS_ID] = [SML].[STATUS_ID]
											)
		WHERE
			[IL].[LICENSE_ID] = @pSOURCE_LICENSE
			AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

	---------------------------------------------------------------------------------
    -- ASIGNA VALORES DEL PROYECTO, SI MANEJA PROYECTO.
    ---------------------------------------------------------------------------------
	print ('proyecto?')
	IF NOT EXISTS (
		SELECT TOP 1 BARCODE_ID FROM wms.OP_WMS_TASK_LIST
		WHERE WAVE_PICKING_ID = @pWAVE_PICKING_ID AND BARCODE_ID = @pMATERIAL_BARCODE 
		AND MATERIAL_ID = @pMATERIAL_ID
		AND STATUS_CODE = @pSTATUS_CODE
	) BEGIN 
	SELECT
		@pRESULT = 'Error, no se ha encontrado una tarea con los parámetros enviados'
		,@ErrorCode = 233;
		RAISERROR (@pRESULT, 16, 1);
		END;

		IF @PROJECT_ID_LICENSE IS NOT NULL
		BEGIN
			SELECT
				@PROJECT_CODE = [OPPORTUNITY_CODE]
				,@PROJECT_NAME = [OPPORTUNITY_NAME]
				,@PROJECT_SHORT_NAME = [SHORT_NAME]
			FROM
				[wms].[OP_WMS_PROJECT]
			WHERE
				[ID] = @PROJECT_ID_LICENSE;
		END;		

		SELECT TOP 1
			@WAREHOUSE_PARENT = ISNULL([WAREHOUSE_PARENT],
										'BODEGA_DEF')
		FROM
			[wms].[OP_WMS_SHELF_SPOTS]
		WHERE
			[LOCATION_SPOT] = @pSOURCE_LOCATION;


	
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_TASK_LIST] [TL]
						WHERE
							[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
							AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
							AND [TL].[IS_COMPLETED] = 0 )
		BEGIN
			SELECT
				@pRESULT = 'ERROR, Tarea ha sido completada, verifique.'
				,@ErrorCode = 1202;
			RAISERROR (@pRESULT, 16, 1);
		END;


		IF @pQUANTITY_UNITS > (SELECT
									SUM(ISNULL([TL].[QUANTITY_PENDING],
											0))
								FROM
									[wms].[OP_WMS_TASK_LIST] [TL]
								WHERE
									[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
									AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL)
		BEGIN
			SELECT
				@pRESULT = 'ERROR, La cantidad sobrepasa la tarea.'
				,@ErrorCode = 1202;
			RAISERROR (@pRESULT, 16, 1);
		END;

    ---------------------------------------------------------------------------------
    -- Validamos que el producto maneja lote y que no este en la tabla de tareas
    ---------------------------------------------------------------------------------  
		IF (
			NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [TL]
							WHERE
								[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
								AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
								AND [TL].[LICENSE_ID_SOURCE] = @pSOURCE_LICENSE )
			OR EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_TASK_LIST] [TL]
						WHERE
							[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
							AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
							AND [TL].[LICENSE_ID_SOURCE] = @pSOURCE_LICENSE
							AND (
									[TL].[QUANTITY_PENDING] = 0
									OR [TL].[QUANTITY_PENDING] < @pQUANTITY_UNITS
								) )
			)
			--AND @HANDLE_BATCH = 0
		BEGIN
			print ('calidar cantidad:')
      ---------------------------------------------------------------------------------
      -- Obtenemos la cantidad disponible de la licencia
      ---------------------------------------------------------------------------------
			INSERT	INTO @AVAILABLE_PICKING_LICENSE
					(
						[LICENSE_ID]
						,[MATERIAL_ID]
						,[QTY_AVAILABLE]
						,[TONE]
						,[CALIBER]
						,[SPOT_TYPE]
						,[USED_MT2]
						,[TASK_SUBTYPE]
						,[IS_DISCRETIONARY]
						,[QUANTITY_PENDING]
						,[SERIAL_NUMBER_REQUESTS]
					)
					EXEC [wms].[OP_WMS_SP_VALIDATE_IF_PICKING_LICENSE_IS_AVAILABLE] @WAVE_PICKING_ID = @pWAVE_PICKING_ID,
						@CURRENT_LOCATION = @pSOURCE_LOCATION,
						@MATERIAL_ID = @pMATERIAL_ID_LOCAL,
						@LICENSE_ID = @pSOURCE_LICENSE,
						@LOGIN = @pLOGIN_ID;

			SELECT TOP 1
				@QTY_AVAILABLE_NEW_LICENSE = ISNULL([QTY_AVAILABLE],
											0)
			FROM
				@AVAILABLE_PICKING_LICENSE;

      ---------------------------------------------------------------------------------
      -- Validamos si todavia hay inventario disponible
      ---------------------------------------------------------------------------------  
			IF @QTY_AVAILABLE_NEW_LICENSE < @pQUANTITY_UNITS
			BEGIN
				SELECT
					@pRESULT = 'ERROR, Inventario insuficiente['
					+ CONVERT(VARCHAR(20), @QTY_AVAILABLE_NEW_LICENSE)
					+ '] en licencia origen: ['
					+ CONVERT(VARCHAR(20), @pSOURCE_LICENSE)
					+ '] verifique.'
					,@ErrorCode = 1201;
				RAISERROR (@pRESULT, 16, 1);
			END;

			DECLARE
				@QTY_TOTAL NUMERIC(18, 4) = 0
				,@QTY_TOTAL_PENDING NUMERIC(18, 4) = 0;

			SELECT
				@QTY_TOTAL = SUM([TL].[QUANTITY_ASSIGNED])
				,@QTY_TOTAL_PENDING = SUM([TL].[QUANTITY_PENDING])
				,@PROJECT_ID_TASK = MAX([TL].[PROJECT_ID])
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND TL.STATUS_CODE = @pSTATUS_CODE;

      ---------------------------------------------------------------------------------
      -- Validamos que si la licencia esta en la tabla de tareas
      ---------------------------------------------------------------------------------  
			print @pWAVE_PICKING_ID
			print @pMATERIAL_ID_LOCAL
			print @pSOURCE_LICENSE
			IF NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [TL]
							WHERE
								[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
								AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
								AND [TL].[LICENSE_ID_SOURCE] = @pSOURCE_LICENSE )
			BEGIN
				SET @LICENSE_BELONG_TO_WAVE_PICKING = 0;
				SET @UPDATE_LICENSE = 1;
				DECLARE
					@TONE VARCHAR(25)
					,@CALIBER VARCHAR(25);
				SELECT TOP 1
					@TONE = [APL].[TONE]
					,@CALIBER = [APL].[CALIBER]
				FROM
					@AVAILABLE_PICKING_LICENSE [APL];

		---------------------------------------------------------------------------------
		-- OBTIENE EL PROYECTO DE LA TASK_LIST, SI ES UN CAMBIO DE LICENCIA.
		---------------------------------------------------------------------------------
		-- SI EL CAMBIO DE LICENCIA ES DEL MISMO PROYECTO SOLO REBAJA LA CANTIDAD 
		---------------------------------------------------------------------------------
				IF @PROJECT_ID_LICENSE IS NULL
				BEGIN	
					SELECT TOP 1
						@PROJECT_ID_TASK = [PROJECT_ID]
						,@PROJECT_CODE = [PROJECT_CODE]
						,@PROJECT_NAME = [PROJECT_NAME]
						,@PROJECT_SHORT_NAME = [PROJECT_SHORT_NAME]
					FROM
						[wms].[OP_WMS_TASK_LIST]
					WHERE
						[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
						AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;
				END;	
        ---------------------------------------------------------------------------------
        -- Agregamos la licencia a la tarea
        ---------------------------------------------------------------------------------  
				INSERT	INTO [wms].[OP_WMS_TASK_LIST]
						(
							[WAVE_PICKING_ID]
							,[TRANS_OWNER]
							,[TASK_TYPE]
							,[TASK_SUBTYPE]
							,[TASK_OWNER]
							,[TASK_ASSIGNEDTO]
							,[TASK_COMMENTS]
							,[ASSIGNED_DATE]
							,[QUANTITY_PENDING]
							,[QUANTITY_ASSIGNED]
							,[CODIGO_POLIZA_SOURCE]
							,[CODIGO_POLIZA_TARGET]
							,[LICENSE_ID_SOURCE]
							,[REGIMEN]
							,[IS_COMPLETED]
							,[IS_DISCRETIONAL]
							,[IS_PAUSED]
							,[IS_CANCELED]
							,[MATERIAL_ID]
							,[BARCODE_ID]
							,[ALTERNATE_BARCODE]
							,[MATERIAL_NAME]
							,[WAREHOUSE_SOURCE]
							,[WAREHOUSE_TARGET]
							,[LOCATION_SPOT_SOURCE]
							,[LOCATION_SPOT_TARGET]
							,[CLIENT_OWNER]
							,[CLIENT_NAME]
							,[ACCEPTED_DATE]
							,[MATERIAL_SHORT_NAME]
							,[IS_lOCKED]
							,[IS_DISCRETIONARY]
							,[LINE_NUMBER_POLIZA_SOURCE]
							,[LINE_NUMBER_POLIZA_TARGET]
							,[IS_ACCEPTED]
							,[IS_FROM_SONDA]
							,[IS_FROM_ERP]
							,[PRIORITY]
							,[FROM_MASTERPACK]
							,[OWNER]
							,[SOURCE_TYPE]
							,[TONE]
							,[CALIBER]
							,[LICENSE_ID_TARGET]
							,[IN_PICKING_LINE]
							,[STATUS_CODE]
							,[PROJECT_ID]
							,[PROJECT_CODE]
							,[PROJECT_NAME]
							,[PROJECT_SHORT_NAME]
							,[DOC_ID_SOURCE]
						)
				SELECT TOP 1
					[TL].[WAVE_PICKING_ID]
					,[TL].[TRANS_OWNER]
					,[TL].[TASK_TYPE]
					,[TL].[TASK_SUBTYPE]
					,[TL].[TASK_OWNER]
					,@pLOGIN_ID
					,[TL].[TASK_COMMENTS]
					,[TL].[ASSIGNED_DATE]
					,@pQUANTITY_UNITS
					,@pQUANTITY_UNITS
					,@pCODIGO_POLIZA
					,[TL].[CODIGO_POLIZA_TARGET]
					,@pSOURCE_LICENSE
					,[TL].[REGIMEN]
					,0
					,1
					,0
					,0
					,@pMATERIAL_ID_LOCAL
					,@pMATERIAL_BARCODE
					,@ALTERNATE_BARCODE
					,@MATERIAL_NAME
					,@WAREHOUSE_PARENT
					,[TL].[WAREHOUSE_TARGET]
					,@pSOURCE_LOCATION
					,[TL].[LOCATION_SPOT_TARGET]
					,@pCLIENT_ID_LOCAL
					,@CLIENT_NAME
					,[TL].[ACCEPTED_DATE]
					,@MATERIAL_NAME
					,[TL].[IS_lOCKED]
					,[TL].[IS_DISCRETIONARY]
					,[TL].[LINE_NUMBER_POLIZA_SOURCE]
					,[TL].[LINE_NUMBER_POLIZA_TARGET]
					,[TL].[IS_ACCEPTED]
					,[TL].[IS_FROM_SONDA]
					,[TL].[IS_FROM_ERP]
					,[TL].[PRIORITY]
					,[TL].[FROM_MASTERPACK]
					,[TL].[OWNER]
					,[TL].[SOURCE_TYPE]
					,@TONE
					,@CALIBER
					,[TL].[LICENSE_ID_TARGET]
					,[TL].[IN_PICKING_LINE]
					,@pSTATUS_CODE
					,ISNULL(@PROJECT_ID_LICENSE,
							@PROJECT_ID_TASK)
					,@PROJECT_CODE
					,@PROJECT_NAME
					,@PROJECT_SHORT_NAME
					,[TL].[DOC_ID_SOURCE]
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [TL].[STATUS_CODE] = @pSTATUS_CODE; 


				---------------------------------------------------------------------------------
				-- AGREGAMOS LA NUEVA LICENCIA EN EL INVENTARIO RESERVADO Y LOG. SI MANEJA PROYECTO
				---------------------------------------------------------------------------------
				-- VERIFICA SI LA LICENCIA NUEVA NO PERTENECE AL MISMO PROYECTO, INSERTA UN NUEVO REGISTRO AL INVENTARIO RESERVADO
				---------------------------------------------------------------------------------
				IF @PROJECT_ID_LICENSE IS NULL
					AND @PROJECT_ID_TASK IS NOT NULL
				BEGIN
					IF NOT EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
									WHERE
										[LICENSE_ID] = @pSOURCE_LICENSE
										AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
										AND [PROJECT_ID] = @PROJECT_ID_TASK )
					BEGIN
						INSERT	INTO [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
								(
									[PROJECT_ID]
									,[PK_LINE]
									,[LICENSE_ID]
									,[MATERIAL_ID]
									,[MATERIAL_NAME]
									,[QTY_LICENSE]
									,[QTY_RESERVED]
									,[QTY_DISPATCHED]
									,[RESERVED_PICKING]
									,[TONE]
									,[CALIBER]
									,[BATCH]
									,[DATE_EXPIRATION]
									,[STATUS_CODE]
									,[CLIENT_CODE]
									,[CLIENT_NAME]
									,[MOBILE]
								)
						VALUES
								(
									@PROJECT_ID_TASK  -- PROJECT_ID - uniqueidentifier
									,@PK_LINE  -- PK_LINE - numeric
									,@pSOURCE_LICENSE  -- LICENSE_ID - numeric
									,@pMATERIAL_ID_LOCAL  -- MATERIAL_ID - varchar(50)
									,@MATERIAL_NAME  -- MATERIAL_NAME - varchar(150)
									,@QTY_LICENSE  -- QTY_LICENSE - numeric
									,@pQUANTITY_UNITS  -- QTY_RESERVED - numeric
									,@pQUANTITY_UNITS  -- QTY_DISPATCHED - numeric
									,0  -- RESERVED_PICKING - numeric
									,@TONE  -- TONE - varchar(20)
									,@CALIBER  -- CALIBER - varchar(20)
									,@BATCH  -- BATCH - varchar(50)
									,@DATE_EXPIRATION  -- DATE_EXPIRATION - date
									,@pSTATUS_CODE  -- STATUS_CODE - varchar(100)
									,@CLIENT_CODE  -- CLIENT_CODE - varchar(25)
									,@CLIENT_NAME  -- CLIENT_NAME - varchar(50)
									,1
								);
					
					
					END;
					ELSE
					BEGIN
						-- ------------------------------------------------------------------------------------
						-- si previamente se asigno la licencia al inventario del proyecto solo sumamos cantidades
						-- ------------------------------------------------------------------------------------
						UPDATE
							[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
						SET	
							[QTY_RESERVED] = [QTY_RESERVED]
							+ @pQUANTITY_UNITS
							,[QTY_DISPATCHED] = [QTY_DISPATCHED]
							+ @pQUANTITY_UNITS
						WHERE
							[LICENSE_ID] = @pSOURCE_LICENSE
							AND [MATERIAL_ID] = @pMATERIAL_ID
							AND [PROJECT_ID] = @PROJECT_ID_TASK;
					END;
					

					INSERT	INTO [wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
							(
								[TYPE_LOG]
								,[PROJECT_ID]
								,[PK_LINE]
								,[LICENSE_ID]
								,[MATERIAL_ID]
								,[MATERIAL_NAME]
								,[QTY_LICENSE]
								,[QTY_RESERVED]
								,[QTY_DISPATCHED]
								,[PICKING_DEMAND_HEADER_ID]
								,[WAVE_PICKING_ID]
								,[CREATED_BY]
								,[CREATED_DATE]
							)
					VALUES
							(
								'MOBILE'  -- TYPE_LOG - varchar(20)
								,@PROJECT_ID_TASK  -- PROJECT_ID - uniqueidentifier
								,@PK_LINE  -- PK_LINE - numeric
								,@pSOURCE_LICENSE  -- LICENSE_ID - numeric
								,@pMATERIAL_ID_LOCAL  -- MATERIAL_ID - varchar(50)
								,@MATERIAL_NAME  -- MATERIAL_NAME - varchar(150)
								,@QTY_LICENSE  -- QTY_LICENSE - numeric
								,@pQUANTITY_UNITS  -- QTY_RESERVED - numeric
								,@pQUANTITY_UNITS  -- QTY_DISPATCHED - numeric
								,0  -- PICKING_DEMAND_HEADER_ID - int
								,@pWAVE_PICKING_ID  -- WAVE_PICKING_ID - numeric
								,@LOGIN_NAME  -- CREATED_BY - varchar(64)
								,GETDATE()  -- CREATED_DATE - datetime
							);

				END;

			--

			END;
			ELSE
			BEGIN
				SET @UPDATE_LICENSE = 1;
				SET @LICENSE_BELONG_TO_WAVE_PICKING = 1;
        ---------------------------------------------------------------------------------
        -- Actualizamos la cantidad de la licencia
        ---------------------------------------------------------------------------------


				UPDATE
					[wms].[OP_WMS_TASK_LIST]
				SET	
					[QUANTITY_PENDING] += @pQUANTITY_UNITS
					- [QUANTITY_PENDING]
					,[QUANTITY_ASSIGNED] += @pQUANTITY_UNITS
					- [QUANTITY_PENDING]
				WHERE
					[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [LICENSE_ID_SOURCE] = @pSOURCE_LICENSE;

			END;
		END;


		SELECT TOP 1
			@pTASK_IS_CANCELED = [T].[IS_CANCELED]
			,@IS_FROM_SONDA = [T].[IS_FROM_SONDA]
			,@TRANSFER_REQUEST_ID = [T].[TRANSFER_REQUEST_ID]
			,@SOURCE_TYPE = [T].[SOURCE_TYPE]
			,@TRANS_SUBTYPE = [T].[TASK_SUBTYPE]
		FROM
			[wms].[OP_WMS_TASK_LIST] [T]
		WHERE
			[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
			AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;




    ---------------------------------------------------------------------------------
    -- VALIDACIONES
    ---------------------------------------------------------------------------------  

		IF (@pTASK_IS_CANCELED <> 0)
		BEGIN
			SELECT
				@pRESULT = 'ERROR, Tarea ha sido cancelada, verifique.'
				,@ErrorCode = 1202;
			RAISERROR (@pRESULT, 16, 1);
		END;


		IF @pMATERIAL_ID_LOCAL IS NULL
		BEGIN
			SELECT
				@pRESULT = 'ERROR, SKU Invalido: ['
				+ @pMATERIAL_BARCODE + '/'
				+ @pCLIENT_ID_LOCAL + '] verifique.'
				,@ErrorCode = 1203;
			RAISERROR (@pRESULT, 16, 1);
		END;

		IF (@pINV_AVAILABLE < @pQUANTITY_UNITS)
		BEGIN
			SELECT
				@pRESULT = 'ERROR, Inventario insuficiente['
				+ CONVERT(VARCHAR(20), @pINV_AVAILABLE)
				+ '] en licencia origen: ['
				+ CONVERT(VARCHAR(20), @pSOURCE_LICENSE)
				+ '] verifique.'
				,@ErrorCode = 1201;
			RAISERROR (@pRESULT, 16, 1);
		END;

    ---------------------------------------------------------------------------------
    -- INSERTA TRANSACCIÓN DE PICKING
    ---------------------------------------------------------------------------------  
		IF @HANDLE_SERIAL = 1
		BEGIN
			INSERT	INTO [wms].[OP_WMS_TRANS]
					(
						[TERMS_OF_TRADE]
						,[TRANS_DATE]
						,[LOGIN_ID]
						,[LOGIN_NAME]
						,[TRANS_TYPE]
						,[TRANS_DESCRIPTION]
						,[TRANS_EXTRA_COMMENTS]
						,[MATERIAL_BARCODE]
						,[MATERIAL_CODE]
						,[MATERIAL_DESCRIPTION]
						,[MATERIAL_TYPE]
						,[MATERIAL_COST]
						,[SOURCE_LICENSE]
						,[TARGET_LICENSE]
						,[SOURCE_LOCATION]
						,[TARGET_LOCATION]
						,[CLIENT_OWNER]
						,[CLIENT_NAME]
						,[QUANTITY_UNITS]
						,[SOURCE_WAREHOUSE]
						,[TARGET_WAREHOUSE]
						,[TRANS_SUBTYPE]
						,[CODIGO_POLIZA]
						,[LICENSE_ID]
						,[STATUS]
						,[WAVE_PICKING_ID]
						,[TASK_ID]
						,[IS_FROM_SONDA]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[SERIAL]
						,[STATUS_CODE]
						,[PROJECT_ID]
						,[PROJECT_CODE]
						,[PROJECT_NAME]
						,[PROJECT_SHORT_NAME]
					)
			SELECT
				@TERMS_OF_TRADE
				,GETDATE()
				,@pLOGIN_ID
				,@LOGIN_NAME
				,'DESPACHO_GENERAL'
				,ISNULL((SELECT TOP 1
								[PARAM_CAPTION]
							FROM
								[wms].[OP_WMS_FUNC_GETTRANS_DESC]('DESPACHO_GENERAL')),
						'DESPACHO GENERAL')
				,NULL
				,@pMATERIAL_BARCODE
				,@pMATERIAL_ID_LOCAL
				,(SELECT TOP 1
						*
					FROM
						[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE,
											@pCLIENT_ID_LOCAL))
				,NULL
				,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID_LOCAL,
											@pCLIENT_ID_LOCAL)
				,@pSOURCE_LICENSE
				,NULL
				,@pSOURCE_LOCATION
				,'PUERTA_1'
				,@pCLIENT_ID_LOCAL
				,(SELECT TOP 1
						*
					FROM
						[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_ID_LOCAL))
				,-1
				,@WAREHOUSE_PARENT
				,NULL
				,@TRANS_SUBTYPE
				,@pCODIGO_POLIZA
				,@pSOURCE_LICENSE
				,'PROCESSED'
				,@pWAVE_PICKING_ID
				,@pWAVE_PICKING_ID
				,@IS_FROM_SONDA
				,@BATCH
				,@DATE_EXPIRATION
				,[S].[SERIAL]
				,@pSTATUS_CODE
				,ISNULL(@PROJECT_ID_LICENSE,
						@PROJECT_ID_TASK)
				,@PROJECT_CODE
				,@PROJECT_NAME
				,@PROJECT_SHORT_NAME
			FROM
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
			INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [S].[WAVE_PICKING_ID]
											AND [S].[LICENSE_ID] = [T].[LICENSE_ID_SOURCE]
											AND [S].[MATERIAL_ID] = [T].[MATERIAL_ID]
											AND [T].[TASK_ASSIGNEDTO] = [S].[ASSIGNED_TO]
			WHERE
				[S].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [T].[TASK_ASSIGNEDTO] = @pLOGIN_ID
				AND [S].[STATUS] = 2;

		END;
		ELSE
		BEGIN
			INSERT	INTO [wms].[OP_WMS_TRANS]
					(
						[TERMS_OF_TRADE]
						,[TRANS_DATE]
						,[LOGIN_ID]
						,[LOGIN_NAME]
						,[TRANS_TYPE]
						,[TRANS_DESCRIPTION]
						,[TRANS_EXTRA_COMMENTS]
						,[MATERIAL_BARCODE]
						,[MATERIAL_CODE]
						,[MATERIAL_DESCRIPTION]
						,[MATERIAL_TYPE]
						,[MATERIAL_COST]
						,[SOURCE_LICENSE]
						,[TARGET_LICENSE]
						,[SOURCE_LOCATION]
						,[TARGET_LOCATION]
						,[CLIENT_OWNER]
						,[CLIENT_NAME]
						,[QUANTITY_UNITS]
						,[SOURCE_WAREHOUSE]
						,[TARGET_WAREHOUSE]
						,[TRANS_SUBTYPE]
						,[CODIGO_POLIZA]
						,[LICENSE_ID]
						,[STATUS]
						,[WAVE_PICKING_ID]
						,[TASK_ID]
						,[IS_FROM_SONDA]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[SOURCE_TYPE]
						,[TRANSFER_REQUEST_ID]
						,[VIN]
						,[STATUS_CODE]
						,[PROJECT_ID]
						,[PROJECT_CODE]
						,[PROJECT_NAME]
						,[PROJECT_SHORT_NAME]
					)
			VALUES
					(
						@TERMS_OF_TRADE
						,GETDATE()
						,@pLOGIN_ID
						,@LOGIN_NAME
						,'DESPACHO_GENERAL'
						,ISNULL((SELECT TOP 1
										[PARAM_CAPTION]
									FROM
										[wms].[OP_WMS_FUNC_GETTRANS_DESC]('DESPACHO_GENERAL')),
								'DESPACHO GENERAL')
						,NULL
						,@pMATERIAL_BARCODE
						,@pMATERIAL_ID_LOCAL
						,(SELECT TOP 1
								*
							FROM
								[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE,
											@pCLIENT_ID_LOCAL))
						,NULL
						,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID_LOCAL,
											@pCLIENT_ID_LOCAL)
						,@pSOURCE_LICENSE
						,NULL
						,@pSOURCE_LOCATION
						,'PUERTA_1'
						,@pCLIENT_ID_LOCAL
						,@CLIENT_NAME
						,(@pQUANTITY_UNITS * -1)
						,@WAREHOUSE_PARENT
						,NULL
						,@TRANS_SUBTYPE
						,@pCODIGO_POLIZA
						,@pSOURCE_LICENSE
						,'PROCESSED'
						,@pWAVE_PICKING_ID
						,@pWAVE_PICKING_ID
						,@IS_FROM_SONDA
						,@BATCH
						,@DATE_EXPIRATION
						,@SOURCE_TYPE
						,@TRANSFER_REQUEST_ID
						,@VIN
						,@pSTATUS_CODE
						,ISNULL(@PROJECT_ID_LICENSE,
								@PROJECT_ID_TASK)
						,@PROJECT_CODE
						,@PROJECT_NAME
						,@PROJECT_SHORT_NAME
					);
		END;

		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[QTY] = [QTY] - @pQUANTITY_UNITS
			,[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATED_BY] = @pLOGIN_ID
		WHERE
			[LICENSE_ID] = @pSOURCE_LICENSE
			AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

		-- --------------------------------------------------------------------------------
		-- ACTUALIZAMOS LA CANTIDAD DE LA LICENCIA EN EL INVENTARIO RESERVADO SI MANEJA PROYECTO.
		-- --------------------------------------------------------------------------------
		IF @PROJECT_ID_LICENSE IS NOT NULL
		BEGIN
			-- OBTENEMOS EL QTY RESERVADO
			DECLARE	@logQTY_RESERVED INTEGER = 0;
			SELECT
				@logQTY_RESERVED = [QTY_RESERVED]
			FROM
				[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
			WHERE
				[PROJECT_ID] = @PROJECT_ID_LICENSE
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [LICENSE_ID] = @pSOURCE_LICENSE;
			
		-- --------------------------------------------------------------------------------
		-- ACTUALIZA INFORMACION EN LA LICENCIA SIEMPRE Y CUANDO EXISTA EN EL INVENTARIO ASIGNADO AL PROYECTO.
		-- --------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
			SET	
				[QTY_DISPATCHED] = [QTY_DISPATCHED]
				+ @pQUANTITY_UNITS
			WHERE
				[PROJECT_ID] = @PROJECT_ID_LICENSE
				AND [LICENSE_ID] = @pSOURCE_LICENSE
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;
		-- --------------------------------------------------------------------------------
		-- INSERTAMOS LOG DEL INVENTARIO RESERVADO POR DESPACHO GENRAL
		-- --------------------------------------------------------------------------------
			INSERT	INTO [wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
					(
						[TYPE_LOG]
						,[PROJECT_ID]
						,[PK_LINE]
						,[LICENSE_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY_LICENSE]
						,[QTY_RESERVED]
						,[QTY_DISPATCHED]
						,[PICKING_DEMAND_HEADER_ID]
						,[WAVE_PICKING_ID]
						,[CREATED_BY]
						,[CREATED_DATE]
					)
			VALUES
					(
						'DESPACHO_GENERAL'  -- TYPE_LOG - varchar(20)
						,@PROJECT_ID_LICENSE  -- PROJECT_ID - uniqueidentifier
						,@PK_LINE  -- PK_LINE - numeric
						,@pSOURCE_LICENSE  -- LICENSE_ID - numeric
						,@pMATERIAL_ID_LOCAL  -- MATERIAL_ID - varchar(50)
						,@MATERIAL_NAME  -- MATERIAL_NAME - varchar(150)
						,@QTY_LICENSE  -- QTY_LICENSE - numeric
						,@logQTY_RESERVED  -- QTY_RESERVED - numeric
						,@pQUANTITY_UNITS  -- QTY_DISPATCHED - numeric
						,0  -- PICKING_DEMAND_HEADER_ID - int
						,@pWAVE_PICKING_ID  -- WAVE_PICKING_ID - numeric
						,@LOGIN_NAME  -- CREATED_BY - varchar(64)
						,GETDATE()  -- CREATED_DATE - datetime
					);


		END;
		PRINT @PROJECT_ID_LICENSE;
		PRINT @PROJECT_ID_TASK;
		PRINT @LICENSE_BELONG_TO_WAVE_PICKING;
		
		IF @PROJECT_ID_LICENSE IS NULL
			AND @PROJECT_ID_TASK IS NOT NULL
			AND @LICENSE_BELONG_TO_WAVE_PICKING = 1
		BEGIN
			--agregamos la licencia al inventario del proyecto
			SELECT
				@PROJECT_ID_TASK = [PROJECT_ID]
				,@PROJECT_CODE = [PROJECT_CODE]
				,@PROJECT_NAME = [PROJECT_NAME]
				,@PROJECT_SHORT_NAME = [PROJECT_SHORT_NAME]
			FROM
				[wms].[OP_WMS_TASK_LIST]
			WHERE
				[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

			--asigno el proyecto a la fila de la licencia en el inventario por licencia
			IF NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
							WHERE
								[LICENSE_ID] = @pSOURCE_LICENSE
								AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
								AND [PROJECT_ID] = @PROJECT_ID_TASK )
			BEGIN
				-- ------------------------------------------------------------------------------------
				-- si no existe la fila la agregamos
				-- ------------------------------------------------------------------------------------
				INSERT	INTO [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
						(
							[PROJECT_ID]
							,[PK_LINE]
							,[LICENSE_ID]
							,[MATERIAL_ID]
							,[MATERIAL_NAME]
							,[QTY_LICENSE]
							,[QTY_RESERVED]
							,[QTY_DISPATCHED]
							,[RESERVED_PICKING]
							,[TONE]
							,[CALIBER]
							,[BATCH]
							,[DATE_EXPIRATION]
							,[STATUS_CODE]
							,[CLIENT_CODE]
							,[CLIENT_NAME]
							,[MOBILE]
							
						)
				VALUES
						(
							@PROJECT_ID_TASK  -- PROJECT_ID - uniqueidentifier
							,@PK_LINE  -- PK_LINE - numeric
							,@pSOURCE_LICENSE  -- LICENSE_ID - numeric
							,@pMATERIAL_ID_LOCAL  -- MATERIAL_ID - varchar(50)
							,@MATERIAL_NAME  -- MATERIAL_NAME - varchar(150)
							,@QTY_LICENSE  -- QTY_LICENSE - numeric
							,@pQUANTITY_UNITS  -- QTY_RESERVED - numeric
							,@pQUANTITY_UNITS  -- QTY_DISPATCHED - numeric
							,0  -- RESERVED_PICKING - numeric
							,@TONE  -- TONE - varchar(20)
							,@CALIBER  -- CALIBER - varchar(20)
							,@BATCH  -- BATCH - varchar(50)
							,@DATE_EXPIRATION  -- DATE_EXPIRATION - date
							,@pSTATUS_CODE  -- STATUS_CODE - varchar(100)
							,@CLIENT_CODE  -- CLIENT_CODE - varchar(25)
							,@CLIENT_NAME  -- CLIENT_NAME - varchar(50)
							,2
						);
			END;
			ELSE
			BEGIN
				-- ------------------------------------------------------------------------------------
						-- si previamente se asigno la licencia al inventario del proyecto solo sumamos cantidades
						-- ------------------------------------------------------------------------------------
				UPDATE
					[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
				SET	
					[QTY_RESERVED] = [QTY_RESERVED]
					+ @pQUANTITY_UNITS
					,[QTY_DISPATCHED] = [QTY_DISPATCHED]
					+ @pQUANTITY_UNITS
				WHERE
					[LICENSE_ID] = @pSOURCE_LICENSE
					AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [PROJECT_ID] = @PROJECT_ID_TASK;
			END;

			INSERT	INTO [wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
					(
						[TYPE_LOG]
						,[PROJECT_ID]
						,[PK_LINE]
						,[LICENSE_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY_LICENSE]
						,[QTY_RESERVED]
						,[QTY_DISPATCHED]
						,[PICKING_DEMAND_HEADER_ID]
						,[WAVE_PICKING_ID]
						,[CREATED_BY]
						,[CREATED_DATE]
							
					)
			VALUES
					(
						'COMP_PICKING'  -- TYPE_LOG - varchar(20)
						,@PROJECT_ID_TASK  -- PROJECT_ID - uniqueidentifier
						,@PK_LINE  -- PK_LINE - numeric
						,@pSOURCE_LICENSE  -- LICENSE_ID - numeric
						,@pMATERIAL_ID_LOCAL  -- MATERIAL_ID - varchar(50)
						,@MATERIAL_NAME  -- MATERIAL_NAME - varchar(150)
						,@QTY_LICENSE  -- QTY_LICENSE - numeric
						,@pQUANTITY_UNITS  -- QTY_RESERVED - numeric
						,@pQUANTITY_UNITS  -- QTY_DISPATCHED - numeric
						,0  -- PICKING_DEMAND_HEADER_ID - int
						,@pWAVE_PICKING_ID  -- WAVE_PICKING_ID - numeric
						,@LOGIN_NAME  -- CREATED_BY - varchar(64)
						,GETDATE()  -- CREATED_DATE - datetime
							
					);
		END;
		--
		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATED_BY] = @pLOGIN_ID
		WHERE
			[LICENSE_ID] = @pSOURCE_LICENSE;

		IF @pTipoUbicacion = 'PISO'
		BEGIN
			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[USED_MT2] = [USED_MT2] - @pMt2
			WHERE
				[LICENSE_ID] = @pSOURCE_LICENSE;
		END;

		IF @IS_MASTER_PACK = 1
		BEGIN
			EXEC [wms].[OP_WMS_SP_DISPATCH_MASTER_PACK] @MATERIAL_ID = @pMATERIAL_ID_LOCAL,
				@LICENCE_ID = @pSOURCE_LICENSE,
				@QTY_DISPATCH = @pQUANTITY_UNITS;
		END;

		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[QUANTITY_PENDING] = [QUANTITY_PENDING]
			- @pQUANTITY_UNITS
		WHERE
			[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
			AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
			AND [LICENSE_ID_SOURCE] = @pSOURCE_LICENSE;


		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_TASK_LIST] [T]
					WHERE
						[T].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
						AND [T].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
						AND [T].[LICENSE_ID_SOURCE] = @pSOURCE_LICENSE
						AND [T].[QUANTITY_PENDING] = 0 )
		BEGIN
			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[IS_COMPLETED] = 1
				,[COMPLETED_DATE] = GETDATE()
			WHERE
				[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [LICENSE_ID_SOURCE] = @pSOURCE_LICENSE;

		END;

    ---------------------------------------------------------------------------------
    -- Validamos si se agrego o se actualizo una licencia
    ---------------------------------------------------------------------------------  
		IF @UPDATE_LICENSE = 1
		BEGIN
      ---------------------------------------------------------------------------------
      -- Obtenemos las licencias que tengan cantidad pendiente
      ---------------------------------------------------------------------------------  

			DECLARE	@QTY_COMPLETED NUMERIC(18, 4) = 0;
			DECLARE	@QTY_PENDING NUMERIC(18, 4) = 0;


			SELECT
				@QTY_COMPLETED = SUM([TL].[QUANTITY_ASSIGNED])
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [TL].[QUANTITY_PENDING] = 0;

			SET @QTY_PENDING = (@QTY_TOTAL - @QTY_COMPLETED);

      ---------------------------------------------------------------------------------
      -- Se valida que si la cantidad pendiente es cero, se elimina las licencias 
      ---------------------------------------------------------------------------------  

			IF @QTY_PENDING = 0
			BEGIN
				DELETE
					[wms].[OP_WMS_TASK_LIST]
				WHERE
					[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [QUANTITY_PENDING] > 0
					AND STATUS_CODE = @pSTATUS_CODE;
			END;
			ELSE
			BEGIN

        ---------------------------------------------------------------------------------
        -- Obtenemos la licencia po cantidad pendientes 
        ---------------------------------------------------------------------------------
				DECLARE	@LICENSES TABLE (
						[LICENSE_ID] INT
						,[MATERIAL_ID] VARCHAR(50)
						,[QUANTITY_PENDING] NUMERIC(18, 4)
						,[QUANTITY_ASSIGNED] NUMERIC(18, 4)
					);

				INSERT	INTO @LICENSES
				SELECT
					[TL].[LICENSE_ID_SOURCE]
					,[TL].[MATERIAL_ID]
					,[TL].[QUANTITY_PENDING]
					,[TL].[QUANTITY_ASSIGNED]
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [TL].[QUANTITY_PENDING] > 0
					AND [TL].STATUS_CODE = @pSTATUS_CODE;

				DECLARE
					@QUANTITY_PENDING NUMERIC(18, 4) = 0
					,@QUANTITY_ASSIGNED NUMERIC(18, 4) = 0
					,@LICENSE_ID_SOURCE INT;

        ---------------------------------------------------------------------------------
        -- Recorremos las licencias para ajustarlas
        ---------------------------------------------------------------------------------

				SET @QTY_PENDING = CASE	WHEN (@QTY_TOTAL_PENDING
											- @pQUANTITY_UNITS) = 0
										THEN @pQUANTITY_UNITS
										ELSE (@QTY_TOTAL_PENDING
											- @pQUANTITY_UNITS)
									END;

				WHILE @QTY_PENDING > 0
				BEGIN

					SELECT TOP 1
						@QUANTITY_PENDING = [QUANTITY_PENDING]
						,@QUANTITY_ASSIGNED = [QUANTITY_ASSIGNED]
						,@LICENSE_ID_SOURCE = [L].[LICENSE_ID]
					FROM
						@LICENSES [L];

				print '@pWAVE_PICKING_ID'
				print @pWAVE_PICKING_ID
				print '@LICENSE_ID_SOURCE'
				print @LICENSE_ID_SOURCE
				print '@pMATERIAL_ID_LOCAL'
				print @pMATERIAL_ID_LOCAL
				print '@QUANTITY_PENDING'
				print @QUANTITY_PENDING
				print '@QTY_PENDING'
				print @QTY_PENDING
				print '@QTY_TOTAL_PENDING'
				print @QTY_TOTAL_PENDING
				print '@pQUANTITY_UNITS'
				print @pQUANTITY_UNITS
					IF (@QUANTITY_PENDING <= @QTY_PENDING)
					BEGIN
					print 'if 1'
						SET @QTY_PENDING -= @QUANTITY_PENDING;

						IF ((@QTY_TOTAL_PENDING
							- @pQUANTITY_UNITS)) = 0
						BEGIN
							UPDATE
								[wms].[OP_WMS_TASK_LIST]
							SET	
								[QUANTITY_PENDING] -= @QUANTITY_PENDING
								,[QUANTITY_ASSIGNED] -= @QUANTITY_PENDING
							WHERE
								[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
								AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
								AND [LICENSE_ID_SOURCE] = @LICENSE_ID_SOURCE;
						END;

					END;
					ELSE
					BEGIN
					print 'else 1'
						UPDATE
							[wms].[OP_WMS_TASK_LIST]
						SET	
							[QUANTITY_PENDING] = @QTY_PENDING
							,[QUANTITY_ASSIGNED] = CASE
											WHEN [QUANTITY_PENDING] = [QUANTITY_ASSIGNED]
											THEN @QTY_PENDING
											ELSE (([QUANTITY_ASSIGNED]
											- [QUANTITY_PENDING])
											+ @QTY_PENDING)
											END
						WHERE
							[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
							AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
							AND [LICENSE_ID_SOURCE] = @LICENSE_ID_SOURCE;
						SET @QTY_PENDING = 0;
					END;

					DELETE
						@LICENSES
					WHERE
						[LICENSE_ID] = @LICENSE_ID_SOURCE;

				END;
				print 'update 3'
				UPDATE
					[TL]
				SET	
					[TL].[QUANTITY_ASSIGNED] = ([TL].[QUANTITY_ASSIGNED]
											- [TL].[QUANTITY_PENDING])
					,[TL].[QUANTITY_PENDING] = 0
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				INNER JOIN @LICENSES [L] ON ([L].[LICENSE_ID] = [TL].[LICENSE_ID_SOURCE])
				WHERE
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

			END;

			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[IS_COMPLETED] = 1
				,[COMPLETED_DATE] = GETDATE()
			WHERE
				[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [QUANTITY_PENDING] = 0
				AND [IS_COMPLETED] = 0;

			DELETE
				[wms].[OP_WMS_TASK_LIST]
			WHERE
				[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [QUANTITY_PENDING] = 0
				AND [QUANTITY_ASSIGNED] = 0
				AND STATUS_CODE = @pSTATUS_CODE

		END;


    ---------------------------------------------------------------------------------
    -- Validamos si tiene activado el parametro para agregar productos a la licencia
    ---------------------------------------------------------------------------------    
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_PARAMETER] [P]
					WHERE
						[P].[GROUP_ID] = 'PICKING'
						AND [P].[PARAMETER_ID] = 'CREATE_LICENSE_IN_PICKING'
						AND [P].[VALUE] = '1' )
		BEGIN

      ---------------------------------------------------------------------------------
      -- Validamos si existe una licencia con la ola de picking
      ---------------------------------------------------------------------------------    
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_LICENSES] [L]
						WHERE
							[L].[LICENSE_ID] = @LICENSE_DISPATCH_ID )
			BEGIN

        ---------------------------------------------------------------------------------
        -- Declaramos las variables necesarias
        ---------------------------------------------------------------------------------    
				DECLARE
					@LOCATION_SPOT_TARGET VARCHAR(25)
					,@VOLUME_FACTOR NUMERIC(18, 4)
					,@BARCODE_ID VARCHAR(25)
					,@STATUS_CODE VARCHAR(50)
					,@STATUS_NAME VARCHAR(100)
					,@BLOCKS_INVENTORY VARCHAR(50)
					,@ALLOW_REALLOC VARCHAR(50)
					,@TARGET_LOCATION VARCHAR(50) = ''
					,@DESCRIPTION VARCHAR(200)
					,@COLOR VARCHAR(50)
					,@STATUS_ID INT;

				DECLARE	@STATUS_TB TABLE (
						[RESULTADO] INT
						,[MENSAJE] VARCHAR(15)
						,[CODIGO] INT
						,[STATUS_ID] INT
					);

        ---------------------------------------------------------------------------------
        -- Obtenemos los datos para agregar el producto a la licencia
        ---------------------------------------------------------------------------------        
		
				SELECT TOP 1
					@LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET]
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID;
        ----
				SELECT TOP 1
					@VOLUME_FACTOR = [M].[VOLUME_FACTOR]
					,@BARCODE_ID = [M].[BARCODE_ID]
				FROM
					[wms].[OP_WMS_MATERIALS] [M]
				WHERE
					[M].[MATERIAL_ID] = @pMATERIAL_ID;
        ----
				SELECT
					@TONE = [TCM].[TONE]
					,@CALIBER = [TCM].[CALIBER]
				FROM
					[wms].[OP_WMS_INV_X_LICENSE] [L]
				INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([L].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
				WHERE
					[L].[LICENSE_ID] = @pSOURCE_LICENSE
					AND [L].[MATERIAL_ID] = @pMATERIAL_ID;
        ----
				SELECT TOP 1
					@STATUS_CODE = [PARAM_NAME]
					,@STATUS_NAME = [PARAM_CAPTION]
					,@BLOCKS_INVENTORY = CASE [SPARE1]
											WHEN 'SI' THEN 1
											WHEN '1' THEN 1
											ELSE 0
											END
					,@ALLOW_REALLOC = CASE [SPARE2]
										WHEN 'SI' THEN 1
										WHEN '1' THEN 1
										ELSE 0
										END
					,@TARGET_LOCATION = [SPARE3]
					,@DESCRIPTION = [TEXT_VALUE]
					,@COLOR = [COLOR]
				FROM
					[wms].[OP_WMS_CONFIGURATIONS]
				WHERE
					[PARAM_TYPE] = 'ESTADO'
					AND [PARAM_GROUP] = 'ESTADOS'
					AND PARAM_NAME = 
					(SELECT TOP 1 STATUS_CODE FROM wms.OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE WHERE LICENSE_ID = @pSOURCE_LICENSE)
					

        ---------------------------------------------------------------------------------
        -- Validamos si la licencia con el producto ya fue ingresada
        ---------------------------------------------------------------------------------    
				IF EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_INV_X_LICENSE] [IL]
							WHERE
								[IL].[LICENSE_ID] = @LICENSE_DISPATCH_ID
								AND [IL].[MATERIAL_ID] = @pMATERIAL_ID )
				BEGIN


					IF @TRANSFER_REQUEST_ID IS NOT NULL
					BEGIN
            ---------------------------------------------------------------------------------
            -- Validamos si el producto maneja lote y si ya fue ingresado el producto a la licencia
            ---------------------------------------------------------------------------------    
						IF EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_INV_X_LICENSE] [IL]
									INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
									WHERE
										[IL].[LICENSE_ID] = @LICENSE_DISPATCH_ID
										AND [IL].[MATERIAL_ID] = @pMATERIAL_ID
										AND (
											[IL].[DATE_EXPIRATION] <> @DATE_EXPIRATION
											OR [IL].[BATCH] <> @BATCH
											)
										AND [M].[BATCH_REQUESTED] = 1 )
						BEGIN
							SELECT
								@ErrorCode = 3001;
							RAISERROR ('Ya existe un producto con ese lote, debe de crear otra licencia.', 16, 1);
							RETURN;
						END;

            ---------------------------------------------------------------------------------
            -- Validamos si el producto maneja tono o calibre y si ya fue ingresado el producto a la licencia
            ---------------------------------------------------------------------------------    
						IF EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_INV_X_LICENSE] [IL]
									INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
									INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
									WHERE
										[IL].[LICENSE_ID] = @LICENSE_DISPATCH_ID
										AND [IL].[MATERIAL_ID] = @pMATERIAL_ID
										AND (
											[M].[HANDLE_TONE] = 1
											OR [M].[HANDLE_CALIBER] = 1
											)
										AND (
											[TCM].[TONE] <> @TONE
											OR [TCM].[CALIBER] <> @CALIBER
											) )
						BEGIN
							SELECT
								@ErrorCode = 3002;
							RAISERROR ('Ya existe un producto con ese tono o calibre, debe de crear otra licencia.', 16, 1);
							RETURN;
						END;
					END;

		    ---------------------------------------------------------------------------------
            -- Validamos si el producto maneja lote y si ya fue ingresado el producto a la licencia
            ---------------------------------------------------------------------------------    
			print @STATUS_CODE
						IF NOT EXISTS (SELECT TOP 1 1
									FROM wms.OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE WHERE STATUS_CODE = @STATUS_CODE AND LICENSE_ID = @LICENSE_DISPATCH_ID)
						BEGIN
							SELECT
								@ErrorCode = 1116;
							RAISERROR ('Este estado de material es distinto al último, por favor crea otra licencia', 16, 1);
							RETURN;
						END;
          ---------------------------------------------------------------------------------
          -- Actualizamos el producto ya verificado antes que todos los campos sean iguales
          ---------------------------------------------------------------------------------    
					UPDATE
						[wms].[OP_WMS_INV_X_LICENSE]
					SET	
						[QTY] = [QTY] + @pQUANTITY_UNITS
					WHERE
						[LICENSE_ID] = @LICENSE_DISPATCH_ID
						AND [MATERIAL_ID] = @pMATERIAL_ID;
				END;
				ELSE
				BEGIN
          ---------------------------------------------------------------------------------
          -- Insertamos el nuevo estado para el nuevo producto.
          ---------------------------------------------------------------------------------

					INSERT	[wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
							(
								[STATUS_CODE]
								,[STATUS_NAME]
								,[BLOCKS_INVENTORY]
								,[ALLOW_REALLOC]
								,[TARGET_LOCATION]
								,[DESCRIPTION]
								,[COLOR]
								,[LICENSE_ID]
							)
					VALUES
							(
								@STATUS_CODE
								,@STATUS_NAME
								,@BLOCKS_INVENTORY
								,@ALLOW_REALLOC
								,@TARGET_LOCATION
								,@DESCRIPTION
								,@COLOR
								,@LICENSE_DISPATCH_ID
							);


					SET @STATUS_ID = SCOPE_IDENTITY();

          ---------------------------------------------------------------------------------
          -- Declaramos las variables necesarias
          ---------------------------------------------------------------------------------    
					DECLARE	@TONE_AND_CALIBER_ID INT = NULL;

          ---------------------------------------------------------------------------------
          -- Validamos si el producto manje tono o calibre
          ---------------------------------------------------------------------------------    
					IF EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_MATERIALS] [M]
								WHERE
									[M].[MATERIAL_ID] = @pMATERIAL_ID
									AND (
											[M].[HANDLE_TONE] = 1
											OR [M].[HANDLE_CALIBER] = 1
										) )
					BEGIN

            ---------------------------------------------------------------------------------
            -- Obtenemos el id si existe el tono y calibre con ese producto
            ---------------------------------------------------------------------------------    
						SELECT
							@TONE_AND_CALIBER_ID = [TCM].[TONE_AND_CALIBER_ID]
						FROM
							[wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
						WHERE
							[TCM].[MATERIAL_ID] = @pMATERIAL_ID
							AND [TCM].[TONE] = @TONE
							AND [TCM].[CALIBER] = @CALIBER;
					END;

          ---------------------------------------------------------------------------------
          -- Insertamos el inventario para la licencia de despacho
          ---------------------------------------------------------------------------------    

					INSERT	INTO [wms].[OP_WMS_INV_X_LICENSE]
							(
								[LICENSE_ID]
								,[MATERIAL_ID]
								,[MATERIAL_NAME]
								,[QTY]
								,[VOLUME_FACTOR]
								,[WEIGTH]
								,[SERIAL_NUMBER]
								,[COMMENTS]
								,[LAST_UPDATED]
								,[LAST_UPDATED_BY]
								,[BARCODE_ID]
								,[TERMS_OF_TRADE]
								,[STATUS]
								,[CREATED_DATE]
								,[DATE_EXPIRATION]
								,[BATCH]
								,[ENTERED_QTY]
								,[VIN]
								,[HANDLE_SERIAL]
								,[IS_EXTERNAL_INVENTORY]
								,[IS_BLOCKED]
								,[BLOCKED_STATUS]
								,[STATUS_ID]
								,[TONE_AND_CALIBER_ID]
								,[LOCKED_BY_INTERFACES]
							)
					VALUES
							(
								@LICENSE_DISPATCH_ID
								,@pMATERIAL_ID
								,@MATERIAL_NAME
								,@pQUANTITY_UNITS
								,@VOLUME_FACTOR
								,0
								,'N/A'
								,'N/A'
								,GETDATE()
								,@pLOGIN_ID
								,@BARCODE_ID
								,@TERMS_OF_TRADE
								,''
								,GETDATE()
								,@DATE_EXPIRATION
								,@BATCH
								,@pQUANTITY_UNITS
								,@VIN
								,@HANDLE_SERIAL
								,0
								,0
								,NULL
								,@STATUS_ID
								,@TONE_AND_CALIBER_ID
								,1
							);
				END;

        ---------------------------------------------------------------------------------
        -- Validamos si el producto maneja master pack
        ---------------------------------------------------------------------------------    
				IF EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_MATERIALS] [M]
							WHERE
								[M].[MATERIAL_ID] = @pMATERIAL_ID
								AND [M].[IS_MASTER_PACK] = 1 )
				BEGIN
          ---------------------------------------------------------------------------------
          -- Declaramos las vaaribles necesarias
          ---------------------------------------------------------------------------------    
					DECLARE
						@MASTER_PACK_HEADER_ID_SOURCE INT
						,@MASTER_PACK_HEADER_ID INT;

					PRINT 'Licencia';
					PRINT @pSOURCE_LICENSE;
					SELECT TOP 1
						@MASTER_PACK_HEADER_ID_SOURCE = [MPH].[MASTER_PACK_HEADER_ID]
					FROM
						[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
					WHERE
						[MPH].[LICENSE_ID] = @pSOURCE_LICENSE;
          ---------------------------------------------------------------------------------
          -- Validamos si el ya se ingreso el master pack herdader 
          ---------------------------------------------------------------------------------    
					IF EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
								WHERE
									[MPH].[LICENSE_ID] = @LICENSE_DISPATCH_ID )
					BEGIN
            ---------------------------------------------------------------------------------
            -- Actualizamos la cantidad del master pack
            ---------------------------------------------------------------------------------    
						UPDATE
							[MPH]
						SET	
							[MPH].[QTY] = [MPH].[QTY]
							+ @pQUANTITY_UNITS
						FROM
							[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
						WHERE
							[MPH].[LICENSE_ID] = @LICENSE_DISPATCH_ID;
					END;
					ELSE
					BEGIN
            ---------------------------------------------------------------------------------
            -- Insertamos el master pack header
            ---------------------------------------------------------------------------------    
						INSERT	[wms].[OP_WMS_MASTER_PACK_HEADER]
								(
									[LICENSE_ID]
									,[MATERIAL_ID]
									,[POLICY_HEADER_ID]
									,[LAST_UPDATED]
									,[LAST_UPDATE_BY]
									,[EXPLODED]
									,[EXPLODED_DATE]
									,[RECEPTION_DATE]
									,[IS_AUTHORIZED]
									,[ATTEMPTED_WITH_ERROR]
									,[IS_POSTED_ERP]
									,[POSTED_ERP]
									,[POSTED_RESPONSE]
									,[ERP_REFERENCE]
									,[ERP_REFERENCE_DOC_NUM]
									,[QTY]
									,[IS_IMPLOSION]
								)
						SELECT TOP 1
							@LICENSE_DISPATCH_ID
							,[MPH].[MATERIAL_ID]
							,[MPH].[POLICY_HEADER_ID]
							,GETDATE()
							,@pLOGIN_ID
							,[MPH].[EXPLODED]
							,[MPH].[EXPLODED_DATE]
							,GETDATE()
							,[MPH].[IS_AUTHORIZED]
							,[MPH].[ATTEMPTED_WITH_ERROR]
							,[MPH].[IS_POSTED_ERP]
							,[MPH].[POSTED_ERP]
							,[MPH].[POSTED_RESPONSE]
							,[MPH].[ERP_REFERENCE]
							,[MPH].[ERP_REFERENCE_DOC_NUM]
							,@pQUANTITY_UNITS
							,[MPH].[IS_IMPLOSION]
						FROM
							[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
						WHERE
							[MPH].[LICENSE_ID] = @pSOURCE_LICENSE;

            ---------------------------------------------------------------------------------
            -- Obtenemos el master pack header generado
            ---------------------------------------------------------------------------------    
						SELECT
							@MASTER_PACK_HEADER_ID = SCOPE_IDENTITY();


						INSERT	INTO [wms].[OP_WMS_MASTER_PACK_DETAIL]
								(
									[MASTER_PACK_HEADER_ID]
									,[MATERIAL_ID]
									,[QTY]
									,[BATCH]
									,[DATE_EXPIRATION]
								)
						SELECT
							@MASTER_PACK_HEADER_ID
							,[MPDSS].[MATERIAL_ID]
							,[MPDSS].[QTY]
							,[MPDSS].[BATCH]
							,[MPDSS].[DATE_EXPIRATION]
						FROM
							[wms].[OP_WMS_MASTER_PACK_DETAIL] [MPDSS]
						WHERE
							[MPDSS].[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID_SOURCE;
					END;
				END;
			END;
		END;

		COMMIT TRANSACTION;
		EXEC [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED] @WAVE_PICKING_ID = @pWAVE_PICKING_ID, -- int
			@LOGIN = @pLOGIN_ID; -- varchar(50)

		SELECT
			@pRESULT = 'OK';

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@LICENSE_DISPATCH_ID AS VARCHAR) [DbData];

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			@ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@ErrorCode AS [Codigo]
			,'' AS [DbData];

		SELECT
			@pRESULT = ERROR_MESSAGE();
	END CATCH;

END;