-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	12-May-18 @ G-FORCE Team Sprint Capibara
-- Description:			SP que consulta las polizas asignadas a una bodega y a un cliente
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_ACTIVE_INCOME_POLICY] @WAREHOUSE ='CEDI_ZONA_5', @CLIENT_OWNER = 'wms'
				SELECT * FROM [wms].[OP_WMS_POLIZA_HEADER]

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ACTIVE_INCOME_POLICY] (
		@WAREHOUSE VARCHAR(25)
		,@CLIENT_OWNER VARCHAR(25)
		,@REGIMEN VARCHAR(25) = 'GENERAL'
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	
	SELECT
		[H].[DOC_ID]
		,[H].[CODIGO_POLIZA]
		,MAX([H].[FECHA_DOCUMENTO]) [FECHA_DOCUMENTO]
		,MAX([H].[TIPO]) [TIPO]
		,[L].[CLIENT_OWNER]
		,MAX([L].[REGIMEN]) REGIMEN
		, [H].[NUMERO_ORDEN] 
	FROM
		[wms].[OP_WMS_POLIZA_HEADER] [H]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CODIGO_POLIZA] = [H].[CODIGO_POLIZA]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	WHERE
		[IL].[QTY] > 0
		AND [L].[CURRENT_WAREHOUSE] = @WAREHOUSE
		AND [L].[CLIENT_OWNER] = @CLIENT_OWNER
		AND [L].[REGIMEN] = @REGIMEN
		AND [H].[TIPO] = 'INGRESO'
	GROUP BY
		[H].[DOC_ID]
		,[H].[CODIGO_POLIZA]
		,[H].[NUMERO_ORDEN],
		[L].[CLIENT_OWNER];

	
	
END;