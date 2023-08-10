-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	14-12-2015
-- Description:			Obtiene las etiquetas por cliente

-- Modificacion 5/10/2017 @ A-Team Sprint Issa
					-- diego.as
					-- Se agrega columna QRY_GROUP

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se cambio la referencia a la vista de etiquetas de scoutings

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SWIFT_SP_GET_TAG_FOR_CUSTOMER] @CODE_CUSTOMER = 'SO-1762'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TAG_FOR_CUSTOMER]
	@CODE_CUSTOMER VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 		
		T.TAG_COLOR
		,T.TAG_VALUE_TEXT
		,[T].QRY_GROUP
	FROM  [SONDA].[SWIFT_VIEW_ALL_TAG_X_CUSTOMER_NEW] AS TC
		INNER JOIN [SONDA].[SWIFT_TAGS] AS T ON T.[TAG_COLOR] = TC.[TAG_COLOR]
		WHERE TC.CUSTOMER = @CODE_CUSTOMER

END
