-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FUNC_GET_VALORIZACION
(	
	-- Add the parameters for the function here
	--<@param1, sysname, @p1> <Data_Type_For_Param1, , int>, 
	--<@param2, sysname, @p2> <Data_Type_For_Param2, , char>
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT *FROM [wms].OP_WMS_VIEW_VALORIZACION
)