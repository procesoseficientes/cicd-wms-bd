-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180713 GForce@FocaMonje
-- Description:			Obtiene un listado de ubicaciones sugeridas para ubicar material de recepcion o de reubicacion parcial/completa

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SUGGESTED_LOCATIONS]
					@LICENSE_ID = 317851,
					@LOGIN_ID = 'MARVIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUGGESTED_LOCATIONS] (
		@LICENSE_ID INT
		,@LOGIN_ID VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;

  -- ----------------------------------
  -- Declaramos las variables necesarias
  -- ----------------------------------

	DECLARE	@TIPO_ORDENAMIENTO INT = 0;

	SELECT TOP 1
		@TIPO_ORDENAMIENTO = [NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_GROUP] = 'RECEPCION'
		AND [PARAM_NAME] = 'TIPO_ORDENAMIENTO_UBICACIONES_SUGERIDAS';

	DECLARE	@MATERIAL TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[VIN] VARCHAR(50)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
		);

	DECLARE	@SUGGESTED_LOCATIONS AS TABLE (
			[LOCATION] VARCHAR(25)
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(200)
			,[QTY] NUMERIC(18, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
		);

  -- ----------------------------------
  -- Obtenemos los materiales de la licencia para su busqueda de ubicaciones sugeridas
  -- ----------------------------------

	INSERT	INTO @MATERIAL
			(
				[MATERIAL_ID]
				,[BATCH]
				,[DATE_EXPIRATION]
				,[VIN]
				,[TONE]
				,[CALIBER]
			)
	SELECT
		[owixl].[MATERIAL_ID]
		,[owixl].[BATCH]
		,[owixl].[DATE_EXPIRATION]
		,[owixl].[VIN]
		,[owtacbm].[TONE]
		,[owtacbm].[CALIBER]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [owixl]
	LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [owtacbm] ON ([owixl].[TONE_AND_CALIBER_ID] = [owtacbm].[TONE_AND_CALIBER_ID])
	WHERE
		[owixl].[LICENSE_ID] = @LICENSE_ID;

  -- ----------------------------------
  -- Recorremos los productos
  -- ----------------------------------
	WHILE EXISTS ( SELECT
						1
					FROM
						@MATERIAL )
	BEGIN
		DECLARE
			@MATERIAL_ID VARCHAR(50)
			,@BATCH VARCHAR(50)
			,@DATE_EXPIRATION DATE
			,@VIN VARCHAR(50)
			,@TONE VARCHAR(20)
			,@CALIBER VARCHAR(20);

    -- ----------------------------------
    -- Obtenemos el primer producto a buscar las ubicaciones sugeridas
    -- ----------------------------------
		SELECT TOP 1
			@MATERIAL_ID = [MATERIAL_ID]
			,@BATCH = [BATCH]
			,@DATE_EXPIRATION = [DATE_EXPIRATION]
			,@VIN = [VIN]
			,@TONE = [TONE]
			,@CALIBER = [CALIBER]
		FROM
			@MATERIAL;


    -- ----------------------------------
    -- Insertamos las ubicaciones encontradas con las mismos caracteristicas
    -- ----------------------------------
		INSERT	INTO @SUGGESTED_LOCATIONS
				(
					[LOCATION]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[TONE]
					,[CALIBER]
					,[BATCH]
					,[DATE_EXPIRATION]
				)
		SELECT TOP 10
			[L].[CURRENT_LOCATION]
			,MAX([IL].[MATERIAL_ID]) AS [MATERIAL_ID]
			,MAX([IL].[MATERIAL_NAME]) AS [MATERIAL_NAME]
			,SUM([IL].[QTY]) AS [QTY]
			,[TCM].[TONE]
			,[TCM].[CALIBER]
			,[IL].[BATCH]
			,[IL].[DATE_EXPIRATION]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
		INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([L].[CURRENT_LOCATION] = [SS].[LOCATION_SPOT])
		INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON ([L].[CURRENT_WAREHOUSE] = [WU].[WAREHOUSE_ID])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
		LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
		WHERE
			[L].[LICENSE_ID] <> @LICENSE_ID
			AND [IL].[MATERIAL_ID] = @MATERIAL_ID
			AND [WU].[LOGIN_ID] = @LOGIN_ID
			AND [IL].[QTY] > 0
			AND (
					@BATCH IS NULL
					OR UPPER(ISNULL([IL].[BATCH], '')) = @BATCH
				)
			AND (
					@TONE IS NULL
					OR UPPER(ISNULL([TCM].[TONE], '')) = @TONE
				)
			AND (
					@CALIBER IS NULL
					OR UPPER(ISNULL([TCM].[CALIBER], '')) = @CALIBER
				)
		GROUP BY
			[L].[CURRENT_LOCATION]
			,[TCM].[TONE]
			,[TCM].[CALIBER]
			,[IL].[BATCH]
			,[IL].[DATE_EXPIRATION]
		HAVING
			SUM([IL].[QTY]) > 0;

    -- ----------------------------------
    -- Validamos si se ingresaron ubicaciones con coincidencia
    -- ----------------------------------
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							@SUGGESTED_LOCATIONS
						WHERE
							[MATERIAL_ID] = @MATERIAL_ID )
		BEGIN
      -- ----------------------------------
      -- Ingresemos las ubicaciones que sean igual al producto
      -- ----------------------------------
			INSERT	INTO @SUGGESTED_LOCATIONS
					(
						[LOCATION]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY]
						,[TONE]
						,[CALIBER]
						,[BATCH]
						,[DATE_EXPIRATION]
					)
			SELECT TOP 10
				[L].[CURRENT_LOCATION]
				,MAX([IL].[MATERIAL_ID]) AS [MATERIAL_ID]
				,MAX([IL].[MATERIAL_NAME]) AS [MATERIAL_NAME]
				,SUM([IL].[QTY]) AS [QTY]
				,[TCM].[TONE]
				,[TCM].[CALIBER]
				,[IL].[BATCH]
				,[IL].[DATE_EXPIRATION]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
			INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([L].[CURRENT_LOCATION] = [SS].[LOCATION_SPOT])
			INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON ([L].[CURRENT_WAREHOUSE] = [WU].[WAREHOUSE_ID])
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
			LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
			WHERE
				[L].[LICENSE_ID] <> @LICENSE_ID
				AND [IL].[MATERIAL_ID] = @MATERIAL_ID
				AND [WU].[LOGIN_ID] = @LOGIN_ID
			GROUP BY
				[L].[CURRENT_LOCATION]
				,[TCM].[TONE]
				,[TCM].[CALIBER]
				,[IL].[BATCH]
				,[IL].[DATE_EXPIRATION]
			HAVING
				SUM([IL].[QTY]) > 0;
		END;

    -- ----------------------------------
    -- Se elimna el material
    -- ----------------------------------
		DELETE
			@MATERIAL
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID;
	END;

	SELECT
		[LOCATION]
		,[MATERIAL_ID]
		,[MATERIAL_NAME]
		,[QTY]
		,[TONE]
		,[CALIBER]
		,[BATCH]
		,[DATE_EXPIRATION]
	FROM
		@SUGGESTED_LOCATIONS [SL]
	WHERE
		[SL].[QTY] > 0
	ORDER BY
		[SL].[MATERIAL_ID]
		,CASE @TIPO_ORDENAMIENTO
			WHEN 0 THEN -[SL].[QTY]
			ELSE [SL].[QTY]
			END;


END;