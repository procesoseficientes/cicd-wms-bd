-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	07-12-2015
-- Description:			Valida que cuando el evento sea venta  que el usuario de PREVENTA
--						tenga asociado ORDEN DE VENTA, RESOLUCION y BODEGA.

-- Modificacion			10-06-2016
--						hector.gonzalez
--						Se agrego validacion de existencia de sequencias de documentos de toma de inventario

-- Modificacion			10-10-2016
--						diego.as
--						Se agrego validacion de existencia de sequencias de documentos de Cobro de Factura

--Modificacion 11-04-2016 Sprint 4- TeamA
--            rudi.garcia
--            Se agrego la validacion de ver si vendedor tiene un portafolio asignado y ver si tiene productos.

-- Modificacion 12-Jan-17 @ A-Team Sprint Adeben
-- alberto.ruiz
-- Se agrego validacion si la ruta tiene la regla para asignar un acuerdo comercial a los clientes nuevos y si esta activa si tiene que tener un acuerdo comercial asignado a la ruta

-- Modificacion 28-Feb-17 @ A-Team Sprint Donkor
-- alberto.ruiz
-- Se ajusto para que cuando valida la lista de precios por defecto no sea un bit

-- Modificacion 23-Mar-17 @ A-Team Sprint Fenyang
-- alberto.ruiz
-- Se agrega validacion de parametros de etiqueta

-- Modificacion 26-Aug-17 @ Reborn-Team Sprint Bearbeitung
-- hector.gonzalez
-- Se agrega validacion de Historico de Promociones

-- Modificacion 5/13/2018 @ G-Force - Team Sprint Castor
					-- diego.as
					-- se agrega validacion de secuencia de documentos para cobro de facturas de credito vencidas. 

-- Modificacion			12/4/2018 @ G-Force Team Sprint 
-- Autor:				diego.as
-- Historia/Bug:		Product Backlog Item 23773: Micro Encuestas en Preventa
-- Descripcion:			12/4/2018 - Se agrega validacion de secuencia de documentos para proceso de microencuestas si la ruta tiene asigana por lo menos una microencuesta

/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_VALIDATE_ROUTE] @CODE_ROUTE = 'R011'
				exec [SONDA].[SWIFT_SP_VALIDATE_ROUTE] @CODE_ROUTE = 'JOSE@SONDA'
				exec [SONDA].[SWIFT_SP_VALIDATE_ROUTE] @CODE_ROUTE = 'JOEL@SONDA'
				exec [SONDA].[SWIFT_SP_VALIDATE_ROUTE] @CODE_ROUTE = 'ALBERTO@SONDA'
				exec [SONDA].[SWIFT_SP_VALIDATE_ROUTE] @CODE_ROUTE = 'RUDI@SONDA'				
				exec [SONDA].[SWIFT_SP_VALIDATE_ROUTE] @CODE_ROUTE = '001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_ROUTE]
	@CODE_ROUTE VARCHAR(50)
