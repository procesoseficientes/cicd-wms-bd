-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [wms].[OP_BASC_FUNC_GET_QUESTION]
(	
	@pFORM_CODE			varchar(50),
	@pQUESTION_GROUP	varchar(50),
	@pQUESTION_NAME		varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		QUESTION_ID, 
		QUESTION_PROMPT 
	FROM 
		[wms].OP_BASC_FORMS
	WHERE 
		FORM_CODE		= @pFORM_CODE		AND 
		QUESTION_GROUP	= @pQUESTION_GROUP	AND 
		QUESTION_NAME	= @pQUESTION_NAME
)