-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-Aug-2018 G-Force@Humano
-- Description:	        Sp que obtiene la ultima licencia generada del despacho.

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181010 GForce@Langosta
-- Description:	        se agrega validacion para que solo tome en cuenta licencias creadas por el operador

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LAST_DISPATCH_LICENSE_GENERATED_BY_WAVE_PICKING] (
		@WAVE_PICKING_ID INT
		,@LOGIN_ID VARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT TOP 1
		ISNULL([L].[LICENSE_ID], 0) AS [LICENSE_ID]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	WHERE
		[L].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [L].[CURRENT_LOCATION] = @LOGIN_ID
	ORDER BY
		[L].[LAST_UPDATED] DESC;

END;