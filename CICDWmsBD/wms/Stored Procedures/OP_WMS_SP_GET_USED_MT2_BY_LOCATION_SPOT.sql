-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/19/2018 @ REBORN-Team Sprint Ulrich 
-- Description:			obtiene los mt2 usados de la ubicacion de piso enviada

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_USED_MT2_BY_LOCATION_SPOT]
					@LOCATION_SPOT = 'B01-P04-F01-NU'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_USED_MT2_BY_LOCATION_SPOT] (
		@LOCATION_SPOT VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MT2_USED DECIMAL(18, 2) = 0;
	--
	SELECT TOP 1
		@MT2_USED = ISNULL((SELECT
								SUM([USED_MT2])
							FROM
								[wms].[OP_WMS_LICENSES] [L]
							WHERE
								[S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
								AND 0 < (SELECT
											COUNT(*)
											FROM
											[wms].[OP_WMS_INV_X_LICENSE] [IL]
											WHERE
											[L].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [IL].[QTY] > 0)),
							0)
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [S]
	WHERE
		[LOCATION_SPOT] = @LOCATION_SPOT;
	--
	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CAST(@MT2_USED AS VARCHAR) [DbData];
END;