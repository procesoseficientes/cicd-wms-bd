-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_KARDEX_TXNS_GET]
	-- Add the parameters for the stored procedure here
	@FechaInicio date,
	@FechaFinal date,	
	@CERTIFICADO_ID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;                                   
	
	SELECT *, (COST * TX_CURRENT_BALANCE) AS Valorization
	FROM [wms].OP_WMS_KARDEX_TXNS
	WHERE CERTIFICATE_ID = @CERTIFICADO_ID
	AND CONVERT(DATE, TX_CREATED) BETWEEN  @FechaInicio AND @FechaFinal
END