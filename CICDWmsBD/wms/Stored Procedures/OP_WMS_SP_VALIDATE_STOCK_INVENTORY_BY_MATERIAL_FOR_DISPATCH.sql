-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/12/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Valida el inventario de la demanda despacho.

-- Modificacion 8/14/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se agrego como cliente el OWNER del producto.

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega validacion extra en @MP_COMPONENT para que no se dupliquen los datos.

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-13 @ Team REBORN - Sprint Collin
-- Description:	   Se agrego @HANDLE_TONE_OR_CALIBER para que no traiga inventario los materiales que manejen tono o calibre

-- Modificacion 11-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- pablo.aguilar 
-- Se quita validación de masterpack en linea de picking 

-- Modificacion 26-Nov-18 @ G-Force Team Sprint ornitorinco
-- rudi.garcia
-- Historia: Product Backlog Item 25517: Demanda de despacho con estados por linea
-- Se agrego la condicion de estado del matarial

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyectos

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			Se agrega parametro de tolerancia minima de fecha de expiracion para validar inventario cuando es consolidado

-- Autor:				fabrizio.delcompare
-- Fecha de Creacion: 	23-Jul-2029
-- Description:			Cambio completo del query, ahora automaticamente trae disponibilidad recursiva basada en masterpack

-- Autor:				Elder Lucas
-- Fecha de Creacion: 	30 de julio 2022
-- Description:			Se agrega condición para decidir si se calculará el potencial de armado de del material en caso de que no hayan masterpacks ya armados

-- Autor:				Elder Lucas
-- Fecha de Creacion: 	30 de agosto 2022
-- Description:			Cambio en condición de calculo de potencial de armado para no dejar en 0 la cantidad cuando el parametro está apagado

-- Autor:				Elder Lucas
-- Fecha de Creacion: 	21 de septiembre 2022
-- Description:			Se revierten los cambios anteriores por mal funcionamiento imprevisto
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIAL_FOR_DISPATCH]
					@XML = N'
<ArrayOfOrdenDeVentaDetalle>
  <OrdenDeVentaDetalle>
    <SKU>wms/SKUPRUEBA</SKU>
    <DESCRIPTION_SKU>Prueba</DESCRIPTION_SKU>
    <QTY>3000</QTY>
    <EXTERNAL_SOURCE_ID>1</EXTERNAL_SOURCE_ID>
    <IS_MASTER_PACK>1</IS_MASTER_PACK>
    <MATERIAL_OWNER>wms</MATERIAL_OWNER>
  </OrdenDeVentaDetalle>
  <OrdenDeVentaDetalle>   
    <SKU>wms/RD001</SKU>
    <DESCRIPTION_SKU>Radiadores</DESCRIPTION_SKU>
    <QTY>9500</QTY>
    <EXTERNAL_SOURCE_ID>1</EXTERNAL_SOURCE_ID>
	<IS_MASTER_PACK>1</IS_MASTER_PACK>
    <MATERIAL_OWNER>wms</MATERIAL_OWNER>
  </OrdenDeVentaDetalle>
  <OrdenDeVentaDetalle>
    <SKU>wms/C00000123</SKU>
    <DESCRIPTION_SKU>ROSAL VERDE PEQUEO 1UNX24UN  CAJA</DESCRIPTION_SKU>
    <QTY>3.00</QTY>
    <EXTERNAL_SOURCE_ID>1</EXTERNAL_SOURCE_ID>
	<IS_MASTER_PACK>0</IS_MASTER_PACK>
    <MATERIAL_OWNER>wms</MATERIAL_OWNER>
  </OrdenDeVentaDetalle>
