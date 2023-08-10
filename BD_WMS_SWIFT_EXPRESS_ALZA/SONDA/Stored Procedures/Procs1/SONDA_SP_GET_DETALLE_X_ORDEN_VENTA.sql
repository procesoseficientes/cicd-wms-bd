-- =============================================
-- Autor:				Jose Roberto
-- Fecha de Creacion: 	13-11-2015
-- Description:			Obtine el detalle para la ordenes de venta por codigo de venta

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SONDA_SP_GET_DETALLE_X_ORDEN_VENTA] @SALES_ORDER_ID = 0001
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_DETALLE_X_ORDEN_VENTA
	@SALES_ORDER_ID INTEGER
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT *
	FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] AS D
	Inner Join [SONDA].[SONDA_SALES_ORDER_HEADER] AS E	on (D.SALES_ORDER_ID = E.SALES_ORDER_ID) 
	where D.SALES_ORDER_ID=@SALES_ORDER_ID
	AND E.IS_READY_TO_SEND=1
END
