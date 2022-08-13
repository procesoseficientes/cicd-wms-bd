-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_KARDEX_CERTIFICATE_GET]
	-- Add the parameters for the stored procedure here
	@USERS VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CERTIFICADO_ID AS INT
	
	SELECT TOP 1  @CERTIFICADO_ID = CERTIFICATE_ID
	FROM [wms].OP_WMS_LOGINS l 
		INNER JOIN [wms].OP_WMS_CERTIFICATES c ON l.[3PL_WAREHOUSE] = c.[3PL_WAREHOUSE]
	WHERE LOGIN_ID = @USERS                                      

	SELECT sd.*, c.*, (QTY * COST) AS CostTotal
	FROM [wms].OP_WMS_SUPERVISIONS_DETAIL sd
		INNER JOIN [wms].OP_WMS_CERTIFICATES c ON sd.SUPER_ID = c.SUPERVISION_ID
	WHERE CERTIFICATE_ID = @CERTIFICADO_ID
		
END