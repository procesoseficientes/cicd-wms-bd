-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que elimina la serie del material

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] WHERE [CORRELATIVE] = 2
				--
				EXEC [wms].[OP_WMS_SP_DELETE_MATERIAL_X_SERIAL_NUMBER]
					@CORRELATIVE = 2
				-- 
				SELECT * FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] WHERE [CORRELATIVE] = 2
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_MATERIAL_X_SERIAL_NUMBER] (@CORRELATIVE INT)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
		
        DELETE FROM
            [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
        WHERE
            [CORRELATIVE] = @CORRELATIVE;
	
        SELECT
            1 AS Resultado
           ,'Proceso Exitoso' Mensaje
           ,0 Codigo
           ,'' DbData;
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() AS [Mensaje]
           ,@@error AS [Codigo]
           ,'' AS [DbData];
    END CATCH;
	--
END;