-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	06-Sep-2018 G-Force@Jaguarundi
-- Description:	        Sp que rebaja las licencias y las ordenes

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELIVERY_LICENSES_PREPARED] (
		@XML XML
		,@LOGIN VARCHAR(50)
		,@WAVE_PICKING_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN;

    -- ------------------------------------------------------------------------------------
    -- Declaramos tablas a utilizar
    -- ------------------------------------------------------------------------------------
		DECLARE	@ErrorCode INT = 0;

		DECLARE	@LICENSE_ORIGIN AS TABLE (
				[LICENSE_ID] INT
				,[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
			);

		DECLARE	@LICENSE_PICKING_DEMAND AS TABLE (
				[LICENSE_ID] INT
				,[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
			);

		DECLARE	@PICKING_DEMAND_HEADER AS TABLE (
				[PICKING_DEMAND_HEADER_ID] INT
			);

		DECLARE	@PICKING_DEMAND_DETAIL AS TABLE (
				[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
				,[QTY_ORIGIN] DECIMAL(18, 4)
			);

    -- ------------------------------------------------------------------------------------
    -- Obtenemos las licencias a rebajar
    -- ------------------------------------------------------------------------------------

		INSERT	INTO @LICENSE_ORIGIN
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[QTY]
				)
		SELECT
			[x].[Rec].[query]('./LICENSE_ID').[value]('.',
											'int')
			,[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'VARCHAR(50)')
			,[x].[Rec].[query]('./QTY').[value]('.',
											'DECIMAL(18,4)')
		FROM
			@XML.[nodes]('/ArrayOfLicense/License') AS [x] ([Rec]);

		INSERT	INTO @LICENSE_PICKING_DEMAND
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[QTY]
				)
		SELECT
			[LICENSE_ID]
			,[MATERIAL_ID]
			,[QTY]
		FROM
			@LICENSE_ORIGIN;

    -- ------------------------------------------------------------------------------------
    -- Obtenemos las demandas de despacho
    -- ------------------------------------------------------------------------------------
		INSERT	INTO @PICKING_DEMAND_HEADER
				(
					[PICKING_DEMAND_HEADER_ID]
				)
		SELECT
			[PDH].[PICKING_DEMAND_HEADER_ID]
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
		WHERE
			[PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		ORDER BY
			[PDH].[PRIORITY] DESC;

    -- ------------------------------------------------------------------------------------
    -- Recorremos los picking de despacho
    -- ------------------------------------------------------------------------------------

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@PICKING_DEMAND_HEADER )
		BEGIN

      -- ------------------------------------------------------------------------------------
      -- Declaramos las variables a utilizar
      -- ------------------------------------------------------------------------------------
			DECLARE	@PICKING_DEMAND_HEADER_ID INT;

      -- ------------------------------------------------------------------------------------
      -- Obtenemos la primera demanda de despacho
      -- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@PICKING_DEMAND_HEADER_ID = [PICKING_DEMAND_HEADER_ID]
			FROM
				@PICKING_DEMAND_HEADER;

      -- ------------------------------------------------------------------------------------
      -- Limpiamos la tabla de detalle temporal
      -- ------------------------------------------------------------------------------------
			DELETE
				@PICKING_DEMAND_DETAIL;

      -- ------------------------------------------------------------------------------------
      -- Obtenemos los detalles de la demanda de despacho
      -- ------------------------------------------------------------------------------------
			INSERT	INTO @PICKING_DEMAND_DETAIL
					(
						[MATERIAL_ID]
						,[QTY]
						,[QTY_ORIGIN]
					)
			SELECT
				[PDD].[MATERIAL_ID]
				,[PDD].[QTY]
				,[PDD].[QTY]
			FROM
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
			WHERE
				[PDD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

      -- ------------------------------------------------------------------------------------
      -- Actualizamos las cantidades del detalle de la tabla temporal
      -- ------------------------------------------------------------------------------------
			UPDATE
				[PDD]
			SET	
				[QTY] = CASE	WHEN [PDD].[QTY] <= [LPD].[QTY]
								THEN [PDD].[QTY]
								ELSE [LPD].[QTY]
						END
			FROM
				@PICKING_DEMAND_DETAIL [PDD]
			INNER JOIN @LICENSE_PICKING_DEMAND [LPD] ON ([PDD].[MATERIAL_ID] = [LPD].[MATERIAL_ID]);

      -- ------------------------------------------------------------------------------------
      -- Actualizamos las cantidades de la licencia
      -- ------------------------------------------------------------------------------------
			UPDATE
				[LPD]
			SET	
				[QTY] = [LPD].[QTY] - [PDD].[QTY]
			FROM
				@LICENSE_PICKING_DEMAND [LPD]
			INNER JOIN @PICKING_DEMAND_DETAIL [PDD] ON ([LPD].[MATERIAL_ID] = [PDD].[MATERIAL_ID]);

      -- ------------------------------------------------------------------------------------
      -- Actualizamos las cantidades del detalle de la verdadera tabla
      -- ------------------------------------------------------------------------------------

			UPDATE
				[PDD]
			SET	
				[QTY] = [PDDT].[QTY]
			FROM
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
			INNER JOIN @PICKING_DEMAND_DETAIL [PDDT] ON ([PDD].[MATERIAL_ID] = [PDDT].[MATERIAL_ID])
			WHERE
				[PDD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;


      -- ------------------------------------------------------------------------------------
      -- Validamos si es necesario crear otro documento
      -- ------------------------------------------------------------------------------------

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							@PICKING_DEMAND_DETAIL
						WHERE
							[QTY] <> [QTY_ORIGIN] )
			BEGIN
				DECLARE	@ID INT;

        -- ------------------------------------------------------------------------------------
        -- Actualizamos la el campo de si es completado
        -- ------------------------------------------------------------------------------------

				UPDATE
					[PDH]
				SET	
					[PDH].[IS_COMPLETED] = 0
					,[LAST_UPDATE] = GETDATE()
					,[LAST_UPDATE_BY] = @LOGIN
					,[IS_AUTHORIZED] = 1
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
				WHERE
					[PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

        -- ------------------------------------------------------------------------------------
        -- Insertamos el encabezado de la nueva orden
        -- ------------------------------------------------------------------------------------

				INSERT	INTO [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
						(
							[DOC_NUM]
							,[CLIENT_CODE]
							,[CODE_ROUTE]
							,[CODE_SELLER]
							,[TOTAL_AMOUNT]
							,[SERIAL_NUMBER]
							,[DOC_NUM_SEQUENCE]
							,[EXTERNAL_SOURCE_ID]
							,[IS_FROM_ERP]
							,[IS_FROM_SONDA]
							,[LAST_UPDATE]
							,[LAST_UPDATE_BY]
							,[IS_COMPLETED]
							,[WAVE_PICKING_ID]
							,[CODE_WAREHOUSE]
							,[IS_AUTHORIZED]
							,[ATTEMPTED_WITH_ERROR]
							,[IS_POSTED_ERP]
							,[POSTED_ERP]
							,[POSTED_RESPONSE]
							,[ERP_REFERENCE]
							,[CLIENT_NAME]
							,[CREATED_DATE]
							,[ERP_REFERENCE_DOC_NUM]
							,[DOC_ENTRY]
							,[IS_CONSOLIDATED]
							,[PRIORITY]
							,[HAS_MASTERPACK]
							,[POSTED_STATUS]
							,[OWNER]
							,[CLIENT_OWNER]
							,[MASTER_ID_SELLER]
							,[SELLER_OWNER]
							,[SOURCE_TYPE]
							,[INNER_SALE_STATUS]
							,[INNER_SALE_RESPONSE]
							,[DEMAND_TYPE]
							,[TRANSFER_REQUEST_ID]
							,[ADDRESS_CUSTOMER]
							,[STATE_CODE]
							,[DISCOUNT]
							,[UPDATED_VEHICLE]
							,[UPDATED_VEHICLE_RESPONSE]
							,[UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR]
							,[DELIVERY_NOTE_INVOICE]
							,[DEMAND_SEQUENCE]
							,[IS_CANCELED_FROM_SONDA_SD]
							,[TYPE_DEMAND_CODE]
							,[TYPE_DEMAND_NAME]
							,[IS_FOR_DELIVERY_IMMEDIATE]
							,[DEMAND_DELIVERY_DATE]
							,[PROJECT]
						)
				SELECT TOP 1
					[PDH].[DOC_NUM]
					,[PDH].[CLIENT_CODE]
					,[PDH].[CODE_ROUTE]
					,[PDH].[CODE_SELLER]
					,[PDH].[TOTAL_AMOUNT]
					,[PDH].[SERIAL_NUMBER]
					,[PDH].[DOC_NUM_SEQUENCE]
					,[PDH].[EXTERNAL_SOURCE_ID]
					,[PDH].[IS_FROM_ERP]
					,[PDH].[IS_FROM_SONDA]
					,GETDATE()--[PDH].[LAST_UPDATE]
					,@LOGIN--[PDH].[LAST_UPDATE_BY]
					,[PDH].[IS_COMPLETED]
					,[PDH].[WAVE_PICKING_ID]
					,[PDH].[CODE_WAREHOUSE]
					,[PDH].[IS_AUTHORIZED]
					,[PDH].[ATTEMPTED_WITH_ERROR]
					,[PDH].[IS_POSTED_ERP]
					,[PDH].[POSTED_ERP]
					,[PDH].[POSTED_RESPONSE]
					,[PDH].[ERP_REFERENCE]
					,[PDH].[CLIENT_NAME]
					,[PDH].[CREATED_DATE]
					,[PDH].[ERP_REFERENCE_DOC_NUM]
					,[PDH].[DOC_ENTRY]
					,[PDH].[IS_CONSOLIDATED]
					,[PDH].[PRIORITY]
					,[PDH].[HAS_MASTERPACK]
					,[PDH].[POSTED_STATUS]
					,[PDH].[OWNER]
					,[PDH].[CLIENT_OWNER]
					,[PDH].[MASTER_ID_SELLER]
					,[PDH].[SELLER_OWNER]
					,[PDH].[SOURCE_TYPE]
					,[PDH].[INNER_SALE_STATUS]
					,[PDH].[INNER_SALE_RESPONSE]
					,[PDH].[DEMAND_TYPE]
					,[PDH].[TRANSFER_REQUEST_ID]
					,[PDH].[ADDRESS_CUSTOMER]
					,[PDH].[STATE_CODE]
					,[PDH].[DISCOUNT]
					,[PDH].[UPDATED_VEHICLE]
					,[PDH].[UPDATED_VEHICLE_RESPONSE]
					,[PDH].[UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR]
					,[PDH].[DELIVERY_NOTE_INVOICE]
					,[PDH].[DEMAND_SEQUENCE]
					,[PDH].[IS_CANCELED_FROM_SONDA_SD]
					,[PDH].[TYPE_DEMAND_CODE]
					,[PDH].[TYPE_DEMAND_NAME]
					,[PDH].[IS_FOR_DELIVERY_IMMEDIATE]
					,[PDH].[DEMAND_DELIVERY_DATE]
					,[PDH].[PROJECT]
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
				WHERE
					[PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

				SET @ID = SCOPE_IDENTITY();

        -- ------------------------------------------------------------------------------------
        -- Insertamos el detalle de la nueva orden
        -- ------------------------------------------------------------------------------------
				INSERT	INTO [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
						(
							[PICKING_DEMAND_HEADER_ID]
							,[MATERIAL_ID]
							,[QTY]
							,[LINE_NUM]
							,[ERP_OBJECT_TYPE]
							,[PRICE]
							,[WAS_IMPLODED]
							,[QTY_IMPLODED]
							,[MASTER_ID_MATERIAL]
							,[MATERIAL_OWNER]
							,[ATTEMPTED_WITH_ERROR]
							,[IS_POSTED_ERP]
							,[POSTED_ERP]
							,[ERP_REFERENCE]
							,[POSTED_STATUS]
							,[POSTED_RESPONSE]
							,[INNER_SALE_STATUS]
							,[INNER_SALE_RESPONSE]
							,[TONE]
							,[CALIBER]
							,[DISCOUNT]
							,[IS_BONUS]
							,[DISCOUNT_TYPE]
							,[UNIT_MEASUREMENT]
						)
				SELECT
					@ID
					,[PDD].[MATERIAL_ID]
					,[PDDT].[QTY]--[PDD].[QTY]
					,[PDD].[LINE_NUM]
					,[PDD].[ERP_OBJECT_TYPE]
					,[PDD].[PRICE]
					,[PDD].[WAS_IMPLODED]
					,[PDD].[QTY_IMPLODED]
					,[PDD].[MASTER_ID_MATERIAL]
					,[PDD].[MATERIAL_OWNER]
					,[PDD].[ATTEMPTED_WITH_ERROR]
					,[PDD].[IS_POSTED_ERP]
					,[PDD].[POSTED_ERP]
					,[PDD].[ERP_REFERENCE]
					,[PDD].[POSTED_STATUS]
					,[PDD].[POSTED_RESPONSE]
					,[PDD].[INNER_SALE_STATUS]
					,[PDD].[INNER_SALE_RESPONSE]
					,[PDD].[TONE]
					,[PDD].[CALIBER]
					,[PDD].[DISCOUNT]
					,[PDD].[IS_BONUS]
					,[PDD].[DISCOUNT_TYPE]
					,[PDD].[UNIT_MEASUREMENT]
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
				INNER JOIN @PICKING_DEMAND_DETAIL [PDDT] ON ([PDD].[MATERIAL_ID] = [PDDT].[MATERIAL_ID])
				WHERE
					[PDD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
					AND [PDDT].[QTY] <> [PDDT].[QTY_ORIGIN];

			END;

      -- ------------------------------------------------------------------------------------
      -- Eliminamos la demanda ya procesada
      -- ------------------------------------------------------------------------------------
			DELETE
				@PICKING_DEMAND_HEADER
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

      -- ------------------------------------------------------------------------------------
      -- Eliminamos las licencias que ya no tengan inventario
      -- ------------------------------------------------------------------------------------
			DELETE
				@LICENSE_PICKING_DEMAND
			WHERE
				[QTY] = 0;

		END;

		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							@LICENSE_PICKING_DEMAND )
		BEGIN
			UPDATE
				[IL]
			SET	
				[IL].[ENTERED_QTY] = [IL].[QTY]
				,[IL].[QTY] = [LO].[QTY]
				,[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @LOGIN
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			INNER JOIN @LICENSE_ORIGIN [LO] ON (
											[IL].[LICENSE_ID] = [LO].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [LO].[MATERIAL_ID]
											);
		END;
		ELSE
		BEGIN
			SELECT
				@ErrorCode = 4001;
			RAISERROR ('No se puedo rebajar todo el inventario.', 16, 1);
			RETURN;
		END;

		COMMIT;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('' AS VARCHAR) [DbData];

	END TRY
	BEGIN CATCH
		ROLLBACK;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@ErrorCode [Codigo];
	END CATCH;
END;