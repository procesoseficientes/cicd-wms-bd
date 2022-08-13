-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-Jul-17 @ Nexus TEAM Sprint AgeOfEmpires
-- Description:			SP que obtiene las polizas fiscales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_POLIZA_FISCAL_ENTRY]
					@TYPE = 'INGRESO'
				--
				EXEC [wms].[OP_WMS_GET_POLIZA_FISCAL_ENTRY]
					@TYPE = 'DETALLE_INGRESO'
				--
				EXEC [wms].[OP_WMS_GET_POLIZA_FISCAL_ENTRY]
					@TYPE = 'EGRESO'
				--
				EXEC [wms].[OP_WMS_GET_POLIZA_FISCAL_ENTRY]
					@TYPE = 'DETALLE_EGRESO'
				--
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_POLIZA_FISCAL_ENTRY] (
	@TYPE VARCHAR(50)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@QUERY NVARCHAR(4000) = ''
		,@TIPO VARCHAR(25)
		,@REGIMEN VARCHAR(25);
	--
	SELECT 
		@REGIMEN = 'FISCAL'
		,@TIPO = CASE @TYPE
			WHEN 'INGRESO' THEN 'INGRESO'
			WHEN 'DETALLE_INGRESO' THEN 'INGRESO'
			WHEN 'EGRESO' THEN 'EGRESO'
			WHEN 'DETALLE_EGRESO' THEN 'EGRESO'
		END
		,@QUERY = CASE @TYPE
			WHEN 'INGRESO' THEN N'SELECT
									[PH].[REGIMEN]
									,[PH].[NUMERO_ORDEN]
									,[PH].[NUMERO_DUA]
									,[PH].[CODIGO_POLIZA]
									,[PH].[DOC_ID] [DOCUMENTO]
									,[PH].[FECHA_DOCUMENTO]
									,[CL].[CLIENT_NAME] [NOMBRE_CLIENTE]
									,[PH].[STATUS] [ESTADO]
									,[wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]([PH].[REGIMEN]) [DIAS_REGIMEN]
									,DATEDIFF(DAY,GETDATE(),[wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])) [DIAS_PARA_VENCER]
									,[wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA]) [FECHA_VENCIMIENTO]
									,CASE 
										WHEN DATEDIFF(DAY,GETDATE(),[wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])) > 0 THEN ''Libre''
										ELSE ''Bloqueado''
									END [ESTADO_REGIMEN]
								FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
								LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [CL] ON ([CL].[CLIENT_CODE] = [PH].[CLIENT_CODE])
								WHERE [PH].[DOC_ID] > 0
									AND [PH].[TIPO] = @TIPO
									AND [PH].[WAREHOUSE_REGIMEN] = @REGIMEN;'

			WHEN 'DETALLE_INGRESO' THEN N'SELECT
											[PD].[DOC_ID] [DOCUMENTO]
											,[PD].[LINE_NUMBER] [LINEA]
											,[PD].[SKU_DESCRIPTION] [DESCRIPCION]
											,ISNULL([TT].[DESCRIPCION],''Sin Acuerdo comercial'') [ACUERDO_COMERCIAL]
											,[PD].[BULTOS]
											,[PD].[QTY] [CANTIDAD]
											,[PD].[CUSTOMS_AMOUNT] [VALOR_ADUANA]
											,[PD].[DAI]
											,[PD].[IVA]
											,[PD].[MISC_TAXES] [IMPTOS_VARIOS]
											,([PD].[CUSTOMS_AMOUNT] + [PD].[DAI] + [PD].[IVA] + [PD].[MISC_TAXES]) [TOTAL]
										FROM [wms].[OP_WMS_POLIZA_DETAIL] [PD]
										INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([PH].[DOC_ID] = [PD].[DOC_ID])
										LEFT JOIN [wms].[OP_WMS_VIEW_CUSTOMER_TERMS_OF_TRADE] [TT] ON (
											[TT].[ACUERDO_COMERCIAL] = [PH].[ACUERDO_COMERCIAL]
											AND [TT].[CLIENT_CODE] = [PH].[CLIENT_CODE]
										)
										WHERE [PH].[DOC_ID] > 0 
											AND [PH].[TIPO] = @TIPO
											AND [PH].[WAREHOUSE_REGIMEN] = @REGIMEN;'
			WHEN 'EGRESO' THEN N'SELECT DISTINCT
									[PH].[NUMERO_ORDEN]
									,[PH].[NUMERO_DUA]
									,[PH].[CODIGO_POLIZA]
									,[PH].[DOC_ID] [DOCUMENTO]
									,[PH].[ACUERDO_COMERCIAL]
									,[PH].[FECHA_DOCUMENTO]
									,[PD].[CODIGO_POLIZA_ORIGEN] [POLIZA_ORIGEN]
									,[PD].[ORIGIN_DOC_ID] [DOCUMENTO_ORIGEN]
									,[PH].[STATUS] [ESTADO]
									,CONVERT(VARCHAR, [PH].[DOC_ID]) + CONVERT(VARCHAR, [PD].[ORIGIN_DOC_ID]) [LLAVE]
									,[wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]([PH].[REGIMEN]) [DIAS_REGIMEN]
									,DATEDIFF(DAY,GETDATE(),[wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])) [DIAS_PARA_VENCER]
									,[wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA]) [FECHA_VENCIMIENTO]
									,CASE 
										WHEN DATEDIFF(DAY,GETDATE(),[wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])) > 0 THEN ''Libre''
										ELSE ''Bloqueado''
									END [ESTADO_REGIMEN]
								FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
								LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD] ON [PH].[DOC_ID] = [PD].[DOC_ID]
								WHERE [PH].[DOC_ID] > 0 
									AND [PH].[TIPO] = @TIPO
									AND [PH].[WAREHOUSE_REGIMEN] = @REGIMEN
									AND [PD].[ORIGIN_DOC_ID] > 0;'
			WHEN 'DETALLE_EGRESO' THEN N'SELECT
											[PD].[DOC_ID] [DOCUMENTO]
											,[PD].[LINE_NUMBER] [LINEA]
											,[PD].[SKU_DESCRIPTION] [DESCRIPCION]
											,ISNULL([TT].[DESCRIPCION],''Sin Acuerdo comercial'') [ACUERDO_COMERCIAL]
											,[PD].[BULTOS]
											,[PD].[QTY] [CANTIDAD]
											,[PD].[CUSTOMS_AMOUNT] [VALOR_ADUANA]
											,[PD].[DAI]
											,[PD].[IVA]
											,[PD].[MISC_TAXES] [IMPTOS_VARIOS]
											,([PD].[CUSTOMS_AMOUNT] + [PD].[DAI] + [PD].[IVA] + [PD].[MISC_TAXES]) [TOTAL]
											,[PD].[ORIGIN_LINE_NUMBER] [LINEA_ORIGEN]
											,[PD].[CODIGO_POLIZA_ORIGEN] [POLIZA_ORIGEN]
											,CONVERT(VARCHAR, [PD].[DOC_ID]) + CONVERT(VARCHAR, [PD].[ORIGIN_DOC_ID]) [LLAVE]
										FROM [wms].[OP_WMS_POLIZA_DETAIL] [PD]
										INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([PH].[DOC_ID] = [PD].[DOC_ID])
										LEFT JOIN [wms].[OP_WMS_VIEW_CUSTOMER_TERMS_OF_TRADE] [TT] ON (
											[TT].[ACUERDO_COMERCIAL] = [PH].[ACUERDO_COMERCIAL]
											AND [TT].[CLIENT_CODE] = [PH].[CLIENT_CODE]
										)
										WHERE [PH].[DOC_ID] > 0 
											AND [PH].[TIPO] = @TIPO
											AND [PH].[WAREHOUSE_REGIMEN] = @REGIMEN
											AND [PD].[ORIGIN_DOC_ID] > 0; '
		END
		--
		PRINT '--> @QUERY: ' + @QUERY
		--
		EXEC [sys].[sp_executesql] @QUERY,N'@TIPO VARCHAR(25),@REGIMEN VARCHAR(25)',@TIPO = @TIPO, @REGIMEN = @REGIMEN
END