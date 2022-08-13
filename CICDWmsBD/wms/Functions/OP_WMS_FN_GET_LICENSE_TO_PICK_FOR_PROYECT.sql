-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		19-Jul-2019  G-Force@Dublin
-- Historia:      Product Backlog Item 30120: Demanda de despacho por proyecto
-- Description:   Se obtiene el inventario del proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:			agrego parámetro de mínimo de días de fecha de expiración
--						para que se omitan con fecha de expiración próximas a vencer

-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			agrego como parámetro una licencia de la cual no quiero que se tome en cuenta su inventario disponible en el algoritmo de picking

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].OP_WMS_FN_GET_LICENSE_TO_PICK_FOR_PROYECT('wms/I00000002','BODEGA_02',255,1,NULL)		
*/
-- =============================================

CREATE FUNCTION [wms].[OP_WMS_FN_GET_LICENSE_TO_PICK_FOR_PROYECT] (
		@MATERIAL_ID VARCHAR(50)
		,@WAREHOUSE VARCHAR(25)
		,@QUANTITY_ASSIGNED NUMERIC(18, 4)
		,@HANDLE_BATCH INT = 0
		,@PICKING_TYPE VARCHAR(25) = NULL
		,@PICKING_HEADER_ID INT = NULL
		,@STATUS_CODE VARCHAR(50) = NULL
		,@DISPATCH_BY_STATUS INT = 0
		,@PROYECT_ID UNIQUEIDENTIFIER
		,@MIN_DAYS_EXPIRATION_DATE INT
		,@LICENSE_ID_TO_EXCLUDE [NUMERIC](18, 0) = -1
	)
RETURNS @LICENSE TABLE (
		[CURRENT_LOCATION] VARCHAR(25)
		,[CURRENT_WAREHOUSE] VARCHAR(25)
		,[LICENSE_ID] NUMERIC(18, 0)
		,[CODIGO_POLIZA] VARCHAR(25)
		,[QTY] NUMERIC(18, 4)
		,[FECHA_DOCUMENTO] DATETIME
		,[ORDER] INT NOT NULL
		,[SOURCE] VARCHAR(15)
		,[ALLOW_FAST_PICKING] INT
	)
