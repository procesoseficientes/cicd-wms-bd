-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		09-JuLio-19 @ GForce-Team Sprint Dublin
-- Description:			    ELIMINA INVENTARIO DEL PROYECTO

-- Modificacion:			henry.rodriguez
-- Fecha:					06-Agosto-2019 G-Force@Estambul
-- Descripcion:				Se agrega validacion para que permita eliminar el inventario que no tenga reservado para picking o ya despachado.
/*
-- Ejemplo de Ejecucion:
	EXECUTE [wms].[OP_WMS_SP_DELETE_INVENTORY_RESERVED_BY_XML] @LOGIN = 'MARVIN', @PROJECT_ID = '5D9B419A-96D3-4EA1-A2F9-06CE6AB83EED', 
	@XML = '<ArrayOfInventoryReserved>
				<Inventory>
					<ID>1</ID>
					<PK_LINE>527696</PK_LINE>
				</Inventory>
			</ArrayOfInventoryReserved>'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_INVENTORY_RESERVED_BY_XML] (
		@LOGIN AS VARCHAR(25)
		,@PROJECT_ID UNIQUEIDENTIFIER
		,@XML AS XML
	)
AS
BEGIN TRY
	SET NOCOUNT ON;

	---------------------------------------------------------------------------------
	-- DECLARAMOS VARIABLES
	---------------------------------------------------------------------------------
	DECLARE	@TEMP_DELETE_INVENTORY_RESERVED AS TABLE (
			[ID] INTEGER
			,[PK_LINE] INTEGER
		);

	DECLARE	@TEMP_INVENTORY_RESERVED AS TABLE (
			[PROJECT_ID] UNIQUEIDENTIFIER
			,[PK_LINE] NUMERIC(18, 0)
			,[LICENSE_ID] NUMERIC(18, 0)
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[QTY_LICENSE] NUMERIC(18, 4)
			,[INVENTORY_RESERVED] NUMERIC(18, 4)
			,[QTY_DISPATCHED] NUMERIC(18, 4)
		);

	---------------------------------------------------------------------------------
	-- LEEMOS EL XML, INSERTAMOS LOS DATOS EN LA TABLA TEMPORAL
	---------------------------------------------------------------------------------
	INSERT	INTO @TEMP_DELETE_INVENTORY_RESERVED
			(
				[ID]
				,[PK_LINE]
			)
	SELECT
		[x].[data].[query]('./ID').[value]('.', 'INTEGER') [ID]
		,[x].[data].[query]('./PK_LINE').[value]('.',
											'INTEGER') [PK_LINE]
	FROM
		@XML.[nodes]('/ArrayOfInventarioReservadoProyecto/InventarioReservadoProyecto')
		AS [x] ([data])
	INNER JOIN [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP] ON (
											[x].[data].[query]('./ID').[value]('.',
											'INTEGER') = [IRP].[ID]
											AND [x].[data].[query]('./PK_LINE').[value]('.',
											'INTEGER') = [IRP].[PK_LINE]
											)
	LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [FNCIL] ON (
											[IRP].[LICENSE_ID] = [FNCIL].[LICENCE_ID]
											AND [IRP].[MATERIAL_ID] = [FNCIL].[MATERIAL_ID]
											)
	WHERE
		(
			[FNCIL].[COMMITED_QTY] <= 0
			OR [FNCIL].[COMMITED_QTY] IS NULL
		)
		AND (
				[IRP].[QTY_DISPATCHED] <= 0
				OR [IRP].[QTY_DISPATCHED] IS NULL
			);

	---------------------------------------------------------------------------------
	-- LEEMOS EL XML, INSERTAMOS LOS DATOS EN LA TABLA TEMPORAL PARA LUEGO INSERTAR LOG CON LOS DATOS
	---------------------------------------------------------------------------------
	INSERT	INTO @TEMP_INVENTORY_RESERVED
			(
				[PROJECT_ID]
				,[PK_LINE]
				,[LICENSE_ID]
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY_LICENSE]
				,[INVENTORY_RESERVED]
				,[QTY_DISPATCHED]
			)
	SELECT
		[IRP].[PROJECT_ID]
		,[IRP].[PK_LINE]
		,[IRP].[LICENSE_ID]
		,[IRP].[MATERIAL_ID]
		,[IRP].[MATERIAL_NAME]
		,[IRP].[QTY_LICENSE]
		,[IRP].[QTY_RESERVED]
		,[IRP].[QTY_DISPATCHED]
	FROM
		[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
	INNER JOIN @TEMP_DELETE_INVENTORY_RESERVED [TDIR] ON (
											[IRP].[ID] = [TDIR].[ID]
											AND [IRP].[PK_LINE] = [TDIR].[PK_LINE]
											);
		
	---------------------------------------------------------------------------------
	-- ELIMINAMOS EL INVENTARIO ASOCIADO AL PROYECTO
	---------------------------------------------------------------------------------
	DELETE
		[IRBP]
	FROM
		[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRBP]
	INNER JOIN @TEMP_DELETE_INVENTORY_RESERVED [TIR] ON (
											[IRBP].[ID] = [TIR].[ID]
											AND [IRBP].[PK_LINE] = [TIR].[PK_LINE]
											)
	WHERE
		[IRBP].[PROJECT_ID] = @PROJECT_ID;

	---------------------------------------------------------------------------------
	-- ACTUALIZAMOS EL CAMPO PROJECT_ID EN INV_X_LICENSE
	---------------------------------------------------------------------------------
	UPDATE
		[IXL]
	SET	
		[IXL].[PROJECT_ID] = NULL
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IXL]
	INNER JOIN @TEMP_DELETE_INVENTORY_RESERVED [DIR] ON ([IXL].[PK_LINE] = [DIR].[PK_LINE]);

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
		'DELETE'
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
		[INVENTORY_RESERVED]
		, -- QTY_RESERVED - numeric
		[QTY_DISPATCHED]
		, -- QTY_DISPATCHED - numeric
		0
		, -- PICKING_DEMAND_HEADER_ID - int
		0
		, -- WAVE_PICKING_ID - numeric
		@LOGIN
		, -- CREATED_BY - varchar(64)
		GETDATE()  -- CREATED_DATE - datetime
	FROM
		@TEMP_INVENTORY_RESERVED;

	-- ------------------------------------------------------------------------------------
	-- si ya no quedaron licencias asignadas a proyecto regresamos el status a CREADO
	-- ------------------------------------------------------------------------------------
	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
					WHERE
						[PROJECT_ID] = @PROJECT_ID )
	BEGIN
		UPDATE
			[wms].[OP_WMS_PROJECT]
		SET	
			[STATUS] = 'CREATED'
		WHERE
			[ID] = @PROJECT_ID;
	END;
	---------------------------------------------------------------------------------
	-- DEVUELVE CODIGO DE OPERACION SATISFACTORIO.
	---------------------------------------------------------------------------------
	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo];

END TRY
BEGIN CATCH
	SELECT
		-1 AS [Resultado]
		,ERROR_MESSAGE() [Mensaje]
		,@@ERROR [Codigo];
END CATCH;