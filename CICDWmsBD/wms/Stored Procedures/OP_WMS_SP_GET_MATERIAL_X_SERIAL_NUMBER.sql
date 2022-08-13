-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que valida si existe la convinacion material y serie

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	17-Nov-16 @ A-TEAM Sprint BreathOfTheWild 
-- Description:			Se agrego la el parametro "@LICENSE_ID" y la condicion con "[LICENSE_ID]"

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20191118 GForce@Lima
-- Description:			Se agrega la columna STATUS en el conjunto de resultados para poder consultarlo en swift super

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_MATERIAL_X_SERIAL_NUMBER]
					@MATERIAL_ID = 'C00012/CONCLIMON'
					,@SERIAL = 'SERIAL'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIAL_X_SERIAL_NUMBER] (
		@MATERIAL_ID VARCHAR(50)
		,@SERIAL VARCHAR(50) = NULL
		,@LICENSE_ID NUMERIC
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[SSN].[CORRELATIVE]
		,[SSN].[LICENSE_ID]
		,[SSN].[MATERIAL_ID]
		,[SSN].[SERIAL]
		,[SSN].[BATCH]
		,[SSN].[DATE_EXPIRATION]
		,[SSN].[STATUS]
	FROM
		[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [SSN]
	WHERE
		[SSN].[MATERIAL_ID] = @MATERIAL_ID
		AND (
				@SERIAL IS NULL
				OR [SSN].[SERIAL] = @SERIAL
			)
		AND [SSN].[LICENSE_ID] = @LICENSE_ID
		AND [SSN].[STATUS] > 0; 
END;