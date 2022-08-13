-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/9/2017 @ A-TEAM Sprint Balder
-- Description:			Trae el numero de linea si el documento tiene acuerdo comercial activo

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	26-Diciembre-2019
-- Description:			Se modifica el query para obtener las lineas de la poliza de la cual se 
--						obtendra el material para el egreso fiscal.
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_AVAILABLE_LINES]
					@DOC_ID = 49019
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_AVAILABLE_LINES] (@DOC_ID INT)
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @TEMP_RESULT_LINES_DETAIL TABLE
	(
		[ID] INT IDENTITY(1, 1)
		,[DOC_ID] NUMERIC(18, 0)
		,[NUMERO_ORDEN] VARCHAR(25)
		,[LICENSE_ID] NUMERIC(18, 0)
		,[MATERIAL_ID] VARCHAR(50)
	);

	INSERT INTO @TEMP_RESULT_LINES_DETAIL
	(
		[DOC_ID]
		,[NUMERO_ORDEN]
		,[LICENSE_ID]
		,[MATERIAL_ID]
	)
	SELECT DISTINCT
		[PH].[DOC_ID]			-- DOC_ID - numeric(18, 0)
		,[PH].[NUMERO_ORDEN]	-- NUMERO_ORDEN - varchar(25)
		,[IL].[LICENSE_ID]		-- LICENSE_ID - numeric(18, 0)
		,[IL].[MATERIAL_ID]		-- MATERIAL_ID - varchar(50)
	FROM	[wms].[OP_WMS_POLIZA_HEADER] [PH]
		INNER JOIN [wms].[OP_WMS_TRANS] [T]
			ON ([T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA])
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
			ON (
				[IL].[LICENSE_ID] = [T].[LICENSE_ID]
				AND [IL].[MATERIAL_ID] = [T].[MATERIAL_CODE]
				AND [IL].[QTY] > 0
				AND [IL].[LOCKED_BY_INTERFACES] = 0
			)
		INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH]
			ON (
				CAST([TH].[ACUERDO_COMERCIAL_ID] AS VARCHAR(50)) = [T].[TERMS_OF_TRADE]
				AND GETDATE()
			BETWEEN [TH].[VALID_FROM] AND [TH].[VALID_TO]
			)
	WHERE [PH].[DOC_ID] = @DOC_ID
		AND [PH].[WAREHOUSE_REGIMEN] = 'FISCAL'
		AND [PH].[TIPO] = 'INGRESO';


	SELECT	[ID] AS [LINEA]
	FROM	@TEMP_RESULT_LINES_DETAIL;

END;