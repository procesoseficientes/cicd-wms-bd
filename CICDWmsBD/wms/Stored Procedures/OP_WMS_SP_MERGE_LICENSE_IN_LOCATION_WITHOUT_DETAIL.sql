-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/10/2018 @ GForce-Team Sprint Capibara
-- Description:			Unifica las licencias y no devuelve detalle, solo un objeto operación

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_MERGE_LICENSE_IN_LOCATION_WITHOUT_DETAIL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MERGE_LICENSE_IN_LOCATION_WITHOUT_DETAIL] (
		@LOCATION VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50) = NULL
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN	
	SET NOCOUNT ON;
	--

	DECLARE
		@LICENSE_CORRELATIVE INT
		,@CODIGO_POLIZA VARCHAR(50)
		,@LICENSE_ID INT
		,@RESULTADO VARCHAR(250)
		,@ACUERDO_COMERCIAL VARCHAR(50)
		,@CLIENT_CODE VARCHAR(50)
		,@FECHA DATETIME = GETDATE()
		,@STATUS_ID INT
		,@COUNT_ACTUAL_LICENSE INT = 0
		,@COUNT_NEW_LICENSE INT = 0
		,@CLIENT_OWNER VARCHAR(50) = ''
		,@HEADER_ID INT = 0
		,@CORRELATIVE_ID INT = 1
		,@ORDER INT = 1
		,@NEW_LICENSES VARCHAR(MAX)
		,@CODE INT = 0
		,@ERROR_MESSAGE VARCHAR(150)
		,@IS_WASTE_LOCATION INT = 0;

	DECLARE	@OPERACION TABLE (
			[RESULTADO] INT
			,[MENSAJE] VARCHAR(250)
			,[CODIGO] INT
			,[DB_DATA] VARCHAR(50)
		);

	CREATE TABLE [#NEW_LICENCES_DETAIL] (
		[MATERIAL_ID] VARCHAR(50) NOT NULL
		,[MATERIAL_NAME] VARCHAR(200) NULL
		,[BATCH] VARCHAR(50) NULL
		,[DATE_EXPIRATION] DATE NULL
		,[BARCODE_ID] VARCHAR(200) NULL
		,[QTY] NUMERIC(18, 4) NULL
		,[LICENSE_ID] INT NULL
		,[TONE] VARCHAR(20) NULL
		,[CALIBER] VARCHAR(20) NULL
		,[TONE_AND_CALIBER_ID] INT NULL
		,[CLIENT_OWNER] VARCHAR(25) NULL
		,[HANDLE_SERIAL] INT NULL
		,[USED] INT NULL
		,[PICKING_DEMAND_HEADER_ID] INT NULL
		,[DOC_NUM] INT NULL
	);
	
	-- ------------------------------------------------------------------------------------
	-- Verifica si la ubicacion es de merma
	-- ------------------------------------------------------------------------------------
	SELECT
		@IS_WASTE_LOCATION = [IS_WASTE]
	FROM
		[wms].[OP_WMS_SHELF_SPOTS]
	WHERE
		[LOCATION_SPOT] = @LOCATION;

	-- ------------------------------------------------------------------------------------
	-- Se obtiene todos los materiales que se reubicaran. 
	-- ------------------------------------------------------------------------------------				
	-- ------------------------------------------------------------------------------------
	-- Obtener licencias a rebajar 
	-- ------------------------------------------------------------------------------------
	SELECT
		[IL].[PK_LINE]
		,[IL].[LICENSE_ID]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[QTY]
		,[IL].[VOLUME_FACTOR]
		,[IL].[WEIGTH]
		,[IL].[SERIAL_NUMBER]
		,[IL].[COMMENTS]
		,[IL].[LAST_UPDATED]
		,[IL].[LAST_UPDATED_BY]
		,[IL].[BARCODE_ID]
		,[IL].[TERMS_OF_TRADE]
		,[IL].[STATUS]
		,[IL].[CREATED_DATE]
		,CASE	WHEN @IS_WASTE_LOCATION = 0
				THEN [IL].[DATE_EXPIRATION]
				ELSE NULL
			END [DATE_EXPIRATION]
		,CASE	WHEN @IS_WASTE_LOCATION = 0
				THEN [IL].[BATCH]
				ELSE NULL
			END [BATCH]
		,[IL].[ENTERED_QTY]
		,[IL].[VIN]
		,[IL].[HANDLE_SERIAL]
		,[IL].[IS_EXTERNAL_INVENTORY]
		,[IL].[IS_BLOCKED]
		,[IL].[BLOCKED_STATUS]
		,[IL].[STATUS_ID]
		,CASE	WHEN @IS_WASTE_LOCATION = 0
				THEN [IL].[TONE_AND_CALIBER_ID]
				ELSE NULL
			END [TONE_AND_CALIBER_ID]
		,[IL].[LOCKED_BY_INTERFACES]
		,[L].[CURRENT_WAREHOUSE]
		,[L].[CURRENT_LOCATION]
		,CASE	WHEN [L].[PICKING_DEMAND_HEADER_ID] IS NULL
				THEN ISNULL([C].[COMMITED_QTY], 0)
				ELSE 0
			END [NEW_QTY]
		,CASE	WHEN [L].[PICKING_DEMAND_HEADER_ID] IS NULL
				THEN [C].[COMMITED_QTY]
				ELSE 0
			END [COMMITED_QTY]
		,CASE	WHEN @IS_WASTE_LOCATION = 0 THEN [TC].[TONE]
				ELSE NULL
			END [TONE]
		,CASE	WHEN @IS_WASTE_LOCATION = 0
				THEN [TC].[CALIBER]
				ELSE NULL
			END [CALIBER]
		,[L].[CLIENT_OWNER]
		,CASE	WHEN @IS_WASTE_LOCATION = 0
				THEN RANK() OVER (PARTITION BY [L].[PICKING_DEMAND_HEADER_ID],
									[IL].[MATERIAL_ID] ORDER BY [IL].[BATCH], [IL].[DATE_EXPIRATION], [TC].[TONE], [TC].[CALIBER] DESC)
				ELSE 1
			END AS [CORRELATIVE_LICENSE_ID]
		,[L].[PICKING_DEMAND_HEADER_ID]
	INTO
		[#OLD_LICENSE]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON [S].[STATUS_ID] = [IL].[STATUS_ID]
	LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [C] ON [C].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [C].[LICENCE_ID] = [IL].[LICENSE_ID]
	LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
	WHERE
		[L].[CURRENT_LOCATION] = @LOCATION
		AND [IL].[QTY] > 0
		AND [IL].[IS_BLOCKED] = 0
		AND (
				[IL].[LOCKED_BY_INTERFACES] = 0
				OR [L].[PICKING_DEMAND_HEADER_ID] IS NOT NULL
			)
		AND [S].[BLOCKS_INVENTORY] = 0
		AND (
				@MATERIAL_ID IS NULL
				OR [IL].[MATERIAL_ID] = @MATERIAL_ID
			)
		AND (
				[IL].[HANDLE_SERIAL] = 0
				OR [C].[MATERIAL_ID] IS NULL
			);


	-- ------------------------------------------------------------------------------------
	-- Obtiene las nuevas licencias dividas
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[CLIENT_OWNER]
		,[PICKING_DEMAND_HEADER_ID]
		,[CORRELATIVE_LICENSE_ID]
	INTO
		[#POSSIBLE_LICENSES]
	FROM
		[#OLD_LICENSE];

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#POSSIBLE_LICENSES] )
	BEGIN
		SELECT TOP 1
			@CLIENT_OWNER = [CLIENT_OWNER]
			,@HEADER_ID = ISNULL([PICKING_DEMAND_HEADER_ID],
									0)
			,@ORDER = [CORRELATIVE_LICENSE_ID]
		FROM
			[#POSSIBLE_LICENSES];
		--
		INSERT	INTO [#NEW_LICENCES_DETAIL]
		SELECT
			[IL].[MATERIAL_ID]
			,MAX([M].[MATERIAL_NAME]) AS [MATERIAL_NAME]
			,[IL].[BATCH]
			,[IL].[DATE_EXPIRATION]
			,MAX([M].[BARCODE_ID]) AS [BARCODE_ID]
			,SUM([IL].[QTY])
			- SUM(ISNULL([IL].[COMMITED_QTY], 0)) [QTY]
			,@CORRELATIVE_ID AS [LICENSE_ID]
			,[IL].[TONE]
			,[IL].[CALIBER]
			,MAX([IL].[TONE_AND_CALIBER_ID]) [TONE_AND_CALIBER_ID]
			,[IL].[CLIENT_OWNER]
			,MAX([IL].[HANDLE_SERIAL]) [HANDLE_SERIAL]
			,0 AS [USED]
			,[IL].[PICKING_DEMAND_HEADER_ID]
			,[PDH].[DOC_NUM]
		FROM
			[#OLD_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [IL].[MATERIAL_ID])
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[PICKING_DEMAND_HEADER_ID] = [IL].[PICKING_DEMAND_HEADER_ID]
		WHERE
			[IL].[CLIENT_OWNER] = @CLIENT_OWNER
			AND ISNULL([IL].[PICKING_DEMAND_HEADER_ID], 0) = @HEADER_ID
			AND [IL].[CORRELATIVE_LICENSE_ID] = @ORDER
		GROUP BY
			[IL].[CLIENT_OWNER]
			,[IL].[MATERIAL_ID]
			--,[IL].[MATERIAL_NAME]
			,[IL].[BATCH]
			,[IL].[DATE_EXPIRATION]
			,[IL].[TONE]
			,[IL].[CALIBER]
			--,[IL].[BARCODE_ID]
			,[IL].[CORRELATIVE_LICENSE_ID]
			,[IL].[PICKING_DEMAND_HEADER_ID]
			,[PDH].[DOC_NUM]
		HAVING
			SUM([IL].[QTY]) - SUM(ISNULL([IL].[COMMITED_QTY],
											0)) > 0;
		--
		SELECT
			@CORRELATIVE_ID = @CORRELATIVE_ID + 1;
		--
		DELETE FROM
			[#POSSIBLE_LICENSES]
		WHERE
			[CLIENT_OWNER] = @CLIENT_OWNER
			AND ISNULL([PICKING_DEMAND_HEADER_ID], 0) = @HEADER_ID
			AND [CORRELATIVE_LICENSE_ID] = @ORDER;
	END;

	SELECT
		@COUNT_ACTUAL_LICENSE = COUNT([LICENSE_ID])
	FROM
		[#OLD_LICENSE];
	PRINT 'Licencias actuales '
		+ CAST(@COUNT_ACTUAL_LICENSE AS VARCHAR);


	SELECT
		@COUNT_NEW_LICENSE = COUNT([LICENSE_ID])
	FROM
		(SELECT DISTINCT
				[LICENSE_ID] [LICENSE_ID]
			FROM
				[#NEW_LICENCES_DETAIL]) [LD];
	PRINT 'Licencias nuevas '
		+ CAST(@COUNT_NEW_LICENSE AS VARCHAR);



	BEGIN TRY
		BEGIN TRAN;

		IF @COUNT_ACTUAL_LICENSE <= @COUNT_NEW_LICENSE
		BEGIN
			SET @CODE = 1601;
			RAISERROR ('No hay licencias pendientes de unificar', 16, 1);
			RETURN;
		END;

		PRINT 'inicia proceso';

		-- ------------------------------------------------------------------------------------
		-- Se obtiene el estado default 
		-- ------------------------------------------------------------------------------------
		EXEC [wms].[OP_WMS_SP_CREATE_MATERIAL_STATUS] 'ESTADO_DEFAULT',
			@STATUS_ID OUT, @DEFAULT = 1;
		PRINT 'Obtiene Estado';
		-- ------------------------------------------------------------------------------------
		-- Se recorre nueva lista para creación de licencias.
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#NEW_LICENCES_DETAIL]
						WHERE
							[USED] = 0 )
		BEGIN
			SELECT
				@LICENSE_CORRELATIVE = [LICENSE_ID]
				,@CLIENT_CODE = [CLIENT_OWNER]
				,@HEADER_ID = [PICKING_DEMAND_HEADER_ID]
			FROM
				[#NEW_LICENCES_DETAIL]
			WHERE
				[USED] = 0;

			PRINT 'INICIA CORRELATIVO  '
				+ CAST(@LICENSE_CORRELATIVE AS VARCHAR);

			SELECT TOP 1
				@ACUERDO_COMERCIAL = [AC].[ACUERDO_COMERCIAL]
			FROM
				[wms].[OP_WMS_ACUERDOS_X_CLIENTE] [AC]
			LEFT JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [T] ON [T].[ACUERDO_COMERCIAL_ID] = [AC].[ACUERDO_COMERCIAL]
			WHERE
				[AC].[CLIENT_ID] = @CLIENT_CODE
			ORDER BY
				[T].[DEFAULT] DESC;

			PRINT 'Antes poliza  ';

			IF ISNULL(@ACUERDO_COMERCIAL, 0) = 0
			BEGIN
				SET @CODE = 1602;
				SET @ERROR_MESSAGE = CONCAT('No hay acuerdos comerciales configurados para el cliente = ',
											@CLIENT_CODE);
				RAISERROR (@ERROR_MESSAGE, 16, 1);
				RETURN;
			END;

			-- ------------------------------------------------------------------------------------
			-- Inserta la poliza
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @OPERACION
					(
						[RESULTADO]
						,[MENSAJE]
						,[CODIGO]
						,[DB_DATA]
					)
					EXEC [wms].[OP_WMS_SP_INSERT_POLIZA_HEADER] @DOC_ID = 0, -- int
						@FECHA_LLEGADA = @FECHA, -- datetime
						@LAST_UPDATED_BY = @LOGIN, -- varchar(25)
						@LAST_UPDATED = @FECHA, -- datetime
						@CLIENT_CODE = @CLIENT_CODE, -- varchar(25)
						@FECHA_DOCUMENTO = @FECHA, -- datetime
						@TIPO = 'INGRESO', -- varchar(25)
						@CODIGO_POLIZA = '0', -- varchar(25)
						@ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL, -- varchar(50)
						@STATUS = 'CREATED'; -- varchar(15)




			-- ------------------------------------------------------------------------------------
			-- Obtiene el codigo de poliza
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@CODIGO_POLIZA = [DB_DATA]
			FROM
				@OPERACION;

			--
			DELETE
				@OPERACION;

			PRINT 'Crea Poliza '
				+ CAST(@CODIGO_POLIZA AS VARCHAR);
			-- ------------------------------------------------------------------------------------
			-- Inserta la licencia
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @OPERACION
					(
						[RESULTADO]
						,[MENSAJE]
						,[CODIGO]
						,[DB_DATA]
					)
					EXEC [wms].[OP_WMS_SP_CREA_LICENCIA] @pCODIGO_POLIZA = @CODIGO_POLIZA, -- varchar(25)
						@pLOGIN = @LOGIN, -- varchar(25)
						@pLICENCIA_ID = @LICENSE_ID OUT, -- numeric
						@pCLIENT_OWNER = @CLIENT_CODE, -- varchar(25)
						@pREGIMEN = 'GENERAL', -- varchar(50)
						@pResult = @RESULTADO OUT,
						@LOCATION = @LOCATION;-- varchar(250)

			DELETE
				@OPERACION;
			PRINT 'Crea Licencia '
				+ CAST(@LICENSE_ID AS VARCHAR)
				+ ' - Orden de preparado: '
				+ CAST(ISNULL(@HEADER_ID, '') AS VARCHAR);


			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[PICKING_DEMAND_HEADER_ID] = @HEADER_ID
			WHERE
				[LICENSE_ID] = @LICENSE_ID;
			-- ------------------------------------------------------------------------------------
			-- Insertar nuevo inventario en licencia.
			-- ------------------------------------------------------------------------------------
			INSERT	INTO [wms].[OP_WMS_INV_X_LICENSE]
					(
						[LICENSE_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY]
						,[LAST_UPDATED]
						,[LAST_UPDATED_BY]
						,[BARCODE_ID]
						,[TERMS_OF_TRADE]
						,[STATUS]
						,[CREATED_DATE]
						,[DATE_EXPIRATION]
						,[BATCH]
						,[ENTERED_QTY]
						,[HANDLE_SERIAL]
						,[IS_EXTERNAL_INVENTORY]
						,[IS_BLOCKED]
						,[STATUS_ID]
						,[TONE_AND_CALIBER_ID]
						,[LOCKED_BY_INTERFACES]
						,[COMMENTS]
					)
			SELECT
				@LICENSE_ID
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY]
				,@FECHA
				,@LOGIN
				,[BARCODE_ID]
				,@ACUERDO_COMERCIAL
				,'PROCESSED'
				,@FECHA
				,[DATE_EXPIRATION]
				,[BATCH]
				,[QTY]
				,[HANDLE_SERIAL]
				,0
				,0
				,@STATUS_ID
				,[TONE_AND_CALIBER_ID]
				,CASE	WHEN [PICKING_DEMAND_HEADER_ID] IS NULL
						THEN 0
						ELSE 1
					END
				,'Unificacion de licencias ubicación '
				+ @LOCATION
			FROM
				[#NEW_LICENCES_DETAIL]
			WHERE
				[LICENSE_ID] = @LICENSE_CORRELATIVE
				AND [USED] = 0;

			-- ------------------------------------------------------------------------------------
			-- Realizar transacción
			-- ------------------------------------------------------------------------------------
			INSERT	INTO [wms].[OP_WMS_TRANS]
					(
						[TERMS_OF_TRADE]
						,[TRANS_DATE]
						,[LOGIN_ID]
						,[LOGIN_NAME]
						,[TRANS_TYPE]
						,[TRANS_DESCRIPTION]
						,[TRANS_EXTRA_COMMENTS]
						,[MATERIAL_BARCODE]
						,[MATERIAL_CODE]
						,[MATERIAL_DESCRIPTION]
						,[MATERIAL_COST]
						,[SOURCE_LICENSE]
						,[TARGET_LICENSE]
						,[SOURCE_LOCATION]
						,[TARGET_LOCATION]
						,[CLIENT_OWNER]
						,[CLIENT_NAME]
						,[QUANTITY_UNITS]
						,[SOURCE_WAREHOUSE]
						,[TARGET_WAREHOUSE]
						,[TRANS_SUBTYPE]
						,[CODIGO_POLIZA]
						,[LICENSE_ID]
						,[STATUS]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[ORIGINAL_LICENSE]
					)
			SELECT
				@ACUERDO_COMERCIAL
				,CURRENT_TIMESTAMP
				,@LOGIN
				,@LOGIN
				,'REUBICACION_PARCIAL'
				,'RE-UBICACION PARCIAL'
				,'REUBICACION'
				,[IL].[BARCODE_ID]
				,[IL].[MATERIAL_ID]
				,[IL].[MATERIAL_NAME]
				,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL]([IL].[MATERIAL_ID],
											[IL].[CLIENT_OWNER])
				,[IL].[LICENSE_ID]
				,@LICENSE_ID
				,@LOCATION
				,@LOCATION
				,@CLIENT_CODE
				,@CLIENT_CODE
				,[IL].[QTY] - ISNULL([IL].[COMMITED_QTY], 0)
				,[IL].[CURRENT_WAREHOUSE]
				,[IL].[CURRENT_WAREHOUSE]
				,'REUBICACION'
				,@CODIGO_POLIZA
				,@LICENSE_ID
				,'PROCESSED'
				,[IL].[BATCH]
				,[IL].[DATE_EXPIRATION]
				,[IL].[LICENSE_ID]
			FROM
				[#OLD_LICENSE] [IL]
			WHERE
				[IL].[CORRELATIVE_LICENSE_ID] = @LICENSE_CORRELATIVE;



			-- ------------------------------------------------------------------------------------
			-- Se mueve las series de la licencia a la nueva 
			-- ------------------------------------------------------------------------------------
			UPDATE
				[MS]
			SET	
				[MS].[LICENSE_ID] = @LICENSE_ID
			FROM
				[#OLD_LICENSE] [IL]
			INNER JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS] ON [MS].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [MS].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [MS].[STATUS] > 0
			WHERE
				[IL].[CORRELATIVE_LICENSE_ID] = @LICENSE_CORRELATIVE;

			-- ------------------------------------------------------------------------------------
			-- Se rebajan 
			-- ------------------------------------------------------------------------------------
			UPDATE
				[IL]
			SET	
				[IL].[QTY] = [NEW_QTY]
			FROM
				[#OLD_LICENSE] [L]
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[PK_LINE] = [L].[PK_LINE]
			WHERE
				[L].[CORRELATIVE_LICENSE_ID] = @LICENSE_CORRELATIVE;




			-- ------------------------------------------------------------------------------------
			-- Se elimina las materiales ya unificados
			-- ------------------------------------------------------------------------------------
			UPDATE
				[#NEW_LICENCES_DETAIL]
			SET	
				[USED] = 1
				,[LICENSE_ID] = @LICENSE_ID
			WHERE
				[LICENSE_ID] = @LICENSE_CORRELATIVE;

			DELETE
				[#OLD_LICENSE]
			WHERE
				[CORRELATIVE_LICENSE_ID] = @LICENSE_CORRELATIVE;

			PRINT 'TERMINO NUEVA LICENCIA '
				+ CAST(@LICENSE_ID AS VARCHAR);
			PRINT 'TERMINA CORRELATIVO  '
				+ CAST(@LICENSE_CORRELATIVE AS VARCHAR);

		END;


		--

		SELECT
			@NEW_LICENSES = CASE	WHEN @NEW_LICENSES IS NULL
									THEN CAST([LICENSE_ID] AS VARCHAR)
											+ '-'
											+ [CLIENT_OWNER]
									ELSE @NEW_LICENSES + '|'
											+ CAST([LICENSE_ID] AS VARCHAR)
											+ '-'
											+ [CLIENT_OWNER]
							END
		FROM
			[#NEW_LICENCES_DETAIL]
		GROUP BY
			[LICENSE_ID]
			,[CLIENT_OWNER];

		COMMIT;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,@NEW_LICENSES [DbData];

	END TRY
	BEGIN CATCH
		ROLLBACK;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,IIF(@CODE != 0, @CODE, @@ERROR) [Codigo]
			,'' [DbData];
	END CATCH;
END;