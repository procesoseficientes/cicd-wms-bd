-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/12/2017 @ NEXUS-Team Sprint HeyYouPikachu!
-- Description:			Elimina detalles del manifiesto de carga cuando ya esta certificado

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_DELETE_MANIFEST_DETAIL_WHEN_ITS_CERTIFIED]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_MANIFEST_DETAIL_WHEN_ITS_CERTIFIED](
	@MANIFEST_HEADER_ID INT
	,@DEMAND_HEADER_ID VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las demandas a eliminar del detalle del manifiesto de carga
		-- ------------------------------------------------------------------------------------
		SELECT [VALUE] [PICKING_DEMAND_HEADER_ID] 
		INTO #DEMAND
		FROM [wms].[OP_WMS_FN_SPLIT](@DEMAND_HEADER_ID, '|')
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene los IDs de manifiesto detalle a eliminar de picking labels x manifest
		-- ------------------------------------------------------------------------------------
		SELECT [MD].[MANIFEST_DETAIL_ID]
		INTO #MANIFEST_DETAIL 
		FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
		INNER JOIN [#DEMAND] [D] ON [D].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID]
		
		-- ------------------------------------------------------------------------------------
		-- Elimina de picking label x manifest utilizando los ids obtenidos anteriormente
		-- ------------------------------------------------------------------------------------
		DELETE [P]
		FROM [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [P]
		INNER JOIN [#MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_DETAIL_ID] = [P].[MANIFEST_DETAIL_ID]

		-- ------------------------------------------------------------------------------------
		-- Elimina de manifiesto detalle
		-- ------------------------------------------------------------------------------------
		DELETE [MD]
		FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
		INNER JOIN [#DEMAND] [D] ON [D].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID]
		WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		
		-- ------------------------------------------------------------------------------------
		-- Envia el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT  
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,'' DbData

	END TRY
	BEGIN CATCH
		SELECT 
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@@error AS [Codigo]
			,'' AS [DbData]
	END CATCH;

END