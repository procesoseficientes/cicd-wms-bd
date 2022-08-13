-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_KARDEX_GET]
	-- Add the parameters for the stored procedure here
	@CERTIFICADO_ID INT 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;                               

	SELECT *
	FROM [wms].OP_WMS_KARDEX
	WHERE CERTIFATE_ID = @CERTIFICADO_ID
		
END