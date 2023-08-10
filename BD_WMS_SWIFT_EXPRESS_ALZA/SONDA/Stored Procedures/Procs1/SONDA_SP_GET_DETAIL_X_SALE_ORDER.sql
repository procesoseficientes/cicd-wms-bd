-- =============================================
-- Autor:				Jose Roberto
-- Fecha de Creacion: 	13-11-2015
-- Description:			ObtenerDetallePorOrdenDeVenta

-- Modificado 12-05-2016
		-- hector.gonzalez
		-- Se modifico los campos QTY, PRICE, TOTAL_LINE agregando la funcion SWIFT_FN_GET_DISPLAY_NUMBER a dischos campos 
		--  y se agregaron las columnas SALES_ORDER_TYPE, CODE_PACK_UNIT, DESCRIPTION_PACK_UNIT

-- Modificacion 04-07-16
					-- alberto.ruiz
					-- Se corrigio el uso de la funcion de los decimales para mostrar

-- Modificacion 04-11-2016
          -- diego.as
          -- Se agrego Columna LONG
/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SONDA_SP_GET_DETAIL_X_SALE_ORDER]@SALES_ORDER_ID='14527'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_DETAIL_X_SALE_ORDER (
	@SALES_ORDER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DEFAULT_DISPLAY_DECIMALS INT
		,@QUERY NVARCHAR(2000)

	-- ------------------------------------------------------------------------------------
	-- Coloca parametros iniciales
	--------------------------------------------------------------------------------------
	SELECT @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SET @QUERY = N'
	Select 
		D.SKU
		, S.DESCRIPTION_SKU
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(D.QTY)) AS ''QTY'' 
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(D.PRICE)) AS ''PRICE''
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(D.TOTAL_LINE)) AS ''TOTAL_LINE''
    ,E.SALES_ORDER_TYPE
    ,PU.CODE_PACK_UNIT
    ,PU.DESCRIPTION_PACK_UNIT
    ,D.DISCOUNT	
    ,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(D.TOTAL_LINE-(D.TOTAL_LINE*(D.DISCOUNT/100)))) AS  ''TOTAL_DISCOUNT''
    ,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(ISNULL(D.LONG,0))) AS ''LONG''
	from [SONDA].[SONDA_SALES_ORDER_HEADER] as E
		INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] as D ON (D.SALES_ORDER_ID=E.SALES_ORDER_ID)
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] AS S ON (D.SKU = S.CODE_SKU)
		LEFT JOIN [SONDA].[SONDA_PACK_UNIT] PU ON D.CODE_PACK_UNIT = PU.CODE_PACK_UNIT
	where E.SALES_ORDER_ID = '+ CAST(@SALES_ORDER_ID AS VARCHAR)
	--
	PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'
END
