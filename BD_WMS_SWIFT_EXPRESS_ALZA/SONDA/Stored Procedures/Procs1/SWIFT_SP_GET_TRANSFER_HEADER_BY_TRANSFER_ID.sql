-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	30-Jan-17 @ A-TEAM Sprint Bankole 
-- Description:			SP que obtiene una transferencia

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_TRANSFER_HEADER_BY_TRANSFER_ID]
					@TRANSFER_ID = 119
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TRANSFER_HEADER_BY_TRANSFER_ID](
	@TRANSFER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[TH].[TRANSFER_ID]
		,[TH].[SELLER_CODE]
		,[TH].[SELLER_ROUTE]
		,[TH].[CODE_WAREHOUSE_SOURCE]
		,[TH].[CODE_WAREHOUSE_TARGET]
		,[TH].[STATUS]
		,[TH].[LAST_UPDATE]
		,[TH].[LAST_UPDATE_BY]
		,[TH].[COMMENT]
		,[TH].[IS_ONLINE]
		,[TH].[CREATION_DATE]
	FROM [SONDA].[SWIFT_TRANSFER_HEADER] [TH]
	WHERE [TH].[TRANSFER_ID] = @TRANSFER_ID
END
