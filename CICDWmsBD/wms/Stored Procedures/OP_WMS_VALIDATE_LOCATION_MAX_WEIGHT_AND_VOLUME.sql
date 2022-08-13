-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/19/2018 @ REBORN-Team Sprint Ulrich
-- Description:			Valida el volumen y peso de la ubicacion de tipo rack

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_VALIDATE_LOCATION_MAX_WEIGHT_AND_VOLUME]	
					@LOCATION_SPOT = 'B01-R03-C03-NA'
					,@LICENSE_ID = 469790
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_VALIDATE_LOCATION_MAX_WEIGHT_AND_VOLUME] (
		@LOCATION_SPOT VARCHAR(25)
		,@LICENSE_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@LOCATION_WEIGHT DECIMAL(18, 2)
		,@MAX_WEIGHT DECIMAL(18, 2)
		,@LOCATION_VOLUME DECIMAL(18, 2)
		,@MAX_VOLUME DECIMAL(18, 2)
		,@SPOT_TYPE VARCHAR(50);

	DECLARE	@LOCATION_TABLE TABLE (
			[LOCATION] VARCHAR(25)
			,[SPOT_TYPE] VARCHAR(25)
			,[MAX_WEIGHT] DECIMAL(18, 2) DEFAULT 0
			,[LOCATION_WEIGHT] DECIMAL(18, 2) DEFAULT 0
			,[LOCATION_VOLUME] DECIMAL(18, 4) DEFAULT 0
			,[VOLUME] DECIMAL(18, 4) DEFAULT 0
		);

  -- ------------------------------------------------------------------------------------
  -- Se obtienen las variables de la ubicacion
  -- ------------------------------------------------------------------------------------

	INSERT	INTO @LOCATION_TABLE
			(
				[LOCATION]
				,[SPOT_TYPE]
				,[MAX_WEIGHT]
				,[LOCATION_WEIGHT]
				,[LOCATION_VOLUME]
				,[VOLUME]
			)
	SELECT
		[SS].[LOCATION_SPOT]
		,MAX([SS].[SPOT_TYPE]) AS [SPOT_TYPE]
		,ISNULL(MAX([SS].[MAX_WEIGHT]), 0) [MAX_WEIGHT]
		,SUM([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](ISNULL([M].[WEIGTH],
											0),
											ISNULL([M].[WEIGHT_MEASUREMENT],
											'KG'))
				* ISNULL([IL].[QTY], 0)) [LOCATION_WEIGHT]
		,CASE	WHEN MAX([SS].[SPOT_TYPE]) = 'PISO'
				THEN ISNULL(SUM([L].[USED_MT2]), 0)
				ELSE ISNULL(MAX([M].[VOLUME_FACTOR]), 0)
						* ISNULL(SUM([IL].[QTY]), 0)
			END AS [LOCATION_VOLUME]
		,CASE	WHEN MAX([SS].[SPOT_TYPE]) = 'PISO'
				THEN ISNULL(MAX([SS].[MAX_MT2_OCCUPANCY]), 0)
				ELSE MAX([SS].[VOLUME])
			END [VOLUME]
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [SS]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON (
											[SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
											AND [SS].[WAREHOUSE_PARENT] = [L].[CURRENT_WAREHOUSE]
											)
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
	WHERE
		[SS].[ALLOW_STORAGE] = 1
		AND [SS].[LOCATION_SPOT] = @LOCATION_SPOT
	GROUP BY
		[SS].[LOCATION_SPOT];

	IF NOT EXISTS ( SELECT
						1
					FROM
						@LOCATION_TABLE )
	BEGIN
		INSERT	INTO @LOCATION_TABLE
				(
					[LOCATION]
					,[SPOT_TYPE]
					,[MAX_WEIGHT]
					,[LOCATION_VOLUME]
					,[VOLUME]
				)
		SELECT
			[SS].[LOCATION_SPOT]
			,MAX([SS].[SPOT_TYPE]) AS [SPOT_TYPE]
			,ISNULL(MAX([SS].[MAX_WEIGHT]), 0) [MAX_WEIGHT]
			,CASE	WHEN MAX([SS].[SPOT_TYPE]) = 'PISO'
					THEN 0
					ELSE 0
				END AS [LOCATION_VOLUME]
			,CASE	WHEN MAX([SS].[SPOT_TYPE]) = 'PISO'
					THEN ISNULL(MAX([SS].[MAX_MT2_OCCUPANCY]),
								0)
					ELSE MAX([SS].[VOLUME])
				END [VOLUME]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS] [SS]
		LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON (
											[SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
											AND [SS].[WAREHOUSE_PARENT] = [L].[CURRENT_WAREHOUSE]
											)
		WHERE
			[L].[LICENSE_ID] IS NULL
			AND [SS].[ALLOW_STORAGE] = 1
			AND [SS].[LOCATION_SPOT] = @LOCATION_SPOT
		GROUP BY
			[SS].[LOCATION_SPOT];

	END;


	SELECT TOP 1
		@LOCATION_WEIGHT = ISNULL([LT].[LOCATION_WEIGHT], 0)
		,@LOCATION_VOLUME = ISNULL([LT].[LOCATION_VOLUME], 0)
		,@MAX_WEIGHT = [LT].[MAX_WEIGHT]
		,@MAX_VOLUME = [LT].[VOLUME]
		,@SPOT_TYPE = [LT].[SPOT_TYPE]
	FROM
		@LOCATION_TABLE [LT];

  -- ------------------------------------------------------------------------------------
  -- Se muestra el resultado final
  -- ------------------------------------------------------------------------------------
	IF @SPOT_TYPE = 'PISO'
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- Se obtienen las variables de la licencia
    -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			SUM([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](ISNULL([M].[WEIGTH],
											0),
											ISNULL([M].[WEIGHT_MEASUREMENT],
											'KG'))
				* [IL].[ENTERED_QTY]) [LICENSE_WEIGHT]
			,MAX(ISNULL([M].[VOLUME_FACTOR], 0)) [LICENSE_VOLUME]
		INTO
			[#RESULT]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
		WHERE
			[IL].[LICENSE_ID] = @LICENSE_ID;
    --
		SELECT
			CASE	WHEN (@MAX_WEIGHT - (@LOCATION_WEIGHT
											+ [LICENSE_WEIGHT])) > ROUND(0,
											4)
					THEN ROUND(@MAX_WEIGHT
								- (@LOCATION_WEIGHT
									+ [LICENSE_WEIGHT]), 4)
					ELSE 0
			END [AVAILABLE_WEIGHT]
			,CASE	WHEN (@MAX_WEIGHT - (@LOCATION_WEIGHT
											+ [LICENSE_WEIGHT])) > 0
					THEN 'checkmark'
					ELSE 'close'
				END [WEIGHT_ICON]
			,CASE	WHEN (@MAX_WEIGHT - (@LOCATION_WEIGHT
											+ [LICENSE_WEIGHT])) > 0
					THEN 'success'
					ELSE 'danger'
				END [WEIGHT_ICON_COLOR]
			,CASE	WHEN (@MAX_VOLUME - (@LOCATION_VOLUME
											+ [LICENSE_VOLUME])) > 0
					THEN @MAX_VOLUME - (@LOCATION_VOLUME
										+ [LICENSE_VOLUME])
					ELSE 0
				END [AVAILABLE_VOLUME]
			,CASE	WHEN (@MAX_VOLUME - (@LOCATION_VOLUME
											+ [LICENSE_VOLUME])) > 0
					THEN 'checkmark'
					ELSE 'close'
				END [VOLUME_ICON]
			,CASE	WHEN (@MAX_VOLUME - (@LOCATION_VOLUME
											+ [LICENSE_VOLUME])) > 0
					THEN 'success'
					ELSE 'danger'
				END [VOLUME_ICON_COLOR]
		FROM
			[#RESULT];
	END;
	ELSE
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- Se obtienen las variables de la licencia
    -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			SUM([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](ISNULL([M].[WEIGTH],
											0),
											ISNULL([M].[WEIGHT_MEASUREMENT],
											'KG'))
				* [IL].[ENTERED_QTY]) [LICENSE_WEIGHT]
			,SUM(ISNULL([M].[VOLUME_FACTOR], 0)
					* [IL].[ENTERED_QTY]) [LICENSE_VOLUME]
		INTO
			[#LICENSE]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
		WHERE
			[IL].[LICENSE_ID] = @LICENSE_ID;
    --
		SELECT
			CASE	WHEN (@MAX_WEIGHT - (@LOCATION_WEIGHT
											+ [LICENSE_WEIGHT])) > ROUND(0,
											4)
					THEN ROUND(@MAX_WEIGHT
								- (@LOCATION_WEIGHT
									+ [LICENSE_WEIGHT]), 4)
					ELSE 0
			END [AVAILABLE_WEIGHT]
			,CASE	WHEN (@MAX_WEIGHT - (@LOCATION_WEIGHT
											+ [LICENSE_WEIGHT])) > 0
					THEN 'checkmark'
					ELSE 'close'
				END [WEIGHT_ICON]
			,CASE	WHEN (@MAX_WEIGHT - (@LOCATION_WEIGHT
											+ [LICENSE_WEIGHT])) > 0
					THEN 'success'
					ELSE 'danger'
				END [WEIGHT_ICON_COLOR]
			,CASE	WHEN (@MAX_VOLUME - (@LOCATION_VOLUME
											+ [LICENSE_VOLUME])) > 0
					THEN @MAX_VOLUME - (@LOCATION_VOLUME
										+ [LICENSE_VOLUME])
					ELSE 0
				END [AVAILABLE_VOLUME]
			,CASE	WHEN (@MAX_VOLUME - (@LOCATION_VOLUME
											+ [LICENSE_VOLUME])) > 0
					THEN 'checkmark'
					ELSE 'close'
				END [VOLUME_ICON]
			,CASE	WHEN (@MAX_VOLUME - (@LOCATION_VOLUME
											+ [LICENSE_VOLUME])) > 0
					THEN 'success'
					ELSE 'danger'
				END [VOLUME_ICON_COLOR]
		FROM
			[#LICENSE];
	END;
END;