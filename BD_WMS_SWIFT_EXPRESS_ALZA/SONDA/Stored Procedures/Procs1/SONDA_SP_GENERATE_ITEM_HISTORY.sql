-- =============================================
-- Author:     	hector.gonzalez
-- Create date: 2016-04-06 
-- Description: Genera el listado de productos y la cantidad de cada uno que fue solicitado en la ultima orden de venta por cada 
--              cliente en base a las tareas generadas para cada ruta y se almacena en la tabla SONDA_ITEM_HISTORY
--              correr script 026-HG-20160411-SWIFT_PARAMETER-TB-SWIFT_PARAMETER-SeAgragaronParametros para agregar parametros

-- Modificacion 18-05-2016
-- alberto.ruiz
-- Se agrego columna CODE_PACK_UNIT y se van a excluir los registros que en el detalle de orden de venta tengan la columna CODE_PACK_UNIT como nulo

-- Modificacion 		7/11/2019 @ G-Force Team Sprint ESTOCOLMO
-- Autor: 				diego.as
-- Historia/Bug:		Product Backlog Item 30461: Visualizacion de Ultima fecha y precio de compra
-- Descripcion: 		7/11/2019 - Se modifica SP para que genere el historico para todos los clientes de las ordenes de venta ya que solo generaba las del plan de ruta
--						Se agrega almacenamiento de informacion de descuentos para procesos posteriores segun sea necesario en cada implementacion
--						Se agrega almacenamiento de informacion de monto del documento (enviado desde el movil con todo el proceso de aplicacion de promociones)

