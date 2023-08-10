-- =============================================
-- Author:     	hector.gonzalez
-- Create date: 2016-04-08 
-- Description:  Obtiene el listado de la tabla SONDA_ITEM_HISTORY parametro: CODE_ROUTE

-- Modificacion 18-05-2016
-- alberto.ruiz
-- Se agrego columna CODE_PACK_UNIT

-- Modificacion 		7/15/2019 @ G-Force Team Sprint Estocolmo
-- Autor: 				diego.as
-- Historia/Bug:		Product Backlog Item 30461: Visualizacion de Ultima fecha y precio de compra
-- Descripcion: 		7/15/2019 - Se agrega envio de columnas [LAST_PRICE] y [SALE_DATE]

/*
Ejemplo de Ejecucion:

            EXEC [SONDA].[SONDA_SP_GET_ITEM_HISTORY_BY_ROUTE]  
				@CODE_ROUTE = RUDI@SONDA
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_ITEM_HISTORY_BY_ROUTE] @CODE_ROUTE VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT [H].[CODE_ROUTE],
           [H].[DOC_TYPE],
           [H].[CODE_CUSTOMER],
           [H].[CODE_SKU],
           [H].[QTY],
           [H].[CODE_PACK_UNIT],
           CASE
               WHEN [H].[DISPLAY_AMOUNT] IS NULL THEN
                   [H].[BASE_PRICE]
               WHEN [H].[DISPLAY_AMOUNT] = 0 THEN
                   [H].[BASE_PRICE]
               ELSE
                   CAST(([H].[DISPLAY_AMOUNT] / [H].[QTY]) AS NUMERIC(18, 6))
           END AS [LAST_PRICE],
           CAST([H].[SALE_DATE] AS DATE) [SALE_DATE]
    FROM [SONDA].[SONDA_ITEM_HISTORY] [H]
    WHERE [H].[CODE_ROUTE] = @CODE_ROUTE;
END;

