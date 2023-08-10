-- =============================================
-- Author:         diego.as
-- Create date:    26-02-2016
-- Description:    Obtiene los SKU del PICKING
--					que se le envía como parámetro
/*
Ejemplo de Ejecucion:

	EXEC [SONDA].[SWIFT_SP_GET_SKU_BY_PICKING]
	@PICKING_HEADER = 1008
	------------------------------------------
	SELECT * FROM [SONDA].SWIFT_PICKING_DETAIL 
	WHERE PICKING_HEADER = 1008
	 				
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_BY_PICKING]
(
	@PICKING_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		PD.[PICKING_DETAIL]
		,PD.[PICKING_HEADER]
		,PD.[CODE_SKU]
		,PD.[DESCRIPTION_SKU]
		,PD.[DISPATCH]
		,PD.[SCANNED]
		,PD.[DIFFERENCE]
	FROM [SONDA].[SWIFT_PICKING_DETAIL] AS PD
	WHERE PD.PICKING_HEADER = @PICKING_HEADER 

END
