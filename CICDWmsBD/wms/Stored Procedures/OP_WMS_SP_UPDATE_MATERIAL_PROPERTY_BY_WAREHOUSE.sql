-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Nov-17 @ Nexus Team Sprint GTA 
-- Description:			SP que actualiza 

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_MATERIAL_PROPERTY_BY_WAREHOUSE]
					@MATERIAL_PROPERTY_ID = 1
					,@MATERIAL_ID = 'Me_Llega/C00000493'
					,@WAREHOUSE = 'C001'
					,@VALUE = '1'
					,@LOGIN = 'admin'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_MATERIAL_PROPERTY_BY_WAREHOUSE](
	@MATERIAL_PROPERTY_ID INT
	,@MATERIAL_ID VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
	,@VALUE VARCHAR(250)
	,@LOGIN  VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE]
		SET	
			[VALUE] = @VALUE
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LOGIN
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
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN 'Ya existe una configuracion igual'
				ELSE ERROR_MESSAGE() 
			END Mensaje
			,@@ERROR Codigo
			,'' DbData
	END CATCH
END