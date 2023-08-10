-- =============================================
-- Author:     	hector.gonzalez
-- Create date: 2016-07-19 
-- Description: Obtiene los datos de los poligonos por tipo

-- Modificacion 21-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrega el parametro IS_MULTISELLER

/*
Ejemplo de Ejecucion:
			      EXEC [SONDA].[SWIFT_SP_GET_POLYGONS_BY_TYPE] 
					@POLYGON_TYPE = 'SECTOR'
					,@POLYGON_ID_PARENT = NULL
					,@POLYGON_ID = NULL
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_POLYGONS_BY_TYPE] (
	@POLYGON_TYPE VARCHAR(250)
	,@POLYGON_ID_PARENT VARCHAR(250) = NULL
	,@POLYGON_ID INT = NULL
	,@POLYGON_SUB_TYPE VARCHAR(250) = NULL
	,@IS_MULTISELLER INT = 0
) AS
BEGIN
  --
	SELECT
		[P1].[POLYGON_ID]
		,[P1].[POLYGON_NAME]
		,[P1].[POLYGON_DESCRIPTION]
		,[P1].[COMMENT]
		,[P1].[LAST_UPDATE_BY]
		,[P1].[LAST_UPDATE_DATETIME]
		,[P1].[POLYGON_ID_PARENT]
		,[P1].[POLYGON_TYPE]
		,[P1].[SUB_TYPE]
		,[P2].[POLYGON_NAME] AS [POLYGON_NAME_PARENT]
	FROM [SONDA].[SWIFT_POLYGON] [P1]
	LEFT JOIN [SONDA].[SWIFT_POLYGON] [P2] ON ([P1].[POLYGON_ID_PARENT] = [P2].[POLYGON_ID])
	WHERE
		(
			@POLYGON_TYPE IS NULL
			OR [P1].[POLYGON_TYPE] = @POLYGON_TYPE
		)
		AND (
				@POLYGON_ID_PARENT IS NULL
				OR [P1].[POLYGON_ID_PARENT] = @POLYGON_ID_PARENT
			)
		AND (
				@POLYGON_ID IS NULL
				OR [P1].[POLYGON_ID] = @POLYGON_ID
			)
		AND (
				@POLYGON_SUB_TYPE IS NULL
				OR [P1].[SUB_TYPE] = @POLYGON_SUB_TYPE
			)
		AND [P1].[IS_MULTISELLER] = @IS_MULTISELLER;
END;