/*
Ejemplo de Ejecucion:

            EXEC [SONDA].SONDA_SP_GENERATE_ITEM_HISTORY
			--
			SELECT * FROM [SONDA].[SONDA_ITEM_HISTORY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GENERATE_ITEM_HISTORY]
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @DOC_TYPE VARCHAR(50);

    -- ------------------------------------------------------------------------------------
    -- Limpia la tabla
    -- ------------------------------------------------------------------------------------
    TRUNCATE TABLE [SONDA].[SONDA_ITEM_HISTORY];

    -- ------------------------------------------------------------------------------------
    -- Se obtiene el tipo de orden de venta
    -- ------------------------------------------------------------------------------------
    SELECT @DOC_TYPE = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER', 'DOC_TYPE');

    -- ------------------------------------------------------------------------------------
    -- Obtiene encabezados de la ultima orden de compra de los clientes
    -- ------------------------------------------------------------------------------------
    SELECT [H].[POS_TERMINAL] AS [CODE_ROUTE],
           [H].[CLIENT_ID],
           [H].[REFERENCE_ID],
           [H].[SALES_ORDER_ID],
           [H].[POSTED_DATETIME],
           [H].[TOTAL_AMOUNT_DISPLAY] AS [DOCUMENT_AMOUNT],
           [H].[DISCOUNT_BY_GENERAL_AMOUNT] AS [DISCOUNT_BY_GENERAL_AMOUNT_HEADER],
           ROW_NUMBER() OVER (PARTITION BY [P].[CODE_ROUTE],
                                           [H].[CLIENT_ID]
                              ORDER BY [H].[SALES_ORDER_ID] DESC
                             ) [ORDER]
    INTO [#SALES_ORDER_BY_CUSTOMER]
    FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [H]
        LEFT JOIN [SONDA].[SONDA_ROUTE_PLAN] [P]
            ON ([H].[CLIENT_ID] = [P].[RELATED_CLIENT_CODE])
    WHERE [H].[IS_READY_TO_SEND] = 1;

    -- ------------------------------------------------------------------------------------
    -- Obtiene detalles de ordenes de ventas
    -- ------------------------------------------------------------------------------------
    SELECT [D].[SALES_ORDER_ID],
           [D].[SKU],
           [D].[LINE_SEQ],
           [D].[QTY],
           [D].[PRICE],
           [D].[DISCOUNT],
           [D].[TOTAL_LINE],
           [D].[POSTED_DATETIME],
           [D].[SERIE],
           [D].[SERIE_2],
           [D].[REQUERIES_SERIE],
           [D].[COMBO_REFERENCE],
           [D].[PARENT_SEQ],
           [D].[IS_ACTIVE_ROUTE],
           [D].[CODE_PACK_UNIT],
           [D].[IS_BONUS],
           [D].[LONG],
           [D].[ERP_REFERENCE],
           [D].[POSTED_ERP],
           [D].[POSTED_RESPONSE],
           [D].[IS_POSTED_ERP],
           [D].[ATTEMPTED_WITH_ERROR],
           [D].[INTERFACE_OWNER],
           [D].[DISCOUNT_TYPE],
           [D].[DISCOUNT_BY_FAMILY],
           [D].[DISCOUNT_BY_GENERAL_AMOUNT],
           [D].[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
           [D].[TYPE_OF_DISCOUNT_BY_FAMILY],
           [D].[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT],
           [D].[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
           [D].[BASE_PRICE],
           [D].[CODE_FAMILY],
           [D].[UNIQUE_DISCOUNT_BY_SCALE_APPLIED],
           [D].[DISPLAY_AMOUNT],
           [H].[DISCOUNT_BY_GENERAL_AMOUNT_HEADER]
    INTO [#SALES_ORDER_DETAIL]
    FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] AS [D]
        INNER JOIN [#SALES_ORDER_BY_CUSTOMER] AS [H]
            ON ([H].[SALES_ORDER_ID] = [D].[SALES_ORDER_ID])
    WHERE [H].[SALES_ORDER_ID] > 0;

    --
    SELECT [C].[CODE_ROUTE],
           @DOC_TYPE [DOC_TYPE],
           [C].[CLIENT_ID],
           [C].[REFERENCE_ID],
           [D].[SKU],
           [D].[CODE_PACK_UNIT],
           SUM([D].[QTY]) [QTY],
           MAX([D].[DISCOUNT]) [DISCOUNT],
           MAX([D].[DISCOUNT_TYPE]) [DISCOUNT_TYPE],
           MAX([D].[DISCOUNT_BY_FAMILY]) [DISCOUNT_BY_FAMILY],
           MAX([D].[DISCOUNT_BY_GENERAL_AMOUNT]) [DISCOUNT_BY_GENERAL_AMOUNT],
           MAX([D].[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]) [DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
           MAX([D].[TYPE_OF_DISCOUNT_BY_FAMILY]) [TYPE_OF_DISCOUNT_BY_FAMILY],
           MAX([D].[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT]) [TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT],
           MAX([D].[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]) [TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
           MAX([D].[UNIQUE_DISCOUNT_BY_SCALE_APPLIED]) [UNIQUE_DISCOUNT_BY_SCALE_APPLIED],
           MAX([D].[DISPLAY_AMOUNT]) [DISPLAY_AMOUNT],
           MAX([D].[PRICE]) [PRICE],
           MAX([D].[POSTED_DATETIME]) [POSTED_DATETIME],
           MAX([C].[DOCUMENT_AMOUNT]) [DOCUMENT_AMOUNT],
           MAX([C].[DISCOUNT_BY_GENERAL_AMOUNT_HEADER]) [DISCOUNT_BY_GENERAL_AMOUNT_HEADER]
    INTO [#SALES_ORDER]
    FROM [#SALES_ORDER_BY_CUSTOMER] [C]
        INNER JOIN [#SALES_ORDER_DETAIL] [D]
            ON ([D].[SALES_ORDER_ID] = [C].[SALES_ORDER_ID])
    WHERE [C].[ORDER] = 1
          AND [D].[CODE_PACK_UNIT] IS NOT NULL
    GROUP BY [C].[CODE_ROUTE],
             [C].[CLIENT_ID],
             [C].[REFERENCE_ID],
             [D].[SKU],
             [D].[CODE_PACK_UNIT];

    -- ------------------------------------------------------------------------------------
    -- Inserta las ordenes de venta al item history
    -- ------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SONDA_ITEM_HISTORY]
    (
        [CODE_ROUTE],
        [DOC_TYPE],
        [CODE_CUSTOMER],
        [CODE_SKU],
        [QTY],
        [CODE_PACK_UNIT],
        [DISCOUNT],
        [DISCOUNT_TYPE],
        [DISCOUNT_BY_FAMILY],
        [DISCOUNT_BY_GENERAL_AMOUNT],
        [DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
        [TYPE_OF_DISCOUNT_BY_FAMILY],
        [TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT],
        [TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
        [UNIQUE_DISCOUNT_BY_SCALE_APPLIED],
        [DISPLAY_AMOUNT],
        [BASE_PRICE],
        [SALE_DATE],
        [DOCUMENT_AMOUNT],
        [DISCOUNT_BY_GENERAL_AMOUNT_HEADER]
    )
    SELECT [S].[CODE_ROUTE],
           [S].[DOC_TYPE],
           [S].[CLIENT_ID],
           [S].[SKU],
           [S].[QTY],
           [S].[CODE_PACK_UNIT],
           [S].[DISCOUNT],
           [S].[DISCOUNT_TYPE],
           [S].[DISCOUNT_BY_FAMILY],
           [S].[DISCOUNT_BY_GENERAL_AMOUNT],
           [S].[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
           [S].[TYPE_OF_DISCOUNT_BY_FAMILY],
           [S].[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT],
           [S].[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE],
           [S].[UNIQUE_DISCOUNT_BY_SCALE_APPLIED],
           [S].[DISPLAY_AMOUNT],
           [S].[PRICE],
           [S].[POSTED_DATETIME],
           ISNULL([S].[DOCUMENT_AMOUNT], 0),
           ISNULL([S].[DISCOUNT_BY_GENERAL_AMOUNT_HEADER], 0)
    FROM [#SALES_ORDER] [S];

    -- ------------------------------------------------------------------------------------
    -- Se obtiene el tipo de inventario
    -- ------------------------------------------------------------------------------------
    SELECT @DOC_TYPE = [SONDA].[SWIFT_FN_GET_PARAMETER]('TAKE_INVENTORY', 'DOC_TYPE');

    -- ------------------------------------------------------------------------------------
    -- Obtiene la ultima toma de inventario por cliente
    -- ------------------------------------------------------------------------------------
    SELECT [P].[CODE_ROUTE],
           [H].[CLIENT_ID],
           [H].[TAKE_INVENTORY_ID],
           ROW_NUMBER() OVER (PARTITION BY [P].[CODE_ROUTE],
                                           [H].[CLIENT_ID]
                              ORDER BY [H].[TAKE_INVENTORY_ID] DESC
                             ) [ORDER]
    INTO [#TAKE_INVENTORY_BY_CUSTOMER]
    FROM [SONDA].[SONDA_TAKE_INVENTORY_HEADER] [H]
        INNER JOIN [SONDA].[SONDA_ROUTE_PLAN] [P]
            ON ([H].[CLIENT_ID] = [P].[RELATED_CLIENT_CODE]);
    --
    SELECT [C].[CODE_ROUTE],
           @DOC_TYPE [DOC_TYPE],
           [C].[CLIENT_ID],
           [D].[CODE_SKU],
           [D].[CODE_PACK_UNIT],
           [D].[QTY] [QTY]
    INTO [#TAKE_INVENTORY]
    FROM [#TAKE_INVENTORY_BY_CUSTOMER] [C]
        INNER JOIN [SONDA].[SONDA_TAKE_INVENTORY_HEADER] [H]
            ON ([H].[TAKE_INVENTORY_ID] = [C].[TAKE_INVENTORY_ID])
        INNER JOIN [SONDA].[SONDA_TAKE_INVENTORY_DETAIL] [D]
            ON ([D].[TAKE_INVENTORY_ID] = [H].[TAKE_INVENTORY_ID])
    WHERE [C].[ORDER] = 1
          AND [D].[CODE_PACK_UNIT] IS NOT NULL;

    -- ------------------------------------------------------------------------------------
    -- Inserta las ordenes de venta al item history
    -- ------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SONDA_ITEM_HISTORY]
    (
        [CODE_ROUTE],
        [DOC_TYPE],
        [CODE_CUSTOMER],
        [CODE_SKU],
        [QTY],
        [CODE_PACK_UNIT]
    )
    SELECT [T].[CODE_ROUTE],
           [T].[DOC_TYPE],
           [T].[CLIENT_ID],
           [T].[CODE_SKU],
           [T].[QTY],
           [T].[CODE_PACK_UNIT]
    FROM [#TAKE_INVENTORY] [T];
END;

