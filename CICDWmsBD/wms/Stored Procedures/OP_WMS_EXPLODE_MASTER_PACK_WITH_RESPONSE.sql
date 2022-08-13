-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/18/2018 @ NEXUS-Team Sprint Jumanji 
-- Description:			Ejecuta el SP OP_WMS_EXPLODE_MASTER_PACK y devuelve un objeto operacion.

-- Modificacion 5/30/2018 @ GForce-Team Sprint Dinosaurio
-- marvin.solares
-- Se modifica el state error para uso en translate para mostrar mensajes de error en version Android

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK_WITH_RESPONSE]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_EXPLODE_MASTER_PACK_WITH_RESPONSE](
	@LICENSE_ID INT,
	@MATERIAL_ID VARCHAR(50),
	@LAST_UPDATE_BY VARCHAR(50),
	@MANUAL_EXPLOTION INT,
	@FROM_HAND_HELD INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] 
			@LICENSE_ID = @LICENSE_ID, -- int
		    @MATERIAL_ID = @MATERIAL_ID, -- varchar(50)
		    @LAST_UPDATE_BY = @LAST_UPDATE_BY, -- varchar(50)
		    @MANUAL_EXPLOTION = @MANUAL_EXPLOTION,
			@FROM_HAND_HELD = @FROM_HAND_HELD-- int
		--
		SELECT 1 AS Resultado
			,'Proceso Exitoso' AS Mensaje
			,1 AS Codigo
			,'' AS DbData
	END TRY
	BEGIN CATCH
		SELECT 
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,ERROR_STATE() AS [Codigo]
			,'' AS [DbData]
	END CATCH;
END
GO

