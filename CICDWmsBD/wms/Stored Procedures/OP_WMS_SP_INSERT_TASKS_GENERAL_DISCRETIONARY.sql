-- =============================================
-- Autor:	       ....
-- Fecha de Creacion: ....
-- Description:	        ....

-- Modificado:	        pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint EPONA
-- Description:	        Se modifica para que busque en la vista donde no le importe la fecha de vencimiento.  

-- Modificado:	        hector.gonzalez
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint BreathOfTheWild
-- Description:	        se agrega parametro SERIAL_NUMBER y update final a tabla [OP_WMS_MATERIAL_X_SERIAL_NUMBER]

-- Modificacion 28-Nov-2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rudi.garcia
					-- Se agregaron los campos de TONE y CALIBER

-- Modificacion:		henry.rodriguez
-- Fecha:				19-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrega parametro de PROJECT_ID cuando sea discrecional por proyecto y validacion correspondiente.

-- Modificacion:		henry.rodriguez
-- Fecha:				25-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrega campo Status_Code en insert a taskList.

-- Modificacion			henry.rodriguez
-- Fecha				29-Julio-2019 G-Force@Dublin
-- Descripcion			Se agrega ORDER_NUMBER en insert de task list.

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			asigno la ubicacion de salida al egreso discresional

/*
-- Ejemplo de Ejecucion:
			
 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_DISCRETIONARY]
	@TASK_OWNER VARCHAR(25)
	,@TASK_ASSIGNEDTO VARCHAR(25)
	,@QUANTITY_ASSIGNED NUMERIC(18, 4)
	,@CODIGO_POLIZA_TARGET VARCHAR(25)
	,@MATERIAL_ID VARCHAR(25)
	,@BARCODE_ID VARCHAR(50)
	,@ALTERNATE_BARCODE VARCHAR(50)
	,@MATERIAL_NAME VARCHAR(200)
	,@CLIENT_OWNER VARCHAR(25)
	,@CLIENT_NAME VARCHAR(150)
	,@PRESULT VARCHAR(4000) OUTPUT
	,@WAVE_PICKING_ID NUMERIC(18, 0) OUTPUT
--
	,@LICENSE_ID NUMERIC(18, 0)
	,@TypeDiscretionary VARCHAR(100)
	,@SERIAL_NUMBER VARCHAR(50) = NULL
	,@TONE VARCHAR(20) = NULL
	,@CALIBER VARCHAR(20) = NULL
	,@PROJECT_ID UNIQUEIDENTIFIER = NULL
	,@LOCATION_SPOT_TARGET VARCHAR(50)
AS
BEGIN
  --@CURRENT_LOCATION,@CURRENT_WAREHOUSE,@LICENSE_ID,@CODIGO_POLIZA_SOURCE;
	DECLARE	@WPI NUMERIC(18, 0);
	DECLARE	@ASSIGNED_DATE DATETIME;
	DECLARE	@CURRENT_LOCATION VARCHAR(25);
	DECLARE	@CURRENT_WAREHOUSE VARCHAR(25);
  --DECLARE @LICENSE_ID NUMERIC(18,0);
	DECLARE	@TASK_COMMENTS VARCHAR(150);
	DECLARE	@CODIGO_POLIZA_SOURCE VARCHAR(25);
	DECLARE	@TASK_TYPE VARCHAR(25);
	DECLARE	@TASK_SUBTYPE VARCHAR(25);
	DECLARE	@QUANTITY_PENDING NUMERIC(18, 4);
  --DECLARE @HAVBATCH NUMERIC(18);
	DECLARE
		@PROJECT_CODE VARCHAR(50)
		,@PROJECT_NAME VARCHAR(150)
		,@PROJECT_SHORT_NAME VARCHAR(25)
		,@STATUS_CODE VARCHAR(50)
		,@ORDER_NUMBER VARCHAR(25);

	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN;

		SELECT
			@ASSIGNED_DATE = GETDATE();
		SELECT
			@TASK_TYPE = 'TAREA_PICKING';
		SELECT
			@TASK_SUBTYPE = 'DESPACHO_GENERAL';
		SELECT
			@QUANTITY_PENDING = @QUANTITY_ASSIGNED;

		IF @WAVE_PICKING_ID = 0
		BEGIN
			SELECT
				@WAVE_PICKING_ID = NEXT VALUE FOR [wms].[OP_WMS_SEQ_WAVE_PICKING_ID]; 
		END;
		IF @WPI = NULL
		BEGIN
			SET @WPI = 1;
		END;

		IF @WAVE_PICKING_ID = 0
		BEGIN
			SET @WAVE_PICKING_ID = @WPI;
		END;
		ELSE
		BEGIN
			SET @WPI = @WAVE_PICKING_ID;
		END;

		-- ------------------------------------------------------------------------------------
		-- OBTENEMOS EL NUMERO DE ORDEN QUE SE INGRESO
		-- ------------------------------------------------------------------------------------
		SELECT
			@ORDER_NUMBER = [NUMERO_ORDEN]
		FROM
			[wms].[OP_WMS_POLIZA_HEADER]
		WHERE
			[CODIGO_POLIZA] = @CODIGO_POLIZA_TARGET;

		-- ----------------------------------------------------------------------
		-- OBTIENE EL ESTADO DE LA LICENCIA
		-- ----------------------------------------------------------------------
		SELECT
			@STATUS_CODE = [SML].[STATUS_CODE]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON (
											[IL].[STATUS_ID] = [SML].[STATUS_ID]
											AND [IL].[LICENSE_ID] = [SML].[LICENSE_ID]
											)
		WHERE
			[IL].[LICENSE_ID] = @LICENSE_ID
			AND [IL].[MATERIAL_ID] = @MATERIAL_ID;

		-- ----------------------------------------------------------------------
		-- SI MANEJA PROJECTO OBTENEMOS LA INFORMACION DEL PROYECTO.
		-- ----------------------------------------------------------------------
		IF @PROJECT_ID IS NOT NULL
		BEGIN
			SELECT
				@PROJECT_CODE = [OPPORTUNITY_CODE]
				,@PROJECT_NAME = [OPPORTUNITY_NAME]
				,@PROJECT_SHORT_NAME = [SHORT_NAME]
			FROM
				[wms].[OP_WMS_PROJECT]
			WHERE
				[ID] = @PROJECT_ID;

			-- ------------------------------
			-- OBTIENE EL CLIENT_OWNER Y CLIENT_NAME DE LA LICENCIA.
			-- ------------------------------
			SELECT
				@CLIENT_OWNER = [VC].[CLIENT_CODE]
				,@CLIENT_NAME = [VC].[CLIENT_NAME]
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC] ON ([L].[CLIENT_OWNER] = [VC].[CLIENT_CODE])
			WHERE
				[LICENSE_ID] = @LICENSE_ID;

		END;
		--
		IF NOT EXISTS ( SELECT
							1
						FROM
							[wms].[OP_WMS_VIEW_INVENTORY_GENERAL_BY_MATERIALS]
						WHERE
							[CLIENT_OWNER] = @CLIENT_OWNER
							AND [MATERIAL_ID] = @MATERIAL_ID
							AND [LICENSE_ID] = @LICENSE_ID
							AND [QTY] > 0
							AND (
									[SERIAL] = @SERIAL_NUMBER
									OR @SERIAL_NUMBER IS NULL
								) )
		BEGIN
			SELECT
				@PRESULT = 'ERROR, NO VIEW_PICKING_AVAILABLE_GENERAL. CLIENTE: '
				+ @CLIENT_NAME + ' SKU: ' + @MATERIAL_ID;
			ROLLBACK TRAN;
			RETURN -1;
		END;

		SELECT
			@CURRENT_LOCATION = (SELECT
										[CURRENT_LOCATION]
									FROM
										[wms].[OP_WMS_LICENSES]
									WHERE
										[LICENSE_ID] = @LICENSE_ID);
		SELECT
			@CURRENT_WAREHOUSE = (SELECT
										[CURRENT_WAREHOUSE]
									FROM
										[wms].[OP_WMS_LICENSES]
									WHERE
										[LICENSE_ID] = @LICENSE_ID);
		SELECT
			@CODIGO_POLIZA_SOURCE = (SELECT
											[CODIGO_POLIZA]
										FROM
											[wms].[OP_WMS_LICENSES]
										WHERE
											[LICENSE_ID] = @LICENSE_ID);
		SELECT
			@TASK_COMMENTS = 'OLA DE PICKING #'
			+ CAST(@WPI AS VARCHAR);


		BEGIN
			IF EXISTS ( SELECT
							1
						FROM
							[wms].[OP_WMS_TASK_LIST]
						WHERE
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [CODIGO_POLIZA_SOURCE] = @CODIGO_POLIZA_SOURCE
							AND [CODIGO_POLIZA_TARGET] = @CODIGO_POLIZA_TARGET
							AND [LICENSE_ID_SOURCE] = @LICENSE_ID
							AND [MATERIAL_ID] = @MATERIAL_ID
							AND [PROJECT_ID] = @PROJECT_ID )
			BEGIN
				DECLARE	@vCURRENT_ASSIGNED NUMERIC(18, 2);

				UPDATE
					[wms].[OP_WMS_TASK_LIST]
				SET	
					[QUANTITY_PENDING] = [QUANTITY_PENDING]
					+ @QUANTITY_PENDING
					,[QUANTITY_ASSIGNED] = [QUANTITY_ASSIGNED]
					+ @QUANTITY_ASSIGNED
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [CODIGO_POLIZA_SOURCE] = @CODIGO_POLIZA_SOURCE
					AND [CODIGO_POLIZA_TARGET] = @CODIGO_POLIZA_TARGET
					AND [LICENSE_ID_SOURCE] = @LICENSE_ID
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [PROJECT_ID] = @PROJECT_ID;


			END;
			ELSE
			BEGIN
				INSERT	INTO [wms].[OP_WMS_TASK_LIST]
						(
							[WAVE_PICKING_ID]
							,[TASK_TYPE]
							,[TASK_SUBTYPE]
							,[TASK_OWNER]
							,[TASK_ASSIGNEDTO]
							,[ASSIGNED_DATE]
							,[QUANTITY_PENDING]
							,[QUANTITY_ASSIGNED]
							,[CODIGO_POLIZA_SOURCE]
							,[CODIGO_POLIZA_TARGET]
							,[LICENSE_ID_SOURCE]
							,[REGIMEN]
							,[IS_DISCRETIONAL]
							,[MATERIAL_ID]
							,[BARCODE_ID]
							,[ALTERNATE_BARCODE]
							,[MATERIAL_NAME]
							,[WAREHOUSE_SOURCE]
							,[LOCATION_SPOT_SOURCE]
							,[CLIENT_OWNER]
							,[CLIENT_NAME]
							,[TASK_COMMENTS]
							,[TRANS_OWNER]
							,[IS_COMPLETED]
							,[MATERIAL_SHORT_NAME]
							,[IS_DISCRETIONARY]
							,[TYPE_DISCRETIONARY]
							,[TONE]
							,[CALIBER]
							,[STATUS_CODE]
							,[PROJECT_ID]
							,[PROJECT_CODE]
							,[PROJECT_NAME]
							,[PROJECT_SHORT_NAME]
							,[ORDER_NUMBER]
							,[LOCATION_SPOT_TARGET]

						)
				VALUES
						(
							@WAVE_PICKING_ID
							,@TASK_TYPE
							,@TASK_SUBTYPE
							,@TASK_OWNER
							,@TASK_ASSIGNEDTO
							,@ASSIGNED_DATE
							,@QUANTITY_PENDING
							,@QUANTITY_ASSIGNED
							,@CODIGO_POLIZA_SOURCE
							,@CODIGO_POLIZA_TARGET
							,@LICENSE_ID
							,'GENERAL'
							,1
							,@MATERIAL_ID
							,@BARCODE_ID
							,@ALTERNATE_BARCODE
							,@MATERIAL_NAME
							,@CURRENT_WAREHOUSE
							,@CURRENT_LOCATION
							,@CLIENT_OWNER
							,@CLIENT_NAME
							,@TASK_COMMENTS
							,0
							,0
							,@MATERIAL_NAME
							,'1'
							,@TypeDiscretionary
							,@TONE
							,@CALIBER
							,@STATUS_CODE
							,@PROJECT_ID
							,@PROJECT_CODE
							,@PROJECT_NAME
							,@PROJECT_SHORT_NAME
							,@ORDER_NUMBER
							,@LOCATION_SPOT_TARGET
						);

			END;
      -- ------------------------------------------------------------------------------------
      -- Se apartan las series
      -- ------------------------------------------------------------------------------------

			IF @SERIAL_NUMBER IS NOT NULL
				AND @SERIAL_NUMBER <> ''
			BEGIN
				UPDATE
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				SET	
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				WHERE
					[SERIAL] = @SERIAL_NUMBER
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [LICENSE_ID] = @LICENSE_ID
					AND [STATUS] = 1;
			END;

      -- ------------------------------------------------------------------------------------
      -- Se Obtiene olas de picking del material y licencia
      -- ------------------------------------------------------------------------------------

			DECLARE	@OLAS_PICKING TABLE (
					[WAVE_PICKING_ID] NUMERIC
				);
			INSERT	INTO @OLAS_PICKING
					(
						[WAVE_PICKING_ID]
					)
			SELECT
				[TL].[WAVE_PICKING_ID]
			FROM
				[wms].[OP_WMS_TASK_LIST] AS [TL]
			WHERE
				[TL].[MATERIAL_ID] = @MATERIAL_ID
				AND [TL].[LICENSE_ID_SOURCE] = @LICENSE_ID
				AND [TL].[IS_DISCRETIONARY] = 0
				AND [TL].[PROJECT_ID] = @PROJECT_ID
			GROUP BY
				[TL].[WAVE_PICKING_ID];

      --          WHILE EXISTS ( SELECT TOP 1
      --                          1
      --                         FROM
      --                          @OLAS_PICKING )
      --          BEGIN

      --              SELECT TOP 1
      --                  @WAVE_PICKING_ID = [WAVE_PICKING_ID]
      --              FROM
      --                  @OLAS_PICKING;

      ---- ------------------------------------------------------------------------------------
      ---- Se rebaja el detalle de la demanda de despacho
      ---- ------------------------------------------------------------------------------------
      --              EXEC [wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE] @LOGIN_ID = @TASK_ASSIGNEDTO,
      --                  @WAVE_PICKING_ID = @WAVE_PICKING_ID,
      --                  @MATERIAL_ID = @MATERIAL_ID;
      --              DELETE FROM
      --                  @OLAS_PICKING
      --              WHERE
      --                  [WAVE_PICKING_ID] = @WAVE_PICKING_ID;
      --          END;




		END;


		SELECT
			@PRESULT = 'OK';
		SELECT
			@WAVE_PICKING_ID = @WPI;

		COMMIT TRAN;
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT
			@PRESULT = ERROR_MESSAGE();
	END CATCH;

END;