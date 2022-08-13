-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	12-May-18 @ G-FORCE Capibara
-- Description:			SP que retorna el listado de querys disponibles
/*
-- Ejemplo de Ejecucion:
				[wms].[OP_WMS_SP_GET_QUERY_LIST]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_QUERY_LIST] (
		@LOGIN VARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[ID]
		,[NAME]
	FROM
		[wms].[OP_WMS_QUERY_LIST]; 
END;

