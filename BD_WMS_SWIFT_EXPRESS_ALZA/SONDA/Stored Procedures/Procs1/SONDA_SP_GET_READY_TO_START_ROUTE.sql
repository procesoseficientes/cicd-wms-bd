-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	12-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que prepara el inicio de ruta

-- Modificacion 07-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agrego que genere la venta por multiplo

-- Modificacion 03-May-17 @ A-Team Sprint Hondo
-- alberto.ruiz
-- Se agrega seccion de listas de precios

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-17 @ Team REBORN - Sprint 
-- Description:	   Se agregan validaciones para ver si se generan listas nuevas y validacion si la implementacino es intercompany

-- Modificacion		11/14/2018 @ G-Force Team Sprint Mamut
-- Autor:			diego.as
-- Historia/Bug:	Product Backlog Item 25662: Precios Especiales en el movil
-- Descripcion:		11/14/2018 - Se agrega funcionalidad para generar listas de precios especiales para la ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_READY_TO_START_ROUTE]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_READY_TO_START_ROUTE]
	(
		@CODE_ROUTE VARCHAR(50)
		,@CALLED_FROM_PREPROCESS INT = 0
	)
AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE
			@GENERATE_TRADE_AGREEMENT_OUTPUT INT
			,@GENERATE_DISCOUNT INT
			,@GENERATE_BONUS INT
			,@GENERATE_SKU_SALES_BY_MULTIPLE INT
			,@MUST_GENERATE_LIST_OF_SPECIAL_PRICE INT = 0;

		EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_TRADE_AGREEMENT] @CODE_ROUTE = @CODE_ROUTE ,
			@GENERATE_TRADE_AGREEMENT = @GENERATE_TRADE_AGREEMENT_OUTPUT OUTPUT;

		EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_BONUS] @CODE_ROUTE = @CODE_ROUTE ,
			@GENERATE_BONUS = @GENERATE_BONUS OUTPUT;

		EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_DISCOUNT] @CODE_ROUTE = @CODE_ROUTE ,
			@GENERATE_DISCOUNT = @GENERATE_DISCOUNT OUTPUT;

		EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_SKU_SALES_BY_MULTIPLE] @CODE_ROUTE = @CODE_ROUTE ,
			@GENERATE_SKU_SALES_BY_MULTIPLE = @GENERATE_SKU_SALES_BY_MULTIPLE OUTPUT;

		EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_SPECIAL_PRICES_BY_SCALE] @CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
			@GENERATE_SPECIAL_PRICES_BY_SCALE = @MUST_GENERATE_LIST_OF_SPECIAL_PRICE OUTPUT; -- int
  

		-- ------------------------------------------------------------------------------------
		-- Genera los descuentos para la ruta
		-- ------------------------------------------------------------------------------------
		IF @GENERATE_TRADE_AGREEMENT_OUTPUT = 1
			OR @GENERATE_DISCOUNT = 1
		BEGIN
			EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_FROM_TRADE_AGREEMENT] @CODE_ROUTE = @CODE_ROUTE;
		END;
		-- ------------------------------------------------------------------------------------
		-- Genera las bonificaciones para la ruta
		-- ------------------------------------------------------------------------------------
		IF @GENERATE_TRADE_AGREEMENT_OUTPUT = 1
			OR @GENERATE_BONUS = 1
		BEGIN
			EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FROM_TRADE_AGREEMENT] @CODE_ROUTE = @CODE_ROUTE;
		END;
		-- ------------------------------------------------------------------------------------
		-- Genera las bonificaciones para la ruta
		-- ------------------------------------------------------------------------------------
		IF @GENERATE_TRADE_AGREEMENT_OUTPUT = 1
			OR @GENERATE_SKU_SALES_BY_MULTIPLE = 1
		BEGIN
			EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_FROM_TRADE_AGREEMENT] @CODE_ROUTE = @CODE_ROUTE;
		END;

		-- ------------------------------------------------------------------------------------
		-- Genera las listas de precios especiales para la ruta
		-- ------------------------------------------------------------------------------------
		IF @GENERATE_TRADE_AGREEMENT_OUTPUT = 1
			OR @MUST_GENERATE_LIST_OF_SPECIAL_PRICE = 1
		BEGIN
			EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_FROM_TRADE_AGREEMENT] @CODE_ROUTE = @CODE_ROUTE;
		END;

		------------------------------------------------------------------------------------
		-- Se valida si la implementacion es INTERCOMPANY y si el SP fue llamado desde el preprocesado
		-- ------------------------------------------------------------------------------------
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[SWIFT_EXPRESS].[SONDA].[SWIFT_PARAMETER] [SP]
					WHERE
						[SP].[GROUP_ID] = 'IMPLEMENTATION'
						AND [SP].[PARAMETER_ID] = 'IS_INTERCOMPANY'
						AND [SP].[VALUE] = '1' )
			AND @CALLED_FROM_PREPROCESS = 0
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Genera los precios para la ruta
			-- ------------------------------------------------------------------------------------
			EXEC [SONDA].[SWIFT_SP_GENERATE_PRICE_LIST_FOR_ROUTE] @CODE_ROUTE = @CODE_ROUTE;

		END;

	END;
