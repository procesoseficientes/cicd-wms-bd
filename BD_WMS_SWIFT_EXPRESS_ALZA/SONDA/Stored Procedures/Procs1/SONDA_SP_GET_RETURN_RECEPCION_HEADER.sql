-- =============================================
-- Author:         diego.as
-- Create date:    09-02-2016
-- Description:    Obtiene los HEADER de la Tabla 
--				   [SONDA].SONDA_DOC_ROUTE_RETURN_HEADER 
--				   con transacción y control de errores.
/*
Ejemplo de Ejecucion:

	EXEC [SONDA].[SONDA_SP_GET_RETURN_RECEPCION_HEADER] 
	@ID_RETURN_HEADER = 2
	 				
*/
-- =============================================

CREATE PROCEDURE [SONDA].SONDA_SP_GET_RETURN_RECEPCION_HEADER
(
	@ID_RETURN_HEADER INT
)
AS
BEGIN
    SET NOCOUNT ON;

		SELECT TOP 1
			RH.ID_DOC_RETURN_HEADER
			,RH.USER_LOGIN
			,RH.WAREHOUSE_SOURCE
			,RH.WAREHOUSE_TARGET
			,RH.NAME_USER
			,RH.LAST_UPDATE
			,RH.LAST_UPDATE_BY
			,RH.STATUS_DOC
			,RH.ATTEMPTED_WITH_ERROR
			,RH.IS_POSTED_ERP
			,RH.POSTED_ERP
			,RH.POSTED_RESPONSE
		FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER] RH 
		WHERE RH.ID_DOC_RETURN_HEADER = @ID_RETURN_HEADER

END
