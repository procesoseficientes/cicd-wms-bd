-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt
-- Description:			Asocia las clases entre ellas, de ambos lados A a B y B a A.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_ASSOCIATE_CLASS] 
					@CLASS_ID = 1, -- int
					@CLASS_ASSOCIATED_ID = 3 -- int
				-- 
				SELECT * FROM [wms].[OP_WMS_CLASS_ASSOCIATION]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ASSOCIATE_CLASS](
	@CLASS_ID INT
	,@CLASS_ASSOCIATED_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		--
		INSERT INTO [wms].[OP_WMS_CLASS_ASSOCIATION]
				(
					[CLASS_ID]
					,[CLASS_ASSOCIATED_ID]
				)
		VALUES
				(
					@CLASS_ID  -- CLASS_ID - int
					,@CLASS_ASSOCIATED_ID  -- CLASS_ASSOCIATED_ID - int
				)
		--
		INSERT INTO [wms].[OP_WMS_CLASS_ASSOCIATION]
				(
					[CLASS_ID]
					,[CLASS_ASSOCIATED_ID]
				)
		VALUES
				(
					@CLASS_ASSOCIATED_ID  -- CLASS_ID - int
					,@CLASS_ID  -- CLASS_ASSOCIATED_ID - int
				)
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(1 AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'La clase no existe.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END