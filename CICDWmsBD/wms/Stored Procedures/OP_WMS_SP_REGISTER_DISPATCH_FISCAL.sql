-- =============================================
-- Autor:					juancarlos.escalante
-- Fecha de Creacion: 		03-10-2016 @ A-TEAM Sprint 2
-- Description:			    Se modificó el insert para que se registre el id de la tarea

-- Modificacion 02-Nov-16 @ A-Team Sprint 4
-- alberto.ruiz
-- Se ajusto el campo de COMPLETED_DATE

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 lLLAMAR A SP OP_WMS_SP_DISPATCH_MASTER_PACK

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion


/*
-- Ejemplo de Ejecucion:
		DECLARE @pRESULT VARCHAR(300)
		--
		EXEC [wms].[OP_WMS_SP_REGISTER_DISPATCH_FISCAL] 
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
			@pRESULT = @pRESULT OUTPUT, -- varchar(300)
			@pTASK_ID = NULL -- numeric
		--
		SELECT @pRESULT
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_DISPATCH_FISCAL] (
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

	DECLARE	@ErrorMessage NVARCHAR(4000);
	DECLARE	@ErrorSeverity INT;
	DECLARE	@ErrorState INT;
	DECLARE	@pTASK_IS_PAUSED INT;
	DECLARE	@pTASK_IS_CANCELED INT;
	DECLARE	@pSKUQtyPending NUMERIC(18, 0);
	DECLARE	@pMATERIAL_ID_LOCAL VARCHAR(50);
	DECLARE	@pCLIENT_ID_LOCAL VARCHAR(25);
	DECLARE
		@BATCH VARCHAR(50)
		,@DATE_EXPIRATION DATETIME;
	BEGIN TRY

		SELECT
			@pTASK_IS_PAUSED = (SELECT
									[IS_PAUSED]
								FROM
									[wms].[OP_WMS_TASK_LIST]
								WHERE
									[SERIAL_NUMBER] = @pSERIAL_NUMBER);

		SELECT
			@pTASK_IS_CANCELED = (SELECT
										[IS_CANCELED]
									FROM
										[wms].[OP_WMS_TASK_LIST]
									WHERE
										[SERIAL_NUMBER] = @pSERIAL_NUMBER);

		IF (@pTASK_IS_PAUSED <> 0)
		BEGIN
			SELECT
				@pRESULT = 'ERROR, Tarea en PAUSA, verifique.';
			RETURN -1;
		END;

		IF (@pTASK_IS_CANCELED <> 0)
		BEGIN
			SELECT
				@pRESULT = 'ERROR, Tarea ha sido cancelada, verifique.';
			RETURN -1;
		END;

		SELECT
			@pCLIENT_ID_LOCAL = (SELECT
										[CLIENT_OWNER]
									FROM
										[wms].[OP_WMS_LICENSES]
									WHERE
										[LICENSE_ID] = @pSOURCE_LICENSE);

		SELECT
			@pMATERIAL_ID_LOCAL = (SELECT
										[MATERIAL_ID]
									FROM
										[wms].[OP_WMS_MATERIALS]
									WHERE
										(
											[BARCODE_ID] = @pMATERIAL_BARCODE
											OR [ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
										)
										AND [CLIENT_OWNER] = @pCLIENT_ID_LOCAL);

		IF @pMATERIAL_ID_LOCAL IS NULL
		BEGIN
			SELECT
				@pRESULT = 'ERROR, SKU Invalido: ['
				+ @pMATERIAL_BARCODE + '] verifique.';
			RETURN -1;
		END;


		BEGIN TRANSACTION;

			SELECT TOP 1
				@BATCH = [IL].[BATCH]
				,@DATE_EXPIRATION = [IL].[DATE_EXPIRATION]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			WHERE
				[IL].[LICENSE_ID] = @pSOURCE_LICENSE
				AND @pMATERIAL_ID = [IL].[BARCODE_ID];

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
    -- Inicio Modificacion #001
						,[TASK_ID]
						,[BATCH]
						,[DATE_EXPIRATION]
    -- Fin Modificacion #001
					)
			VALUES
					(
						ISNULL((SELECT
									[TERMS_OF_TRADE]
								FROM
									[wms].[OP_WMS_INV_X_LICENSE]
								WHERE
									[LICENSE_ID] = @pSOURCE_LICENSE
									AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL),
								'N/A')
						,GETDATE()
						,@pLOGIN_ID
						,(SELECT
								*
							FROM
								[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID))
						,'DESPACHO_FISCAL'
						,ISNULL((SELECT
										[PARAM_CAPTION]
									FROM
										[wms].[OP_WMS_FUNC_GETTRANS_DESC]('DESPACHO_FISCAL')),
								'DESPACHO FISCAL')
						,NULL
						,@pMATERIAL_BARCODE
						,@pMATERIAL_ID_LOCAL
						,(SELECT
								*
							FROM
								[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE,
											@pCLIENT_OWNER))
						,NULL
						,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID_LOCAL,
											@pCLIENT_ID_LOCAL)
						,@pSOURCE_LICENSE
						,NULL
						,@pSOURCE_LOCATION
						,'PUERTA_1'
						,@pCLIENT_ID_LOCAL
						,(SELECT
								*
							FROM
								[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_ID_LOCAL))
						,(@pQUANTITY_UNITS * -1)
						,ISNULL((SELECT
										ISNULL([WAREHOUSE_PARENT],
											'BODEGA_DEF')
									FROM
										[wms].[OP_WMS_SHELF_SPOTS]
									WHERE
										[LOCATION_SPOT] = @pSOURCE_LOCATION),
								'BODEGA_DEF')
						,NULL
						,'PICKING'
						,@pCODIGO_POLIZA
						,@pSOURCE_LICENSE
						,'PROCESSED'
						,@pWAVE_PICKING_ID
      -- Inicio Modificacion #001
						,@pTASK_ID
						,@BATCH
						,@DATE_EXPIRATION
      -- Fin Modificacion #001
					);

			UPDATE
				[wms].[OP_WMS_INV_X_LICENSE]
			SET	
				[QTY] = [QTY] - @pQUANTITY_UNITS
				,[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @pLOGIN_ID
			WHERE
				[LICENSE_ID] = @pSOURCE_LICENSE
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_MATERIALS] [M]
						WHERE
							[M].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
							AND [M].[IS_MASTER_PACK] = 1 )
			BEGIN
				EXEC [wms].[OP_WMS_SP_DISPATCH_MASTER_PACK] @MATERIAL_ID = @pMATERIAL_ID_LOCAL,
					@LICENCE_ID = @pSOURCE_LICENSE,
					@QTY_DISPATCH = @pQUANTITY_UNITS;
			END;


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
					[USED_MT2] = @pMt2
				WHERE
					[LICENSE_ID] = @pSOURCE_LICENSE;
			END;

			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[QUANTITY_PENDING] = [QUANTITY_PENDING]
				- @pQUANTITY_UNITS
			WHERE
				[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
				AND [LICENSE_ID_SOURCE] = @pSOURCE_LICENSE
				AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [CODIGO_POLIZA_TARGET] = @pCODIGO_POLIZA;

			SELECT
				@pSKUQtyPending = (SELECT
										SUM([QUANTITY_PENDING])
									FROM
										[wms].[OP_WMS_TASK_LIST]
									WHERE
										[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
										AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
										AND [CODIGO_POLIZA_TARGET] = @pCODIGO_POLIZA);

			IF (@pSKUQtyPending <= 0)
			BEGIN
				UPDATE
					[wms].[OP_WMS_TASK_LIST]
				SET	
					[IS_COMPLETED] = 1
					,[COMPLETED_DATE] = GETDATE()
				WHERE
					[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [CODIGO_POLIZA_TARGET] = @pCODIGO_POLIZA
					AND [LICENSE_ID_SOURCE] = @pSOURCE_LICENSE;

				COMMIT TRANSACTION;

				DELETE FROM
					[wms].[OP_WMS_TASK_LIST]
				WHERE
					[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
					AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [CODIGO_POLIZA_TARGET] = @pCODIGO_POLIZA
					AND [IS_COMPLETED] = 0
					AND [QUANTITY_PENDING] = 0;
			END;
			ELSE
			BEGIN

				SELECT
					@pSKUQtyPending = (SELECT
											COUNT(1)
										FROM
											[wms].[OP_WMS_TASK_LIST]
										WHERE
											[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
											AND [IS_COMPLETED] = 1
											AND [COMPLETED_DATE] IS NOT NULL);

				IF (@pSKUQtyPending = 0)
				BEGIN
					UPDATE
						[wms].[OP_WMS_TASK_LIST]
					SET	
						[COMPLETED_DATE] = GETDATE()
					WHERE
						[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
						AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
						AND [CODIGO_POLIZA_TARGET] = @pCODIGO_POLIZA
						AND [LICENSE_ID_SOURCE] = @pSOURCE_LICENSE;
				END;

				COMMIT TRANSACTION;
			END;

			SELECT
				@pRESULT = 'OK';

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;
			SELECT
				@pRESULT = ERROR_MESSAGE();
		END CATCH;

	END;