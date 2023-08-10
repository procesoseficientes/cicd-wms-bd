-- =============================================
-- Author:         diego.as
-- Create date:    09-02-2016
-- Description:    Obtiene los DETAILS de la Tabla 
--				   [SONDA].SONDA_DOC_ROUTE_RETURN_DETAIL 
--				   con transacción y control de errores.
/*
Ejemplo de Ejecucion:

	EXEC [SONDA].[SONDA_SP_GET_RETURN_RECEPCION_DETAIL] 
	@ID_RETURN_HEADER = 1
	 				
*/
-- =============================================

CREATE PROCEDURE [SONDA].SONDA_SP_GET_RETURN_RECEPCION_DETAIL
(
	@ID_RETURN_HEADER INT
)
AS
BEGIN
    SET NOCOUNT ON;

		SELECT 
			RD.ID_DOC_RETURN_DETAIL
			,RD.ID_DOC_RETURN_HEADER
			,RD.CODE_SKU
			,RD.QTY 
			,RD.DESCRIPTION_SKU
		FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_DETAIL] RD 
		WHERE RD.ID_DOC_RETURN_HEADER = @ID_RETURN_HEADER
END
