-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/15/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/15/2018 - SP que obtiene la informacion de listado de precios especiales para enviarlos al movil		     

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SONDA_SP_GET_LIST_OF_SPECIAL_PRICE_BY_SCALE_FOR_ROUTE]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_LIST_OF_SPECIAL_PRICE_BY_SCALE_FOR_ROUTE]
	(
		@CODE_ROUTE VARCHAR(50)
	)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		DECLARE	@SPECIAL_PRICE_LIST TABLE
			(
				[SPECIAL_PRICE_LIST_ID] INT
				,UNIQUE ([SPECIAL_PRICE_LIST_ID])
			);
	--
		INSERT	INTO @SPECIAL_PRICE_LIST
				(
					[SPECIAL_PRICE_LIST_ID]
				)
		SELECT
			[SPL].[SPECIAL_PRICE_LIST_ID]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST] [SPL]
		WHERE
			[SPL].[CODE_ROUTE] = @CODE_ROUTE;
	--
		SELECT DISTINCT
			[SPLBS].[SPECIAL_PRICE_LIST_ID]
			,[SPLBS].[CODE_SKU]
			,[SPLBS].[PACK_UNIT]
			,[SPLBS].[LOW_LIMIT]
			,[SPLBS].[HIGH_LIMIT]
			,[SPLBS].[SPECIAL_PRICE]
			,[SPLBS].[PROMO_ID]
			,[SPLBS].[PROMO_NAME]
			,[SPLBS].[PROMO_TYPE]
			,[SPLBS].[FREQUENCY]
			,[SPLBS].[APPLY_DISCOUNT]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE] AS [SPLBS]
		INNER JOIN @SPECIAL_PRICE_LIST [SPL]
		ON	([SPL].[SPECIAL_PRICE_LIST_ID] = [SPLBS].[SPECIAL_PRICE_LIST_ID])
		WHERE
			[SPLBS].[SPECIAL_PRICE_LIST_ID] > 0;
	END;
