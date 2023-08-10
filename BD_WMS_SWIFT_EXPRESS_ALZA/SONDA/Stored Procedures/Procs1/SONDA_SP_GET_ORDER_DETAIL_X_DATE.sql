-- =============================================
-- Autor:				Jose Roberto
-- Fecha de Creacion: 	13-11-2015
-- Description:			Obtine todas las ventas entre un rango de fechas

/*
-- Ejemplo de Ejecucion:
	exec [SONDA].[SONDA_SP_GET_ORDER_DETAIL_X_DATE] @POSTED_DATETIME="2004-05-23T14:25:10" CLOSED_ROUTE_DATETIME="2004-05-23T14:25:10"
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_ORDER_DETAIL_X_DATE 
@POSTED_DATETIME DATETIME,
@CLOSED_ROUTE_DATETIME DATETIME
AS

Select * 
from [SONDA].[SONDA_SALES_ORDER_DETAIL] as D ,[SONDA].[SONDA_SALES_ORDER_HEADER] as E
where D.SALES_ORDER_ID=E.SALES_ORDER_ID 
and E.POSTED_DATETIME Between @POSTED_DATETIME AND @CLOSED_ROUTE_DATETIME
AND E.IS_READY_TO_SEND=1
