-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-Jan-18 @ Nexus Team Sprint Strom
-- Description:			SP que agrega cliente

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CREATE_CLIENT]
					@CLIENT_CODE = 'PRUEBA1'
					,@CLIENT_NAME = 'CLIENTE DE PRUEBA'
					,@IS_ACTIVE = 1
					,@CLIENT_CODE_ERP = NULL
				-- 
				SELECT * FROM [wms].[OP_WMS_CLIENT]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_CLIENT] (
	@CLIENT_CODE VARCHAR(50)
	,@CLIENT_NAME VARCHAR(250)
	,@IS_ACTIVE INT
	,@CLIENT_CODE_ERP VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [wms].[OP_WMS_CLIENT]
				(
					[CLIENT_CODE]
					,[CLIENT_NAME]
					,[IS_ACTIVE]
					,[CLIENT_CODE_ERP]
				)
		VALUES
				(
					@CLIENT_CODE  -- CLIENT_CODE - varchar(50)
					,@CLIENT_NAME  -- CLIENT_NAME - varchar(250)
					,@IS_ACTIVE  -- IS_ACTIVE - int
					,@CLIENT_CODE_ERP  -- CLIENT_CODE_ERP - varchar(50)
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
				WHEN '2627' THEN 'El código de cliente ' + @CLIENT_CODE + ' ya existe'
				ELSE ERROR_MESSAGE() 
			END Mensaje 
			,@@ERROR Codigo 
	END CATCH
END