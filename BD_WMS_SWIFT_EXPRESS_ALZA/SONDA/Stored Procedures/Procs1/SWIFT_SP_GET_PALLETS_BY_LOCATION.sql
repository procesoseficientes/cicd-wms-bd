-- =============================================
-- Author:         diego.as
-- Create date:    19-02-2016
-- Description:    Obtiene los PALLET'S de la Tabla 
--				   [SONDA].[SWIFT_PALLET] 
--				   tomando como parametro el campo @CODE_LOCATION
--					al mismo tiempo hace un INNER JOIN con la tabla
--					[SONDA].[SWIFT_BATCH] mediante el campo BATCH_ID
/*
Ejemplo de Ejecucion:

	EXEC [SONDA].[SWIFT_SP_GET_PALLETS_BY_LOCATION] 
	@CODE_LOCATION = 'A3'
	 				
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PALLETS_BY_LOCATION]
(
	@CODE_LOCATION VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SP.LOCATION
		,SP.PALLET_ID
		,SP.BATCH_ID
		,SB.SKU
		,SVS.DESCRIPTION_SKU
		,SP.QTY
		,SP.STATUS
		,SP.WAREHOUSE
		,CAST(BATCH_SUPPLIER_EXPIRATION_DATE AS VARCHAR(10)) AS BATCH_SUPPLIER_EXPIRATION_DATE
	FROM [SONDA].[SWIFT_PALLET] AS SP  
	INNER JOIN [SONDA].[SWIFT_BATCH] AS SB ON (
		SB.BATCH_ID = SP.BATCH_ID
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_SKU] AS SVS ON (
		SVS.CODE_SKU = SB.SKU
	)
	WHERE SP.LOCATION = @CODE_LOCATION AND SP.QTY > 0

END
