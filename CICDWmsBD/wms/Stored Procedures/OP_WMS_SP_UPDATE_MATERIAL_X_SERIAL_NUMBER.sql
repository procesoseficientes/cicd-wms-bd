-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que actuliza la fecha de vencimiento y lote por material

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_MATERIAL_X_SERIAL_NUMBER]
					@CORRELATIVE = 1
					,@BATCH = 'BATCH 2'
					,@DATE_EXPIRATION = '20171112'
				-- 
				SELECT * FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_MATERIAL_X_SERIAL_NUMBER](
	@CORRELATIVE INT
	,@BATCH VARCHAR(50)
	,@DATE_EXPIRATION DATE
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	UPDATE [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
	SET	
		[BATCH] = @BATCH
		,[DATE_EXPIRATION] = @DATE_EXPIRATION
	WHERE [CORRELATIVE] = @CORRELATIVE
END