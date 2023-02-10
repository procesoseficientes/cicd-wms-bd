-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-02 @ Team ERGON - Sprint GANONDORF
-- Description:	        Crea tareas de reubicacion 

-- Modificacion 22-Dec-17 @ Nexus Team Sprint @IceAge
-- pablo.aguilar
-- Se agrega if para realizar el ultimo top 1 ordenado segun la regla de batch o qty mas pequeña.

-- Modificación:				Elder Lucas
-- Fecha Modificació:			16 de agosto 2022
-- Descripción:					Se obtiene usuario por defecto segun bodega de destino del reabastecimiento

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_CREATE_REPLEANISH_TASK] @MATERIAL_ID = 'C00277/MILAN-16M'
                                                       ,@WAVE_PICKING_ID = 0
                                                       ,@TARGET_ZONE = 'Z_BODEGA_01'
                                                       ,@TARGET_LOCATION = 'B11-P03-F01-NU'
                                                       ,@QTY = '2'
                                                       ,@TASK_SUB_TYPE = 'REUBICACION_LP'
                                                       ,@PRESULT = ''
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_REPLEANISH_TASK] (
		@MATERIAL_ID VARCHAR(25)
		,@WAVE_PICKING_ID NUMERIC(18, 0) OUTPUT
		,@TARGET_ZONE VARCHAR(25)
		,@TARGET_LOCATION VARCHAR(25)
		,@MATERIAL_ID_TARGET VARCHAR(25) = NULL
		,@QTY VARCHAR(50)
		,@TASK_SUB_TYPE VARCHAR(25)
		,@PRESULT VARCHAR(4000) OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@HAVBATCH NUMERIC(18) = 0
		,@QUANTITY_PENDING NUMERIC(18, 4)
		,@TASK_TYPE VARCHAR(25)
		,@ASSIGNED_DATE DATETIME
		,@CURRENT_ASSIGNED NUMERIC(18, 2)
		,@LICENSE_ID NUMERIC(18, 0)
		,@BARCODE_ID VARCHAR(50)
		,@ALTERNATE_BARCODE VARCHAR(50) = ''
		,@MATERIAL_NAME VARCHAR(200)
		,@CURRENT_WAREHOUSE VARCHAR(25)
		,@CURRENT_LOCATION VARCHAR(25)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@CODIGO_POLIZA_SOURCE VARCHAR(25)
		,@TASK_COMMENTS VARCHAR(150)
		,@WAREHOUSE_TARGET VARCHAR(25);

	DECLARE	@LICENCIAS TABLE (
			[CURRENT_LOCATION] VARCHAR(25)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[LICENSE_ID] NUMERIC
			,[CODIGO_POLIZA] VARCHAR(25)
			,[QTY] NUMERIC
			,[DATE_BASE] DATETIME
		);

		PRINT '@TARGET_ZONE: '+@TARGET_ZONE

		SELECT
			[DZ].[ZONE]
		INTO
			[#ZONES_FOR_REALLOC]
		FROM
			[wms].[OP_WMS_ZONE] [Z] WITH (NOLOCK)
		INNER JOIN [wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] [ZR] WITH (NOLOCK) ON [ZR].REPLENISH_ZONE_ID = [Z].[ZONE_ID]
		INNER JOIN [wms].[OP_WMS_ZONE] [DZ] WITH (NOLOCK) ON [ZR].[ZONE_ID] = [DZ].[ZONE_ID]
		WHERE
			[Z].[ZONE] = @TARGET_ZONE;




	SELECT
		@ASSIGNED_DATE = GETDATE()
		,@TASK_TYPE = 'TAREA_REUBICACION'
		,@QUANTITY_PENDING = @QTY;


	--IF @WAVE_PICKING_ID = 0
	--BEGIN
		SELECT @WAVE_PICKING_ID = NEXT VALUE FOR [wms].[OP_WMS_SEQ_WAVE_PICKING_ID]; 

	--END;


	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL]
					WHERE
						[MATERIAL_ID] = @MATERIAL_ID
						AND [QTY] > 0 )
	BEGIN
		SELECT
			@PRESULT = 'ERROR, No cuenta con inventario suficiente para continuar con la operación del SKU: '
			+ @MATERIAL_ID;
		RAISERROR (@PRESULT, 16, 1);
	END;

	SELECT
		@WAREHOUSE_TARGET = [S].[WAREHOUSE_PARENT]
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [S]
	WHERE
		[S].[LOCATION_SPOT] = @TARGET_LOCATION;
  ---------------------------------------------------------------------------------
  -- Valida si maneja lote
  ---------------------------------------------------------------------------------  


	SELECT TOP 1
		@HAVBATCH = ISNULL([BATCH_REQUESTED], 0)
		,@BARCODE_ID = [OWM].[BARCODE_ID]
		,@ALTERNATE_BARCODE = [OWM].[ALTERNATE_BARCODE]
		,@MATERIAL_NAME = [OWM].[MATERIAL_NAME]
		,@CLIENT_OWNER = [OWM].[CLIENT_OWNER]
	FROM
		[wms].[OP_WMS_MATERIALS] [OWM]
	WHERE
		[MATERIAL_ID] = @MATERIAL_ID;

	SELECT TOP 1
		@CLIENT_NAME = [C].[CLIENT_NAME]
	FROM
		[wms].[OP_WMS_VIEW_CLIENTS] [C]
	WHERE
		[C].[CLIENT_CODE] = @CLIENT_OWNER;

	SELECT
		@TASK_COMMENTS = 'OLA DE REUBICACION #'
		+ CAST(@WAVE_PICKING_ID AS VARCHAR);


		PRINT @TASK_COMMENTS
	BEGIN TRY
		BEGIN TRANSACTION;

		PRINT ('@HAVBATCH')
		PRINT @HAVBATCH 
		IF @HAVBATCH = 0
		BEGIN
      ---------------------------------------------------------------------------------
      -- No maneja lote 
      ---------------------------------------------------------------------------------  
			INSERT	INTO @LICENCIAS
			SELECT
				[RAG].[CURRENT_LOCATION]
				,[RAG].[CURRENT_WAREHOUSE]
				,[RAG].[LICENSE_ID]
				,[RAG].[CODIGO_POLIZA]
				,[RAG].[QTY]
				,[RAG].[FECHA_DOCUMENTO]
			FROM
				[wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL] [RAG] WITH (NOLOCK)
			INNER JOIN [#ZONES_FOR_REALLOC] [ZFR] ON [RAG].[ZONE] = [ZFR].[ZONE]
			WHERE
				[RAG].[MATERIAL_ID] = @MATERIAL_ID
				AND [RAG].[QTY] > 0;


		END;
		ELSE
		BEGIN
      ---------------------------------------------------------------------------------
      -- Maneja lote 
      ---------------------------------------------------------------------------------
	  PRINT '1'
			INSERT	INTO @LICENCIAS
			SELECT
				[RAGB].[CURRENT_LOCATION]
				,[RAGB].[CURRENT_WAREHOUSE]
				,[RAGB].[LICENSE_ID]
				,[RAGB].[CODIGO_POLIZA]
				,[RAGB].[QTY]
				,[RAGB].[DATE_EXPIRATION_FOR_PICKING]
			FROM
				[wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL_BATCH] [RAGB] WITH (NOLOCK)
			INNER JOIN [#ZONES_FOR_REALLOC] [ZFR] ON [RAGB].[ZONE] = [ZFR].[ZONE]
			WHERE
				[RAGB].[MATERIAL_ID] = @MATERIAL_ID
				AND [RAGB].[QTY] > 0;

		END;

    ---------------------------------------------------------------------------------
    -- Recorrer por licencias el material
    ---------------------------------------------------------------------------------  

		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							@LICENCIAS ))
		BEGIN
		PRINT '2'

    ---------------------------------------------------------------------------------
    -- Recorrer por licencias el material
    ---------------------------------------------------------------------------------  
			IF @HAVBATCH = 1
			BEGIN
				SELECT TOP 1
					@CURRENT_LOCATION = [L].[CURRENT_LOCATION]
					,@CURRENT_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
					,@LICENSE_ID = [L].[LICENSE_ID]
					,@CODIGO_POLIZA_SOURCE = [L].[CODIGO_POLIZA]
					,@CURRENT_ASSIGNED = CASE
											WHEN @QUANTITY_PENDING >= [L].[QTY]
											THEN [L].[QTY]
											ELSE @QUANTITY_PENDING
											END
				FROM
					@LICENCIAS [L]
				ORDER BY
					[L].[DATE_BASE]
					,[L].[QTY] ASC
					,[L].[CURRENT_LOCATION] ASC;

			END;
			ELSE
			BEGIN
				SELECT TOP 1
					@CURRENT_LOCATION = [L].[CURRENT_LOCATION]
					,@CURRENT_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
					,@LICENSE_ID = [L].[LICENSE_ID]
					,@CODIGO_POLIZA_SOURCE = [L].[CODIGO_POLIZA]
					,@CURRENT_ASSIGNED = CASE
											WHEN @QUANTITY_PENDING >= [L].[QTY]
											THEN [L].[QTY]
											ELSE @QUANTITY_PENDING
											END
				FROM
					@LICENCIAS [L]
				ORDER BY
					[L].[QTY] ASC
					,[L].[CURRENT_LOCATION] ASC;
			END;
			PRINT '3'

			PRINT CAST(@LICENSE_ID AS VARCHAR);

			--Obtenemos usuario por defecto

			DECLARE @DEFAULT_USER VARCHAR(25) = (SELECT TEXT_VALUE FROM wms.OP_WMS_CONFIGURATIONS WHERE PARAM_TYPE = 'SISTEMA' AND PARAM_GROUP = 'DEFAULT_USER_REPLANISH' AND PARAM_NAME = @WAREHOUSE_TARGET)

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
						,[WAREHOUSE_TARGET]
						,[LOCATION_SPOT_SOURCE]
						,[LOCATION_SPOT_TARGET]
						,[CLIENT_OWNER]
						,[CLIENT_NAME]
						,[TASK_COMMENTS]
						,[TRANS_OWNER]
						,[IS_COMPLETED]
						,[MATERIAL_SHORT_NAME]
						,[REPLENISH_MATERIAL_ID_TARGET]
					)
			VALUES
					(
						@WAVE_PICKING_ID
						,@TASK_TYPE
						,@TASK_SUB_TYPE
						,'AUTOMATICO'
						,ISNULL(@DEFAULT_USER, '')
						,@ASSIGNED_DATE
						,@CURRENT_ASSIGNED
						,@CURRENT_ASSIGNED
						,@CODIGO_POLIZA_SOURCE
						,@CODIGO_POLIZA_SOURCE
						,@LICENSE_ID
						,'GENERAL'
						,1
						,@MATERIAL_ID
						,@BARCODE_ID
						,@ALTERNATE_BARCODE
						,@MATERIAL_NAME
						,@CURRENT_WAREHOUSE
						,@WAREHOUSE_TARGET
						,@CURRENT_LOCATION
						,@TARGET_LOCATION
						,@CLIENT_OWNER
						,@CLIENT_NAME
						,@TASK_COMMENTS
						,0
						,0
						,@MATERIAL_NAME
						,@MATERIAL_ID_TARGET
					);

			SELECT
				@QUANTITY_PENDING = @QUANTITY_PENDING
				- @CURRENT_ASSIGNED;


			IF @QUANTITY_PENDING <= 0
			BEGIN
				DELETE
					@LICENCIAS;
			END;
			ELSE
			BEGIN
				DELETE
					@LICENCIAS
				WHERE
					[LICENSE_ID] = @LICENSE_ID;
			END;
		END;

		SELECT
			@PRESULT = 'OK';
		COMMIT TRAN;
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT
			@PRESULT = ERROR_MESSAGE();

	END CATCH;


END;