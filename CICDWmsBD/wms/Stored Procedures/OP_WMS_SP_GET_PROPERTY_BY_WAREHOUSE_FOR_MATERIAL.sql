-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Nov-17 @ Nexus Team Sprint GTA
-- Description:			SP que obtiene las propiedades por material
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PROPERTY_BY_WAREHOUSE_FOR_MATERIAL]
					@MATERIAL_ID = 'Me_Llega/C00000493'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PROPERTY_BY_WAREHOUSE_FOR_MATERIAL](
	@MATERIAL_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[MPW].[MATERIAL_PROPERTY_ID]
		,[MPW].[WAREHOUSE_ID]
		,[MPW].[MATERIAL_ID]
		,[MPW].[VALUE]
		,CAST([MPO].[TEXT] AS VARCHAR) [TEXT]  
		,[MPW].[CREATED_BY]
		,[MPW].[CREATED_DATETIME]
		,[MPW].[LAST_UPDATE_BY]
		,[MPW].[LAST_UPDATE]
		,[MPW].[MATERIAL_PROPERTY_ID] [MODIFIED]
	FROM [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [MPW]
	INNER JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_OPTION] [MPO] ON (
		[MPO].[MATERIAL_PROPERTY_ID] = [MPW].[MATERIAL_PROPERTY_ID]
		AND [MPO].[VALUE] = [MPW].[VALUE]
	)
	WHERE [MPW].[MATERIAL_ID] = @MATERIAL_ID
END