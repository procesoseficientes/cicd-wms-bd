-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			SP que elimina la asociacion de clases entre ellas

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM 
				--
				EXEC [wms].[OP_WMS_SP_DEASSOCIATE_CLASS]
					@CLASS_ID = 1
					,@CLASS_ASSOCIATED_ID = 3
				-- 
				SELECT * FROM [wms].[OP_WMS_CLASS_ASSOCIATION]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DEASSOCIATE_CLASS](
	@CLASS_ID INT
	,@CLASS_ASSOCIATED_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE FROM [wms].[OP_WMS_CLASS_ASSOCIATION]
		WHERE [CLASS_ID] = @CLASS_ID
			AND [CLASS_ASSOCIATED_ID] = @CLASS_ASSOCIATED_ID
		--
		
		DELETE FROM [wms].[OP_WMS_CLASS_ASSOCIATION]
		WHERE [CLASS_ASSOCIATED_ID] = @CLASS_ID
			AND [CLASS_ID] = @CLASS_ASSOCIATED_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END