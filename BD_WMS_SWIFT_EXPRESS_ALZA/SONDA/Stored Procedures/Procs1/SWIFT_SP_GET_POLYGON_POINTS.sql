-- =============================================
-- Author:     	hector.gonzalez
-- Create date: 2016-07-19 
-- Description: Obtiene los puntos del poligono

-- Modificacion 30-09-2016 @ A-Team Sprint 2
-- rudi.garcia
-- Se agrego parametro IS_MULTIPOLYGON, para obtener solo los multipoligonos

-- Modificacion 23-Jan-17 @ A-Team Sprint Bankole
					-- alberto.ruiz
					-- Se agrego que limpie la varible @POLYGON_SUB_TYPE cuando es un poligono de ruta

/*
Ejemplo de Ejecucion:
			      EXEC [SONDA].[SWIFT_SP_GET_POLYGON_POINTS] 
					@POLYGON_ID = 7        
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_POLYGON_POINTS (
	@POLYGON_ID INT = NULL
	,@POLYGON_TYPE VARCHAR(250) = NULL
	,@POLYGON_SUB_TYPE VARCHAR(250) = NULL
	,@POLYGON_ID_PARENT INT = NULL
	,@IS_MULTIPOLYGON INT = 0
	,@AVAILABLE INT = 0
) AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT @POLYGON_SUB_TYPE = CASE WHEN @POLYGON_TYPE = 'RUTA' THEN NULL ELSE @POLYGON_SUB_TYPE END
	--
	SELECT
		[spp].[POLYGON_ID]
		,[spp].[POSITION]
		,[spp].[LATITUDE]
		,[spp].[LONGITUDE]
	FROM [SONDA].[SWIFT_POLYGON_POINT] [spp]
	INNER JOIN [SONDA].[SWIFT_POLYGON] [sp] ON (
		[spp].[POLYGON_ID] = [sp].[POLYGON_ID]
	)
	WHERE
		(
			@POLYGON_ID IS NULL
			OR [spp].[POLYGON_ID] = @POLYGON_ID
		)
		AND (
				@POLYGON_TYPE IS NULL
				OR [sp].[POLYGON_TYPE] = @POLYGON_TYPE
			)
		AND (
				@POLYGON_SUB_TYPE IS NULL
				OR [sp].[SUB_TYPE] = @POLYGON_SUB_TYPE
			)
		AND (
				@POLYGON_ID_PARENT IS NULL
				OR [sp].[POLYGON_ID_PARENT] = @POLYGON_ID_PARENT
			);
END
