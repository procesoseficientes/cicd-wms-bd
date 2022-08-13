-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_KARDEX_INSERT]
	-- Add the parameters for the stored procedure here
	@CERTIFICADO_ID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	                               

	INSERT INTO [wms].OP_WMS_KARDEX (CERTIFATE_ID, SKU, SKU_DESCRIPTION, CURRENT_BALACE, COST)
	SELECT CERTIFICATE_ID, su.CODE, [DESCRIPTION], QTY, su.COST
	FROM [wms].OP_WMS_SUPERVISIONS_DETAIL su
		INNER JOIN [wms].OP_WMS_CERTIFICATES c ON su.SUPER_ID = c.SUPERVISION_ID
	WHERE NOT EXISTS (SELECT 1
		FROM [wms].OP_WMS_KARDEX k
		WHERE CERTIFATE_ID = c.CERTIFICATE_ID
		AND SKU = su.CODE
		)		
	AND CERTIFICATE_ID = @CERTIFICADO_ID   
END