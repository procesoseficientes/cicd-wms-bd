﻿-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-03-16 @ Team ERGON - Sprint V-ERGON 
-- Description:	 Se crea procedimiento para hacer commit del inventario de una orden de venta. 




/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SONDA_SP_COMMIT_INVENTORY_BY_SALES_ORDER_ID] @SALE_ORDER_ID = 

  SELECT * FROM [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE] [C] WHERE C.CODE_SKU IN ('100003'
,'100007'
, '100012'
,'100018') AND C.CODE_WAREHOUSE = 'C001' 

   SELECT * FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [SH]
  INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] [SD]
    ON [SH].[SALES_ORDER_ID] = [SD].[SALES_ORDER_ID] 

  WHERE SH.SALES_ORDER_ID = 36954
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_COMMIT_INVENTORY_BY_SALES_ORDER_ID] (@SALE_ORDER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  UPDATE [C]
  SET [C].[IS_COMITED] = [C].[IS_COMITED] + [SD].[QTY]
  FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [SH]
  INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] [SD]
    ON [SH].[SALES_ORDER_ID] = [SD].[SALES_ORDER_ID]
  INNER JOIN [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE] [C]
    ON [C].[CODE_WAREHOUSE] = [SH].[WAREHOUSE]
    AND [C].[CODE_SKU] = [SD].[SKU]
  WHERE [SH].[SALES_ORDER_ID] = @SALE_ORDER_ID
END