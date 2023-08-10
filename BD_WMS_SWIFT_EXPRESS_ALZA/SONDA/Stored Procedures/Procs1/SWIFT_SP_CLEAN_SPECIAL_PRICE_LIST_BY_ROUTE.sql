-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que limpia la informacion de listas de precios especiales por escala para la ruta que se le envia como parametro		     

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_CLEAN_SPECIAL_PRICE_LIST_BY_ROUTE]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_SPECIAL_PRICE_LIST_BY_ROUTE]
	(
		@CODE_ROUTE VARCHAR(250)
	)
AS
	BEGIN
		SET NOCOUNT ON;
  --
		DECLARE	@SPECIAL_PRICE_LIST TABLE
			(
				[SPECIAL_PRICE_LIST_ID] INT
					NOT NULL UNIQUE ([SPECIAL_PRICE_LIST_ID])
			);

		-- ------------------------------------------------------------------------------------
		-- Obtiene las listas de precios especiales
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @SPECIAL_PRICE_LIST
		SELECT DISTINCT
			[SP].[SPECIAL_PRICE_LIST_ID]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST] AS [SP]
		WHERE
			[SP].[CODE_ROUTE] = @CODE_ROUTE;

		-- ------------------------------------------------------------------------------------
		-- Limpia las tablas
		-- ------------------------------------------------------------------------------------	
		DELETE
			[SPLBC]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_CUSTOMER] AS [SPLBC]
		INNER JOIN @SPECIAL_PRICE_LIST AS [SPL]
		ON	([SPL].[SPECIAL_PRICE_LIST_ID] = [SPLBC].[SPECIAL_PRICE_LIST_ID])
		WHERE
			[SPLBC].[SPECIAL_PRICE_LIST_ID] > 0;
		
  --
		DELETE
			[SPBL]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE] AS [SPBL]
		INNER JOIN @SPECIAL_PRICE_LIST AS [SPL]
		ON	([SPL].[SPECIAL_PRICE_LIST_ID] = [SPBL].[SPECIAL_PRICE_LIST_ID])
		WHERE
			[SPBL].[SPECIAL_PRICE_LIST_ID] > 0;

  --
		DELETE
			[SPL]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST] AS [SPL]
		INNER JOIN @SPECIAL_PRICE_LIST AS [SPLS]
		ON	([SPLS].[SPECIAL_PRICE_LIST_ID] = [SPL].[SPECIAL_PRICE_LIST_ID])
		WHERE
			[SPL].[SPECIAL_PRICE_LIST_ID] > 0;
	END;
