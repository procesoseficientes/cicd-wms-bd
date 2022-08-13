
-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		2018-04-11 @ G-Force Sprint Buho
-- Description:			    Procesar reubicación por entrega no inmediata. 

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:
        DECLARE @pRESULT VARCHAR(300)
		--
		EXEC [wms].[OP_WMS_SP_REGISTER_REALLOC_FOR_NO_IMMEDIATE_PICKING] 
			@pLOGIN_ID = '' , -- varchar(25)
			@pCLIENT_OWNER = '' , -- varchar(25)
			@pMATERIAL_ID = '' , -- varchar(50)
			@pMATERIAL_BARCODE = '' , -- varchar(25)
			@pSOURCE_LICENSE = NULL , -- numeric
			@pSOURCE_LOCATION = '' , -- varchar(25)
			@pQUANTITY_UNITS = NULL , -- numeric
			@pCODIGO_POLIZA = '' , -- varchar(25)
			@pWAVE_PICKING_ID = NULL , -- numeric
			@pSERIAL_NUMBER = NULL , -- numeric
			@pTipoUbicacion = '' , -- varchar(25)
			@pMt2 = NULL , -- numeric
			@pRESULT = @pRESULT OUTPUT , -- varchar(300)
			@pTASK_ID = NULL -- numeric
		--
		SELECT @pRESULT
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_REALLOC_FOR_NO_IMMEDIATE_PICKING] (
		@LOGIN_ID VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@MATERIAL_BARCODE VARCHAR(25)
		,@SOURCE_LICENSE NUMERIC(18, 0)
		,@SOURCE_LOCATION VARCHAR(25)
		,@QUANTITY_UNITS NUMERIC(18, 4)
		,@WAVE_PICKING_ID NUMERIC(18, 0)
		,@MT2 NUMERIC(18, 2)
		,@TYPE_LOCATION VARCHAR(25)
		,@TARGET_LOCATION VARCHAR(25)
		,@NEW_LICENSE_ID NUMERIC(18, 0) = 0 OUTPUT
		,@RESULT VARCHAR(500) = '' OUTPUT
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@pTASK_IS_PAUSED INT
		,@pTASK_IS_CANCELED INT
		,@pMATERIAL_ID_LOCAL VARCHAR(50)
		,@pCLIENT_ID_LOCAL VARCHAR(50)
		,@pINV_AVAILABLE NUMERIC(18, 4)
		,@pCODIGO_POLIZA VARCHAR(50)
		,@pREGIMEN VARCHAR(20)
		,@pTaskId NUMERIC
		,@TERMS_OF_TRADE VARCHAR(50)
		,@BATCH VARCHAR(50)
		,@DATE_EXPIRATION DATE
		,@VIN VARCHAR(40)
		,@CURRENT_WAREHOUSE VARCHAR(25)
		,@TARGET_WAREHOUSE VARCHAR(25)
		,@TASK_SUBTYPE VARCHAR(25)
		,@STATUS_NAME VARCHAR(100)
		,@PICKING_DEMAND_HEADER_ID INT
		,@QTY_AVAILABLE_NEW_LICENSE NUMERIC(18, 4)
		,@UPDATE_LICENSE INT = 0
		,@CLIENT_NAME VARCHAR(100)
		,@ALTERNATE_BARCODE VARCHAR(25)
		,@MATERIAL_NAME VARCHAR(100)
		,@HANDLE_BATCH INT
		,@ErrorCode INT
		,@TONE VARCHAR(20) = NULL
		,@CALIBER VARCHAR(20) = NULL;    

	DECLARE	@OPERACION TABLE (
			[RESULTADO] INT
			,[MENSAJE] VARCHAR(250)
			,[CODIGO] INT
			,[DB_DATA] VARCHAR(50)
		);


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

	-- ----------------------------------------------------------------------------------
    -- Obtenemos la poliza de la licencia
    -- ----------------------------------------------------------------------------------
		SELECT TOP 1
			@pCODIGO_POLIZA = [L].[CODIGO_POLIZA]
			,@pREGIMEN = [L].[REGIMEN]
			,@TERMS_OF_TRADE = [IL].[TERMS_OF_TRADE]
			,@CURRENT_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
			,@pCLIENT_ID_LOCAL = [L].[CLIENT_OWNER]
			,@CLIENT_NAME = [C].[CLIENT_NAME]
		FROM
			[wms].[OP_WMS_LICENSES] [L]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [IL].[LICENSE_ID])
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [C].[CLIENT_CODE] = [L].[CLIENT_OWNER]
		WHERE
			[L].[LICENSE_ID] = @SOURCE_LICENSE;


		SELECT TOP 1
			@PICKING_DEMAND_HEADER_ID = [PICKING_DEMAND_HEADER_ID]
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;



    -- ----------------------------------------------------------------------------------
    -- Obtenemos el id del material
    -- ----------------------------------------------------------------------------------
		SELECT TOP 1
			@pMATERIAL_ID_LOCAL = [M].[MATERIAL_ID]
			,@MATERIAL_ID = [M].[MATERIAL_ID]
			,@ALTERNATE_BARCODE = [M].[ALTERNATE_BARCODE]
			,@MATERIAL_NAME = [M].[MATERIAL_NAME]
			,@HANDLE_BATCH = ISNULL([M].[BATCH_REQUESTED], 0)
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		WHERE
			(
				[M].[BARCODE_ID] = @MATERIAL_BARCODE
				OR [M].[ALTERNATE_BARCODE] = @MATERIAL_BARCODE
			)
			AND [M].[CLIENT_OWNER] = @pCLIENT_ID_LOCAL;
    -- ----------------------------------------------------------------------------------
    -- Obtenemos si la tarea esta en pausa
    -- ----------------------------------------------------------------------------------

		SELECT TOP 1
			@pTASK_IS_PAUSED = [TL].[IS_PAUSED]
			,@TASK_SUBTYPE = [TL].[TASK_SUBTYPE]
			,@pTASK_IS_CANCELED = [TL].[IS_CANCELED]
			,@pTaskId = [TL].[SERIAL_NUMBER]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [TL].[MATERIAL_ID] = @MATERIAL_ID;

		SELECT TOP 1
			@CURRENT_WAREHOUSE = [WAREHOUSE_PARENT]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS]
		WHERE
			[LOCATION_SPOT] = @TARGET_LOCATION;
				
    -- ----------------------------------------------------------------------------------
    -- Validamos si la tarea enta en pausa
    -- ----------------------------------------------------------------------------------
		IF (@pTASK_IS_PAUSED <> 0)
		BEGIN
			SELECT
				@RESULT = 'ERROR, Tarea en PAUSA, verifique.';

			SELECT
				-1 AS [Resultado]
				,@RESULT [Mensaje]
				,1234 [Codigo]
				,CAST('' AS VARCHAR) [DbData];
			ROLLBACK;
			RETURN -1; 
		END;
    -- ----------------------------------------------------------------------------------
    -- Validamos si la tarea esta cancelada
    -- ----------------------------------------------------------------------------------
		IF (@pTASK_IS_CANCELED <> 0)
		BEGIN
			SELECT
				@RESULT = 'ERROR, Tarea ha sido cancelada, verifique.';
			SELECT
				-1 AS [Resultado]
				,@RESULT [Mensaje]
				,1234 [Codigo]
				,CAST('' AS VARCHAR) [DbData];
			ROLLBACK;
			RETURN -1; 
		END;
    -- ----------------------------------------------------------------------------------
    -- Validamos el sku
    -- ----------------------------------------------------------------------------------
		IF @pMATERIAL_ID_LOCAL IS NULL
		BEGIN
			SELECT
				@RESULT = 'ERROR, SKU Invalido: ['
				+ @MATERIAL_BARCODE + '/'
				+ @pCLIENT_ID_LOCAL + '] verifique.';
			SELECT
				-1 AS [Resultado]
				,@RESULT [Mensaje]
				,1234 [Codigo]
				,CAST('' AS VARCHAR) [DbData];
			ROLLBACK;
			RETURN -1; 
		END;

    -- ----------------------------------------------------------------------------------
    -- Obtenemos la cantidad del inventario de la licencia
    -- ----------------------------------------------------------------------------------
		SELECT
			@pINV_AVAILABLE = (SELECT TOP 1
									[QTY]
								FROM
									[wms].[OP_WMS_INV_X_LICENSE] [IL]
								WHERE
									[IL].[LICENSE_ID] = @SOURCE_LICENSE
									AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL);

    -- ----------------------------------------------------------------------------------
    -- Validamos si suficiente inventario
    -- ----------------------------------------------------------------------------------
		IF (@pINV_AVAILABLE < @QUANTITY_UNITS)
		BEGIN
			SELECT
				@RESULT = 'ERROR, Inventario insuficiente['
				+ CONVERT(VARCHAR(20), @pINV_AVAILABLE)
				+ '] en licencia origen: ['
				+ CONVERT(VARCHAR(20), @SOURCE_LICENSE)
				+ '] verifique.';
			SELECT
				-1 AS [Resultado]
				,@RESULT [Mensaje]
				,1234 [Codigo]
				,CAST('' AS VARCHAR) [DbData];
			ROLLBACK;
			RETURN -1; 
		END;

    -- ----------------------------------------------------------------------------------
    -- Obtenemos el lote y fecha de expiracion de la licencia
    -- ----------------------------------------------------------------------------------
		SELECT TOP 1
			@BATCH = [IL].[BATCH]
			,@DATE_EXPIRATION = [IL].[DATE_EXPIRATION]
			,@VIN = [IL].[VIN]
			,@STATUS_NAME = [S].[STATUS_CODE]
			,@TONE = [T].[TONE]
			,@CALIBER = [T].[CALIBER]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON [S].[STATUS_ID] = [IL].[STATUS_ID]
		LEFT	 JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [T] ON [T].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
		WHERE
			[IL].[LICENSE_ID] = @SOURCE_LICENSE
			AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

		-- ------------------------------------------------------------------------------------
		-- Agregar inventario a nueva licencia. 
		-- ------------------------------------------------------------------------------------
		EXEC [wms].[OP_WMS_SP_AGREGA_SKU_LICENCIA] @pLICENSE_ID = @NEW_LICENSE_ID,
			@pBARCODE = @MATERIAL_BARCODE,
			@pQTY = @QUANTITY_UNITS,
			@pLAST_LOGIN = @LOGIN_ID, @pVOLUME_FACTOR = 0,
			@pWEIGTH = 0, @pComments = '', @pSerial = '',
			@pAcuerdoComercial = @TERMS_OF_TRADE,
			@pTOTAL_SKUs = 1, @pSTATUS = 'PROCESSED',
			@pResult = @RESULT OUTPUT,
			@DATE_EXPIRATION = @DATE_EXPIRATION,
			@BATCH = @BATCH, @VIN = @VIN,
			@PARAM_NAME = @STATUS_NAME, @TONE = @TONE,
			@CALIBER = @CALIBER;
		IF @RESULT <> 'OK'
		BEGIN
			SELECT
				@RESULT;
			RAISERROR(@RESULT,16,1);
			RETURN -1;
		END;

    -- ----------------------------------------------------------------------------------
    -- Se crea la transaccion del producto ingresado 
    -- ----------------------------------------------------------------------------------
		EXEC [wms].[OP_WMS_SP_REGISTER_INV_TRANS] @pTRADE_AGREEMENT = @TERMS_OF_TRADE,
			@pLOGIN_ID = @LOGIN_ID,
			@pTRANS_TYPE = 'TAREA_REUBICACION',
			@pTRANS_EXTRA_COMMENTS = 'N/A',
			@pMATERIAL_BARCODE = @MATERIAL_BARCODE,
			@pMATERIAL_CODE = @MATERIAL_ID,
			@pSOURCE_LICENSE = @SOURCE_LICENSE,
			@pTARGET_LICENSE = @NEW_LICENSE_ID,
			@pSOURCE_LOCATION = @SOURCE_LOCATION,
			@pTARGET_LOCATION = @TARGET_LOCATION,
			@pCLIENT_OWNER = @pCLIENT_ID_LOCAL,
			@pQUANTITY_UNITS = @QUANTITY_UNITS,
			@pSOURCE_WAREHOUSE = @CURRENT_WAREHOUSE,
			@pTARGET_WAREHOUSE = @TARGET_WAREHOUSE,
			@pTRANS_SUBTYPE = 'ENTREGA_NO_INMEDIATA',
			@pCODIGO_POLIZA = @pCODIGO_POLIZA,
			@pLICENSE_ID = @NEW_LICENSE_ID,
			@pSTATUS = 'PROCESSED', @pTRANS_MT2 = 0,
			@VIN = @VIN, @pRESULT = @RESULT OUTPUT,
			@pTASK_ID = @WAVE_PICKING_ID, @SERIAL = '',
			@BATCH = @BATCH,
			@DATE_EXPIRATION = @DATE_EXPIRATION;
		IF @RESULT <> 'OK'
		BEGIN
			SELECT
				@RESULT;
			RAISERROR(@RESULT,16,1);
			RETURN -1;
		END;

    --    -- ----------------------------------------------------------------------------------
    --    -- Se crea la transaccion de la re-abastecimiento
    --    -- ----------------------------------------------------------------------------------
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
				)
		VALUES
				(
					@TERMS_OF_TRADE
					,GETDATE()
					,@LOGIN_ID
					,(SELECT TOP 1
							[LOGIN_NAME]
						FROM
							[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN_ID))
					,'TAREA_REUBICACION'
					,ISNULL((SELECT
									[PARAM_CAPTION]
								FROM
									[wms].[OP_WMS_FUNC_GETTRANS_DESC]('TAREA_REUBICACION')),
							'TAREA_REUBICACION')
					,NULL
					,@MATERIAL_BARCODE
					,@pMATERIAL_ID_LOCAL
					,(SELECT TOP 1
							[MATERIAL_NAME]
						FROM
							[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@MATERIAL_BARCODE,
											@pCLIENT_ID_LOCAL))
					,NULL
					,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID_LOCAL,
											@pCLIENT_ID_LOCAL)
					,@SOURCE_LICENSE
					,NULL
					,@SOURCE_LOCATION
					,@TARGET_LOCATION
					,@pCLIENT_ID_LOCAL
					,(SELECT TOP 1
							[CLIENT_NAME]
						FROM
							[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_ID_LOCAL))
					,(@QUANTITY_UNITS * -1)
					,@CURRENT_WAREHOUSE
					,@CURRENT_WAREHOUSE
					,'ENTREGA_NO_INMEDIATA'
					,@pCODIGO_POLIZA
					,@SOURCE_LICENSE
					,'PROCESSED'
					,@WAVE_PICKING_ID
					,@WAVE_PICKING_ID
					,0
					,@BATCH
					,@DATE_EXPIRATION
				);


    ---------------------------------------------------------------------------------
    -- Validamos que el producto maneja lote y que no este en la tabla de tareas
    ---------------------------------------------------------------------------------  
		IF (
			NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [TL]
							WHERE
								[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [TL].[MATERIAL_ID] = @MATERIAL_ID
								AND [TL].[LICENSE_ID_SOURCE] = @SOURCE_LICENSE )
			OR EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_TASK_LIST] [TL]
						WHERE
							[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [TL].[MATERIAL_ID] = @MATERIAL_ID
							AND [TL].[LICENSE_ID_SOURCE] = @SOURCE_LICENSE
							AND (
									[TL].[QUANTITY_PENDING] = 0
									OR [TL].[QUANTITY_PENDING] < @QUANTITY_UNITS
								) )
			)
			AND @HANDLE_BATCH = 0
		BEGIN

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
					EXEC [wms].[OP_WMS_SP_VALIDATE_IF_PICKING_LICENSE_IS_AVAILABLE] @WAVE_PICKING_ID = @WAVE_PICKING_ID,
						@CURRENT_LOCATION = @SOURCE_LOCATION,
						@MATERIAL_ID = @MATERIAL_ID,
						@LICENSE_ID = @SOURCE_LICENSE,
						@LOGIN = @LOGIN_ID;

			SELECT TOP 1
				@QTY_AVAILABLE_NEW_LICENSE = ISNULL([QTY_AVAILABLE],
											0)
			FROM
				@AVAILABLE_PICKING_LICENSE;

      ---------------------------------------------------------------------------------
      -- Validamos si todavia hay inventario disponible
      ---------------------------------------------------------------------------------  
			IF @QTY_AVAILABLE_NEW_LICENSE < @QUANTITY_UNITS
			BEGIN
				SELECT
					@RESULT = 'ERROR, Inventario insuficiente['
					+ CONVERT(VARCHAR(20), @QTY_AVAILABLE_NEW_LICENSE)
					+ '] en licencia origen: ['
					+ CONVERT(VARCHAR(20), @SOURCE_LICENSE)
					+ '] verifique.'
					,@ErrorCode = 1201;
				RAISERROR (@RESULT, 16, 1);
			END;

			DECLARE
				@QTY_TOTAL NUMERIC(18, 4) = 0
				,@QTY_TOTAL_PENDING NUMERIC(18, 4) = 0;

			SELECT
				@QTY_TOTAL = SUM([TL].[QUANTITY_ASSIGNED])
				,@QTY_TOTAL_PENDING = SUM([TL].[QUANTITY_PENDING])
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [TL].[MATERIAL_ID] = @MATERIAL_ID;

      ---------------------------------------------------------------------------------
      -- Validamos que si la licencia esta en la tabla de tareas
      ---------------------------------------------------------------------------------  
			IF NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [TL]
							WHERE
								[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [TL].[MATERIAL_ID] = @MATERIAL_ID
								AND [TL].[LICENSE_ID_SOURCE] = @SOURCE_LICENSE )
			BEGIN
				SET @UPDATE_LICENSE = 1;				
				SELECT TOP 1
					@TONE = [APL].[TONE]
					,@CALIBER = [APL].[CALIBER]
				FROM
					@AVAILABLE_PICKING_LICENSE [APL];
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
						)
				SELECT TOP 1
					[TL].[WAVE_PICKING_ID]
					,[TL].[TRANS_OWNER]
					,[TL].[TASK_TYPE]
					,[TL].[TASK_SUBTYPE]
					,[TL].[TASK_OWNER]
					,@LOGIN_ID
					,[TL].[TASK_COMMENTS]
					,[TL].[ASSIGNED_DATE]
					,@QUANTITY_UNITS
					,@QUANTITY_UNITS
					,@pCODIGO_POLIZA
					,[TL].[CODIGO_POLIZA_TARGET]
					,@SOURCE_LICENSE
					,[TL].[REGIMEN]
					,0
					,1
					,0
					,0
					,@MATERIAL_ID
					,@MATERIAL_BARCODE
					,@ALTERNATE_BARCODE
					,@MATERIAL_NAME
					,@CURRENT_WAREHOUSE
					,[TL].[WAREHOUSE_TARGET]
					,@SOURCE_LOCATION
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
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
			END;
			ELSE
			BEGIN
				SET @UPDATE_LICENSE = 1;
        ---------------------------------------------------------------------------------
        -- Actualizamos la cantidad de la licencia
        ---------------------------------------------------------------------------------

        
				UPDATE
					[wms].[OP_WMS_TASK_LIST]
				SET	
					[QUANTITY_PENDING] += @QUANTITY_UNITS
					- [QUANTITY_PENDING]
					,[QUANTITY_ASSIGNED] += @QUANTITY_UNITS
					- [QUANTITY_PENDING]
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [LICENSE_ID_SOURCE] = @SOURCE_LICENSE;

			END;     
		END;

    -- ----------------------------------------------------------------------------------
    -- Se rebaja el inventario de la licencia origen
    -- ----------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[QTY] = [QTY] - @QUANTITY_UNITS
			,[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATED_BY] = @LOGIN_ID
		WHERE
			[LICENSE_ID] = @SOURCE_LICENSE
			AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;



    -- ----------------------------------------------------------------------------------
    -- Se actualiza la licencia origen
    -- ----------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATED_BY] = @LOGIN_ID
			,[USED_MT2] = [USED_MT2] - @MT2
		WHERE
			[LICENSE_ID] = @SOURCE_LICENSE;

		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[CURRENT_LOCATION] = @TARGET_LOCATION
			,[CURRENT_WAREHOUSE] = @CURRENT_WAREHOUSE
			,[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
		WHERE
			[LICENSE_ID] = @NEW_LICENSE_ID;


		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[LOCKED_BY_INTERFACES] = 1
		WHERE
			[LICENSE_ID] = @NEW_LICENSE_ID;

    -- ----------------------------------------------------------------------------------
    -- Valida si la ubicación es de piso
    -- ----------------------------------------------------------------------------------
		IF @TYPE_LOCATION = 'PISO'
		BEGIN
			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[USED_MT2] = @MT2
			WHERE
				[LICENSE_ID] = @NEW_LICENSE_ID;
		END;

    -- ----------------------------------------------------------------------------------
    -- Validamos si el material es master pack
    -- ----------------------------------------------------------------------------------
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MATERIALS] [M]
					WHERE
						[M].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
						AND [M].[IS_MASTER_PACK] = 1 )
		BEGIN
			EXEC [wms].[OP_WMS_INSERT_MASTER_PACK_BY_REALLOC_PARTIAL] @SOURCE_LICENSE = @SOURCE_LICENSE,
				@TARGET_LICENSE = @NEW_LICENSE_ID,
				@MATERIAL_ID = @pMATERIAL_ID_LOCAL,
				@QTY_REALLOC = @QUANTITY_UNITS;
		END;

    -- ----------------------------------------------------------------------------------
    -- Actualizamo la cantidad de la tarea
    -- ----------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[QUANTITY_PENDING] = [QUANTITY_PENDING]
			- @QUANTITY_UNITS
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
			AND [LICENSE_ID_SOURCE] = @SOURCE_LICENSE;


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
				[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [TL].[MATERIAL_ID] = @MATERIAL_ID
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
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [QUANTITY_PENDING] > 0;
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
					[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [TL].[MATERIAL_ID] = @MATERIAL_ID
					AND [TL].[QUANTITY_PENDING] > 0;

				DECLARE
					@QUANTITY_PENDING NUMERIC(18, 4) = 0
					,@QUANTITY_ASSIGNED NUMERIC(18, 4) = 0
					,@LICENSE_ID_SOURCE INT;

        ---------------------------------------------------------------------------------
        -- Recorremos las licencias para ajustarlas
        ---------------------------------------------------------------------------------

				SET @QTY_PENDING = CASE	WHEN (@QTY_TOTAL_PENDING
											- @QUANTITY_UNITS) = 0
										THEN @QUANTITY_UNITS
										ELSE (@QTY_TOTAL_PENDING
											- @QUANTITY_UNITS)
									END;
        
				WHILE @QTY_PENDING > 0
				BEGIN

					SELECT TOP 1
						@QUANTITY_PENDING = [QUANTITY_PENDING]
						,@QUANTITY_ASSIGNED = [QUANTITY_ASSIGNED]
						,@LICENSE_ID_SOURCE = [L].[LICENSE_ID]
					FROM
						@LICENSES [L];

					IF (@QUANTITY_PENDING <= @QTY_PENDING)
					BEGIN
						SET @QTY_PENDING -= @QUANTITY_PENDING;

						IF ((@QTY_TOTAL_PENDING
							- @QUANTITY_UNITS)) = 0
						BEGIN
							UPDATE
								[wms].[OP_WMS_TASK_LIST]
							SET	
								[QUANTITY_PENDING] -= @QUANTITY_PENDING
								,[QUANTITY_ASSIGNED] -= @QUANTITY_PENDING
							WHERE
								[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [MATERIAL_ID] = @MATERIAL_ID
								AND [LICENSE_ID_SOURCE] = @LICENSE_ID_SOURCE;
						END;

					END;
					ELSE
					BEGIN
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
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
							AND [LICENSE_ID_SOURCE] = @LICENSE_ID_SOURCE;
						SET @QTY_PENDING = 0;
					END;

					DELETE
						@LICENSES
					WHERE
						[LICENSE_ID] = @LICENSE_ID_SOURCE;

				END;
        
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
					[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;          

			END;

			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[IS_COMPLETED] = 1
				,[COMPLETED_DATE] = GETDATE()
			WHERE
				[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [QUANTITY_PENDING] = 0
				AND [IS_COMPLETED] = 0;

			DELETE
				[wms].[OP_WMS_TASK_LIST]
			WHERE
				[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [QUANTITY_PENDING] = 0
				AND [QUANTITY_ASSIGNED] = 0;

		END;

    -- ----------------------------------------------------------------------------------
    -- Validamos si podemos finalizar la tarea
    -- ----------------------------------------------------------------------------------    
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_TASK_LIST] [T]
					WHERE
						[T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [T].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
						AND [T].[LICENSE_ID_SOURCE] = @SOURCE_LICENSE
						AND [T].[QUANTITY_PENDING] <= 0 )
		BEGIN
			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[IS_COMPLETED] = 1
				,[COMPLETED_DATE] = GETDATE()
			WHERE
				[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [LICENSE_ID_SOURCE] = @SOURCE_LICENSE;

		END;		

		COMMIT TRANSACTION;

		SELECT
			@RESULT = 'OK';

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('1' AS VARCHAR) [DbData];

	END TRY
	BEGIN CATCH

		PRINT ERROR_MESSAGE();
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END; 
			

		SELECT
			@ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@ErrorCode AS [Codigo]
			,CAST('' AS VARCHAR) [DbData];

		SELECT
			@RESULT = ERROR_MESSAGE();
	END CATCH;

END;