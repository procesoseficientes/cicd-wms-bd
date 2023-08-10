
-- =====================================================
-- Author:         diego.as
-- Create date:    21-03-2016
-- Description:    Trae las Series de generadas en una Tarea de Recepcion
/*
	MODIFICACION: diego.as
		DESCRIPCION: Se agregaron nuevos campos a la consulta
		FECHA: 29-3-2016
*/			   

/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SWIFT_SP_GET_SERIES_SCANNED_SKU]
			@TXNID = 6018
			,@TXNCODESKU = '100030'
		
*/			
-- =====================================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SERIES_SCANNED_SKU]
(
	@TXNID INT
	,@TXNCODESKU VARCHAR(50)
)
AS
BEGIN
	SELECT TXN_ID
		,TXN_CODE_SKU
		,TXN_DESCRIPTION_SKU
		,TXN_SERIE 
	FROM [SONDA].SWIFT_TXNS_SERIES
	WHERE TXN_ID = @TXNID 
		AND TXN_CODE_SKU = @TXNCODESKU
END
