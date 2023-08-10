-- =====================================================
-- Author:         diego.as
-- Create date:    06-04-2016
-- Description:    Trae la listas de precios DEFAULT
--
/*
-- Modificacion: 14-04-2016
			Autor: diego.as
			Descripcion: Se modifico para que mandara a llamar a la funcion [SONDA].[SWIFT_FN_GET_PARAMETER]
						 en lugar del SELECT que se tenia a la tabla [SONDA].[SWIFT_PARAMETER]
*/				   
-- Modificacion 3/7/2017 @ A-Team Sprint Ebonne
					-- rodrigo.gomez
					-- Se añadio la obtencion del codigo de lista de precios por usuario y si no tiene uno asignado, devuelve el que esta en parametros

-- Modificacion 5/3/2017 @ A-Team Sprint Hondo
					-- rodrigo.gomez
					-- Se envia -1 como lista de precios por defecto

/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SONDA_SP_GET_DEFAULT_PRICE_LIST] @LOGIN = 'rudi@SONDA'
		
*/			
-- =====================================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_DEFAULT_PRICE_LIST]
	@LOGIN VARCHAR(50) = NULL
AS
BEGIN
	SELECT ISNULL([CODE_PRICE_LIST], [SONDA].[SWIFT_FN_GET_PARAMETER] ('ERP_HARDCODE_VALUES','PRICE_LIST')) AS CODE_PRICE_LIST
	FROM [SONDA].[USERS]
	WHERE [LOGIN] = @LOGIN
	--SELECT '-1' AS CODE_PRICE_LIST
END
