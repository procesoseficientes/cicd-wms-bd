-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		12-07-2016 @ Sprint  ζ
-- Description:			    SP que obtiene el reporte consolidado de carga por operador

/*
-- Ejemplo de Ejecucion:
		--
		EXEC [SONDA].[SWIFT_SP_GET_MANIFEST_DETAILS]
			@MANIFEST_HEADER = 3071
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_MANIFEST_DETAILS] (
	@MANIFEST_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@QUERY NVARCHAR(1000) = ''
		,@ERP_DOC INT
		,@IS_FROM_SALES_ORDER INT
	--
	CREATE TABLE #SALES_ORDER_DETAIL (
		SAP_PICKING_ID INT
		,ERP_DOC INT
		,CUSTOMER_ID VARCHAR(250)
		,CUSTOMER_NAME VARCHAR(250)
		,SKU VARCHAR(250)
		,SKU_DESCRIPTION VARCHAR(250)
		,QTY NUMERIC(18,6)
		,QTY_SOURCE NUMERIC(18,6)
		,SHIPPING_TO VARCHAR(250)
		,SELLER_NAME VARCHAR(250)
		,COMMETS VARCHAR(250)
		,TOTAL_LINE NUMERIC(18,6)
		,TARGET_WAREHOUSE VARCHAR(250)
		,SORUCE_WAREHOUSE VARCHAR(250)
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene el documento del ERP y si es orden de venta o transeferencia de inventario
	-- ------------------------------------------------------------------------------------
	SELECT 
		[MD].[DOC_SAP_PICKING] ERP_DOC
		,CASE CONVERT(INT,[PH].[CLASSIFICATION_PICKING])
			WHEN 4 THEN 1
			ELSE 0
		END [IS_FROM_SALES_ORDER]
	INTO #ERP_DOCUMENT
	FROM [SONDA].[SWIFT_MANIFEST_DETAIL] [MD]
	INNER JOIN [SONDA].[SWIFT_PICKING_HEADER] [PH] ON (
		[MD].[CODE_PICKING] = [PH].[PICKING_HEADER]
	)
	WHERE [CODE_MANIFEST_HEADER] = @MANIFEST_HEADER

	WHILE EXISTS (SELECT TOP 1 1 FROM [#ERP_DOCUMENT])
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el documento
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@ERP_DOC = [E].[ERP_DOC]
			,@IS_FROM_SALES_ORDER = [E].[IS_FROM_SALES_ORDER]
		FROM [#ERP_DOCUMENT] [E]
		--
		PRINT '--> @ERP_DOC: ' + CAST(@ERP_DOC AS VARCHAR)
		PRINT '--> @IS_FROM_SALES_ORDER: ' + CAST(@IS_FROM_SALES_ORDER AS VARCHAR)

		-- ------------------------------------------------------------------------------------
		-- Obtiene el documento dependiento si es orden de venta o transferencia de inventario
		-- ------------------------------------------------------------------------------------
		SELECT @QUERY = CASE @IS_FROM_SALES_ORDER
			WHEN 1 THEN N'INSERT INTO #SALES_ORDER_DETAIL (
					SAP_PICKING_ID
						,ERP_DOC
						,CUSTOMER_ID
						,CUSTOMER_NAME
						,SKU
						,SKU_DESCRIPTION
						,QTY
						,QTY_SOURCE
						,SHIPPING_TO
						,SELLER_NAME
						,COMMETS
						,TOTAL_LINE
				)
				EXEC [SONDA].[SWIFT_SP_GET_SAP_PICKING] @pERP_DOC = ' + CAST(@ERP_DOC AS VARCHAR)
			ELSE N'INSERT INTO #SALES_ORDER_DETAIL (
				SAP_PICKING_ID
					,ERP_DOC
					,CUSTOMER_ID
					,CUSTOMER_NAME
					,SKU
					,SKU_DESCRIPTION
					,QTY
					,QTY_SOURCE
					,SHIPPING_TO
					,SELLER_NAME
					,COMMETS
					,TARGET_WAREHOUSE
					,SORUCE_WAREHOUSE
			)
			EXEC [SONDA].[SWIFT_SP_GET_SAP_PICKING_ITR] @pERP_DOC = ' + CAST(@ERP_DOC AS VARCHAR)
			END
		--
		PRINT '--> @QUERY: ' + @QUERY
		--
		EXEC(@QUERY)

		-- ------------------------------------------------------------------------------------
		-- Elimina el documento obtenido
		-- ------------------------------------------------------------------------------------
		DELETE FROM [#ERP_DOCUMENT] WHERE [ERP_DOC] = @ERP_DOC
	END

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT 
		[SO].[SKU]
		,MAX([SO].[SKU_DESCRIPTION]) [SKU_DESCRIPTION]
		,SUM(ISNULL([SO].[QTY],0)) [QTY]
		,SUM(ISNULL([SO].[TOTAL_LINE],0)) [TOTAL_AMOUNT]
	FROM [#SALES_ORDER_DETAIL] [SO]
	GROUP BY [SO].[SKU]
	ORDER BY [SO].[SKU]
END
