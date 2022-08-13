-- =============================================
-- Autor:					juancarlos.escalante
-- Fecha de Creacion: 		#001 03-10-2016 @ A-TEAM Sprint 2
-- Description:			    Se modificó el insert para que se registre el id de la tarea

-- Modificacion 02-Nov-16 @ A-Team Sprint 4
-- alberto.ruiz
-- Se ajusto el campo de COMPLETED_DATE

-- Modificacion 03-Nov-16 @ A-Team Sprint 4
-- hector.gonzalez
-- Se agrego la columna IS_FROM_SONDA 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 lLLAMAR A SP OP_WMS_SP_DISPATCH_MASTER_PACK

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-13 ErgonTeam@Sheik
-- Description:	 Se adjunta cambio en la forma que se ejecuta un error, y se elimina validación de tarea pausada. 


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-15 ErgonTeam@BreathOfTheWild
-- Description:	 Validar que si el material maneja serie, realizar de diferente forma el insert de la transacción para que genere una linea por cada serie que este involucrada en el picking, verificando la tabla tabla de [OP_WMS_MATERIAL_X_SERIAL_NUMBER], donde las series esten estado 2 (EN_PROCESO) donde corresponda la licencia y el material, con cantidad de 1. 


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-09-02 Nexus@CommandAndConquer
-- Description:	 Se modificó para que almacene el transfer request id y el source type en caso aplique. 

-- Modificacion 9/22/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega top 1 a todos los subqueries

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-11-08 @ Team REBORN - Sprint Eberhard
-- Description:	   Se modifica para que se pueda pickear de cualquier licencia

-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	20-Dec-2017 @ Team REBORN - Sprint Quiterio
-- Description:	   Se modifico la actualicion de los metros cuadrados para que este reste.

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:
        DECLARE @pRESULT VARCHAR(300)
		--
		EXEC [wms].[OP_WMS_SP_REGISTER_DISPATCH_GENERAL] 
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
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_DISPATCH_GENERAL] (
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
		,@VIN VARCHAR(40);

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



		SELECT TOP 1
			@LOGIN_NAME = [D].[LOGIN_NAME]
		FROM
			[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID) [D];


		SELECT TOP 1
			@pCLIENT_ID_LOCAL = [L].[CLIENT_OWNER]
			,@CLIENT_NAME = [C].[CLIENT_NAME]
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


		SELECT TOP 1
			@pINV_AVAILABLE = [IL].[QTY]
			,@BATCH = [IL].[BATCH]
			,@DATE_EXPIRATION = [IL].[DATE_EXPIRATION]
			,@TERMS_OF_TRADE = [IL].[TERMS_OF_TRADE]
			,@VIN = [IL].[VIN]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		WHERE
			[IL].[LICENSE_ID] = @pSOURCE_LICENSE
			AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;


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
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

      ---------------------------------------------------------------------------------
      -- Validamos que si la licencia esta en la tabla de tareas
      ---------------------------------------------------------------------------------  
			IF NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [TL]
							WHERE
								[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
								AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
								AND [TL].[LICENSE_ID_SOURCE] = @pSOURCE_LICENSE )
			BEGIN
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
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID;
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
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [TL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [TL].[QUANTITY_PENDING] > 0;

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

					IF (@QUANTITY_PENDING <= @QTY_PENDING)
					BEGIN
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
				AND [QUANTITY_ASSIGNED] = 0;

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
							[L].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID )
			BEGIN

        ---------------------------------------------------------------------------------
        -- Declaramos las variables necesarias
        ---------------------------------------------------------------------------------    
				DECLARE
					@LOCATION_SPOT_TARGET VARCHAR(25)
					,@LICENSE_ID INT
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
					@LICENSE_ID = [L].[LICENSE_ID]
				FROM
					[wms].[OP_WMS_LICENSES] [L]
				WHERE
					[L].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID;

				SELECT TOP 1
					@LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET]
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					[TL].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID;


				SELECT TOP 1
					@VOLUME_FACTOR = [M].[VOLUME_FACTOR]
					,@BARCODE_ID = [M].[BARCODE_ID]
				FROM
					[wms].[OP_WMS_MATERIALS] [M]
				WHERE
					[M].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

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
					AND [NUMERIC_VALUE] = 1;


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
							,@LICENSE_ID
							
						);


				SET @STATUS_ID = SCOPE_IDENTITY();

        ---------------------------------------------------------------------------------
        -- Validamos si la licencia con el producto ya fue ingresada
        ---------------------------------------------------------------------------------    
				IF EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_INV_X_LICENSE] [IL]
							WHERE
								[IL].[LICENSE_ID] = @LICENSE_ID
								AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL )
				BEGIN
					UPDATE
						[wms].[OP_WMS_INV_X_LICENSE]
					SET	
						[QTY] = [QTY] + @pQUANTITY_UNITS
					WHERE
						[LICENSE_ID] = @LICENSE_ID
						AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;
				END;
				ELSE
				BEGIN
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
								@LICENSE_ID
								,@pMATERIAL_ID_LOCAL
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
								,NULL
								,0
								
							);
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
			,CAST('' AS VARCHAR) [DbData];

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