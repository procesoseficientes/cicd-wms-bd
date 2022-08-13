-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30119: Catalogo de proyectos - Asignacion de inventario
-- Description:			obtiene el inventario disponible para asignar a un proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Jul-2019 G-FORCE@Dublin
-- Description:			se usa otra vista que obtiene las licencias que no estan en olas de picking y tampoco en proyectos

-- Modificacion:		henry.rodriguez
-- Fecha de Creacion: 	30-Jul-2019 G-FORCE@Dublin
-- Description:			Se agrega validacion para que no muestre las licencias con cantidad 0

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_AVAILABLE_TO_ASSIGN_PROJECT]						
					
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_AVAILABLE_TO_ASSIGN_PROJECT] (
		@MATERIAL_XML XML
		,@PROJECT_ID UNIQUEIDENTIFIER
		,@LOGIN_ID VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE	@MATERIAL_TABLE TABLE (
			[MATERIAL_ID] VARCHAR(50)
		);

	INSERT	INTO @MATERIAL_TABLE
			(
				[MATERIAL_ID]
			)
	SELECT
		[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'VARCHAR(25)')
	FROM
		@MATERIAL_XML.[nodes]('/ArrayOfMaterial/Material')
		AS [x] ([Rec]);

	SELECT
		[AL].[PK_LINE]
		,@PROJECT_ID [PROJECT_ID]
		,[AL].[LICENSE_ID]
		,[AL].[MATERIAL_ID]
		,[AL].[MATERIAL_NAME]
		,[AL].[QTY]
		,[AL].[QTY] [QTY_AVAILABLE]
		,[AL].[BATCH]
		,[AL].[DATE_EXPIRATION]
		,[AL].[STATUS_NAME] [STATUS_CODE]
		,[AL].[TONE]
		,[AL].[CALIBER]
	FROM
		[wms].[OP_WMS_VW_COMPLETELY_AVAILABLE_LICENSES] [AL]
	INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON [AL].[CURRENT_WAREHOUSE] = [WU].[WAREHOUSE_ID]
											AND [WU].[LOGIN_ID] = @LOGIN_ID
	INNER JOIN @MATERIAL_TABLE [MT] ON [MT].[MATERIAL_ID] = [AL].[MATERIAL_ID]
	WHERE
		[AL].[QTY] > 0;
	
END;