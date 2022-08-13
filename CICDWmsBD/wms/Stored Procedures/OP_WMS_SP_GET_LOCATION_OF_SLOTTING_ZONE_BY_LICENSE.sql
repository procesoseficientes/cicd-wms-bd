-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	18-Jun-2019 G-FORCE@Cancun-Swift3PL
-- Description:			Obtiene todas las ubicaciones conpatibles con las clases de la licencia

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20-Ago-2019 G-FORCE@FlorencioVarela
-- Description:			ordeno en orden descendente por la capacidad disponible para ubicar

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_SP_GET_LOCATION_OF_SLOTTING_ZONE_BY_LICENSE
					@LICENSE_ID = 469790
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOCATION_OF_SLOTTING_ZONE_BY_LICENSE] (
		@LOGIN VARCHAR(50)
		,@LICENSE_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  -- ----------------------------------------
  -- Declaramos las variables necesarias
  -- ----------------------------------------
	DECLARE
		@COUNT_CLASS_IN_LICENSE INT = 0
		,@LICENSE_WEIGHT NUMERIC(18, 4) = 0
		,@LICENSE_VOLUME_F NUMERIC(18, 4) = 0
		,@LICENSE_VOLUME_R NUMERIC(18, 4) = 0
		,@COUNT_COMPATIBLE_CLASS INT = 0;
  --
	DECLARE	@WAREHOSUE_TABLE TABLE (
			[WAREHOUSE_BY_USER_ID] INT
			,[LOGIN_ID] VARCHAR(25)
			,[WAREHOUSE_ID] VARCHAR(25)
			,[NAME] VARCHAR(50)
			,ERP_WAREHOUSE VARCHAR(50)
		);
  --
	DECLARE	@LICENSE_CLASSES TABLE (
			[CLASS_ID] INT
			,[CLASS_NAME] VARCHAR(50)
			,[CLASS_DESCRIPTION] VARCHAR(250)
			,[CLASS_TYPE] VARCHAR(50)
			,[CREATED_BY] VARCHAR(50)
			,[CREATED_DATETIME] DATETIME
			,[LAST_UPDATED_BY] VARCHAR(50)
			,[LAST_UPDATED] DATETIME
			,[PRIORITY] INT
		);
  --
	DECLARE	@SLOTTING_ZONE TABLE (
			[ID] UNIQUEIDENTIFIER
			,[WAREHOUSE_CODE] VARCHAR(25)
			,[ZONE_ID] INT
			,[ZONE] VARCHAR(50)
			,[MANDATORY] BIT
			,[COUNT_CLASS] INT
			,[COUNT_CLASS_IN_LICENSE] INT
			,[DIFFERENCE_OF_CLASSES] INT
		);
  --
	DECLARE	@LOCATION_TABLE TABLE (
			[SLOTTING_ZONE_ID] UNIQUEIDENTIFIER
			,[WAREHOUSE_CODE] VARCHAR(25)
			,[ZONE_ID] INT
			,[ZONE] VARCHAR(50)
			,[MANDATORY] BIT
			,[COUNT_CLASS] INT
			,[COUNT_CLASS_IN_LICENSE] INT
			,[DIFFERENCE_OF_CLASSES] INT
			,[LOCATION] VARCHAR(25)
			,[SPOT_TYPE] VARCHAR(25)
			,[MAX_WEIGHT] DECIMAL(18, 2) DEFAULT 0
			,[LOCATION_WEIGHT] DECIMAL(18, 2) DEFAULT 0
			,[LOCATION_VOLUME] DECIMAL(18, 4) DEFAULT 0
			,[VOLUME] DECIMAL(18, 4) DEFAULT 0
			,[IS_COMPATIBLE_CLASSES] INT DEFAULT (1)
		);--
	DECLARE	@CLASSES_ON_LOCATION TABLE (
			[LOCATION] VARCHAR(25)
			,[CLASS_ID] INT
		);
  --
	DECLARE	@COMPATIBLE_CLASSES TABLE ([CLASS_ID] INT);
  --
	DECLARE	@LOCATION_BY_CLASSES_INCOMPATIBILITY TABLE ([LOCATION]
											VARCHAR(25));

	DECLARE @PARAMETER_USE_SUB_FAMILY VARCHAR(50);

	SELECT  @PARAMETER_USE_SUB_FAMILY = value
    FROM    [wms].[OP_WMS_PARAMETER]
    WHERE   [GROUP_ID] = 'MATERIAL_SUB_FAMILY'
    AND [PARAMETER_ID] = 'USE_MATERIAL_SUB_FAMILY';

  -- ----------------------------------------
  -- Obtenemos las bodegas asignadas al usuario
  -- ----------------------------------------
	INSERT	INTO @WAREHOSUE_TABLE
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_USER_CD] @LOGIN = @LOGIN;

	IF ( @PARAMETER_USE_SUB_FAMILY IS NULL OR @PARAMETER_USE_SUB_FAMILY = '0')
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- Obtiene las clases en la licencia actual
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @LICENSE_CLASSES
	SELECT
		[CLASS_ID]
		,[CLASS_NAME]
		,[CLASS_DESCRIPTION]
		,[CLASS_TYPE]
		,[CREATED_BY]
		,[CREATED_DATETIME]
		,[LAST_UPDATED_BY]
		,[LAST_UPDATED]
		,[PRIORITY]
	FROM
		[wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@LICENSE_ID);


		SET @COUNT_CLASS_IN_LICENSE = (SELECT
											COUNT([MCT].[CLASS_ID])
										FROM
											@LICENSE_CLASSES [MCT]);
	END
	ELSE
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- Obtiene las sub clases en la licencia actual
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @LICENSE_CLASSES
		SELECT
			[SUB_CLASS_ID]
			,[SUB_CLASS_NAME]
			,''
			,''
			,[CREATED_BY]
			,[CREATED_DATETIME]
			,[LAST_UPDATED_BY]
			,[LAST_UPDATED]
			,0
		FROM
			[wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LICENSE](@LICENSE_ID);


		SET @COUNT_CLASS_IN_LICENSE = (SELECT
											COUNT([MCT].[CLASS_ID])
										FROM
											@LICENSE_CLASSES [MCT]);
	END

	IF ( @PARAMETER_USE_SUB_FAMILY IS NULL OR @PARAMETER_USE_SUB_FAMILY = '0')
	BEGIN
  -- ----------------------------------------
  -- Obtenemos todas las zonas compatibles con las clases obtenidas
  -- ----------------------------------------
		INSERT	INTO @SLOTTING_ZONE
				(
					[ID]
					,[WAREHOUSE_CODE]
					,[ZONE_ID]
					,[ZONE]
					,[MANDATORY]
					,[COUNT_CLASS]
					,[COUNT_CLASS_IN_LICENSE]
					,[DIFFERENCE_OF_CLASSES]
				)
		SELECT DISTINCT
			[SZ].[ID]
			,[SZ].[WAREHOUSE_CODE]
			,[SZ].[ZONE_ID]
			,[SZ].[ZONE]
			,[SZ].[MANDATORY]
			,COUNT([SZC].[ID]) AS [COUNT_CLASS]
			,@COUNT_CLASS_IN_LICENSE AS [COUNT_CLASS_IN_LICENSE]
			,(@COUNT_CLASS_IN_LICENSE - COUNT([SZC].[ID])) AS [DIFFERENCE_OF_CLASSES]
		FROM
			[wms].[OP_WMS_SLOTTING_ZONE] [SZ]
		INNER JOIN @WAREHOSUE_TABLE [WT] ON ([SZ].[WAREHOUSE_CODE] = [WT].[WAREHOUSE_ID])
		INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC] ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
		INNER JOIN @LICENSE_CLASSES [MCT] ON ([SZC].[CLASS_ID] = [MCT].[CLASS_ID])
		GROUP BY
			[SZ].[ID]
			,[SZ].[WAREHOUSE_CODE]
			,[SZ].[ZONE_ID]
			,[SZ].[ZONE]
			,[SZ].[MANDATORY];
	END
	ELSE
	BEGIN
  -- ----------------------------------------
  -- Obtenemos todas las zonas compatibles con las sub clases obtenidas
  -- ----------------------------------------
			INSERT	INTO @SLOTTING_ZONE
				(
					[ID]
					,[WAREHOUSE_CODE]
					,[ZONE_ID]
					,[ZONE]
					,[MANDATORY]
					,[COUNT_CLASS]
					,[COUNT_CLASS_IN_LICENSE]
					,[DIFFERENCE_OF_CLASSES]
				)
		SELECT DISTINCT
			[SZ].[ID]
			,[SZ].[WAREHOUSE_CODE]
			,[SZ].[ZONE_ID]
			,[SZ].[ZONE]
			,[SZ].[MANDATORY]
			,COUNT([SZC].[ID]) AS [COUNT_CLASS]
			,@COUNT_CLASS_IN_LICENSE AS [COUNT_CLASS_IN_LICENSE]
			,(@COUNT_CLASS_IN_LICENSE - COUNT([SZC].[ID])) AS [DIFFERENCE_OF_CLASSES]
		FROM
			[wms].[OP_WMS_SLOTTING_ZONE] [SZ]
		INNER JOIN @WAREHOSUE_TABLE [WT] ON ([SZ].[WAREHOUSE_CODE] = [WT].[WAREHOUSE_ID])
		INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SZC] ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
		INNER JOIN @LICENSE_CLASSES [MCT] ON ([SZC].[SUB_CLASS_ID] = [MCT].[CLASS_ID])
		GROUP BY
			[SZ].[ID]
			,[SZ].[WAREHOUSE_CODE]
			,[SZ].[ZONE_ID]
			,[SZ].[ZONE]
			,[SZ].[MANDATORY];
	END

  -- ----------------------------------------
  -- Obtenemos las ubucaciones que si tienen invententario con sus disponbile y permitan almacenaje
  -- ----------------------------------------
	INSERT	INTO @LOCATION_TABLE
			(
				[SLOTTING_ZONE_ID]
				,[WAREHOUSE_CODE]
				,[ZONE_ID]
				,[ZONE]
				,[MANDATORY]
				,[COUNT_CLASS]
				,[COUNT_CLASS_IN_LICENSE]
				,[DIFFERENCE_OF_CLASSES]
				,[LOCATION]
				,[SPOT_TYPE]
				,[MAX_WEIGHT]
				,[LOCATION_WEIGHT]
				,[LOCATION_VOLUME]
				,[VOLUME]
			)
	SELECT
		[SZ].[ID]
		,[SZ].[WAREHOUSE_CODE]
		,[SZ].[ZONE_ID]
		,[SZ].[ZONE]
		,[SZ].[MANDATORY]
		,[SZ].[COUNT_CLASS]
		,[SZ].[COUNT_CLASS_IN_LICENSE]
		,[SZ].[DIFFERENCE_OF_CLASSES]
		,[SS].[LOCATION_SPOT]
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
		@SLOTTING_ZONE [SZ]
	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON (
											[SZ].[ZONE] = [SS].[ZONE]
											AND [SS].[WAREHOUSE_PARENT] = [SZ].[WAREHOUSE_CODE]
											)
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON (
											[SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
											AND [SS].[WAREHOUSE_PARENT] = [L].[CURRENT_WAREHOUSE]
											)
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
	WHERE
		[SS].[ALLOW_STORAGE] = 1
	GROUP BY
		[SZ].[ID]
		,[SZ].[WAREHOUSE_CODE]
		,[SZ].[ZONE_ID]
		,[SZ].[ZONE]
		,[SZ].[MANDATORY]
		,[SZ].[COUNT_CLASS]
		,[SZ].[COUNT_CLASS_IN_LICENSE]
		,[SZ].[DIFFERENCE_OF_CLASSES]
		,[SS].[LOCATION_SPOT];


  -- ----------------------------------------
  -- Obtenemos las ubucaciones que no tienen invententario y que permitan almacenaje
  -- ----------------------------------------
	INSERT	INTO @LOCATION_TABLE
			(
				[SLOTTING_ZONE_ID]
				,[WAREHOUSE_CODE]
				,[ZONE_ID]
				,[ZONE]
				,[MANDATORY]
				,[COUNT_CLASS]
				,[COUNT_CLASS_IN_LICENSE]
				,[DIFFERENCE_OF_CLASSES]
				,[LOCATION]
				,[SPOT_TYPE]
				,[MAX_WEIGHT]
				,[LOCATION_VOLUME]
				,[VOLUME]
			)
	SELECT
		[SZ].[ID]
		,[SZ].[WAREHOUSE_CODE]
		,[SZ].[ZONE_ID]
		,[SZ].[ZONE]
		,[SZ].[MANDATORY]
		,[SZ].[COUNT_CLASS]
		,[SZ].[COUNT_CLASS_IN_LICENSE]
		,[SZ].[DIFFERENCE_OF_CLASSES]
		,[SS].[LOCATION_SPOT]
		,MAX([SS].[SPOT_TYPE]) AS [SPOT_TYPE]
		,ISNULL(MAX([SS].[MAX_WEIGHT]), 0) [MAX_WEIGHT]
		,CASE	WHEN MAX([SS].[SPOT_TYPE]) = 'PISO' THEN 0
				ELSE 0
			END AS [LOCATION_VOLUME]
		,CASE	WHEN MAX([SS].[SPOT_TYPE]) = 'PISO'
				THEN ISNULL(MAX([SS].[MAX_MT2_OCCUPANCY]), 0)
				ELSE MAX([SS].[VOLUME])
			END [VOLUME]
	FROM
		@SLOTTING_ZONE [SZ]
	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON (
											[SZ].[ZONE] = [SS].[ZONE]
											AND [SS].[WAREHOUSE_PARENT] = [SZ].[WAREHOUSE_CODE]
											)
	LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON (
											[SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
											AND [SS].[WAREHOUSE_PARENT] = [L].[CURRENT_WAREHOUSE]
											)
	WHERE
		[L].[LICENSE_ID] IS NULL
		AND [SS].[ALLOW_STORAGE] = 1
	GROUP BY
		[SZ].[ID]
		,[SZ].[WAREHOUSE_CODE]
		,[SZ].[ZONE_ID]
		,[SZ].[ZONE]
		,[SZ].[MANDATORY]
		,[SZ].[COUNT_CLASS]
		,[SZ].[COUNT_CLASS_IN_LICENSE]
		,[SZ].[DIFFERENCE_OF_CLASSES]
		,[SS].[LOCATION_SPOT];


	IF ( @PARAMETER_USE_SUB_FAMILY IS NULL OR @PARAMETER_USE_SUB_FAMILY = '0')
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- Obtiene las clases de la ubicaciones
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @CLASSES_ON_LOCATION
				(
					[LOCATION]
					,[CLASS_ID]
				)
		SELECT DISTINCT
			[L].[CURRENT_LOCATION]
			,[C].[CLASS_ID]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IXL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([L].[LICENSE_ID] = [IXL].[LICENSE_ID])
		INNER JOIN @LOCATION_TABLE [LT] ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [IXL].[MATERIAL_ID])
		INNER JOIN [wms].[OP_WMS_CLASS] [C] ON ([M].[MATERIAL_CLASS] = [C].[CLASS_ID])
		WHERE
			[IXL].[QTY] > 0;

  -- ------------------------------------------------------------------------------------
  -- Obtiene las clases compatibles con la licencia
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @COMPATIBLE_CLASSES
			(
				[CLASS_ID]
			)
	SELECT DISTINCT
		[C].[CLASS_ID]
	FROM
		[wms].[OP_WMS_CLASS] [C]
	INNER JOIN [wms].[OP_WMS_CLASS_ASSOCIATION] [CA] ON ([C].[CLASS_ID] = [CA].[CLASS_ASSOCIATED_ID])
	INNER JOIN @LICENSE_CLASSES [LC] ON ([CA].[CLASS_ID] = [LC].[CLASS_ID]);

  -- ------------------------------------------------------------------------------------
  -- Eliminamos todas las clases de la licencia para luego volverlos a ingresar por si faltara alguna
  -- ------------------------------------------------------------------------------------
		DELETE
			[CC]
		FROM
			@COMPATIBLE_CLASSES [CC]
		INNER JOIN @LICENSE_CLASSES [LC] ON ([CC].[CLASS_ID] = [LC].[CLASS_ID]);

	END
	ELSE
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- Obtiene las sub clases de la ubicaciones
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @CLASSES_ON_LOCATION
				(
					[LOCATION]
					,[CLASS_ID]
				)
		SELECT DISTINCT
			[L].[CURRENT_LOCATION]
			,[C].[SUB_CLASS_ID]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IXL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([L].[LICENSE_ID] = [IXL].[LICENSE_ID])
		INNER JOIN @LOCATION_TABLE [LT] ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [IXL].[MATERIAL_ID])
		INNER JOIN [wms].[OP_WMS_SUB_CLASS] [C] ON ([M].[MATERIAL_SUB_CLASS] = [C].[SUB_CLASS_ID])
		WHERE
			[IXL].[QTY] > 0;
	END

  -- ------------------------------------------------------------------------------------
  -- Ahora insertamos las clases de la licencia, esto es por si no obtenemos todas las clases al principio
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @COMPATIBLE_CLASSES
			(
				[CLASS_ID]
			)
	SELECT
		[CLASS_ID]
	FROM
		@LICENSE_CLASSES;

  -- ------------------------------------------------------------------------------------
  -- Obtenemos la cantidad de clases compatbiles para la ubicacion
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @LOCATION_BY_CLASSES_INCOMPATIBILITY
			(
				[LOCATION]
			)
	SELECT DISTINCT
		[LT].[LOCATION]
	FROM
		@CLASSES_ON_LOCATION [LT]
	LEFT JOIN @COMPATIBLE_CLASSES [CC] ON ([LT].[CLASS_ID] = [CC].[CLASS_ID])
	WHERE
		[CC].[CLASS_ID] IS NULL;

  -- ------------------------------------------------------------------------------------
  -- Actualizamos la ubicaciones para saber si es compatible con las clases de la ubicación
  -- ------------------------------------------------------------------------------------
	UPDATE
		[LT]
	SET	
		[LT].[IS_COMPATIBLE_CLASSES] = CASE	WHEN [LCC].[LOCATION] IS NULL
											THEN 1
											ELSE 0
										END
	FROM
		@LOCATION_TABLE [LT]
	LEFT JOIN @LOCATION_BY_CLASSES_INCOMPATIBILITY [LCC] ON ([LT].[LOCATION] = [LCC].[LOCATION]);

  -- ----------------------------------------
  -- Obtenemos los que ocupara la licencia con sus productos
  -- ----------------------------------------
	SELECT TOP 1
		@LICENSE_WEIGHT = SUM([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](ISNULL([M].[WEIGTH],
											0),
											ISNULL([M].[WEIGHT_MEASUREMENT],
											'KG'))
								* [IL].[ENTERED_QTY])
		,@LICENSE_VOLUME_F = MAX(ISNULL([M].[VOLUME_FACTOR],
										0))
		,@LICENSE_VOLUME_R = SUM(ISNULL([M].[VOLUME_FACTOR],
										0)
									* [IL].[ENTERED_QTY])
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	WHERE
		[IL].[LICENSE_ID] = @LICENSE_ID;

  -- ----------------------------------------
  -- Retornamos el resultado
  -- ----------------------------------------
	SELECT
		[LT].[SLOTTING_ZONE_ID]
		,[LT].[WAREHOUSE_CODE]
		,[LT].[ZONE_ID]
		,[LT].[ZONE]
		,[LT].[MANDATORY]
		,[LT].[COUNT_CLASS]
		,[LT].[COUNT_CLASS_IN_LICENSE]
		,[LT].[DIFFERENCE_OF_CLASSES]
		,[LT].[LOCATION]
		,[LT].[SPOT_TYPE]
		,[LT].[MAX_WEIGHT]
		,[LT].[LOCATION_WEIGHT]
		,[LT].[LOCATION_VOLUME]
		,[LT].[VOLUME]
		,CASE	WHEN ([LT].[MAX_WEIGHT]
						- ([LT].[LOCATION_WEIGHT]
							+ @LICENSE_WEIGHT)) > ROUND(0, 4)
				THEN ROUND([LT].[MAX_WEIGHT]
							- ([LT].[LOCATION_WEIGHT]
								+ @LICENSE_WEIGHT), 4)
				ELSE 0
			END [AVAILABLE_WEIGHT]
		,CASE	WHEN ([LT].[MAX_WEIGHT]
						- ([LT].[LOCATION_WEIGHT]
							+ @LICENSE_WEIGHT)) > 0
				THEN 'checkmark'
				ELSE 'close'
			END [WEIGHT_ICON]
		,CASE	WHEN ([LT].[MAX_WEIGHT]
						- ([LT].[LOCATION_WEIGHT]
							+ @LICENSE_WEIGHT)) > 0
				THEN 'success'
				ELSE 'danger'
			END [WEIGHT_ICON_COLOR]
		,CASE	WHEN ([LT].[VOLUME]
						- ([LT].[LOCATION_VOLUME]
							+ (CASE [LT].[SPOT_TYPE]
									WHEN 'PISO'
									THEN @LICENSE_VOLUME_F
									ELSE @LICENSE_VOLUME_R
								END))) > 0
				THEN [LT].[VOLUME] - ([LT].[LOCATION_VOLUME]
										+ (CASE [LT].[SPOT_TYPE]
											WHEN 'PISO'
											THEN @LICENSE_VOLUME_F
											ELSE @LICENSE_VOLUME_R
											END))
				ELSE 0
			END [AVAILABLE_VOLUME]
		,CASE	WHEN ([LT].[VOLUME]
						- ([LT].[LOCATION_VOLUME]
							+ (CASE [LT].[SPOT_TYPE]
									WHEN 'PISO'
									THEN @LICENSE_VOLUME_F
									ELSE @LICENSE_VOLUME_R
								END))) > 0 THEN 'checkmark'
				ELSE 'close'
			END [VOLUME_ICON]
		,CASE	WHEN ([LT].[VOLUME]
						- ([LT].[LOCATION_VOLUME]
							+ (CASE [LT].[SPOT_TYPE]
									WHEN 'PISO'
									THEN @LICENSE_VOLUME_F
									ELSE @LICENSE_VOLUME_R
								END))) > 0 THEN 'success'
				ELSE 'danger'
			END [VOLUME_ICON_COLOR]
	FROM
		@LOCATION_TABLE [LT]
	WHERE
		[LT].[IS_COMPATIBLE_CLASSES] = 1
	ORDER BY
		15 DESC --PESO DISPONIBLE
		,18 DESC;--VOLUME DISPONIBLE

END;