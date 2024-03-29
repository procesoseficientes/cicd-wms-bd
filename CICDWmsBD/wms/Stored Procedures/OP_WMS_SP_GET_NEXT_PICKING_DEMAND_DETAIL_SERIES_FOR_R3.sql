﻿-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181012 GForce@Langosta
-- Description:	        Sp que trae el detalle de un Picking wms para enviarlo a R3

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181114 GForce@Narwhal
-- Description:	        Modificación para que separe la obtención de series en otro sp

/*
-- Ejemplo de Ejecucion:
			select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			--
			EXEC [wms].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL_SERIES_FOR_R3] 
				@PICKING_DEMAND_HEADER_ID = 5229
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL_SERIES_FOR_R3] (
		@PICKING_DEMAND_HEADER_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	CREATE TABLE [#PICKING_SERIES] (
		[MENGE] DECIMAL(19, 6)
		,[EBELP] INT
		,[SERIAL_NUMBER_REQUESTS] DECIMAL(18, 0)
		,[SERIE] VARCHAR(100)
		,[WAVE_PICKING_ID] DECIMAL(18, 0)
		,[MATERIAL_ID] VARCHAR(50)
		,[VBELN] VARCHAR(200)
		,[ROW_NUMBER] INT
	);
	INSERT	INTO [#PICKING_SERIES]
			(
				[MENGE]
				,[EBELP]
				,[SERIAL_NUMBER_REQUESTS]
				,[SERIE]
				,[WAVE_PICKING_ID]
				,[MATERIAL_ID]
				,[VBELN]
				,[ROW_NUMBER]
			)
	SELECT
		CASE	WHEN [MS].[CORRELATIVE] IS NULL
				THEN [PDD].[QTY]
				ELSE 1
		END [MENGE]
		,[PDD].[LINE_NUM] [EBELP]
		,CASE	WHEN [MS].[CORRELATIVE] IS NULL
				THEN [M].[SERIAL_NUMBER_REQUESTS]
				ELSE 0
			END [SERIAL_NUMBER_REQUESTS]
		,CASE	WHEN [MS].[CORRELATIVE] IS NULL THEN ''
				WHEN [MS].[SERIAL_CORRELATIVE] IS NULL
				THEN [MS].[SERIAL]
				ELSE ISNULL([MS].[SERIAL_PREFIX], '')
						+ CAST([MS].[SERIAL_CORRELATIVE] AS VARCHAR(50))
			END [SERIE]
		,[PDH].[WAVE_PICKING_ID]
		,[M].[MATERIAL_ID]
		,CAST([SO].[VBELN] AS VARCHAR(200))
		,DENSE_RANK() OVER (ORDER BY [PDD].[PICKING_DEMAND_DETAIL_ID]) AS [ROW_NUMBER]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[PICKING_DEMAND_HEADER_ID] = [PDD].[PICKING_DEMAND_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
	INNER JOIN [SWIFT_R3_INTER].[dbo].[RFC_SALE_ORDER] [SO] ON [PDH].[DOC_ENTRY] = [SO].[VBELN]
											AND [SO].[POSNR] = [PDD].[LINE_NUM]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
	LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS] ON [MS].[PICKING_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
											AND [MS].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
											AND [PDD].[LINE_NUM] = [MS].[PICKING_LINE_NUM]
											AND [PDH].[WAVE_PICKING_ID] = [MS].[WAVE_PICKING_ID]
	WHERE
		[PDD].[QTY] > 0
		AND [PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
		AND [PDH].[TYPE_DEMAND_CODE] IN (0, 1)
		AND [M].[SERIAL_NUMBER_REQUESTS] = 1
	GROUP BY
		CASE	WHEN [MS].[CORRELATIVE] IS NULL
				THEN [PDD].[QTY]
				ELSE 1
		END
		,[PDD].[LINE_NUM]
		,CASE	WHEN [MS].[CORRELATIVE] IS NULL
				THEN [M].[SERIAL_NUMBER_REQUESTS]
				ELSE 0
			END
		,CASE	WHEN [MS].[CORRELATIVE] IS NULL THEN ''
				WHEN [MS].[SERIAL_CORRELATIVE] IS NULL
				THEN [MS].[SERIAL]
				ELSE ISNULL([MS].[SERIAL_PREFIX], '')
						+ CAST([MS].[SERIAL_CORRELATIVE] AS VARCHAR(50))
			END
		,[PDH].[WAVE_PICKING_ID]
		,[M].[MATERIAL_ID]
		,CAST([SO].[VBELN] AS VARCHAR(200))
		,[PDD].[PICKING_DEMAND_DETAIL_ID]
	ORDER BY
		[PDD].[PICKING_DEMAND_DETAIL_ID] ASC;

	DECLARE
		@LINE_NUM INT
		,@QTY NUMERIC(18, 4)
		,@SERIAL_NUMBER_ID NUMERIC
		,@WAVE_PICKING_ID INT
		,@MATERIAL_ID VARCHAR(50)
		,@VBELN VARCHAR(200); 

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#PICKING_SERIES]
					WHERE
						[SERIAL_NUMBER_REQUESTS] = 1
						AND [SERIE] = '' )
	BEGIN
						
		SELECT TOP 1
			@LINE_NUM = [EBELP]
			,@QTY = [MENGE]
			,@WAVE_PICKING_ID = [WAVE_PICKING_ID]
			,@MATERIAL_ID = [MATERIAL_ID]
			,@VBELN = [VBELN]
		FROM
			[#PICKING_SERIES]
		WHERE
			[SERIAL_NUMBER_REQUESTS] = 1
			AND [SERIE] = ''; 
			 
		PRINT @MATERIAL_ID + ' LINEA:'
			+ CAST(@LINE_NUM AS VARCHAR) + ' '
			+ CAST (@QTY AS VARCHAR);
		WHILE (@QTY > 0)
		BEGIN
			SELECT TOP 1
				@SERIAL_NUMBER_ID = [CORRELATIVE]
			FROM
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS]
			WHERE
				[MS].[PICKING_HEADER_ID] IS NULL
				AND [MS].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [MS].[MATERIAL_ID] = @MATERIAL_ID;
															
			UPDATE
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
			SET	
				[PICKING_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
				,[PICKING_LINE_NUM] = @LINE_NUM
			WHERE
				@SERIAL_NUMBER_ID = [CORRELATIVE]; 

			INSERT	INTO [#PICKING_SERIES]
					(
						[MENGE]
						,[EBELP]
						,[SERIAL_NUMBER_REQUESTS]
						,[SERIE]
						,[WAVE_PICKING_ID]
						,[MATERIAL_ID]
						,[VBELN]
						,[ROW_NUMBER]
					)
			SELECT TOP 1
				1 [MENGE]
				,[EBELP]
				,0 [SERIAL_NUMBER_REQUESTS]
				,CASE	WHEN [MS].[SERIAL_CORRELATIVE] IS NULL
						THEN [MS].[SERIAL]
						ELSE ISNULL([MS].[SERIAL_PREFIX], '')
								+ CAST([MS].[SERIAL_CORRELATIVE] AS VARCHAR(50))
					END [SERIE]
				,[R].[WAVE_PICKING_ID]
				,[R].[MATERIAL_ID]
				,[R].[VBELN]
				,[R].[ROW_NUMBER]
			FROM
				[#PICKING_SERIES] [R]
			INNER JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS] ON [MS].[CORRELATIVE] = @SERIAL_NUMBER_ID
			WHERE
				[EBELP] = @LINE_NUM;

			SELECT
				@QTY = @QTY - 1;
		END; 
		DELETE
			[#PICKING_SERIES]
		WHERE
			[EBELP] = @LINE_NUM
			AND [SERIAL_NUMBER_REQUESTS] = 1;
	END; 

	SELECT
		[EBELP]
		,[SERIE]
		,[VBELN]
	FROM
		[#PICKING_SERIES]
	WHERE
		ISNULL([SERIE], '') <> ''
	ORDER BY
		[EBELP] ASC
		,[SERIE] ASC;
	
END;
