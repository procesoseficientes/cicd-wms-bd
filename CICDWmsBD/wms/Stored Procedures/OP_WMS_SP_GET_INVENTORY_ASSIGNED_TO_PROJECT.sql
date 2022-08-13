-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30119: Catalogo de proyectos - Asignacion de inventario
-- Description:			obtiene el inventario asignado a un proyecto

-- Modificacion:		henry.rodriguez
-- Fecha de Creacion: 	30-Jul-2019 G-FORCE@Dublin
-- Description:			Se agrega join hacia la funcion [OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE] para obtener la cantidad en picking.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_AVAILABLE_TO_ASSIGN_PROJECT]						
					
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_ASSIGNED_TO_PROJECT] (
		@PROJECT_ID UNIQUEIDENTIFIER
	)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[IRP].[ID]
		,[IRP].[PROJECT_ID]
		,[IRP].[PK_LINE]
		,[IRP].[LICENSE_ID]
		,[IRP].[MATERIAL_ID]
		,[IRP].[MATERIAL_NAME]
		,[IRP].[QTY_LICENSE]
		,[IRP].[QTY_RESERVED]
		,[IRP].[QTY_DISPATCHED]
		,([QTY_RESERVED] - [QTY_DISPATCHED]) AS [QTY_PENDING]
		,ISNULL([FN_CIL].[COMMITED_QTY], 0) [RESERVED_PICKING]
		,[IRP].[STATUS_CODE]
		,[IRP].[TONE]
		,[IRP].[CALIBER]
		,[IRP].[BATCH]
		,[IRP].[DATE_EXPIRATION]
	FROM
		[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
	LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [FN_CIL] ON (
											[IRP].[MATERIAL_ID] = [FN_CIL].[MATERIAL_ID]
											AND [IRP].[LICENSE_ID] = [FN_CIL].[LICENCE_ID]
											)
	WHERE
		[IRP].[PROJECT_ID] = @PROJECT_ID;

END;