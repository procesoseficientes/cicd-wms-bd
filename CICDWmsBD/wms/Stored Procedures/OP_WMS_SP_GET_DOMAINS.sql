-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		24-Jan-18 @ Nexus Team Sprint @KirbysAdventure
-- Description:			    Se crea SP que consulta los dominios para una aplicación

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_DOMAINS]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DOMAINS]
AS
BEGIN
    SET NOCOUNT ON;
	--
	SELECT [ID]
			,[DOMAIN]
			,[USER]
			,[PASSWORD]
			,[SERVER]
			,[PORT]
			,[CREATED_AT]
			,[UPDATED_AT] FROM [dbo].[OP_WMS_DOMAINS]

	END