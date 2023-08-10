/*=======================================================
-- Author:         diego.as
-- Create date:    20-06-2016
-- Description:    Obtiene las Etiquetas disponibles 
				   para el cliente seleccionado	   

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_AVAILABLE_TAGS_BY_SCOUTING]
		 @CODE_CUSTOMER = 'SO-1762'
=========================================================*/

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se cambio la referencia a la vista de etiquetas de scouting.

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_AVAILABLE_TAGS_BY_SCOUTING]
(
	@CODE_CUSTOMER VARCHAR(250)
) AS
BEGIN
	--
	BEGIN TRY
		--
		SELECT [T].[TAG_COLOR]
			,[T].[TAG_VALUE_TEXT]
			,[T].[TAG_PRIORITY]
		FROM [SONDA].[SWIFT_TAGS] AS T
		WHERE [T].[TAG_COLOR] 
			NOT IN(SELECT DISTINCT [TXC].[TAG_COLOR] 
			FROM [SONDA].[SWIFT_VIEW_ALL_TAG_X_CUSTOMER_NEW] AS TXC 
			WHERE [TXC].[CUSTOMER] = @CODE_CUSTOMER)
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
