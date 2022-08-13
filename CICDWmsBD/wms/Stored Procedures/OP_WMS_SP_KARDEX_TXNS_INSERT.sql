-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_KARDEX_TXNS_INSERT]
	-- Add the parameters for the stored procedure here	
	@CERTIFICADO_ID INT,
	@TX_DATE DATE,
	@TX_RECEIPTS NUMERIC(18, 2),
	@TX_DISPACTIL NUMERIC(18, 2),
	@TX_LAST_BALACE NUMERIC(18, 2),
	@TX_CURRENT_BALANCE NUMERIC(18, 2),
	@SKU VARCHAR(50), 
	@SKU_DESCRIPTION VARCHAR(200),
	@COST MONEY
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	INSERT INTO [wms].OP_WMS_KARDEX_TXNS(CERTIFICATE_ID, TX_DATE, TX_RECEIPTS, TX_DISPACTIL, TX_LAST_BALACE, 
											TX_CURRENT_BALANCE, SKU, SKU_DESCRIPTION, COST)
									values(@CERTIFICADO_ID, @TX_DATE, @TX_RECEIPTS, @TX_DISPACTIL, @TX_LAST_BALACE,
											@TX_CURRENT_BALANCE, @SKU, @SKU_DESCRIPTION, @COST)
	
END