-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Nov-17 @ Nexus Team Sprint GTA 
-- Description:			SP que borra 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE]
				--
				EXEC [wms].[OP_WMS_SP_DELETE_MATERIAL_PROPERTY_BY_WAREHOUSE]
					@MATERIAL_PROPERTY_ID = 1
					,@MATERIAL_ID = 'Me_Llega/C00000493'
					,@WAREHOUSE = 'C001'
				-- 
				SELECT * FROM [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_MATERIAL_PROPERTY_BY_WAREHOUSE](
	@MATERIAL_PROPERTY_ID INT
	,@MATERIAL_ID VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE FROM [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE]
		WHERE [MATERIAL_PROPERTY_ID] = @MATERIAL_PROPERTY_ID
			AND [WAREHOUSE_ID] = @WAREHOUSE
			AND [MATERIAL_ID] = @MATERIAL_ID
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
			,'' DbData 
	END CATCH
END