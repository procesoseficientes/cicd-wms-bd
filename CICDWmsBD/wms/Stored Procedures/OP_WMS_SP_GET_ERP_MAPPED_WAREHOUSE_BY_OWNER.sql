-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	31-Oct-18 @ G-Force Team Sprint Langosta 
-- Description:			SP que obtiene las obdegas de SAP mapeado en configuraciones para el  [PARAM_GROUP] = 'ALMACENES_POR_BODEGA'
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_ERP_MAPPED_WAREHOUSE_BY_OWNER] @OWNER = '1102' -- varchar(50)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ERP_MAPPED_WAREHOUSE_BY_OWNER] (@OWNER VARCHAR(50))
AS
BEGIN
	SET NOCOUNT ON;
	--

	--SELECT
	--	[SPARE2] [ERP_WAREHOUSE]
	--	,[SPARE1] [SWIFT_WAREHOUSE]
	--	,CASE	WHEN [SPARE3] = '' THEN [SPARE2]
	--			ELSE [SPARE3]
	--		END [ERP_WAREHOUSE_NAME]
	--FROM
	--	[wms].[OP_WMS_CONFIGURATIONS]
	--WHERE
	--	[PARAM_GROUP] = 'ALMACENES_POR_BODEGA'
	--	AND [TEXT_VALUE] = @OWNER
	--	AND LEN([SPARE2]) > 0;

		SELECT  [ERP_WAREHOUSE], [WAREHOUSE_ID] [SWIFT_WAREHOUSE],  [NAME] [ERP_WAREHOUSE_NAME]  FROM [wms].[OP_WMS_WAREHOUSES]
	
END;