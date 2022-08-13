-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Nov-17 @ Nexus Team Sprint GTA
-- Description:			SP que obtiene las opciones de los materiales
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PROPERTIES_OF_MATERIALS]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PROPERTIES_OF_MATERIALS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[M].[MATERIAL_PROPERTY_ID]
		,[M].[NAME]
		,[M].[DATA_TYPE]
		,[M].[DESCRIPTION]
	FROM [wms].[OP_WMS_MATERIAL_PROPERTY] [M]
	WHERE [M].[MATERIAL_PROPERTY_ID] > 0
END