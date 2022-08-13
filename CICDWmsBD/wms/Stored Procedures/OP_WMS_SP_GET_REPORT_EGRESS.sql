-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	29-09-2016
-- Description:			SP para generar el reporte de egresos

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	14-03-2017
-- Description:			    Se agrego GRUPO_REGIMEN

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego bodegas de usuario logueado

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	02-06-2017 Team Ergon SPRINT Sheik
-- Description:			    Se agrego columna [IS_EXTERNAL_INVENTORY]

-- Modificacion 02-Sep-17 @ Nexus Team Sprint ComandAndConquer
					-- alberto.ruiz
					-- Se agrega el numero de solicitud de traslado y bodega destino

-- Modificacion 21-Sep-17 @ Nexus Team Sprint DuckHunt
					-- alberto.ruiz
					-- Se comentan case de cantidad

/*
--	Ejemplo Ejecucion: 
			EXEC [wms].[OP_WMS_SP_GET_REPORT_EGRESS] 
				@FECHA_INICIO = '2017-09-25 00:00:00'
                ,@FECHA_FINAL = '2017-09-26 23:59:59'
                ,@CLIENT_CODE = 'autovanguard|viscosa|motorganica'
                ,@REGIMEN = 'GENERAL'
                ,@LOGIN = 'MCHACON'
 */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_REPORT_EGRESS] (
	@FECHA_INICIO DATETIME
	,@FECHA_FINAL DATETIME
	,@CLIENT_CODE VARCHAR(MAX)
	,@REGIMEN VARCHAR(25) = NULL
	,@LOGIN VARCHAR(25)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@WAREHOUSE_REGIMEN_GENERAL VARCHAR(25) = 'GENERAL'
		,@WAREHOUSE_REGIMEN_FISCAL VARCHAR(25) = 'FISCAL'
		,@PARAM_GROUP VARCHAR(25) = 'REGIMEN'
		,@TIPO VARCHAR(25) = 'EGRESO';
	--
	DECLARE @WAREHOUSE TABLE (
		[WAREHOUSE_ID] VARCHAR(25)
		,[NAME] VARCHAR(50)
		,[COMMENTS] VARCHAR(150)
		,[ERP_WAREHOUSE] VARCHAR(50)
		,[ALLOW_PICKING] NUMERIC
		,[DEFAULT_RECEPTION_LOCATION] VARCHAR(25)
		,[SHUNT_NAME] VARCHAR(25)
		,[WAREHOUSE_WEATHER] VARCHAR(50)
		,[WAREHOUSE_STATUS] INT
		,[IS_3PL_WAREHUESE] INT
		,[WAHREHOUSE_ADDRESS] VARCHAR(250)
		,[GPS_URL] VARCHAR(100)
		,[WAREHOUSE_BY_USER_ID] INT
	);
  
	-- ------------------------------------------------------------------------------------
	-- Obtiene el listado de clientes
	-- ------------------------------------------------------------------------------------
	SELECT [C].[VALUE] [CLIENT_CODE]
	INTO [#CLIENTS]
	FROM [wms].[OP_WMS_FUNC_SPLIT](@CLIENT_CODE, '|') [C];

	-- ------------------------------------------------------------------------------------
	-- Obtiene las bodegas asociadas por usuario
	-- ------------------------------------------------------------------------------------
	INSERT INTO @WAREHOUSE
	EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN;

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[PH].[DOC_ID]
		,[TL].[MATERIAL_ID]
		,[CLP].[CLIENT_NAME] AS [CLIENT_NAME]
		,[PH].[CLIENT_CODE]
		,CASE	
			WHEN [PH].[WAREHOUSE_REGIMEN] = @WAREHOUSE_REGIMEN_GENERAL THEN [VG].[VALOR_UNITARIO] * CASE [M].[SERIAL_NUMBER_REQUESTS] WHEN  1 THEN 1 ELSE [TL].[QUANTITY_ASSIGNED] END
			WHEN [PH].[WAREHOUSE_REGIMEN] = @WAREHOUSE_REGIMEN_FISCAL THEN [VF].[VALOR_UNITARIO] * CASE [M].[SERIAL_NUMBER_REQUESTS] WHEN  1 THEN 1 ELSE [TL].[QUANTITY_ASSIGNED] END	
			ELSE NULL
		END AS [TOTAL]
		,CASE	
			WHEN [PH].[WAREHOUSE_REGIMEN] = @WAREHOUSE_REGIMEN_GENERAL THEN [VG].[VALOR_UNITARIO]
			WHEN [PH].[WAREHOUSE_REGIMEN] = @WAREHOUSE_REGIMEN_FISCAL THEN [VF].[VALOR_UNITARIO]
			ELSE NULL
		END AS [VALOR_UNITARIO]
		,CASE [M].[SERIAL_NUMBER_REQUESTS]
			WHEN  1 THEN 1
			ELSE [TL].[QUANTITY_ASSIGNED]			
		END AS [CANTIDAD]
		,[TL].[MATERIAL_NAME] AS [DESCRIPCION]
		,[PH].[FECHA_DOCUMENTO] AS [FECHA]
		,[PH].[WAREHOUSE_REGIMEN] AS [REGIMEN]
		,[PH].[NUMERO_ORDEN] AS [ORDEN]
		,[PH].[CODIGO_POLIZA] AS [POLIZA]
		,[PD].[LINE_NUMBER]
		,[CLCONS].[CLIENT_NAME] AS [CONSIGNATARIO]
		,[PH].[REGIMEN] AS [REGIMEN_DOCUMENTO]
		,[C].[SPARE1] AS [GRUPO_REGIMEN]
		,CASE [PH].[IS_EXTERNAL_INVENTORY]
			WHEN 1 THEN 'SI'
			ELSE 'NO'
		END AS [IS_EXTERNAL_INVENTORY]
		,ISNULL([PD].[CUSTOMS_AMOUNT], 0) AS [CUSTOMS_AMOUNT]
		,[PD].[IVA]
		,[PD].[DAI]
		,ISNULL([PD].[IVA], 0) + ISNULL([PD].[DAI], 0) AS [IMPUESTO]
		,[TH].[TRANSFER_REQUEST_ID]
		,[TH].[WAREHOUSE_TO]
		,[T].[BATCH]
		,CASE 
			WHEN [T].[BATCH] IS NULL THEN NULL
			WHEN [T].[BATCH] = '' THEN NULL
			ELSE [T].[DATE_EXPIRATION]
			END AS [DATE_EXPIRATION]
		,[T].[VIN]
	FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[CODIGO_POLIZA_TARGET] = [PH].[CODIGO_POLIZA]
	INNER JOIN [wms].[OP_WMS_TRANS] [T] ON(
	    [T].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
		AND [T].[LICENSE_ID] = [TL].[LICENSE_ID_SOURCE]
		AND [T].[MATERIAL_CODE] = [TL].[MATERIAL_ID]
	)
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON(
		[M].[MATERIAL_ID] = [TL].[MATERIAL_ID]
	)
	LEFT JOIN [wms].[OP_WMS_VIEW_VALORIZACION_FISCAL] [VF] ON (
		[TL].[LICENSE_ID_SOURCE] = [VF].[LICENSE_ID]
		AND [VF].[BARCODE_ID] = [TL].[BARCODE_ID]
	)
	LEFT JOIN [wms].[OP_WMS_VIEW_VALORIZACION_ALMGEN] [VG] ON (
		[TL].[LICENSE_ID_SOURCE] = [VG].[LICENSE_ID]
		AND [VG].[BARCODE_ID] = [TL].[BARCODE_ID]
	)
	LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD] ON (
		[PH].[DOC_ID] = [PD].[DOC_ID]
		AND [TL].[LINE_NUMBER_POLIZA_TARGET] = [PD].[LINE_NUMBER]
	)
	LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [CLP] ON [PH].[CLIENT_CODE] = [CLP].[CLIENT_CODE]
	LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [CLCONS] ON [PD].[CLIENT_CODE] = [CLCONS].[CLIENT_CODE]
	LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON (
		[PH].[REGIMEN] = [C].[PARAM_NAME]
		AND [C].[PARAM_GROUP] = @PARAM_GROUP
	)
	INNER JOIN @WAREHOUSE [W] ON [W].[WAREHOUSE_ID] = [TL].[WAREHOUSE_SOURCE]
	INNER JOIN [#CLIENTS] [CL] ON [CL].[CLIENT_CODE] = [TL].[CLIENT_OWNER]
	LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH] ON ([TH].[TRANSFER_REQUEST_ID] = [TL].[TRANSFER_REQUEST_ID])
	WHERE [PH].[FECHA_DOCUMENTO] BETWEEN @FECHA_INICIO AND @FECHA_FINAL
		AND [TL].[IS_COMPLETED] = 1
		AND [PH].[TIPO] = @TIPO
		AND (
				@REGIMEN IS NULL
				OR [TL].[REGIMEN] = @REGIMEN
			)
END;