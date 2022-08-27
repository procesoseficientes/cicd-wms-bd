-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-Sep-17 @ Nexus Team Sprint DuckHunt
-- Description:			SP que Obtiene si existe el producto y esta configurado como master pack

-- Autor:				marvin.solares
-- Fecha de Creacion: 	29-may-18 @ GForce Team Sprint Dinosaurio
-- Description:			Se agrega codigo de error cuando el material no es masterpack

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_IS_MASTER_PACK]
					@MATERIAL = 'C00084/BACASEC'
				--
				EXEC [wms].[OP_WMS_SP_VALIDATE_IS_MASTER_PACK]
					@MATERIAL = 'BACASEC'
				--
				EXEC [wms].[OP_WMS_SP_VALIDATE_IS_MASTER_PACK]
					@MATERIAL = 'VRF002'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_IS_MASTER_PACK](
	@MATERIAL VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@EXIST_AND_IS_MASTER_PACK INT = -1
		,@MATERIAL_ID VARCHAR(75) = ''
	--
	SELECT TOP 1 
		@EXIST_AND_IS_MASTER_PACK = 1
		,@MATERIAL_ID = [M].[MATERIAL_ID] --+ '|' + [M].[CLIENT_OWNER]
	FROM [wms].[OP_WMS_MATERIALS] [M] 
	WHERE ([M].[MATERIAL_ID] = @MATERIAL
		OR [BARCODE_ID] = @MATERIAL
		OR [ALTERNATE_BARCODE] = @MATERIAL)
		AND [M].[IS_MASTER_PACK] = 1
	--
	SELECT
		@EXIST_AND_IS_MASTER_PACK as Resultado
		,CASE 
			WHEN @EXIST_AND_IS_MASTER_PACK = 1 THEN 'Proceso Exitoso'
			ELSE 'No es un material configurado como master pack.'
		END Mensaje
		,CASE 
			WHEN @EXIST_AND_IS_MASTER_PACK = 1 THEN 0
			ELSE 1603
		END Codigo
		,@MATERIAL_ID DbData
END
