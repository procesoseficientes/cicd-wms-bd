-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		09-JuLio-19 @ GForce-Team Sprint Dublin
-- Description:			    INSERTA INVENTARIO PARA EL PROYECTO

-- Autor:					marvin.solares
-- Fecha de Creacion: 		24-JuLio-19 @ GForce-Team Sprint Dublin
-- Description:			    agrego el owner y owner name en cada fila del inventario asignado al proyecto

-- Modificacion:		marvin.solares
-- Fecha:				13-Agosto-2019 G-Force@FlorencioVarela
-- Bug 31375:			Al momento de despachar licencia que no estan en el proyecto se duplican
-- Descripcion:			al momento de asignar una licencia se suman cantidades si ya esta previamente asignada al proyecto
/*
-- Ejemplo de Ejecucion:
	EXECUTE [wms].[OP_WMS_SP_INSERT_INVENTORY_RESERVED_BY_XML] @LOGIN = 'MARVIN', @XML ='<ArrayOfInventoryReserved>
																		<Inventory>
																			<PROJECT_ID>5D9B419A-96D3-4EA1-A2F9-06CE6AB83EED</PROJECT_ID>
																			<PK_LINE>527696</PK_LINE>
																			<LICENSE_ID>571459</LICENSE_ID>
																			<MATERIAL_ID>viscosa/CANELA</MATERIAL_ID>
																			<MATERIAL_NAME>Canela en Rajas</MATERIAL_NAME>
																			<QTY_LICENSE>2</QTY_LICENSE>
																			<QTY_AVAILABLE>2</QTY_AVAILABLE>
																			<INVENTORY_RESERVED>1</INVENTORY_RESERVED>
																			<TONE></TONE>
																			<CALIBER></CALIBER>
																			<BATCH></BATCH>
																			<DATE_EXPIRATION></DATE_EXPIRATION>
																			<CLIENT_OWNER>viscosa</CLIENT_OWNER>
																			<STATUS_ID>18579</STATUS_ID>
																		</Inventory>
																	</ArrayOfInventoryReserved>'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_INVENTORY_RESERVED_BY_XML] (
		@LOGIN AS VARCHAR(25)
		,@XML AS XML
	)
AS
BEGIN TRY
	SET NOCOUNT ON;

	BEGIN TRAN;
	---------------------------------------------------------------------------------
	-- DECLARAMOS LAS VARIABLES A UTILIZAR
	---------------------------------------------------------------------------------
	DECLARE	@TEMP_INVENTORY_RESERVED AS TABLE (
			[PROJECT_ID] UNIQUEIDENTIFIER
			,[PK_LINE] NUMERIC(18, 0)
			,[LICENSE_ID] NUMERIC(18, 0)
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[QTY_LICENSE] NUMERIC(18, 4)
			,[QTY_AVAILABLE] NUMERIC(18, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[STATUS_CODE] VARCHAR(100)
		);

	DECLARE	@TEMP_INVENTORY_RESERVED_ARRAY AS TABLE (
			[PROJECT_ID] UNIQUEIDENTIFIER
			,[PK_LINE] NUMERIC(18, 0)
			,[LICENSE_ID] NUMERIC(18, 0)
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[QTY_LICENSE] NUMERIC(18, 4)
			,[QTY_AVAILABLE] NUMERIC(18, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[STATUS_CODE] VARCHAR(100)
		);

	DECLARE	@TEMP_INVENTORY_RESERVED_FOR_INSERT_LOG AS TABLE (
			[PROJECT_ID] UNIQUEIDENTIFIER
			,[PK_LINE] NUMERIC(18, 0)
			,[LICENSE_ID] NUMERIC(18, 0)
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[QTY_LICENSE] NUMERIC(18, 4)
			,[QTY_AVAILABLE] NUMERIC(18, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[STATUS_CODE] VARCHAR(100)
		);

	---------------------------------------------------------------------------------
	-- LEEMOS EL XML, INSERTAMOS LOS DATOS EN LA TABLA TEMPORAL
	---------------------------------------------------------------------------------
	INSERT	INTO @TEMP_INVENTORY_RESERVED
			(
				[PROJECT_ID]
				,[PK_LINE]
				,[LICENSE_ID]
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY_LICENSE]
				,[QTY_AVAILABLE]
				,[TONE]
				,[CALIBER]
				,[BATCH]
				,[DATE_EXPIRATION]
				,[STATUS_CODE]
			)
	SELECT
		[x].[data].[query]('./PROJECT_ID').[value]('.',
											'UNIQUEIDENTIFIER') [PROJECT_ID]
		,[x].[data].[query]('./PK_LINE').[value]('.',
											'NUMERIC(18,0)') [PK_LINE]
		,[x].[data].[query]('./LICENSE_ID').[value]('.',
											'NUMERIC(18,0)') [LICENSE_ID]
		,[x].[data].[query]('./MATERIAL_ID').[value]('.',
											'VARCHAR(50)') [MATERIAL_ID]
		,[x].[data].[query]('./MATERIAL_NAME').[value]('.',
											'VARCHAR(150)') [MATERIAL_NAME]
		,[x].[data].[query]('./QTY').[value]('.',
											'NUMERIC(18, 4)') [QTY_LICENSE]
		,[x].[data].[query]('./QTY_AVAILABLE').[value]('.',
											'NUMERIC(18, 4)') [QTY_AVAILABLE]
		,[x].[data].[query]('./TONE').[value]('.',
											'VARCHAR(20)') [TONE]
		,[x].[data].[query]('./CALIBER').[value]('.',
											'VARCHAR(20)') [CALIBER]
		,[x].[data].[query]('./BATCH').[value]('.',
											'VARCHAR(50)') [BATCH]
		,[x].[data].[query]('./DATE_EXPIRATION').[value]('.',
											'DATE') [DATE_EXPIRATION]
		,[x].[data].[query]('./STATUS_CODE').[value]('.',
											'varchar(100)') [STATUS_ID]
	FROM
		@XML.[nodes]('/ArrayOfInventarioReservadoProyecto/InventarioReservadoProyecto')
		AS [x] ([data]);
	
	INSERT	INTO @TEMP_INVENTORY_RESERVED_FOR_INSERT_LOG
			(
				[PROJECT_ID]
				,[PK_LINE]
				,[LICENSE_ID]
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY_LICENSE]
				,[QTY_AVAILABLE]
				,[TONE]
				,[CALIBER]
				,[BATCH]
				,[DATE_EXPIRATION]
				,[STATUS_CODE]
			)
	SELECT
		[PROJECT_ID]
		,[PK_LINE]
		,[LICENSE_ID]
		,[MATERIAL_ID]
		,[MATERIAL_NAME]
		,[QTY_LICENSE]
		,[QTY_AVAILABLE]
		,[TONE]
		,[CALIBER]
		,[BATCH]
		,[DATE_EXPIRATION]
		,[STATUS_CODE]
	FROM
		@TEMP_INVENTORY_RESERVED;
	
	-- ------------------------------------------------------------------------------------
	-- obtengo el project_id
	-- ------------------------------------------------------------------------------------
	DECLARE	@PROJECT_ID UNIQUEIDENTIFIER;
	SELECT TOP 1
		@PROJECT_ID = [PROJECT_ID]
	FROM
		@TEMP_INVENTORY_RESERVED;
	IF @PROJECT_ID IS NULL
	BEGIN
		RAISERROR (N'No selecciono licencias para asignar a proyecto.', 16, 1);
	END;
	---------------------------------------------------------------------------------
	-- INSERTAMOS LOS DATOS EN LA TABLA INVENTORY_RESERVED_BY_PROJECT
	---------------------------------------------------------------------------------
	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						@TEMP_INVENTORY_RESERVED )
	BEGIN 
		DECLARE	@PK_LINE [NUMERIC](18, 0);

		SELECT TOP 1
			@PK_LINE = [PK_LINE]
		FROM
			@TEMP_INVENTORY_RESERVED;
		-- ------------------------------------------------------------------------------------
		-- AGREGO LA FILA QUE QUIERO PROCESAR A LA TABLA TEMPORAL
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @TEMP_INVENTORY_RESERVED_ARRAY
				(
					[PROJECT_ID]
					,[PK_LINE]
					,[LICENSE_ID]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY_LICENSE]
					,[QTY_AVAILABLE]
					,[TONE]
					,[CALIBER]
					,[BATCH]
					,[DATE_EXPIRATION]
					,[STATUS_CODE]
				)
		SELECT
			[PROJECT_ID]
			,[PK_LINE]
			,[LICENSE_ID]
			,[MATERIAL_ID]
			,[MATERIAL_NAME]
			,[QTY_LICENSE]
			,[QTY_AVAILABLE]
			,[TONE]
			,[CALIBER]
			,[BATCH]
			,[DATE_EXPIRATION]
			,[STATUS_CODE]
		FROM
			@TEMP_INVENTORY_RESERVED
		WHERE
			[PK_LINE] = @PK_LINE;

		-- -------------------------------------------------------------------------------------
		-- si ya existe la licencia en el inventario asignado, sumo cantidades en caso contrario
		-- agrego la fila al inventario asignado
		-- -------------------------------------------------------------------------------------
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
						WHERE
							[PROJECT_ID] = @PROJECT_ID
							AND [PK_LINE] = @PK_LINE )
		BEGIN
			INSERT	INTO [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
					(
						[PROJECT_ID]
						,[PK_LINE]
						,[LICENSE_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY_LICENSE]
						,[QTY_RESERVED]
						,[QTY_DISPATCHED]
						,[RESERVED_PICKING]
						,[STATUS_CODE]
						,[TONE]
						,[CALIBER]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[CLIENT_CODE]
						,[CLIENT_NAME]
					)
			SELECT
				[PROJECT_ID]
				,[PK_LINE]
				,[L].[LICENSE_ID]
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY_LICENSE]
				,[QTY_AVAILABLE]
				,0
				,0
				,[STATUS_CODE]
				,[TONE]
				,[CALIBER]
				,[BATCH]
				,ISNULL([DATE_EXPIRATION], NULL)
				,[L].[CLIENT_OWNER]
				,[VC].[CLIENT_NAME]
			FROM
				@TEMP_INVENTORY_RESERVED_ARRAY [T]
			INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [T].[LICENSE_ID]
			LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC] ON [L].[CLIENT_OWNER] = [VC].[CLIENT_CODE];
		END;
		ELSE
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- actualizo cantidades
			-- ------------------------------------------------------------------------------------
			UPDATE
				[IAP]
			SET	
				[IAP].[QTY_RESERVED] = [IAP].[QTY_RESERVED]
				+ [IAR].[QTY_AVAILABLE]
			FROM
				[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IAP]
			INNER JOIN @TEMP_INVENTORY_RESERVED_ARRAY [IAR] ON [IAR].[PK_LINE] = [IAP].[PK_LINE];
		END;

		DELETE FROM
			@TEMP_INVENTORY_RESERVED_ARRAY;

		DELETE FROM
			@TEMP_INVENTORY_RESERVED
		WHERE
			[PK_LINE] = @PK_LINE;
	END;
	

		-- ------------------------------------------------------------------------------------
		-- actualizamos el estado del proyecto
		-- ------------------------------------------------------------------------------------
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					@TEMP_INVENTORY_RESERVED_FOR_INSERT_LOG )
	BEGIN
		UPDATE
			[wms].[OP_WMS_PROJECT]
		SET	
			[STATUS] = 'IN_PROCESS'
		WHERE
			[ID] = @PROJECT_ID;
	END;

	---------------------------------------------------------------------------------
	-- ACTUALIZAMOS EL CAMPO DE PROJECT_ID EN INV_X_LICENSE
	---------------------------------------------------------------------------------
	UPDATE
		[IXL]
	SET	
		[IXL].[PROJECT_ID] = [TIR].[PROJECT_ID]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IXL]
	INNER JOIN @TEMP_INVENTORY_RESERVED_FOR_INSERT_LOG [TIR] ON ([IXL].[PK_LINE] = [TIR].[PK_LINE]);

	---------------------------------------------------------------------------------
	-- INSERTAMOS LOG DE NUEVO REGISTRO EN LA TABLA DE LOG_INVENTORY_RESERVED_BY_PROJECT
	---------------------------------------------------------------------------------
	INSERT	INTO [wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
			(
				[TYPE_LOG]
				,[PROJECT_ID]
				,[PK_LINE]
				,[LICENSE_ID]
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY_LICENSE]
				,[QTY_RESERVED]
				,[QTY_DISPATCHED]
				,[PICKING_DEMAND_HEADER_ID]
				,[WAVE_PICKING_ID]
				,[CREATED_BY]
				,[CREATED_DATE]
			)
	SELECT
		'INSERT'
		, -- TYPE_LOG - varchar(20)
		[PROJECT_ID]
		, -- PROJECT_ID - uniqueidentifier
		[PK_LINE]
		, -- PK_LINE - numeric
		[LICENSE_ID]
		, -- LICENSE_ID - numeric
		[MATERIAL_ID]
		, -- MATERIAL_ID - varchar(50)
		[MATERIAL_NAME]
		, -- MATERIAL_NAME - varchar(150)
		[QTY_LICENSE]
		, -- QTY_LICENSE - numeric
		[QTY_AVAILABLE]
		, -- QTY_RESERVED - numeric
		0
		, -- QTY_DISPATCHED - numeric
		0
		, -- PICKING_DEMAND_HEADER_ID - int
		0
		, -- WAVE_PICKING_ID - numeric
		@LOGIN
		, -- CREATED_BY - varchar(64)
		GETDATE()  -- CREATED_DATE - datetime
	FROM
		@TEMP_INVENTORY_RESERVED_FOR_INSERT_LOG;

		-- ------------------------------------------------------------------------------------
		-- finalizamos la transaccion
		-- ------------------------------------------------------------------------------------
	COMMIT;
	---------------------------------------------------------------------------------
	-- DEUELVE CODIGO DE OPERACION SATISFACTORIO.
	---------------------------------------------------------------------------------
	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo];

END	TRY
BEGIN CATCH
	ROLLBACK;
	SELECT
		-1 AS [Resultado]
		,ERROR_MESSAGE() [Mensaje]
		,@@ERROR [Codigo];
END CATCH;