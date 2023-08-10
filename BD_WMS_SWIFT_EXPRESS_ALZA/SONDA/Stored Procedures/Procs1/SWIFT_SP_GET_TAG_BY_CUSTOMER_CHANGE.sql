-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	13-07-2016
-- Description:			Obtiene las etiquetas por cliente con cambios

-- Modificacion 5/10/2017 @ A-Team Sprint Issa
					-- diego.as
					-- Se agrega columna QRY_GROUP

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SWIFT_SP_GET_TAG_BY_CUSTOMER_CHANGE 
				@CUSTOMER = 3
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TAG_BY_CUSTOMER_CHANGE]
	@CUSTOMER VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 		
		TC.TAG_COLOR
		, ST.TAG_VALUE_TEXT
		, ST.QRY_GROUP
	FROM  [SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE] AS TC
		INNER JOIN [SONDA].[SWIFT_CUSTOMER_CHANGE] CC ON TC.CUSTOMER = CC.CUSTOMER
		INNER JOIN [SONDA].[SWIFT_TAGS] ST ON TC.TAG_COLOR = st.TAG_COLOR
		WHERE TC.CUSTOMER = @CUSTOMER
END
