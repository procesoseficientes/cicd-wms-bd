-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	18-Jun-2019 G-FORCE@Cancun-Swift3PL
-- Description:			Sp que obtiene las ubicaciones sugeridas de material por licencia

-- Autor:				marvin.solares
-- Fecha de Creacion: 	07-Jul-2019 G-FORCE@Cancun-Swift3PL
-- Description:			Se elimina el top 5 de los querys para que muestre todas las coincidencias por sus propiedades

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_SP_GET_SUGGESTED_LOCATIONS_OF_MATERIAL_BY_LICENSE						
					@LICENSE_ID = 469790
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUGGESTED_LOCATIONS_OF_MATERIAL_BY_LICENSE] (
		@LOGIN VARCHAR(50)
		,@LICENSE_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;

  -- ----------------------------------------
  -- Declaramos las variables necesarias.
  -- ----------------------------------------

	DECLARE	@ORDER_BY VARCHAR(25) = 'DESCENDENTE';

	DECLARE	@WAREHOSUE_TABLE TABLE (
			[WAREHOUSE_BY_USER_ID] INT
			,[LOGIN_ID] VARCHAR(25)
			,[WAREHOUSE_ID] VARCHAR(25)
			,[NAME] VARCHAR(50)
			,[ERP_WAREHOUSE] INT
		);

	DECLARE	@MATERIAL_LICENSE_TABLE TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[QTY] NUMERIC(18, 6)
			,[TONE_AND_CALIBER_ID] INT
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[IT_HAS_RECORDS] BIT DEFAULT (0)
		);


	DECLARE	@LOCATION_TABLE TABLE (
			[LOCATION_SPOT] VARCHAR(25)
			,[MATERIAL_ID] VARCHAR(50)
			,[QTY] NUMERIC(18, 6)
			,[TONE_AND_CALIBER_ID] INT
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
		);

  -- ----------------------------------------
  -- Obtenemos el configuracion para el orden de la consulta
  -- ----------------------------------------
	SELECT TOP 1
		@ORDER_BY = [P].[VALUE]
	FROM
		[wms].[OP_WMS_PARAMETER] [P]
	WHERE
		[P].[GROUP_ID] = 'SUGGESTION_TO_LOCATE'
		AND [P].[PARAMETER_ID] = 'ORDER_BY';
  -- ----------------------------------------
  -- Obtenemos las bodegas asignadas al usuario
  -- ----------------------------------------
	INSERT	INTO @WAREHOSUE_TABLE
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_USER_CD] @LOGIN = @LOGIN;

  -- ----------------------------------------
  -- Obtenemos los materiales de la licencia
  -- ----------------------------------------
	INSERT	INTO @MATERIAL_LICENSE_TABLE
			(
				[MATERIAL_ID]
				,[QTY]
				,[TONE_AND_CALIBER_ID]
				,[TONE]
				,[CALIBER]
				,[BATCH]
				,[DATE_EXPIRATION]
			)
	SELECT
		[IL].[MATERIAL_ID]
		,[IL].[QTY]
		,[IL].[TONE_AND_CALIBER_ID]
		,[TCM].[TONE]
		,[TCM].[CALIBER]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
	LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
	WHERE
		[IL].[LICENSE_ID] = @LICENSE_ID;

  -- ----------------------------------------
  -- Obtenemos las bodegas asignadas al usuario
  -- ----------------------------------------
	DECLARE
		@MATERIAL_ID VARCHAR(50)
		,@QTY NUMERIC(18, 6)
		,@TONE_AND_CALIBER_ID INT
		,@TONE VARCHAR(20)
		,@CALIBER VARCHAR(20)
		,@BATCH VARCHAR(50)
		,@DATE_EXPIRATION DATE;

  -- ----------------------------------------
  -- Recorremos los materiales de la licencia para buscar ubicaciones sugeridas
  -- ----------------------------------------
	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						@MATERIAL_LICENSE_TABLE [MLT]
					WHERE
						[MLT].[IT_HAS_RECORDS] = 0 )
	BEGIN
		SELECT TOP 1
			@MATERIAL_ID = [MLT].[MATERIAL_ID]
			,@QTY = [MLT].[QTY]
			,@TONE_AND_CALIBER_ID = [MLT].[TONE_AND_CALIBER_ID]
			,@TONE = [MLT].[TONE]
			,@CALIBER = [MLT].[CALIBER]
			,@BATCH = [MLT].[BATCH]
			,@DATE_EXPIRATION = [MLT].[DATE_EXPIRATION]
		FROM
			@MATERIAL_LICENSE_TABLE [MLT]
		WHERE
			[MLT].[IT_HAS_RECORDS] = 0;


    -- ----------------------------------------
    -- Recorremos los materiales de la licencia para buscar ubicaciones sugeridas con la misma configuracion
    -- ----------------------------------------
		INSERT	INTO @LOCATION_TABLE
				(
					[LOCATION_SPOT]
					,[MATERIAL_ID]
					,[QTY]
					,[TONE_AND_CALIBER_ID]
					,[TONE]
					,[CALIBER]
					,[BATCH]
					,[DATE_EXPIRATION]
				)
		SELECT
			[SS].[LOCATION_SPOT]
			,[IL].[MATERIAL_ID]
			,[IL].[QTY]
			,[IL].[TONE_AND_CALIBER_ID]
			,[TCM].[TONE]
			,[TCM].[CALIBER]
			,[IL].[BATCH]
			,[IL].[DATE_EXPIRATION]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS] [SS]
		INNER JOIN @WAREHOSUE_TABLE [WT] ON ([SS].[WAREHOUSE_PARENT] = [WT].[WAREHOUSE_ID])
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON (
											[SS].[WAREHOUSE_PARENT] = [L].[CURRENT_WAREHOUSE]
											AND [SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
											)
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
		LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
		WHERE
			[SS].[ALLOW_STORAGE] = 1
			AND [IL].[MATERIAL_ID] = @MATERIAL_ID
			AND [IL].[QTY] > 0
			AND [IL].[DATE_EXPIRATION] = @DATE_EXPIRATION
			AND ISNULL([IL].[BATCH], '') = ISNULL(@BATCH, '')
			AND (
					@TONE IS NULL
					OR [TCM].[TONE] = @TONE
				)
			AND (
					@CALIBER IS NULL
					OR [TCM].[CALIBER] = @CALIBER
				)
		ORDER BY
			[IL].[MATERIAL_ID]
			,CASE	WHEN @ORDER_BY = 'ASCENDENTE'
					THEN [IL].[QTY]
				END ASC
			,CASE	WHEN @ORDER_BY = 'DESCENDENTE'
					THEN [IL].[QTY]
				END DESC;

    -- ----------------------------------------
    -- Validamos si se encontraron ubicaciones con la consulta anterior
    -- ----------------------------------------    
		IF NOT EXISTS ( SELECT
							*
						FROM
							@LOCATION_TABLE
						WHERE
							[MATERIAL_ID] = @MATERIAL_ID )
		BEGIN
			INSERT	INTO @LOCATION_TABLE
					(
						[LOCATION_SPOT]
						,[MATERIAL_ID]
						,[QTY]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[TONE]
						,[CALIBER]
					)
			SELECT
				[SS].[LOCATION_SPOT]
				,[IL].[MATERIAL_ID]
				,[IL].[QTY]
				,[IL].[BATCH]
				,[IL].[DATE_EXPIRATION]
				,[TCM].[TONE]
				,[TCM].[CALIBER]
			FROM
				[wms].[OP_WMS_SHELF_SPOTS] [SS]
			INNER JOIN @WAREHOSUE_TABLE [WT] ON ([SS].[WAREHOUSE_PARENT] = [WT].[WAREHOUSE_ID])
			INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON (
											[SS].[WAREHOUSE_PARENT] = [L].[CURRENT_WAREHOUSE]
											AND [SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
											)
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
			LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON [TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
			WHERE
				[SS].[ALLOW_STORAGE] = 1
				AND [IL].[MATERIAL_ID] = @MATERIAL_ID
				AND [IL].[QTY] > 0
			ORDER BY
				[IL].[MATERIAL_ID]
				,CASE	WHEN @ORDER_BY = 'ASCENDENTE'
						THEN [IL].[QTY]
					END ASC
				,CASE	WHEN @ORDER_BY = 'DESCENDENTE'
						THEN [IL].[QTY]
					END DESC;
		END;

		UPDATE
			@MATERIAL_LICENSE_TABLE
		SET	
			[IT_HAS_RECORDS] = 1
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID;


	END;

	SELECT
		[LT].[LOCATION_SPOT]
		,[LT].[MATERIAL_ID]
		,SUM([LT].[QTY]) AS [QTY]
   --,[LT].[TONE_AND_CALIBER_ID]
		,[LT].[TONE]
		,[LT].[CALIBER]
		,[LT].[BATCH]
		,[LT].[DATE_EXPIRATION]
	FROM
		@LOCATION_TABLE [LT]
	GROUP BY
		[LT].[LOCATION_SPOT]
		,[LT].[MATERIAL_ID]
          --,[LT].[TONE_AND_CALIBER_ID]
		,[LT].[TONE]
		,[LT].[CALIBER]
		,[LT].[BATCH]
		,[LT].[DATE_EXPIRATION]
	ORDER BY
		[LT].[MATERIAL_ID]
		,CASE	WHEN @ORDER_BY = 'ASCENDENTE'
				THEN SUM([LT].[QTY])
			END ASC
		,CASE	WHEN @ORDER_BY = 'DESCENDENTE'
				THEN SUM([LT].[QTY])
			END DESC;


END;