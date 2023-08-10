-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		10/21/2017 @ Reborn-Team Sprint Dache
-- Description:			    Funcion que obtiene el STATUS del manifiesto que recibe como parametro

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FUNC_GET_STATUS_MANIFEST_BY_MANIFEST_ID](1108) STATUS_OF_MANIFEST
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_STATUS_MANIFEST_BY_MANIFEST_ID] (@MANIFEST_ID INT)
RETURNS VARCHAR(50)
AS
	BEGIN
		DECLARE	@STATUS_OF_MANIFEST VARCHAR(50);
		SELECT
			@STATUS_OF_MANIFEST = [M].[STATUS]
		FROM
			[wms].[OP_WMS_MANIFEST_HEADER] AS [M]
		WHERE
			[M].[MANIFEST_HEADER_ID] = @MANIFEST_ID;
		
		RETURN @STATUS_OF_MANIFEST;

	END;
GO
GRANT EXECUTE
    ON OBJECT::[wms].[OP_WMS_FUNC_GET_STATUS_MANIFEST_BY_MANIFEST_ID] TO [Uwms]
    AS [wms];