</ArrayOfOrdenDeVentaDetalle>'
					,@CODE_WAREHOUSE = 'BODEGA_01' 

					SELECT * FROM [wms].[OP_WMS_MATERIALS] WHERE [MATERIAL_ID] = 'wms/C00000123'
					
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIAL_FOR_DISPATCH] (
		@XML XML
		,@CODE_WAREHOUSE VARCHAR(50)
		,@HANDLE_TONE_OR_CALIBER INT = 0
		,@IN_PICKING_LINE INT = 0
		,@PROJECT_ID UNIQUEIDENTIFIER = NULL
		,@MIN_DAYS_EXPIRATION_DATE INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@MATERIAL_ID VARCHAR(50)
		,@QUANTITY_ASSIGNED INT
		,@CLIENT_OWNER VARCHAR(25)
		,@IS_MASTER_PACK INT
		,@CURRENTLY_AVAILABLE INT
		,@NEEDED_FOR_ASSEMBLY INT
		,@ASSEMBLY_QUANTITY INT
		,@MATERIAL_NAME VARCHAR(200)
		,@SOURCE_NAME VARCHAR(25)
		,@STATUS_CODE VARCHAR(50)
		,@DISPATCH_BY_STATUS INT = 0
		,@STATUS_CODE_DEFAULT VARCHAR(50)
		,@QTY_AVAILABLE_FROM_LICENSE_PROYECT NUMERIC(18, 4) = 0;
  --


	DECLARE	@RESULT_DETAIL TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(200)
			,[CLIENT_OWNER] VARCHAR(25)
			,[QTY] INT
			,[AVAILABLE] INT
			,[QTY_NEEDED] INT
			,[IS_MASTER_PACK] INT
			,[MASTER_PACK_ID] VARCHAR(50)
			,[QTY_MP] INT DEFAULT (0)
			,[CURRENTLY_AVAILABLE] INT
			,[STATUS_CODE] VARCHAR(50)
			,UNIQUE NONCLUSTERED
				([MATERIAL_ID], [MASTER_PACK_ID], [STATUS_CODE])
		);
  --
	DECLARE	@MP_COMPONENT TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(200)
			,[CLIENT_OWNER] VARCHAR(25)
			,[AVAILABLE] INT
			,[QTY_NEEDED] INT
			,[REAL_QTY] INT
			,[STATUS_CODE] VARCHAR(50)
			,UNIQUE NONCLUSTERED
				([MATERIAL_ID], [STATUS_CODE])
		);

	DECLARE	@INVENTORY_PROYECT_TABLE TABLE (
			[ID] INT
			,[PROJECT_ID] UNIQUEIDENTIFIER
			,[PK_LINE] INT
			,[LICENSE_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[QTY_LICENSE] NUMERIC(18, 4)
			,[QTY_RESERVED] NUMERIC(18, 4)
			,[QTY_DISPATCHED] NUMERIC(18, 4)
			,[RESERVED_PICKING] NUMERIC(18, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[STATUS_CODE] VARCHAR(50)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[CURRENT_LOCATION] VARCHAR(25)
		);

	SELECT
		@DISPATCH_BY_STATUS = CONVERT(INT, [P].[VALUE])
	FROM
		[wms].[OP_WMS_PARAMETER] [P]
	WHERE
		[P].[GROUP_ID] = 'PICKING_DEMAND'
		AND [P].[PARAMETER_ID] = 'DISPATCH_BY_STATUS';

  -- ------------------------------------------------------------------------------------
  -- Obtenemos todos los SKUs desde el XML.
  -- ------------------------------------------------------------------------------------
	SELECT
		[X].[Rec].[query]('./SKU').[value]('.',
											'varchar(50)') [MATERIAL_ID]
		,[X].[Rec].[query]('./DESCRIPTION_SKU').[value]('.',
											'varchar(200)') [MATERIAL_NAME]
		,[X].[Rec].[query]('./QTY').[value]('.',
											'numeric(18,4)') [QTY]
		,[X].[Rec].[query]('./EXTERNAL_SOURCE_ID').[value]('.',
											'int') [EXTERNAL_SOURCE_ID]
		,[X].[Rec].[query]('./SOURCE_NAME').[value]('.',
											'varchar(15)') [SOURCE_NAME]
		,[X].[Rec].[query]('./IS_MASTER_PACK').[value]('.',
											'int') [IS_MASTER_PACK]
		,[X].[Rec].[query]('./MATERIAL_OWNER').[value]('.',
											'varchar(50)') [MATERIAL_OWNER]
		,[X].[Rec].[query]('./STATUS_CODE').[value]('.',
											'varchar(50)') [STATUS_CODE]
	INTO
		[#XMLMATERIAL]
	FROM
		@XML.[nodes]('/ArrayOfOrdenDeVentaDetalle/OrdenDeVentaDetalle')
		AS [X] ([Rec]);

  -- ------------------------------------------------------------------------------------
  -- Agrupa todos los Materiales
  -- ------------------------------------------------------------------------------------
	SELECT
		[XM].[MATERIAL_ID]
		,[XM].[MATERIAL_NAME]
		,SUM([XM].[QTY]) [QTY]
		,[XM].[EXTERNAL_SOURCE_ID]
		,[XM].[SOURCE_NAME]
		,[XM].[IS_MASTER_PACK]
		,[XM].[MATERIAL_OWNER]
		,[XM].[STATUS_CODE]
	INTO
		[#MATERIAL]
	FROM
		[#XMLMATERIAL] [XM]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([XM].[MATERIAL_ID] = [M].[MATERIAL_ID])
	WHERE
		(
			@HANDLE_TONE_OR_CALIBER = 0
			OR (
				[M].[HANDLE_TONE] = 0
				AND [M].[HANDLE_CALIBER] = 0
				)
		)
	GROUP BY
		[XM].[MATERIAL_ID]
		,[XM].[MATERIAL_NAME]
		,[XM].[EXTERNAL_SOURCE_ID]
		,[XM].[SOURCE_NAME]
		,[XM].[IS_MASTER_PACK]
		,[XM].[MATERIAL_OWNER]
		,[XM].[STATUS_CODE]
		,[M].[USE_PICKING_LINE];


  -- ------------------------------------------------------------------------------------
  -- Obtenemos el inventario del proyecto
  -- ------------------------------------------------------------------------------------
	IF @PROJECT_ID IS NOT NULL
	BEGIN
		INSERT	INTO @INVENTORY_PROYECT_TABLE
				(
					[ID]
					,[PROJECT_ID]
					,[PK_LINE]
					,[LICENSE_ID]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY_LICENSE]
					,[QTY_RESERVED]
					,[QTY_DISPATCHED]
					,[RESERVED_PICKING]
					,[TONE]
					,[CALIBER]
					,[BATCH]
					,[DATE_EXPIRATION]
					,[STATUS_CODE]
					,[CURRENT_WAREHOUSE]
					,[CURRENT_LOCATION]
				)
		SELECT
			[IP].[ID]
			,[IP].[PROJECT_ID]
			,[IP].[PK_LINE]
			,[IP].[LICENSE_ID]
			,[IP].[MATERIAL_ID]
			,[IP].[MATERIAL_NAME]
			,[IP].[QTY_LICENSE]
			,[IP].[QTY_RESERVED]
			,[IP].[QTY_DISPATCHED]
			,[IP].[RESERVED_PICKING]
			,[IP].[TONE]
			,[IP].[CALIBER]
			,[IP].[BATCH]
			,[IP].[DATE_EXPIRATION]
			,[IP].[STATUS_CODE]
			,[IP].[CURRENT_WAREHOUSE]
			,[IP].[CURRENT_LOCATION]
		FROM
			[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROJECT_ID) [IP]
		INNER JOIN [#MATERIAL] [M] ON ([IP].[MATERIAL_ID] = [M].[MATERIAL_ID])
		WHERE
			@CODE_WAREHOUSE = [IP].[CURRENT_WAREHOUSE];
	END;
	DECLARE	@DATE_MIN_EXPIRATION_DATE DATE = CAST(DATEADD(DAY,
											@MIN_DAYS_EXPIRATION_DATE,
											GETDATE()) AS DATE);
  -- ------------------------------------------------------------------------------------
  -- Procesa los detalles
  -- ------------------------------------------------------------------------------------
	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#MATERIAL])
	BEGIN
		SELECT TOP 1
			@MATERIAL_ID = [e].[MATERIAL_ID]
			,@QUANTITY_ASSIGNED = [e].[QTY]
			,@CLIENT_OWNER = [e].[MATERIAL_OWNER]
			,@SOURCE_NAME = [e].[SOURCE_NAME]
			,@MATERIAL_NAME = [e].[MATERIAL_NAME]
			,@CURRENTLY_AVAILABLE = 0
			,@STATUS_CODE = [e].[STATUS_CODE]
		FROM
			[#MATERIAL] [e]

		-- ------------------------------------------------------------------------------------
		-- verifico si el material maneja lote para excluir del disponible
		-- licencias que no cumplan el criterio de tolerancia de fecha de expiracion
		-- ------------------------------------------------------------------------------------
		DECLARE	@HANDLE_BATCH_MATERIAL INT = 0;
		SELECT TOP 1
			@HANDLE_BATCH_MATERIAL = [BATCH_REQUESTED]
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID;
		print 'material id: '+@MATERIAL_ID + ' wharehouse: '+ @CODE_WAREHOUSE
    -- ------------------------------------------------------------------------ac------------
    -- Obtiene la cantidad disponible en la vista OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL 
    -- ------------------------------------------------------------------------------------
	--PRINT @CURRENTLY_AVAILABLE
	--IF EXISTS (SELECT TOP 1 1 FROM WMS.OP_WMS_PARAMETER WHERE GROUP_ID = 'PICKING_DEMAND' AND PARAMETER_ID = 'CALCULATE_MASTERPACK_POTENTIAL' AND VALUE = 1)
	--BEGIN
		SELECT @CURRENTLY_AVAILABLE = ISNULL((SELECT SUM(QTY) FROM [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL] WHERE MATERIAL_ID = @MATERIAL_ID 
																														AND CURRENT_WAREHOUSE = @CODE_WAREHOUSE
																														AND STATUS_CODE = @STATUS_CODE), 0)
	--END
	--ELSE
	--BEGIN
	--	SET @CURRENTLY_AVAILABLE = 0
	--END
		--PRINT 'MAT: ' + @MATERIAL_ID +' ; AVAV: ' + CAST(@CURRENTLY_AVAILABLE AS VARCHAR)
    -- ------------------------------------------------------------------------------------
    -- Inserta en la tabla de resultado @DETAIL_RESULT
    -- ------------------------------------------------------------------------------------
		INSERT	INTO @RESULT_DETAIL
				(
					[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[CLIENT_OWNER]
					,[QTY]
					,[AVAILABLE]
					,[QTY_NEEDED]
					,[IS_MASTER_PACK]
					,[CURRENTLY_AVAILABLE]
					,[STATUS_CODE]
				)
		VALUES
				(
					@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
					,@MATERIAL_NAME
					,@CLIENT_OWNER
					,@QUANTITY_ASSIGNED  -- QTY - int
					,@CURRENTLY_AVAILABLE  -- AVAILABLE - int
					,@CURRENTLY_AVAILABLE
					- @QUANTITY_ASSIGNED  -- QTY_NEEDED - int
					,0  -- IS_MASTER_PACK - int
					,@CURRENTLY_AVAILABLE
					,@STATUS_CODE
				);

    -- ------------------------------------------------------------------------------------
    -- Quita el material de la tabla temporal
    -- ------------------------------------------------------------------------------------
		DELETE FROM
			[#MATERIAL]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [SOURCE_NAME] = @SOURCE_NAME
			AND (
					@DISPATCH_BY_STATUS = 0
					OR [STATUS_CODE] = @STATUS_CODE
				);
	END;
  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado final y le da valor a la variable
  -- ------------------------------------------------------------------------------------

	SELECT
		[MATERIAL_ID]
		,[MATERIAL_NAME]
		,[CLIENT_OWNER]
		,[QTY] [REQUEST_QTY]
		,[AVAILABLE] [QTY]
		,[QTY_MP]
		,[QTY_NEEDED]
		,[IS_MASTER_PACK]
		,[MASTER_PACK_ID]
		,[CURRENTLY_AVAILABLE]
		,[STATUS_CODE]
	FROM
		@RESULT_DETAIL
	WHERE
		[QTY_NEEDED] < 0;
END;