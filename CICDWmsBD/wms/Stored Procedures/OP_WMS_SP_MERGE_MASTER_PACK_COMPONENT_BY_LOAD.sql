-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Merge para componentes nuevos/existentes.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_MERGE_MASTER_PACK_COMPONENT_BY_LOAD]
					@MASTER_PACK_CODE = 'wms/SKUPRUEBA'
					,@COMPONENT_MATERIAL = 'wms/bbb'
					,@QTY = 15
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MERGE_MASTER_PACK_COMPONENT_BY_LOAD](
	@MASTER_PACK_CODE VARCHAR(50)
	,@COMPONENT_MATERIAL VARCHAR(50)
	,@QTY INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
	    MERGE [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [TRG]
		USING (
			SELECT
				@MASTER_PACK_CODE [MASTER_PACK_CODE]
				,@COMPONENT_MATERIAL [COMPONENT_MATERIAL]
				,@QTY [QTY]
		) [SRC]
		ON (
			[TRG].[MASTER_PACK_CODE] = [SRC].[MASTER_PACK_CODE] 
			AND [TRG].[COMPONENT_MATERIAL] = [SRC].[COMPONENT_MATERIAL]
		)
		WHEN MATCHED THEN
			UPDATE SET
					[TRG].[QTY] = @QTY
		WHEN NOT MATCHED THEN
			INSERT
					(
						[MASTER_PACK_CODE]
						, [COMPONENT_MATERIAL]
						, [QTY]
					)
			VALUES	(
						@MASTER_PACK_CODE
						, @COMPONENT_MATERIAL
						, @QTY
					);
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
	    SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END