



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_INVENTORY_X_CLIENT]
(	
	@pClientCode   VARCHAR(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT *  
	FROM [wms].OP_WMS_VIEW_INVENTORY_SUMMARY
	WHERE CLIENT_CODE = @pClientCode
)