/*=======================================================
-- Author:         hector.gonzalez
-- Create date:    13-07-2016
-- Description:    Obtiene las Etiquetas disponibles para el cliente con cambios seleccionado	   

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_AVAILABLE_TAGS_BY_CUSTOMER_CHANGE]
		 @CUSTOMER = 3
=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_AVAILABLE_TAGS_BY_CUSTOMER_CHANGE]
(
	@CUSTOMER VARCHAR(250)
) AS
BEGIN
	--
	BEGIN TRY
		--
		SELECT [T].[TAG_COLOR]
			,[T].[TAG_VALUE_TEXT]
		FROM [SONDA].[SWIFT_TAGS] AS T
		WHERE [T].[TAG_COLOR] 
			NOT IN(SELECT DISTINCT [TXC].[TAG_COLOR] 
			FROM [SONDA].SWIFT_TAG_X_CUSTOMER_CHANGE AS TXC 
			WHERE [TXC].[CUSTOMER] = @CUSTOMER)
		AND [T].[TYPE] = 'CUSTOMER'
		ORDER BY [T].[TAG_PRIORITY] ASC
		--
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@ERROR,16,1)
	END CATCH
	--
END
