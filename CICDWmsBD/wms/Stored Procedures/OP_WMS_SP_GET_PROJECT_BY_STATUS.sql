-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	08-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30123: Catalogo de proyectos
-- Description:			Sp que obtiene los proyectos con el estado enviado

-- Autor:				marvin.solares
-- Fecha de Creacion: 	12-Jul-2019 G-FORCE@Dublin
-- Description:			Se agrega el status y el costo total del proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	22-Jul-2019 G-FORCE@Dublin
-- Description:			agrego filtro para que el query pueda devolver todos los proyectos

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PROJECT_BY_STATUS]						
					@STATUS VARCHAR(20) = 'CREATED'
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PROJECT_BY_STATUS] (
		@STATUS VARCHAR(20) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	SET NOCOUNT ON;
	DECLARE	@UNITS BIGINT;

	SELECT
		[IRP].[PROJECT_ID]
		,SUM([IRP].[QTY_RESERVED] * [M].[ERP_AVERAGE_PRICE]) [COST_UNITS]--SUMAMOS LO RESERVADO PARA EL PROYECTO POR SU COSTO ERP PARA PODER ACUMULAR EL COSTO DE TODO EL PROYECTO
		,SUM([IRP].[QTY_DISPATCHED]) * 100
		/ SUM([IRP].[QTY_RESERVED]) [PERCENTAGE_DISPATCHED]
		,SUM([IRP].[QTY_RESERVED]) [UNITS]
	INTO
		[#UNITS_BY_PROJECT]
	FROM
		[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [IRP].[MATERIAL_ID] = [M].[MATERIAL_ID]
	GROUP BY
		[PROJECT_ID];

	DECLARE	@LAST_DISPATCHED_DATE DATETIME;

	SELECT
		MAX([CREATED_DATE]) [LAST_DISPATCHED_DATE]
		,[PROJECT_ID]
	INTO
		[#MOVEMENTS_PROJECTS]
	FROM
		[wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
	GROUP BY
		[PROJECT_ID];

	SELECT
		[P].[ID]
		,[P].[OPPORTUNITY_CODE]
		,[P].[OPPORTUNITY_NAME]
		,[P].[SHORT_NAME]
		,[P].[OBSERVATIONS]
		,[P].[CUSTOMER_CODE]
		,[P].[CUSTOMER_NAME]
		,[P].[STATUS]
		,CASE	WHEN [P].[STATUS] = 'CREATED' THEN 'Creado'
				WHEN [P].[STATUS] = 'COMPLETED'
				THEN 'Completado'
				WHEN [P].[STATUS] = 'IN_PROCESS'
				THEN 'En Proceso'
				WHEN [P].[STATUS] = 'FINALIZED'
				THEN 'Finalizado'
				WHEN [P].[STATUS] = 'CANCELLED'
				THEN 'Cancelado'
				ELSE ''
			END [STATUS_DESCRIPTION]
		,[P].[CREATED_BY]
		,[P].[CREATED_DATE]
		,[P].[LAST_UPDATED_BY]
		,[P].[LAST_UPDATED_DATE]
		,ISNULL([UP].[PERCENTAGE_DISPATCHED], 0) [PERCENTAGE_DISPATCHED]
		,[MP].[LAST_DISPATCHED_DATE] AS [LAST_DISPATCHED_DATE]
		,ISNULL([UP].[COST_UNITS], 0) AS [COST_UNITS]
		,ISNULL([UP].[UNITS], 0) AS [UNITS]
	FROM
		[wms].[OP_WMS_PROJECT] [P]
	LEFT JOIN [#UNITS_BY_PROJECT] [UP] ON [P].[ID] = [UP].[PROJECT_ID]
	LEFT JOIN [#MOVEMENTS_PROJECTS] [MP] ON [P].[ID] = [MP].[PROJECT_ID]
	WHERE
		@STATUS IS NULL
		OR @STATUS = [P].[STATUS]; 

END;