-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que limpia los clientes duplicados en los listados de precios especiales generados para la ruta que recibe como parametro

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_SPECIAL_PRICE_LIST_BY_ROUTE]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_SPECIAL_PRICE_LIST_BY_ROUTE]
	(
		@CODE_ROUTE VARCHAR(250)
	)
AS
	BEGIN
		SET NOCOUNT ON;

		-- ------------------------------------------------------------------------------------
		-- Obtiene valores iniciales
		-- ------------------------------------------------------------------------------------
		DECLARE	@CUSTOMER TABLE
			(
				[ID] INT IDENTITY(1 ,1)
							NOT NULL
				,[CODE_CUSTOMER] VARCHAR(50) NOT NULL
				,UNIQUE ([CODE_CUSTOMER])
			);
		--
		DECLARE	@SELLER_CODE NVARCHAR(155);
		--
		SELECT
			@SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE);
	
		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes a eliminar
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @CUSTOMER
				(
					[CODE_CUSTOMER]
				)
		SELECT
			[DLC].[CODE_CUSTOMER]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_CUSTOMER] [DLC]
		INNER JOIN [SONDA].[SWIFT_SPECIAL_PRICE_LIST] [DL]
		ON	([DL].[SPECIAL_PRICE_LIST_ID] = [DLC].[SPECIAL_PRICE_LIST_ID])
		WHERE
			[DL].[CODE_ROUTE] = @CODE_ROUTE
		GROUP BY
			[DLC].[CODE_CUSTOMER]
		HAVING
			COUNT([DLC].[CODE_CUSTOMER]) > 1;

		-- ------------------------------------------------------------------------------------
		-- Elimina los clientes repetidos
		-- ------------------------------------------------------------------------------------
		DELETE
			[DLC]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_CUSTOMER] [DLC]
		INNER JOIN @CUSTOMER [C]
		ON	([DLC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER])
		WHERE
			[C].[ID] > 0;

	END;
