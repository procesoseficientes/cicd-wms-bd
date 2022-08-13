-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que borra el empaque

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
				--
				EXEC [wms].[OP_WMS_DELETE_MEASUREMENT_UNIT]
					@MEASUREMENT_UNIT_ID = 3
				-- 
				SELECT * FROM [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_DELETE_MEASUREMENT_UNIT](
	@MEASUREMENT_UNIT_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
		WHERE [MEASUREMENT_UNIT_ID] = @MEASUREMENT_UNIT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END