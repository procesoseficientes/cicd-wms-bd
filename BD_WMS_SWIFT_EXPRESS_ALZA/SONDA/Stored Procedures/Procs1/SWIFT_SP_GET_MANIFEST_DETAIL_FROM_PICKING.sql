-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		24-Oct-2016 @ TEAM A - 
-- Description:			    SP que obtiene el detalle de productos en manifiesto

/*
-- Ejemplo de Ejecucion:
		--
		EXEC [SWIFT_SP_GET_MANIFEST_DETAIL_FROM_PICKING] @MANIFEST_HEADER = 3071
		EXEC [SONDA].[SWIFT_SP_GET_MANIFEST_DETAILS]
			@MANIFEST_HEADER = 3071
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_MANIFEST_DETAIL_FROM_PICKING] (
	@MANIFEST_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 
	[spd].[CODE_SKU] AS SKU
	,[spd].[DESCRIPTION_SKU] AS SKU_DESCRIPTION
	,SUM([spd].[SCANNED]) AS QTY
	, 0	AS TOTAL_AMOUNT
	 FROM [SONDA].[SWIFT_MANIFEST_DETAIL] [smd] 
	INNER JOIN [SONDA].[SWIFT_PICKING_DETAIL] [spd] ON [smd].[CODE_PICKING] = [spd].[PICKING_HEADER]
	WHERE [smd].[CODE_MANIFEST_HEADER] = @MANIFEST_HEADER
	GROUP BY [spd].[CODE_SKU] , [spd].[DESCRIPTION_SKU]
END
