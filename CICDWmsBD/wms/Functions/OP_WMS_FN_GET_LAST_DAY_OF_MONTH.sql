-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint Balder 
-- Description:			    Funcion que obtiene el ultimo dia del mes

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]('20160120 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]('20160220 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]('20160420 00:00:00.000')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]
(
	@DATE DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @LAST_DAY DATETIME
	--
	SELECT @LAST_DAY = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@DATE)+1,0))
	--
	RETURN @LAST_DAY
END