AS
BEGIN
	DECLARE	@LICENSE_TEMPORAL TABLE (
			[CURRENT_LOCATION] VARCHAR(25)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[LICENSE_ID] NUMERIC(18, 0)
			,[CODIGO_POLIZA] VARCHAR(25)
			,[QTY] NUMERIC(18, 4)
			,[FECHA_DOCUMENTO] DATETIME
			,[ORDER] INT NOT NULL
			,[SOURCE] VARCHAR(15)
			,[ALLOW_FAST_PICKING] INT
		);

    -- ------------------------------------------------------------------------------------
    -- Obtener tipo de picking
    -- ------------------------------------------------------------------------------------
	IF @PICKING_TYPE IS NULL
		OR @PICKING_TYPE = ''
	BEGIN
		SET @PICKING_TYPE = 'ASCENDENTE';
        --
		SELECT
			@PICKING_TYPE = UPPER([PICKING_TYPE])
		FROM
			[wms].[OP_WMS_WAREHOUSES]
		WHERE
			[WAREHOUSE_ID] = @WAREHOUSE;
	END;

	SELECT
		@DISPATCH_BY_STATUS = CONVERT(INT, [P].[VALUE])
	FROM
		[wms].[OP_WMS_PARAMETER] [P]
	WHERE
		[P].[GROUP_ID] = 'PICKING_DEMAND'
		AND [P].[PARAMETER_ID] = 'DISPATCH_BY_STATUS';

	IF @HANDLE_BATCH = 0
	BEGIN
		INSERT	INTO @LICENSE_TEMPORAL
				(
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,[ORDER]
					,[SOURCE]
					,[ALLOW_FAST_PICKING]
				)
		SELECT
			[IFP].[CURRENT_LOCATION]
			,[IFP].[CURRENT_WAREHOUSE]
			,[IFP].[LICENSE_ID]
			,[IFP].[CODIGO_POLIZA]
			,[IFP].[QTY_LICENSE]
			,[IFP].[FECHA_DOCUMENTO]
			,ROW_NUMBER() OVER (ORDER BY [IFP].[ALLOW_FAST_PICKING] DESC, [IFP].[QTY_LICENSE] ASC, [IFP].[CURRENT_LOCATION] ASC)
			,'ASCENDENTE'
			,[IFP].[ALLOW_FAST_PICKING]
		FROM
			[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROYECT_ID) [IFP]
		WHERE
			@MATERIAL_ID = [IFP].[MATERIAL_ID]
			AND (
					(
						@DISPATCH_BY_STATUS = 0
						OR @STATUS_CODE IS NULL
					)
					OR @STATUS_CODE = [IFP].[STATUS_CODE]
				)
			AND 0 < [IFP].[QTY_LICENSE]
			AND [IFP].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
			AND [IFP].[CURRENT_WAREHOUSE] = @WAREHOUSE;
	END;
	ELSE
	BEGIN
		DECLARE	@DATE_MIN_EXPIRATION_DATE DATE = CAST(DATEADD(DAY,
											@MIN_DAYS_EXPIRATION_DATE,
											GETDATE()) AS DATE);
		INSERT	INTO @LICENSE_TEMPORAL
				(
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,[ORDER]
					,[SOURCE]
					,[ALLOW_FAST_PICKING]
				)
		SELECT
			[IFP].[CURRENT_LOCATION]
			,[IFP].[CURRENT_WAREHOUSE]
			,[IFP].[LICENSE_ID]
			,[IFP].[CODIGO_POLIZA]
			,[IFP].[QTY_LICENSE]
			,[IFP].[FECHA_DOCUMENTO]
			,ROW_NUMBER() OVER (ORDER BY [IFP].[ALLOW_FAST_PICKING] DESC, [IFP].[DATE_EXPIRATION] ASC, [IFP].[QTY_LICENSE] ASC, [IFP].[CURRENT_LOCATION] ASC)
			,'ASCENDENTE'
			,[IFP].[ALLOW_FAST_PICKING]
		FROM
			[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROYECT_ID) [IFP]
		WHERE
			@MATERIAL_ID = [IFP].[MATERIAL_ID]
			AND (
					(
						@DISPATCH_BY_STATUS = 0
						OR @STATUS_CODE IS NULL
					)
					OR @STATUS_CODE = [IFP].[STATUS_CODE]
				)
			AND 0 < [IFP].[QTY_LICENSE]
			AND [IFP].[CURRENT_WAREHOUSE] = @WAREHOUSE
			AND [IFP].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
			AND @DATE_MIN_EXPIRATION_DATE < [IFP].[DATE_EXPIRATION];
	END;


    -- ------------------------------------------------------------------------------------
    -- Si el picking es ascendente unicamente se retorna la tabla temporal que ya está ordenada
    -- ------------------------------------------------------------------------------------
	IF @PICKING_TYPE = 'ASCENDENTE'
	BEGIN
		INSERT	INTO @LICENSE
				(
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,[ORDER]
					,[ALLOW_FAST_PICKING]
				)
		SELECT
			[CURRENT_LOCATION]
			,[CURRENT_WAREHOUSE]
			,[LICENSE_ID]
			,[CODIGO_POLIZA]
			,[QTY]
			,[FECHA_DOCUMENTO]
			,[ORDER]
			,[ALLOW_FAST_PICKING]
		FROM
			@LICENSE_TEMPORAL
		ORDER BY
			[ORDER] ASC;
		GOTO END_RETURN;
	END;
	ELSE
	BEGIN
		DECLARE
			@QTY_TEMP NUMERIC(18, 4)
			,@LICENSE_ID INT
			,@CODIGO_POLIZA VARCHAR(50)
			,@FECHA_DOCUMENTO DATETIME
			,@CURRENT_QTY NUMERIC(18, 4)
			,@LOCATION_SPOT VARCHAR(25)
			,@ORDER INT = 0
			,@HAS_RESULT INT = 0
			,@ALLOW_FAST_PICKING INT = 0
			,@LAST_DATE_EXPIRATION DATETIME;
        --
		SET @QTY_TEMP = @QUANTITY_ASSIGNED;
        --
		WHILE (@QTY_TEMP > 0)
		BEGIN

			SET @HAS_RESULT = 0;

			SELECT TOP 1
				@LAST_DATE_EXPIRATION = [FECHA_DOCUMENTO]
			FROM
				@LICENSE_TEMPORAL
			ORDER BY
				[FECHA_DOCUMENTO] ASC;

			IF @HANDLE_BATCH = 0
			BEGIN

				SELECT TOP 1
					@CURRENT_QTY = [QTY]
					,@LICENSE_ID = [LICENSE_ID]
					,@LOCATION_SPOT = [CURRENT_LOCATION]
					,@CODIGO_POLIZA = [CODIGO_POLIZA]
					,@FECHA_DOCUMENTO = [FECHA_DOCUMENTO]
					,@ALLOW_FAST_PICKING = [ALLOW_FAST_PICKING]
					,@HAS_RESULT = 1
				FROM
					@LICENSE_TEMPORAL
				WHERE
					[QTY] <= @QTY_TEMP
				ORDER BY
					[QTY] DESC
					,[CURRENT_LOCATION] ASC;

			END;
			ELSE
			BEGIN

				SELECT TOP 1
					@CURRENT_QTY = [QTY]
					,@LICENSE_ID = [LICENSE_ID]
					,@LOCATION_SPOT = [CURRENT_LOCATION]
					,@CODIGO_POLIZA = [CODIGO_POLIZA]
					,@FECHA_DOCUMENTO = [FECHA_DOCUMENTO]
					,@ALLOW_FAST_PICKING = [ALLOW_FAST_PICKING]
					,@HAS_RESULT = 1
				FROM
					@LICENSE_TEMPORAL
				WHERE
					[QTY] <= @QTY_TEMP
					AND [FECHA_DOCUMENTO] = @LAST_DATE_EXPIRATION
				ORDER BY
					[ALLOW_FAST_PICKING] DESC
					,[FECHA_DOCUMENTO] ASC
					,[QTY] DESC
					,[CURRENT_LOCATION] ASC;
			END;

			IF @HAS_RESULT = 0
			BEGIN
				INSERT	INTO @LICENSE
						(
							[CURRENT_LOCATION]
							,[CURRENT_WAREHOUSE]
							,[LICENSE_ID]
							,[CODIGO_POLIZA]
							,[QTY]
							,[FECHA_DOCUMENTO]
							,[ORDER]
							,[SOURCE]
							,[ALLOW_FAST_PICKING]
						)
				SELECT
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,CASE	WHEN @HANDLE_BATCH = 0
							THEN @ORDER
									+ ROW_NUMBER() OVER (ORDER BY [ALLOW_FAST_PICKING] DESC, [QTY] ASC, [CURRENT_LOCATION] ASC)
							ELSE @ORDER
									+ ROW_NUMBER() OVER (ORDER BY [ALLOW_FAST_PICKING] DESC, [FECHA_DOCUMENTO] ASC, [QTY] ASC, [CURRENT_LOCATION] ASC)
						END
					,'ASCENDENTE'
					,[ALLOW_FAST_PICKING]
				FROM
					@LICENSE_TEMPORAL
				WHERE
					[LICENSE_ID] NOT IN (SELECT
											[LICENSE_ID]
											FROM
											@LICENSE);
				GOTO END_RETURN;
			END;
			DELETE FROM
				@LICENSE_TEMPORAL
			WHERE
				[LICENSE_ID] = @LICENSE_ID;

			SELECT
				@QTY_TEMP = @QTY_TEMP - @CURRENT_QTY;

			INSERT	INTO @LICENSE
					(
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[FECHA_DOCUMENTO]
						,[ORDER]
						,[SOURCE]
						,[ALLOW_FAST_PICKING]
					)
			VALUES
					(
						@LOCATION_SPOT
						,   -- CURRENT_LOCATION - varchar(25)
						@WAREHOUSE
						,       -- CURRENT_WAREHOUSE - varchar(25)
						@LICENSE_ID
						,      -- LICENSE_ID - numeric
						@CODIGO_POLIZA
						,   -- CODIGO_POLIZA - varchar(25)
						@CURRENT_QTY
						,     -- QTY - numeric
						@FECHA_DOCUMENTO
						, -- FECHA_DOCUMENTO - datetime
						@ORDER
						,           -- ORDER - int							
						'DESCENDENTE'
						,@ALLOW_FAST_PICKING
					);
			SET @ORDER = @ORDER + 1;

		END;
	END;
	END_RETURN:
	RETURN;
END;