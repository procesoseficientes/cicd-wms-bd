-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Nov-17 @ Nexus Team Sprint F-Zero 
-- Description:			SP que borra el detalle de un manifiesto

/*
-- Ejemplo de Ejecucion:
				DECLARE @MANIFEST_HEADER_ID INT = 1121
				--
				SELECT * FROM [wms].[OP_WMS_MANIFEST_DETAIL] WHERE MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID
				--
				EXEC [wms].[OP_WMS_SP_DELETE_MANIFEST_DETAIL]
					@MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID
				-- 
				SELECT * FROM [wms].[OP_WMS_MANIFEST_DETAIL] WHERE MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_MANIFEST_DETAIL](
	@MANIFEST_HEADER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE [P]
		FROM [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [P]
		INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_DETAIL_ID] = [P].[MANIFEST_DETAIL_ID]
		WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		--
		DELETE FROM [wms].[OP_WMS_MANIFEST_DETAIL]
		WHERE [MANIFEST_DETAIL_ID] > 0
			AND [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		--
		SELECT  
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,'' DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo 
	END CATCH
END