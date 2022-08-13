-- =============================================
-- Autor:					marvin.solares
-- Fecha de Creacion: 		08-Jul-2019 G-Force@Dublin
-- Description:			    sp que modifica las propiedades de un material

-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		10-Jul-2019 G-Force@Dublin
-- Description:			    Se agrego propiedad IsNull en la obtencion de propiedades para insertar log.
/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_UPDATE_MATERIAL_PROPERTIES]
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_MATERIAL_PROPERTIES] (
		@LOGIN VARCHAR(25)
		,@OWNER VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@BARCODE_ID VARCHAR(25)
		,@ALTERNATE_BARCODE VARCHAR(25)
		,@BATCH_REQUESTED [NUMERIC](18, 0)
		,@SERIAL_NUMBER_REQUESTS [NUMERIC](18, 0)
		,@HANDLE_TONE [INT]
		,@HANDLE_CALIBER [INT]
	)
AS
BEGIN
	
  -- -----------------------------------------------------------------
  -- ACTUALIZAMOS LA INFORMACION DEL MATERIAL
  -- -----------------------------------------------------------------
	BEGIN TRY
		DECLARE
			@OLD_VALUES VARCHAR(MAX)
			,@NEW_VALUES VARCHAR(MAX);
		SELECT
			@OLD_VALUES = '{BARCODE_ID:['
			+ ISNULL([BARCODE_ID], '')
			+ '],ALTERNATE_BARCODE:['
			+ ISNULL([ALTERNATE_BARCODE], '')
			+ '],BATCH_REQUESTED:['
			+ CAST(ISNULL([BATCH_REQUESTED], '') AS VARCHAR)
			+ '],SERIAL_NUMBER_REQUESTS:['
			+ CAST(ISNULL([SERIAL_NUMBER_REQUESTS], '') AS VARCHAR)
			+ '],HANDLE_TONE:['
			+ CAST(ISNULL([HANDLE_TONE], '') AS VARCHAR)
			+ '],HANDLE_CALIBER:['
			+ CAST(ISNULL([HANDLE_CALIBER], '') AS VARCHAR)
			+ ']}'
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [CLIENT_OWNER] = @OWNER;

		UPDATE
			[wms].[OP_WMS_MATERIALS]
		SET	
			[BARCODE_ID] = @BARCODE_ID
			,[ALTERNATE_BARCODE] = @ALTERNATE_BARCODE
			,[BATCH_REQUESTED] = @BATCH_REQUESTED
			,[SERIAL_NUMBER_REQUESTS] = @SERIAL_NUMBER_REQUESTS
			,[HANDLE_TONE] = @HANDLE_TONE
			,[HANDLE_CALIBER] = @HANDLE_CALIBER
			,[UPDATE_PROPERTIES_BY_HH] = 1
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [CLIENT_OWNER] = @OWNER;

		SET @NEW_VALUES = '{BARCODE_ID:['
			+ ISNULL(@BARCODE_ID, '')
			+ '],ALTERNATE_BARCODE:['
			+ ISNULL(@ALTERNATE_BARCODE, '')
			+ '],BATCH_REQUESTED:['
			+ CAST(ISNULL(@BATCH_REQUESTED, '') AS VARCHAR)
			+ '],SERIAL_NUMBER_REQUESTS:['
			+ CAST(ISNULL(@SERIAL_NUMBER_REQUESTS, '') AS VARCHAR)
			+ '],HANDLE_TONE:['
			+ CAST(ISNULL(@HANDLE_TONE, '') AS VARCHAR)
			+ '],HANDLE_CALIBER:['
			+ CAST(ISNULL(@HANDLE_CALIBER, '') AS VARCHAR)
			+ ']}';

		INSERT	INTO [wms].[LOG_CHANGE_MATERIAL]
				(
					[LOGIN_ID]
					,[OLD_VALUES]
					,[NEW_VALUES]
					,[DATE_UPDATED]
				)
		VALUES
				(
					@LOGIN  -- LOGIN_ID - varchar(50)
					,@OLD_VALUES  -- OLD_VALUES - varchar(max)
					,@NEW_VALUES  -- NEW_VALUES - varchar(max)
					,GETDATE()  -- DATE_UPDATED - datetime
				);


		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]; --,  0 Codigo, '0' DbData
  
	END TRY
	BEGIN CATCH     
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;

	

END;








