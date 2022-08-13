
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint 6
-- Description:			SP que inserta los empaques

-- Autor:				marvin.garcia
-- Fecha de Creacion: 	31-May-18 @ A-TEAM Sprint Dinosaurio
-- Description:			se agregaron validaciones para no permitir codigos de barras existentes en tabla materiales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_INSERT_MEASUREMENT_UNIT]
					@CLIENT_ID = 'C00015'
					,@MATERIAL_ID = 'C00015/AMERQUIM'
					,@MEASUREMENT_UNIT = 'caja pequeña'
					,@QTY = 10
					,@BARCODE = 'C00015/AMERQUIM/caja_pequeña'
					,@ALTERNATIVE_BARCODE = 'C00015/AMERQUIM/caja_pequeña'
				-- 
				SELECT * FROM [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_MEASUREMENT_UNIT] (
		@CLIENT_ID VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@MEASUREMENT_UNIT VARCHAR(50)
		,@QTY INT
		,@BARCODE VARCHAR(100)
		,@ALTERNATIVE_BARCODE VARCHAR(100)
	)
AS
BEGIN
	BEGIN TRY
		DECLARE	@ID INT;
		-- VALIDACION DE CODIGO DE BARRAS EN MATERIALES
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MATERIALS] [M]
					WHERE
						(
							([M].[BARCODE_ID] = @BARCODE)
							OR ([M].[ALTERNATE_BARCODE] = @BARCODE)
						)
						AND [M].[CLIENT_OWNER] = @CLIENT_ID )
		BEGIN
			SELECT
				-1 AS [Resultado]
				,'Código de barras ya esta asociado a un producto' AS [Mensaje]
				,00 AS [Codigo];
			RETURN;
		END;

		-- ------------------------------------------------------------------------------------
		-- validacion de codigo de barras en unidades de medida
		-- ------------------------------------------------------------------------------------

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM]
					INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
					WHERE
						(
							[UMM].[BARCODE] = @BARCODE
							OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE
						)
						AND [M].[CLIENT_OWNER] = @CLIENT_ID
						AND [UMM].[MEASUREMENT_UNIT] != @MEASUREMENT_UNIT)
		BEGIN
			SELECT
				-1 AS [Resultado]
				,'Código de barras ya esta asociado a una unidad de medida' AS [Mensaje]
				,00 AS [Codigo];
			RETURN;
		END;

		IF (ISNULL(@ALTERNATIVE_BARCODE, '') != '')
		BEGIN
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_MATERIALS] [M]
						WHERE
							(
								([M].[ALTERNATE_BARCODE] = @ALTERNATIVE_BARCODE)
								OR ([M].[BARCODE_ID] = @ALTERNATIVE_BARCODE)
							)
							AND [M].[CLIENT_OWNER] = @CLIENT_ID )
			BEGIN
				SELECT
					-1 AS [Resultado]
					,'Código de barras alternativo ya esta asociado a un producto' AS [Mensaje]
					,00 AS [Codigo];
				RETURN;
			END;

			IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM]
					INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
					WHERE
						(
							[UMM].[BARCODE] = @ALTERNATIVE_BARCODE
							OR [UMM].[ALTERNATIVE_BARCODE] = @ALTERNATIVE_BARCODE
						)
						AND [M].[CLIENT_OWNER] = @CLIENT_ID
						AND [UMM].[MEASUREMENT_UNIT] != @MEASUREMENT_UNIT ) 
			BEGIN
				SELECT
					-1 AS [Resultado]
					,'Código de barras alternativo ya esta asociado a una unidad de medida' AS [Mensaje]
					,00 AS [Codigo];
				RETURN;
			END;
		END;
		

		------------------------------------------------------------------
		INSERT	INTO [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
				(
					[CLIENT_ID]
					,[MATERIAL_ID]
					,[MEASUREMENT_UNIT]
					,[QTY]
					,[BARCODE]
					,[ALTERNATIVE_BARCODE]
				)
		VALUES
				(
					@CLIENT_ID  -- CLIENT_ID - varchar(25)
					,@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
					,@MEASUREMENT_UNIT  -- MEASUREMENT_UNIT - varchar(50)
					,@QTY -- QTY - int
					,@BARCODE  -- BARCODE - varchar(100)
					,@ALTERNATIVE_BARCODE  -- ALTERNATIVE_BARCODE - varchar(100)
				);
		--
		SET @ID = SCOPE_IDENTITY();
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@ID AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE	WHEN CAST(@@ERROR AS VARCHAR) = '2627'
							AND ERROR_MESSAGE() LIKE '%UC_OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL_MEASUREMENT_UNIT%'
					THEN CONCAT('Ya existe la unidad de medida para el material en el cliente ',
								@CLIENT_ID)
					WHEN CAST(@@ERROR AS VARCHAR) = '2627'
							AND ERROR_MESSAGE() LIKE '%UC_OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL_BARCODE%'
					THEN CONCAT('Ya existe el código de barras para el material en el cliente ',
								@CLIENT_ID)
					WHEN CAST(@@ERROR AS VARCHAR) = '2627'
							AND ERROR_MESSAGE() LIKE '%UC_OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL_ALTERNATIVE_BARCODE%'
					THEN CONCAT('Ya existe el código de barras alternativo para el material en el cliente ',
								@CLIENT_ID)
					ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;