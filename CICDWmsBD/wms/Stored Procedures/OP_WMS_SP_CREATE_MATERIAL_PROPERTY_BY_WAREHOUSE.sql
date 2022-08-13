-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Nov-17 @ Nexus Team Sprint GTA
-- Description:			SP que agrega la propiedad de un material por bodega
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CREATE_MATERIAL_PROPERTY_BY_WAREHOUSE]
					@MATERIAL_PROPERTY_ID = 1
					,@MATERIAL_ID = 'Me_Llega/C00000493'
					,@WAREHOUSE = 'C001'
					,@VALUE = '0'
					,@LOGIN = 'admin'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_MATERIAL_PROPERTY_BY_WAREHOUSE](
	@MATERIAL_PROPERTY_ID INT
	,@MATERIAL_ID VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
	,@VALUE VARCHAR(250)
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE]
				(
					[MATERIAL_PROPERTY_ID]
					,[WAREHOUSE_ID]
					,[MATERIAL_ID]
					,[VALUE]
					,[CREATED_BY]
					,[CREATED_DATETIME]
					,[LAST_UPDATE_BY]
					,[LAST_UPDATE]
				)
		VALUES
				(
					@MATERIAL_PROPERTY_ID  -- MATERIAL_PROPERTY_ID - int
					,@WAREHOUSE  -- WAREHOUSE_ID - varchar(25)
					,@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
					,@VALUE  -- VALUE - varchar(250)
					,@LOGIN  -- CREATED_BY - varchar(50)
					,GETDATE()  -- CREATED_DATETIME - datetime
					,@LOGIN  -- LAST_UPDATE_BY - varchar(50)
					,GETDATE()  -- LAST_UPDATE - datetime
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,CAST(@ID AS VARCHAR) DbData
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