-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/3/2017 @ NEXUS-Team Sprint ewms 
-- Description:			SP que actualiza un registro de la tabla [OP_WMS_SHELF_SPOTS]

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	30-Jan-2018 @ Reborn-Team Sprint Trotzdem 
-- Description:			Se agrega el campo de volumen

-- Autor:				Modificacion 20180813 GForce@Jaguarundi
-- Fecha de Creacion: 	marvin.solares
-- Description:			Se agrega columna de fast picking

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_SHELF_SPOT]
					@
				-- 
				SELECT * FROM [wms].OP_WMS_SHELF_SPOTS
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_SHELF_SPOT] (
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
		,@FOR_FORKLIFT INT
		,@IS_WASTE INT
	)
AS
BEGIN
	SET NOCOUNT ON;
		--
	BEGIN TRY
		UPDATE
			[wms].[OP_WMS_SHELF_SPOTS]
		SET	
			[WAREHOUSE_PARENT] = @WAREHOUSE_PARENT
			,[ZONE] = @ZONE
			,[LOCATION_SPOT] = @LOCATION_SPOT
			,[SPOT_TYPE] = @SPOT_TYPE
			,[SPOT_ORDERBY] = @SPOT_ORDERBY
			,[SPOT_AISLE] = @SPOT_AISLE
			,[SPOT_COLUMN] = @SPOT_COLUMN
			,[SPOT_LEVEL] = @SPOT_LEVEL
			,[SPOT_PARTITION] = @SPOT_PARTITION
			,[SPOT_LABEL] = @SPOT_LABEL
			,[ALLOW_PICKING] = @ALLOW_PICKING
			,[ALLOW_STORAGE] = @ALLOW_STORAGE
			,[ALLOW_REALLOC] = @ALLOW_REALLOC
			,[AVAILABLE] = @AVAILABLE
			,[LINE_ID] = @LINE_ID
			,[SPOT_LINE] = @SPOT_LINE
			,[MAX_MT2_OCCUPANCY] = @MAX_MT2_OCCUPANCY
			,[MAX_WEIGHT] = @MAX_WEIGHT
			,[SECTION] = @SECTION
			,[VOLUME] = @VOLUME
			,[ALLOW_FAST_PICKING] = @ALLOW_FAST_PICKING
			,[FOR_FORKLIFT] = @FOR_FORKLIFT
			,[IS_WASTE] = @IS_WASTE
		WHERE
			[WAREHOUSE_PARENT] = @WAREHOUSE_PARENT
			AND [LOCATION_SPOT] = @LOCATION_SPOT;

			--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
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