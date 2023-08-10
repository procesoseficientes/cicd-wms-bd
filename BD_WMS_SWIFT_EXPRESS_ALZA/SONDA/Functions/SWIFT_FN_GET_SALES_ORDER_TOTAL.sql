-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/2/2018 @ GFORCE-Team Sprint Elefante
-- Description:			    Calcula el total con todos sus descuentos

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL](51167)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL] (@SALES_ORDER_ID INT)
RETURNS NUMERIC(18, 6)
AS
BEGIN
    DECLARE @DETAIL TABLE
        (
         [SKU] VARCHAR(25)
        ,[LINE_SEQ] INT
        ,[TOTAL] NUMERIC(18, 6)
        ,[DISCOUNT_BY_FAMILY] NUMERIC(18, 6)
        ,[DISCOUNT_BY_GENERAL_AMOUNT] NUMERIC(18, 6)
        ,[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE] NUMERIC(18, 6)
        );
	--
    DECLARE
        @RETURN NUMERIC(18, 6) = 0
       ,@HEADER_DISCOUNT NUMERIC(18, 6) = 0
       ,@DETAIL_TOTAL NUMERIC(18, 6);
	-- ------------------------------------------------------------------------------------
	-- Obtiene el descuento del encabezado
	-- ------------------------------------------------------------------------------------
    SELECT
        @HEADER_DISCOUNT = [DISCOUNT_BY_GENERAL_AMOUNT]
    FROM
        [SONDA].[SONDA_SALES_ORDER_HEADER]
    WHERE
        [SALES_ORDER_ID] = @SALES_ORDER_ID;

	-- ------------------------------------------------------------------------------------
	-- Obtiene los totales y los descuentos y los inserta en una tabla temporal
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @DETAIL
    SELECT
        [SKU]
       ,[LINE_SEQ]
       ,[QTY] * [PRICE]
       ,CASE WHEN [TYPE_OF_DISCOUNT_BY_FAMILY] = 'PERCENTAGE'
             THEN ([QTY] * [PRICE]) * ([DISCOUNT_BY_FAMILY] / 100)
             ELSE [DISCOUNT_BY_FAMILY]
        END [DISCOUNT_BY_FAMILY]
       ,CASE WHEN [TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT] = 'PERCENTAGE'
             THEN ([QTY] * [PRICE]) * ([DISCOUNT_BY_GENERAL_AMOUNT] / 100)
             ELSE [DISCOUNT_BY_GENERAL_AMOUNT]
        END [DISCOUNT_BY_GENERAL_AMOUNT]
       ,CASE WHEN [TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE] = 'PERCENTAGE'
             THEN ([QTY] * [PRICE]) * ([DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
                                       / 100)
             ELSE [DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
        END [DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
    FROM
        [SONDA].[SONDA_SALES_ORDER_DETAIL]
    WHERE
        [SALES_ORDER_ID] = @SALES_ORDER_ID;
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el total del detalle en base a los valores insertados en la tabla temporal
	-- ------------------------------------------------------------------------------------
    SELECT
        @DETAIL_TOTAL = SUM([TOTAL]) - SUM([DISCOUNT_BY_FAMILY])
        - SUM([DISCOUNT_BY_GENERAL_AMOUNT])
        - SUM([DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE])
    FROM
        @DETAIL;

	-- ------------------------------------------------------------------------------------
	-- Aplica el descuento del encabezado al total del detalle
	-- ------------------------------------------------------------------------------------
    SELECT
        @RETURN = @DETAIL_TOTAL - (@DETAIL_TOTAL * (@HEADER_DISCOUNT / 100));

    RETURN @RETURN;

END;
