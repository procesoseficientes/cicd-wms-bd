﻿-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		15-JULIO-2019 G-Force@Dublin
-- Description:			    Obtiene el inventario asociado, BODEGA, PROJECTO Y SI ES DISCRETIONAL
/*
Ejemplo de Ejecucion:
	EXECUTE [wms].[OP_WMS_SP_GET_INVENTORY_RESERVED_BY_PROJECT] @WAREHOUSE = 'BODEGA_01', @PROJECT_ID = '59012660-EDCC-465B-BF08-68D58744D3D8', @DISCRETIONAL = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_RESERVED_BY_PROJECT] (
		@WAREHOUSE VARCHAR(25)
		,@PROJECT_ID UNIQUEIDENTIFIER
		,@DISCRETIONAL BIT
	)
AS
BEGIN

	IF @DISCRETIONAL = 0
	BEGIN

		SELECT
			MAX([GIP].[OPPORTUNITY_NAME]) [OPPORTUNITY_NAME]
			,[GIP].[MATERIAL_ID]
			,MAX([GIP].[MATERIAL_NAME]) [MATERIAL_NAME]
			,MAX([GIP].[BARCODE_ID]) [BARCODE_ID]
			,MAX([GIP].[ALTERNATE_BARCODE]) [ALTERNATE_BARCODE]
			,SUM([GIP].[QTY_LICENSE]) [QTY_LICENSE]
			,SUM([GIP].[QTY_RESERVED]) [QTY_RESERVED]
			,SUM([GIP].[QTY_DISPATCHED]) [QTY_DISPATCHED]
			,MAX([GIP].[CURRENT_WAREHOUSE]) [CURRENT_WAREHOUSE]
			,[GIP].[STATUS_CODE]
		FROM
			[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROJECT_ID) [GIP]
		WHERE
			[GIP].[CURRENT_WAREHOUSE] = @WAREHOUSE
			AND [GIP].[QTY_LICENSE] > 0
		GROUP BY
			[GIP].[MATERIAL_ID]
			,[GIP].[STATUS_CODE];

	END;
	ELSE
	BEGIN 

		SELECT
			[GIP].[LICENSE_ID]
			,[GIP].[MATERIAL_ID]
			,[GIP].[MATERIAL_NAME]
			,[GIP].[QTY_LICENSE]
			,[GIP].[QTY_RESERVED]
			,[GIP].[QTY_DISPATCHED]
			,[GIP].[BARCODE_ID]
			,[GIP].[ALTERNATE_BARCODE]
			,[GIP].[TONE]
			,[GIP].[CALIBER]
			,[GIP].[BATCH]
			,[GIP].[DATE_EXPIRATION]
			,[GIP].[STATUS_CODE]
			,[GIP].[CURRENT_WAREHOUSE]
			,[GIP].[CURRENT_LOCATION]
			,[GIP].[OPPORTUNITY_NAME]
		FROM
			[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROJECT_ID) [GIP]
		WHERE
			[GIP].[CURRENT_WAREHOUSE] = @WAREHOUSE
			AND [GIP].[QTY_LICENSE] > 0;

	END;

	

END;