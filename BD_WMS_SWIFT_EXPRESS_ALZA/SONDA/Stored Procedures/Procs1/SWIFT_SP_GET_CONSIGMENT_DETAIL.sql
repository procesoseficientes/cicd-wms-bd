-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Oct-16 @ A-TEAM Sprint 
-- Description:			SP que obtiene el detalle de las consignaciones filtrado por consignacion

-- Modificado 13-Dic-2016
		-- rudi.garcia
		-- Se agrego el campo "SERIAL_NUMBER"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_CONSIGMENT_DETAIL]  @CONSIGNMENT_ID = 1006
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CONSIGMENT_DETAIL (@CONSIGNMENT_ID INT)
AS
BEGIN

  DECLARE 
		@DEFAULT_DISPLAY_DECIMALS INT
		,@QUERY NVARCHAR(2000)

	-- ------------------------------------------------------------------------------------
	-- Coloca parametros iniciales
	--------------------------------------------------------------------------------------
	SELECT @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')
  PRINT @CONSIGNMENT_ID
  SET @QUERY = N'
	SELECT
		[scd].[SKU]
		,[VS].[DESCRIPTION_SKU]
		,[scd].[LINE_NUM]
		,[scd].[QTY]
		, CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([scd].[PRICE])) [PRICE]   
		, CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([scd].[DISCOUNT])) [DISCOUNT]   		
		, CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([scd].[TOTAL_LINE])) [TOTAL_LINE]		
		,[scd].[POSTED_DATETIME]
		,[scd].[PAYMENT_ID]    
    , CASE WHEN ISNULL([scd].SERIAL_NUMBER,''0'') = ''0'' THEN ''N/A'' WHEN [scd].SERIAL_NUMBER = ''NULL'' THEN ''N/A'' ELSE [scd].SERIAL_NUMBER END AS [SERIAL_NUMBER]
	FROM [SONDA].[SWIFT_CONSIGNMENT_DETAIL] [scd]
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] AS VS ON(
		VS.CODE_SKU = scd.SKU
	)
	WHERE [scd].[CONSIGNMENT_ID] = CONVERT(INT,' + CONVERT(VARCHAR(25),@CONSIGNMENT_ID) + ')
	'
  PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'


END
