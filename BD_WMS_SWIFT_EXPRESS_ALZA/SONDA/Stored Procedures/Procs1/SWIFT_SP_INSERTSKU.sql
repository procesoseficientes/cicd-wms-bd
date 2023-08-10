-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	26-01-2016
-- Description:			Inserta en la tabla de SKu con el valor de en kilogramos

-- MODIFICADO: 08-03-2016
		--diego.as
		-- Se agrego el parametro CODE_FAMILY_SKU que no estaba agregado para Insertar

-- Modificacion 04-Nov-16 @ A-Team Sprint 4
					-- alberto.ruiz
					-- Se agrego el parametro HANDLE_DIMENSION
/*
-- Ejemplo de Ejecucion:
				-- 	
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERTSKU](
	@CODE_SKU VARCHAR(50)
	,@DESCRIPTION_SKU VARCHAR(MAX)
	,@CLASSIFICATION_SKU VARCHAR(50)
	,@BARCODE_SKU VARCHAR(50)
	,@CODE_PROVIDER VARCHAR(50)
	,@COST FLOAT
	,@MEASURE VARCHAR(50)
	,@LAST_UPDATE VARCHAR(50)
	,@LAST_UPDATE_BY VARCHAR(50)
	,@HANDLE_SERIAL_NUMBER VARCHAR(2)
	,@HANDLE_BATCH VARCHAR(2)
	,@UNIT_MEASURE_SKU [INT]
	,@WEIGHT_SKU [NUMERIC](18 ,2)
	,@VOLUME_SKU [NUMERIC](18 ,2)
	,@LONG_SKU [NUMERIC](18 ,2)
	,@WIDTH_SKU [NUMERIC](18 ,2)
	,@HIGH_SKU [NUMERIC](18 ,2)
	,@CODE_FAMILY_SKU VARCHAR(50)
	,@HANDLE_DIMENSION INT = 0
)AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY

		DECLARE	
			@KILOGRAM [NUMERIC](18 ,2)= 0.0
			,@UNIT INT

		SELECT @UNIT = [P].[VALUE]
		FROM [SONDA].[SWIFT_PARAMETER] [P]
		WHERE [P].[GROUP_ID] = 'DEFAULT_MEASURE'
			AND [P].[PARAMETER_ID] = 'KILOGRAMO';

		SET @KILOGRAM = [SONDA].[SWIFT_FN_CONVERT_MEASURE](@MEASURE,@UNIT,@WEIGHT_SKU);
		SELECT
			@KILOGRAM;


		INSERT	INTO [SONDA].[SWIFT_SKU]
				(
					[CODE_SKU]
					,[DESCRIPTION_SKU]
					,[CLASSIFICATION_SKU]
					,[BARCODE_SKU]
					,[CODE_PROVIDER]
					,[COST]
					,[MEASURE]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[HANDLE_SERIAL_NUMBER]
					,[HANDLE_BATCH]
					,[UNIT_MEASURE_SKU]
					,[WEIGHT_SKU]
					,[VOLUME_SKU]
					,[LONG_SKU]
					,[WIDTH_SKU]
					,[HIGH_SKU]
					,[CODE_FAMILY_SKU]
					,[HANDLE_DIMENSION]
				)
		VALUES
				(
					@CODE_SKU
					,@DESCRIPTION_SKU
					,@CLASSIFICATION_SKU
					,@BARCODE_SKU
					,@CODE_PROVIDER
					,@COST
					,@MEASURE
					,GETDATE()
					,@LAST_UPDATE_BY
					,@HANDLE_SERIAL_NUMBER
					,@HANDLE_BATCH
					,@UNIT
					,@KILOGRAM
					,@VOLUME_SKU
					,@LONG_SKU
					,@WIDTH_SKU
					,@HIGH_SKU
					,@CODE_FAMILY_SKU
					,@HANDLE_DIMENSION
				);

	END TRY
	BEGIN CATCH
		DECLARE	
			@ErrorMessage NVARCHAR(4000)
			,@ErrorSeverity INT
			,@ErrorState INT

		SELECT
			@ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END;
