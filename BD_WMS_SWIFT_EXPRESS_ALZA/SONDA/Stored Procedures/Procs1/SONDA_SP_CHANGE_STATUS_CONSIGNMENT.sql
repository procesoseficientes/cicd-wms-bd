
/* ==============================================
-- Author:         diego.as
-- Create date:    01-09-2016 - Sprint ι
-- Description:    Cambia el STATUS de la consignacion a 'CANCELLED'(CANCELLED)

-- MODIFICADO:		20-10-2016
-- Autor:			diego.as @ TEAM-A Sprint 3
-- Descripcion:		Se agrega el campo IS_CLOSED al update para que marque la consignacion como CERRADA
					esto para el registro de que se muestra en el monitor de trazabilidad de la consignacion.

/*
-- EJEMPLO DE EJECUCION:
		-- 
		EXEC [SONDA].[SONDA_SP_CHANGE_STATUS_CONSIGNMENT]
			@CONSIGNMENT_ID = 385
			,@CUSTOMER_ID = 'BO-2090'
			,@CODE_ROUTE = 'RUDI@SONDA'
      ,@DOC_SERIE = 'CONSIGNMENT'
			,@DOC_NUM = 1
		--
		SELECT * FROM [SONDA].[SWIFT_CONSIGNMENT_HEADER]
*/
===============================================*/

CREATE PROCEDURE [SONDA].[SONDA_SP_CHANGE_STATUS_CONSIGNMENT]
(
	@CONSIGNMENT_ID INT
		,@CUSTOMER_ID VARCHAR(50)
		,@CODE_ROUTE VARCHAR(25)
		,@DOC_SERIE VARCHAR(50)
		,@DOC_NUM INT
)AS
BEGIN
	UPDATE [SONDA].[SWIFT_CONSIGNMENT_HEADER]
		SET [STATUS] = 'CANCELLED'
			,[DATE_UPDATE] = GETDATE()
	WHERE [CONSIGNMENT_ID] = @CONSIGNMENT_ID 
		AND [CUSTOMER_ID] = @CUSTOMER_ID
		AND [POS_TERMINAL] = @CODE_ROUTE
		AND [DOC_SERIE] = @DOC_SERIE
		AND [DOC_NUM] = @DOC_NUM
END
