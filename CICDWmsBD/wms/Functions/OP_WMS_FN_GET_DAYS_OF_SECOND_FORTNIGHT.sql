-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint Balder 
-- Description:			    Funcion que obtiene la cantidad de dias para la segunda quincena

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_SECOND_FORTNIGHT]('20160120 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_SECOND_FORTNIGHT]('20160220 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_SECOND_FORTNIGHT]('20160420 00:00:00.000')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_DAYS_OF_SECOND_FORTNIGHT]
(
	@DATE DATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @DAYS INT
	--
	SELECT @DAYS = (1+DATEDIFF(DAY, DATEADD(mm, DATEDIFF(mm,0,@DATE), 15),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@DATE)+1,0))))
	--
	RETURN @DAYS
END