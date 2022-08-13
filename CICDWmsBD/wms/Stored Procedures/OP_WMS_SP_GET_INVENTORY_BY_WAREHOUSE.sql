-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		23-Nov-16 @ A-Team Sprint 5
-- Description:			    Sp que obtiene el inventario disponible de general


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-17 Team ERGON - Sprint EPONA
-- Description:	 Se elimina acuerdo comercial

-- Modificación:        hector.gonzalez
-- Fecha de Creacion: 	2017-06-16 Team ERGON - Sprint BreathOfTheWild
-- Description:	        se agrega [HANDLE_SERIAL]

-- Modificacion 7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- rodrigo.gomez
-- Se agrega el total de invetario para masterpacks incluyendo lo posible a ensamblar y si es masterpack o no

-- Modificacion 28-Nov-2017 @ Reborn-Team Sprint Nach
-- rodrigo.gomez
-- Se quitaron las condiciones de que el producto maneja lote, numero de serie y si es carro.

-- Modificacion:		henry.rodriguez
-- Fecha:				12-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrego el campo STATUS_CODE cuando no es discrecional.
/*
-- Ejemplo de Ejecucion:
		exec [wms].OP_WMS_SP_GET_INVENTORY_BY_WAREHOUSE @CODE_CLIENT='wms'
                                                      ,@CODE_WAREHOUSE='BODEGA_01'  
                                                      ,@IS_DISCRETIONAL=0
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_WAREHOUSE] (
		@CODE_CLIENT VARCHAR(25)
		,@CODE_WAREHOUSE VARCHAR(25)
		,@IS_DISCRETIONAL INT
	)
AS
IF @IS_DISCRETIONAL = 1
BEGIN
	SELECT DISTINCT
		[IG].[MATERIAL_ID]
		,[IG].[MATERIAL_NAME]
		,[IG].[CLIENT_OWNER]
		,[IG].[ALTERNATE_BARCODE]
		,[IG].[BARCODE_ID]
		,[IG].[CLIENT_NAME]
		,SUM([IG].[QTY]) [QTY]
		,SUM([IG].[ON_PICKING]) [ON_PICKING]
		,SUM([IG].[AVAILABLE]) [AVAILABLE]
		,[IG].[BATCH_REQUESTED]
		,[IG].[IS_CAR]
		,[IG].[CURRENT_WAREHOUSE]
	FROM
		[wms].[OP_WMS_VIEW_INVENTORY_GENERAL] AS [IG]
	WHERE
		[IG].[CURRENT_WAREHOUSE] = @CODE_WAREHOUSE
		AND [IG].[CLIENT_OWNER] = @CODE_CLIENT
		AND [IG].[QTY] > 0
	GROUP BY
		[IG].[MATERIAL_ID]
		,[IG].[MATERIAL_NAME]
		,[IG].[CLIENT_OWNER]
		,[IG].[ALTERNATE_BARCODE]
		,[IG].[BARCODE_ID]
		,[IG].[CLIENT_NAME]
		,[IG].[BATCH_REQUESTED]
		,[IG].[IS_CAR]
		,[IG].[CURRENT_WAREHOUSE];
END;
ELSE
BEGIN

	SELECT
		[M].[MATERIAL_ID]
		,[M].[MATERIAL_NAME]
		,[M].[CLIENT_OWNER]
		,[M].[ALTERNATE_BARCODE]
		,[M].[BARCODE_ID]
		,[C].[CLIENT_NAME]
		,ISNULL(SUM([PAG].[LICENCE_QTY]), 0) [QTY]
		,ISNULL(SUM([PAG].[COMMITED_QTY]), 0) [ON_PICKING]
		,ISNULL(SUM([PAG].[QTY]), 0) [AVAILABLE]
		,[M].[BATCH_REQUESTED]
		,[M].[IS_CAR]
		,@CODE_WAREHOUSE [CURRENT_WAREHOUSE]
		,[M].[IS_MASTER_PACK]
		,MAX(CASE	WHEN [M].[IS_MASTER_PACK] = 1
					THEN [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK_ON_DISPATCH_DEMAND]([M].[MATERIAL_ID],
											@CODE_WAREHOUSE,null)
					ELSE 0
				END) [CANTIDAD_MP]
		,ISNULL([PAG].[STATUS_CODE], 'BUEN-ESTADO') [STATUS_CODE]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	LEFT JOIN [wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL] [PAG] ON [PAG].[MATERIAL_ID] = [M].[MATERIAL_ID]
											AND [PAG].[CURRENT_WAREHOUSE] = @CODE_WAREHOUSE
	LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [C].[CLIENT_CODE] = [M].[CLIENT_OWNER]
	WHERE
		[M].[CLIENT_OWNER] = @CODE_CLIENT
	--	AND (QTY <> 0 OR [CANTIDAD_MP]<> 0)
	GROUP BY
		[M].[MATERIAL_ID]
		,[M].[MATERIAL_NAME]
		,[M].[CLIENT_OWNER]
		,[M].[ALTERNATE_BARCODE]
		,[M].[BARCODE_ID]
		,[C].[CLIENT_NAME]
		,[M].[BATCH_REQUESTED]
		,[M].[IS_CAR]
		,[PAG].[CURRENT_WAREHOUSE]
		,[M].[IS_MASTER_PACK]
		,[PAG].[STATUS_CODE]
	HAVING
		ISNULL(SUM([PAG].[QTY]), 0) > 0
		OR MAX(CASE	WHEN [M].[IS_MASTER_PACK] = 1
					THEN [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK_ON_DISPATCH_DEMAND]([M].[MATERIAL_ID],
											@CODE_WAREHOUSE,null)
					ELSE 0
				END) > 0;






END;