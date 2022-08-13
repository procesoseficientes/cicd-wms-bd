




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_INVENTORY_SUM]
(	
	@pMATERIAL_ID   VARCHAR(50),
	@pVOL_FACT		NUMERIC(18,2)
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT SUM(QTY) AS UNIDADES, SUM(QTY)*@pVOL_FACT as QTY_M3  
	FROM [wms].OP_WMS_VIEW_INVENTORY_DETAIL
	WHERE MATERIAL_ID = @pMATERIAL_ID
	GROUP BY MATERIAL_ID
)