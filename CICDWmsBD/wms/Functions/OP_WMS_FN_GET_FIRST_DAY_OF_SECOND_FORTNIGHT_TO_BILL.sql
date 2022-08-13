-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint Balder 
-- Description:			    Funcion que obtiene el primer dia de la segunda quincena

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_SECOND_FORTNIGHT_TO_BILL]('20160120 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_SECOND_FORTNIGHT_TO_BILL]('20160220 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_SECOND_FORTNIGHT_TO_BILL]('20160420 00:00:00.000')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_SECOND_FORTNIGHT_TO_BILL]
(
	@DATE DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @FIRST_DAY DATETIME
	--
	SELECT @FIRST_DAY = DATEADD(mm, DATEDIFF(mm,0,@DATE), 16)
	--
	RETURN @FIRST_DAY
END