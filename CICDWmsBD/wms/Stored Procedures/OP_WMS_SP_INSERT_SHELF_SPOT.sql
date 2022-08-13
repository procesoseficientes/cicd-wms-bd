-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/3/2017 @ NEXUS-Team Sprint ewms
-- Description:			Inserta un registro en la tabla [OP_WMS_SHELF_SPOTS]

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	30-Jan-2018 @ Reborn-Team Sprint Trotzdem 
-- Description:			Se agrega el campo de volumen

-- Autor:				Modificacion 20180813 GForce@Jaguarundi
-- Fecha de Creacion: 	marvin.solares
-- Description:			Se agrega columna de fast picking

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_SHELF_SPOT]
				-- 
				SELECT * FROM [wms].[OP_WMS_SHELF_SPOTS] WHERE SPOT_LABEL = 'P07-09-A-N5-C'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_SHELF_SPOT] (
		@WAREHOUSE_PARENT VARCHAR(25)
		,@ZONE VARCHAR(25)
		,@LOCATION_SPOT VARCHAR(25)
		,@SPOT_TYPE VARCHAR(25)
		,@SPOT_ORDERBY DECIMAL
		,@SPOT_AISLE DECIMAL
		,@SPOT_COLUMN VARCHAR(25)
		,@SPOT_LEVEL VARCHAR(25)
		,@SPOT_PARTITION VARCHAR(50)
		,@SPOT_LABEL VARCHAR(25)
		,@ALLOW_PICKING INT
		,@ALLOW_STORAGE INT
		,@ALLOW_REALLOC INT
		,@AVAILABLE INT
		,@LINE_ID VARCHAR(15)
		,@SPOT_LINE VARCHAR(15)
		,@MAX_MT2_OCCUPANCY INT
		,@MAX_WEIGHT DECIMAL
		,@SECTION VARCHAR(50)
		,@VOLUME NUMERIC(18, 4) = 0
		,@ALLOW_FAST_PICKING INT
		,@IS_WASTE INT
	)
AS
BEGIN
	SET NOCOUNT ON;
		--
	BEGIN TRY
			--
		INSERT	INTO [wms].[OP_WMS_SHELF_SPOTS]
				(
					[WAREHOUSE_PARENT]
					,[ZONE]
					,[LOCATION_SPOT]
					,[SPOT_TYPE]
					,[SPOT_ORDERBY]
					,[SPOT_AISLE]
					,[SPOT_COLUMN]
					,[SPOT_LEVEL]
					,[SPOT_PARTITION]
					,[SPOT_LABEL]
					,[ALLOW_PICKING]
					,[ALLOW_STORAGE]
					,[ALLOW_REALLOC]
					,[AVAILABLE]
					,[LINE_ID]
					,[SPOT_LINE]
					,[MAX_MT2_OCCUPANCY]
					,[MAX_WEIGHT]
					,[SECTION]
					,[VOLUME]
					,[ALLOW_FAST_PICKING]
					,[IS_WASTE]
				)
		VALUES
				(
					@WAREHOUSE_PARENT
					, -- WAREHOUSE_PARENT - varchar(25)
					@ZONE
					, -- ZONE - varchar(25)
					@LOCATION_SPOT
					, -- LOCATION_SPOT - varchar(25)
					@SPOT_TYPE
					, -- SPOT_TYPE - varchar(25)
					@SPOT_ORDERBY
					, -- SPOT_ORDERBY - decimal
					@SPOT_AISLE
					, -- SPOT_AISLE - decimal
					@SPOT_COLUMN
					, -- SPOT_COLUMN - varchar(25)
					@SPOT_LEVEL
					, -- SPOT_LEVEL - varchar(25)
					@SPOT_PARTITION
					, -- SPOT_PARTITION - VARCHAR(50)
					@SPOT_LABEL
					, -- SPOT_LABEL - varchar(25)
					@ALLOW_PICKING
					, -- ALLOW_PICKING - int
					@ALLOW_STORAGE
					, -- ALLOW_STORAGE - int
					@ALLOW_REALLOC
					, -- ALLOW_REALLOC - int
					@AVAILABLE
					, -- AVAILABLE - int
					@LINE_ID
					, -- LINE_ID - varchar(15)
					@SPOT_LINE
					, -- SPOT_LINE - varchar(15)
					@MAX_MT2_OCCUPANCY
					, -- MAX_MT2_OCCUPANCY - int
					@MAX_WEIGHT
					, -- MAX_WEIGHT - decimal
					@SECTION
					,  -- SECTION - varchar(50)
					@VOLUME
					,@ALLOW_FAST_PICKING
					,@IS_WASTE
				);
			--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@LOCATION_SPOT AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN ''
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;