-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		1/8/2018 @ A-Team Sprint 
-- Description:			    Funcion que calcula si todos los productos de una demanda ya fueron entregados y si todos estan entregados, la demanda esta completa, de lo contrario, esta incompleta.

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FUNC_GET_STATE_OF_DEMAND_DISPATCH] 
*/
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FUNC_GET_STATE_OF_DEMAND_DISPATCH
(
	@PICKING_DEMAND_HEADER_ID INT
)
RETURNS INT
AS
BEGIN
	DECLARE @QTY_LABELS_FOUND INT = 0
	,@QTY_LABELS_PENDING INT = 0
	,@MATERIALS_QTY_ASSIGNED NUMERIC(18,6) = 0
	,@MATERIALS_QTY_DELIVERED NUMERIC(18,6) = 0
	,@WAVE_PICKING_ID INT
	
	--
	SELECT 
		@WAVE_PICKING_ID = DH.[WAVE_PICKING_ID] 
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] AS DH
	WHERE DH.[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
	
	--
	SELECT 
		@MATERIALS_QTY_ASSIGNED = SUM(TL.[QUANTITY_ASSIGNED])
	FROM [wms].[OP_WMS_TASK_LIST] AS TL
	WHERE TL.[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		
		--
	SELECT 
		@MATERIALS_QTY_DELIVERED = ISNULL(SUM(PL.[QTY]),0)
	FROM [wms].[OP_WMS_PICKING_LABELS] AS PL
	INNER JOIN [wms].[OP_WMS_DELIVERED_LABEL] AS PLD ON([PLD].[LABEL_ID] = [PL].[LABEL_ID])
	WHERE PL.[WAVE_PICKING_ID] = @WAVE_PICKING_ID

	IF(@MATERIALS_QTY_ASSIGNED = @MATERIALS_QTY_DELIVERED) BEGIN
		RETURN 1;
	END
	ELSE BEGIN 
		RETURN 0;
	END

	RETURN 2;
END