-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint  
-- Description:			    

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]('20160110 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]('20160210 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]('20160410 00:00:00.000')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]
(
	@DATE DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @LAST_DAY DATETIME
	--
	SELECT @LAST_DAY = DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(HOUR,23,DATEADD(mm, DATEDIFF(mm,0,@DATE), 14))))
	--
	RETURN @LAST_DAY
END