





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_PARAMETROS_GENERALES]
(	
	@PARAM_TYPE varchar(25),
	@PARAM_GROUP varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT *
	FROM [wms].OP_WMS_CONFIGURATIONS  
	WHERE PARAM_TYPE = @PARAM_TYPE 
	AND	PARAM_GROUP = @PARAM_GROUP
	
		
)