AS
	BEGIN
		SET NOCOUNT ON;
  --
		DECLARE
			@USER VARCHAR(50)
			,@PResult VARCHAR(250) = ''
			,@RESULT VARCHAR(2000) = ''
			,@PDOC BIT = 0
			,@PWH BIT = 0
			,@SALE_QTY INT = 0
			,@PRESALE_QTY INT = 0
			,@EXIST_PRICE_LIST_DEFAULT VARCHAR(50) = NULL
			,@TAKE_INVENTORY_QTY INT = 0
			,@HAVE_INVENTORY_DOCS BIT = 0
			,@PAYMENT_RULE_ACTIVE INT = 0
			,@SELLER_CODE VARCHAR(50)
			,@CODE_PORTFOLIO VARCHAR(25) = NULL
			,@QTY_SKU_PORTFOLIO INT = 0
			,@HAS_TRADE_AGREEMENT INT = 0
			,@EXISTS_LABEL_GROUP INT = 0
			,@HAVE_DOCUMENT_SEQUENCE_OF_HISTORY_PROMO INT = 0
			,@QTY_SURVEY INT = 0;

  -- -----------------------------------------------
  -- Obtiene tareas y cantidad por tipo
  -- -----------------------------------------------
		SELECT
			[T].[TASK_TYPE]
			,COUNT([TASK_TYPE]) AS [QTY]
		INTO
			[#TASK]
		FROM
			[SONDA].[SWIFT_TASKS] [T]
		INNER JOIN [SONDA].[USERS] [U]
		ON	([T].[ASSIGEND_TO] = [U].[LOGIN])
		WHERE
			[U].[SELLER_ROUTE] = @CODE_ROUTE
			AND [T].[TASK_DATE] = CONVERT(DATE ,GETDATE())
		GROUP BY
			[T].[TASK_TYPE];
  --
		SELECT
			@SALE_QTY = [QTY]
		FROM
			[#TASK] [T]
		WHERE
			[T].[TASK_TYPE] = 'SALE';
  --
		SELECT
			@PRESALE_QTY = [QTY]
		FROM
			[#TASK] [T]
		WHERE
			[T].[TASK_TYPE] = 'PRESALE';
  --
		SELECT
			@TAKE_INVENTORY_QTY = [QTY]
		FROM
			[#TASK] [T]
		WHERE
			[T].[TASK_TYPE] = 'TAKE_INVENTORY';

		SELECT
			@QTY_SURVEY = COUNT(*)
		FROM
			[SONDA].[SWIFT_ASIGNED_QUIZ]
		WHERE
			[ROUTE_CODE] = @CODE_ROUTE;

  -- -----------------------------------------------
  -- Se obtiene el codigo de vendedor de la bodega
  -- -----------------------------------------------
		SELECT TOP 1
			@SELLER_CODE = [U].[RELATED_SELLER]
		FROM
			[SONDA].[USERS] [U]
		WHERE
			[U].[SELLER_ROUTE] = @CODE_ROUTE;

  -- -----------------------------------------------
  -- Obtenemos si vendedor tiene asociado un potafolios
  -- -----------------------------------------------
		SELECT TOP 1
			@CODE_PORTFOLIO = [PS].[CODE_PORTFOLIO]
		FROM
			[SONDA].[SWIFT_PORTFOLIO_BY_SELLER] [PS]
		WHERE
			[PS].[CODE_SELLER] = @SELLER_CODE;

  -- -----------------------------------------------
  -- Validamos si el vendedor tiene un portafolios asociado
  -- -----------------------------------------------
		IF (@CODE_PORTFOLIO IS NOT NULL)
		BEGIN
			SELECT
				@QTY_SKU_PORTFOLIO = COUNT([PS].[CODE_SKU])
			FROM
				[SONDA].[SWIFT_PORTFOLIO_BY_SKU] [PS]
			WHERE
				[PS].[CODE_PORTFOLIO] = @CODE_PORTFOLIO;
    --
			IF (@QTY_SKU_PORTFOLIO = 0)
			BEGIN
				SET @RESULT = 'El portafolio de productos asociado al vendedor no tiene productos.';
			END;
		END;


  -- -----------------------------------------------
  -- Valida si tiene tareas de venta
  -- -----------------------------------------------
		IF (@SALE_QTY > 0)
		BEGIN
			SELECT
				@PDOC = [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_SALE](@CODE_ROUTE);
    --
			IF (@PDOC = 0)
			BEGIN
				SET @RESULT = 'Ruta No Tiene Resolución de Factura por Tareas de Venta Directa';
			END;

			SELECT
				@PWH = [SONDA].[SWIFT_FUNC_VALIDATE_ROUTE_WH_SALE](@CODE_ROUTE);
    --
			IF (@PWH = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Bodega Asignada de Venta Directa';
				END;
				ELSE
				BEGIN
					SET @RESULT = ' Ruta No Tiene Bodega Asignada de Venta Directa';
				END;
			END;
		END;

  -- -----------------------------------------------
  -- Valida si tiene tareas de preventa
  -- -----------------------------------------------
		IF (@PRESALE_QTY > 0)
		BEGIN
			SELECT
				@PDOC = [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_PRESALE](@CODE_ROUTE);
    --
			IF (@PDOC = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Documentos de Ordenes de Venta';
				END;
				ELSE
				BEGIN
					SET @RESULT = 'Ruta No Tiene Documentos de Ordenes de Venta';
				END;
			END;
			SELECT
				@PWH = [SONDA].[SWIFT_FUNC_VALIDATE_ROUTE_WH_PRESALE](@CODE_ROUTE);
    --
			IF (@PWH = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Bodega Asignada de Preventa';
				END;
				ELSE
				BEGIN
					SET @RESULT = 'Ruta No Tiene Bodega Asignada de Preventa';
				END;
			END;
		END;

  -- -----------------------------------------------
  -- Valida si tiene tareas de Toma de Inventario
  -- -----------------------------------------------
		IF (@TAKE_INVENTORY_QTY > 0)
		BEGIN
			SELECT
				@HAVE_INVENTORY_DOCS = [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_TAKE_INVENTORY](@CODE_ROUTE);
    --
			IF (@HAVE_INVENTORY_DOCS = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Documentos de Toma de Inventario';
				END;
				ELSE
				BEGIN
					SET @RESULT = 'Ruta No Tiene Documentos de Toma de Inventario';
				END;
			END;
		END;

  -- -----------------------------------------------
  -- Obtiene Eventos por tipo
  -- -----------------------------------------------
		SELECT
			[E].[TYPE_ACTION]
			,COUNT([TYPE_ACTION]) AS [QTY]
		INTO
			[#EVENT]
		FROM
			[SONDA].[SWIFT_EVENT] [E]
		INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] [RE]
		ON	([E].[EVENT_ID] = [RE].[EVENT_ID])
		INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] [RR]
		ON	([RE].[RULE_ID] = [RR].[RULE_ID])
		WHERE
			[RR].[CODE_ROUTE] = @CODE_ROUTE
			AND [E].[TYPE] = 'agregarCliente'
			AND [E].[ENABLED] = 'Si'
		GROUP BY
			[E].[TYPE_ACTION];
  --
		SELECT
			@SALE_QTY = [QTY]
		FROM
			[#EVENT] [T]
		WHERE
			[T].[TYPE_ACTION] = 'VentaDirecta';
  --
		SELECT
			@PRESALE_QTY = [QTY]
		FROM
			[#EVENT] [T]
		WHERE
			[T].[TYPE_ACTION] = 'Preventa';

  -- -----------------------------------------------
  -- Valida si Tiene  Eventos de Venta
  -- -----------------------------------------------
		IF (@SALE_QTY > 0)--OR CONTAINS(@RESULT,'Ruta No Tiene Resolución de Factura')= 1)
			
		BEGIN
			SELECT
				@PDOC = [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_SALE](@CODE_ROUTE);
    --
			IF (@PDOC = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Resolución de Factura por Tareas de Venta Directa';
				END;
				ELSE
				BEGIN
					SET @RESULT = 'Ruta No Tiene Resolución de Factura por Tareas de Venta Directa';
				END;
			END;
		END;
		SELECT
			@PWH = [SONDA].[SWIFT_FUNC_VALIDATE_ROUTE_WH_SALE](@CODE_ROUTE);
  --
		IF (@PWH = 0)
		BEGIN
			IF (@RESULT != '')
			BEGIN
				SET @RESULT = @RESULT
					+ ', Ruta No Tiene Bodega Asignada de Venta Directa';
			END;
			ELSE
			BEGIN
				SET @RESULT = 'Ruta No Tiene Bodega Asignada de Venta Directa';
			END;
		END;

  -- -----------------------------------------------
  -- Valida si tiene eventos de preventa
  -- -----------------------------------------------
		IF (@PRESALE_QTY > 0)
		BEGIN
			SELECT
				@PDOC = [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_PRESALE](@CODE_ROUTE);
    --
			IF (@PDOC = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Documentos de Ordenes de Venta';
				END;
				ELSE
				BEGIN
					SET @RESULT = 'Ruta No Tiene Documentos de Ordenes de Venta';
				END;
			END;
			SELECT
				@PWH = [SONDA].[SWIFT_FUNC_VALIDATE_ROUTE_WH_PRESALE](@CODE_ROUTE);
    --
			IF (@PWH = 0)
			BEGIN
				IF (@RESULT != '')
				BEGIN
					SET @RESULT = @RESULT
						+ ', Ruta No Tiene Bodega Asignada de Preventa';
				END;
				ELSE
				BEGIN
					SET @RESULT = 'Ruta No Tiene Bodega Asignada de Preventa';
				END;
			END;
		END;

  -- -----------------------------------------------
  -- Valida si tiene Lista de Precios por Default
  -- -----------------------------------------------
		SELECT
			@EXIST_PRICE_LIST_DEFAULT = [SONDA].[SWIFT_FN_GET_PRICE_LIST](NULL);

		IF (@EXIST_PRICE_LIST_DEFAULT IS NULL)
		BEGIN
			IF (@RESULT = '')
			BEGIN
				SET @RESULT = 'Ruta No Tiene Lista De Precios Default Asignada';
			END;
			ELSE
			BEGIN
				SET @RESULT = @RESULT
					+ 'Ruta No Tiene Lista De Precios Default Asignada';
			END;
		END;

  -- ----------------------------------------------------------------------------------------
  -- Valida si tiene activa la regla de cobro de factura Y SI TIENE DOCUMENTOS PARA LA MISMA
  -- ----------------------------------------------------------------------------------------
		SELECT TOP 1
			@PAYMENT_RULE_ACTIVE = 1
		FROM
			[SONDA].[SWIFT_EVENT] AS [E]
		INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] AS [RE]
		ON	([RE].[EVENT_ID] = [E].[EVENT_ID])
		INNER JOIN [SONDA].[SWIFT_RULE] AS [R]
		ON	([R].[RULE_ID] = [RE].[RULE_ID])
		INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] AS [RR]
		ON	([RR].[RULE_ID] = [R].[RULE_ID])
		WHERE
			[RR].[CODE_ROUTE] = @CODE_ROUTE
			AND [E].[TYPE] = 'CobrarOrdenDeVenta'
			AND (
					[E].[ENABLED] = 'SI'
					OR [E].[ENABLED] = 'Si'
				);
  --
		IF (@PAYMENT_RULE_ACTIVE = 1)
		BEGIN
			DECLARE	@HAVE_SEQUENCE INT = 0;
    --
			SELECT
				@HAVE_SEQUENCE = 1
			FROM
				[SONDA].[SWIFT_DOCUMENT_SEQUENCE] AS [DS]
			WHERE
				[DS].[ASSIGNED_TO] = @CODE_ROUTE
				AND [DOC_TYPE] = 'PAYMENT'
				AND ([DS].[CURRENT_DOC] + 1) >= [DS].[DOC_FROM]
				AND ([DS].[CURRENT_DOC] + 1) <= [DS].[DOC_TO];
    --
			IF (@HAVE_SEQUENCE = 0)
			BEGIN
				IF (@RESULT = '')
				BEGIN
					SET @RESULT = 'Ruta No Tiene Documentos para Cobro de Factura';
				END;
				ELSE
				BEGIN
					SET @RESULT = @RESULT
						+ 'Ruta No Tiene Documentos para Cobro de Factura';
				END;
			END;
		END;

  -- ------------------------------------------------------------------------------------
  -- Valida si debe de tener asignado un acuerdo comercial
  -- ------------------------------------------------------------------------------------
		SELECT
			@HAS_TRADE_AGREEMENT = [SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE);
  --
		IF (@HAS_TRADE_AGREEMENT = 0)
		BEGIN
			IF (@RESULT = '')
			BEGIN
				SET @RESULT = 'Ruta No Tiene Acuerdo Comercial Para Clientes Nuevos';
			END;
			ELSE
			BEGIN
				SET @RESULT = @RESULT
					+ 'Ruta No Tiene Acuerdo Comercial Para Clientes Nuevos';
			END;
		END;

  -- ------------------------------------------------------------------------------------
  -- Valida si existen los parametros de etiqutas
  -- ------------------------------------------------------------------------------------
		SELECT
			@EXISTS_LABEL_GROUP = [SONDA].[SWIFT_FN_VALIDATE_EXISTX_GROUP_IN_PARAMETER]('LABEL');
  --
		IF (@EXISTS_LABEL_GROUP = 0)
		BEGIN
			IF (@RESULT = '')
			BEGIN
				SET @RESULT = 'No estan configurados los parametros de etiquetas';
			END;
			ELSE
			BEGIN
				SET @RESULT = @RESULT
					+ 'No estan configurados los parametros de etiquetas';
			END;
		END;

  -- ------------------------------------------------------------------------------------
  -- Valida si la ruta tiene secuencia de documentos de HISTORY_PROMO
  -- ------------------------------------------------------------------------------------
		SELECT
			@HAVE_DOCUMENT_SEQUENCE_OF_HISTORY_PROMO = [SONDA].[SWIFT_FN_VALIDATE_IF_ROUTE_HAVE_DOCUMENT_SEQUENCE_OF_HISTORY_PROMO](@CODE_ROUTE);
  --
		IF (@HAVE_DOCUMENT_SEQUENCE_OF_HISTORY_PROMO = 0)
		BEGIN
			IF (@RESULT = '')
			BEGIN
				SET @RESULT = 'Ruta no tiene Secuencia de Documentos de Historial de Promociones';
			END;
			ELSE
			BEGIN
				SET @RESULT = @RESULT
					+ 'Ruta no tiene Secuencia de Documentos de Historial de Promociones';
			END;
		END;

  -- ----------------------------------------------------------------------------------------------------------------
  -- Valida si la ruta tiene la regla de FacturarAunConFacturasVencidas para que exista una secuencia de documentos
  -- ----------------------------------------------------------------------------------------------------------------
		DECLARE
			@RULE_EXISTS INT = 0
			,@RULE_ENABLED INT = 0
			,@SEQUENCE_EXISTS INT= 0;

		SELECT
			@RULE_EXISTS = 1
			,@RULE_ENABLED = 1
		FROM
			[SONDA].[SWIFT_EVENT] AS [E]
		INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] AS [RE]
		ON	([RE].[EVENT_ID] = [E].[EVENT_ID])
		INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] AS [RR]
		ON	([RR].[RULE_ID] = [RE].[RULE_ID])
		WHERE
			[RR].[CODE_ROUTE] = @CODE_ROUTE
			AND [E].[TYPE] = 'FacturarAunConFacturasVencidas'
			AND [E].[ENABLED] = 'SI';

		IF (
			@RULE_EXISTS = 1
			AND @RULE_ENABLED = 1
			)
		BEGIN
			SELECT
				@SEQUENCE_EXISTS = 1
			FROM
				[SONDA].[SWIFT_DOCUMENT_SEQUENCE]
			WHERE
				[DOC_TYPE] = 'CREDIT_INVOICE_PAYMENT'
				AND [ASSIGNED_TO] = @CODE_ROUTE;
	
			IF (@SEQUENCE_EXISTS = 0)
			BEGIN
				IF (@RESULT = '')
				BEGIN
					SET @RESULT = 'Ruta no tiene Secuencia de Documentos de Pagos de Facturas Vencidas';
				END;
				ELSE
				BEGIN
					SET @RESULT = @RESULT
						+ 'Ruta no tiene Secuencia de Documentos de Pagos de Facturas Vencidas';
				END;
			END;
		END;

		-- -------------------------------------------------------------------------------------------------
		-- Valida si tiene micro encuestas asignadas y si las hay, valida que tenga secuencia de documentos
		-- -------------------------------------------------------------------------------------------------
		
		IF (@QTY_SURVEY > 0)
		BEGIN
			DECLARE	@MICROSURVEY_SEQUECE_EXISTS INT = 0;

			SELECT
				@MICROSURVEY_SEQUECE_EXISTS = COUNT(*)
			FROM
				[SONDA].[SWIFT_DOCUMENT_SEQUENCE] AS [DS]
			WHERE
				[DS].[ASSIGNED_TO] = @CODE_ROUTE;

			IF (@MICROSURVEY_SEQUECE_EXISTS = 0)
			BEGIN
				IF (@RESULT = '')
				BEGIN
					SET @RESULT = 'Ruta no tiene Secuencia de Documentos para Microencuestas';
				END;
				ELSE
				BEGIN
					SET @RESULT = @RESULT
						+ ' Ruta no tiene Secuencia de Documentos para Microencuestas';
				END;
			END;

		END;

  -- ------------------------------------------------------------------------------------
  -- Valida si hay algun resultado sino se manda Exito
  -- ------------------------------------------------------------------------------------
		IF (@RESULT = '')
		BEGIN
			SET @RESULT = 'Exito';--'Validación Exitosa'
		END;
  --
		SELECT
			@RESULT AS [RESULT];
	END;
