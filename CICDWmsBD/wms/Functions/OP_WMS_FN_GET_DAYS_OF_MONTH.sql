-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Jan-17 @ A-Team Sprint Balder 
-- Description:			    Funcion que obtiene la cantidad de dias del mes

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_MONTH]('20160120 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_MONTH]('20160220 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_MONTH]('20170220 00:00:00.000')
		--
		SELECT [wms].[OP_WMS_FN_GET_DAYS_OF_MONTH]('20160420 00:00:00.000')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_DAYS_OF_MONTH]
(
	@DATE DATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @DAYS INT
	--
	SELECT @DAYS = DATEPART(DAY,[wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH](@DATE))
	--
	RETURN @DAYS
END