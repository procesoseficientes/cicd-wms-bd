-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4
-- Description:			SP que inserta la serie por MATERIAL

-- Autor:				rudi.garcia
-- Modificación: 	20-Jun-17 @ TEAM-Ergon Sprint BreathOfTheWeild
-- Description:			Se agrego una condicion que si el @BATCH no venga null, este actualize el lote a las series ingresadas de esa licencia y material.

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Langosta
-- Description:			Se agrega validación para recepción dirigida por orden de compra

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_MATERIAL_X_SERIAL_NUMBER]
					@LICENSE_ID = 5
					,@MATERIAL_ID = 'C00012/CONCLIMON'
					,@SERIAL = 'SERIAL'
					,@BATCH = 'BATCH'
					,@DATE_EXPIRATION = '20171111'
				-- 
				SELECT * FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_MATERIAL_X_SERIAL_NUMBER] (
		@LICENSE_ID NUMERIC(18, 0)
		,@MATERIAL_ID VARCHAR(250)
		,@SERIAL VARCHAR(50)
		,@BATCH VARCHAR(50) = NULL
		,@DATE_EXPIRATION DATE = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE
			@ID INT
			,@ErrorCode INT
			,@TOTAL_SERIES_RECEPCIONADAS INT
			,@RECEPTION_HEADER_ID INT
			,@POLIZA_RECEPTION INT
			,@MAX_QTY NUMERIC(18, 4);
		--
		-- ------------------------------------------------------------------------------------
	-- validacion de recepcion dirigida por ordenes de compra
	-- ------------------------------------------------------------------------------------
		DECLARE	@VALIDA_DOCUMENTO_RECEPCION INT = 0;
		DECLARE	@SOURCE_RECEPTION VARCHAR(20) = 'PURCHASE_ORDER';
		DECLARE	@SOURCE_INVOICE VARCHAR(20) = 'INVOICE';

		SELECT TOP 1
			@VALIDA_DOCUMENTO_RECEPCION = [NUMERIC_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS]
		WHERE
			[PARAM_TYPE] = 'SISTEMA'
			AND [PARAM_GROUP] = 'RECEPCION'
			AND [PARAM_NAME] = 'VALIDA_RECEPCION_DIRIGIDA';

		IF @VALIDA_DOCUMENTO_RECEPCION = 0
		BEGIN
			SET @SOURCE_RECEPTION = 'INVOICE';--cuando el parámetro es 0 debe hacer el flujo normal
		END;


		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
					WHERE
						[MATERIAL_ID] = @MATERIAL_ID
						AND [SERIAL] = @SERIAL
						AND [STATUS] > 0 )
		BEGIN
			SELECT
				@ErrorCode = 3054;
			RAISERROR (N'La serie de fabrica ya esta siendo utilizada, por favor revisar.', 16, 1);
			RETURN;
		END;
		
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_LICENSES] [L]
					INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON [PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA]
					INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH] ON [RH].[DOC_ID_POLIZA] = [PH].[DOC_ID]
					WHERE
						[L].[LICENSE_ID] = @LICENSE_ID
						AND (
								[RH].[SOURCE] = @SOURCE_RECEPTION
								OR [RH].[SOURCE] = @SOURCE_INVOICE
							)
						AND [RH].[IS_POSTED_ERP] <> 1 )
		BEGIN
        -- ------------------------------------------------------------------------------------
        -- Obtiene el reception headerid y taskid
        -- ------------------------------------------------------------------------------------
			DECLARE	@TASK_ID NUMERIC(18, 0);

			SELECT TOP 1
				@RECEPTION_HEADER_ID = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
				,@POLIZA_RECEPTION = [RH].[DOC_ID_POLIZA]
				,@TASK_ID = [RH].[TASK_ID]
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON [PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA]
			INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH] ON [RH].[DOC_ID_POLIZA] = [PH].[DOC_ID]
			WHERE
				[L].[LICENSE_ID] = @LICENSE_ID;

        -- ------------------------------------------------------------------------------------
        -- Obtiene el maximo a recepcionar en la recepcion
        -- ------------------------------------------------------------------------------------		
			SELECT
				[RD].[UNIT]
				,SUM(ISNULL([RD].[QTY], 0))
				* ISNULL([UMM].[QTY], 1) [QTY]
			INTO
				[#MAX_QTY]
			FROM
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
			INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD] ON [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [RD].[MATERIAL_ID]
											AND [RD].[UNIT] = [UMM].[MEASUREMENT_UNIT]
			WHERE
				[RD].[MATERIAL_ID] = @MATERIAL_ID
				AND [RH].[TASK_ID] = @TASK_ID
			GROUP BY
				[RD].[UNIT]
				,[RD].[QTY]
				,[UMM].[QTY];
								
			SELECT
				@MAX_QTY = SUM([QTY])
			FROM
				[#MAX_QTY];
        -- ------------------------------------------------------------------------------------
        -- Obtiene lo ya recepcionado
        -- ------------------------------------------------------------------------------------
			SELECT
				@MAX_QTY = @MAX_QTY - ISNULL(COUNT(1), 0)
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			INNER JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [IL].[STATUS] > 0
			WHERE
				[IL].[MATERIAL_ID] = @MATERIAL_ID
				AND [L].[CODIGO_POLIZA] = CAST(@POLIZA_RECEPTION AS VARCHAR(25));
			

			IF @MAX_QTY = 0
			BEGIN
				SELECT
					@ErrorCode = 1111;
				RAISERROR (N'La cantidad recepcionada excede a la cantidad del documento para el material.', 16, 1);
				RETURN;
			END;
		END;
		

		INSERT	INTO [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[SERIAL]
					,[BATCH]
					,[DATE_EXPIRATION]
				)
		VALUES
				(
					@LICENSE_ID  -- LICENSE_ID - numeric
					,@MATERIAL_ID  -- MATERIAL_ID - varchar(250)
					,@SERIAL  -- SERIAL - varchar(50)
					,@BATCH  -- BATCH - varchar(50)
					,@DATE_EXPIRATION  -- DATE_EXPIRATION - date
				);
		--
		SET @ID = SCOPE_IDENTITY();
		--
		IF @BATCH IS NOT NULL
		BEGIN
			UPDATE
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
			SET	
				[BATCH] = @BATCH
				,[DATE_EXPIRATION] = @DATE_EXPIRATION
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [STATUS] > 0;
		END;    

		SELECT
			1 [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,1 [Codigo]
			,CAST(@ID AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@ErrorCode [Codigo]
			,'' [DbData];
	END CATCH;

	
END;