
-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Oct-16 @ A-TEAM Sprint 
-- Description:			SP que obtiene el detalle de las consignaciones filtrado por fecha.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_CONSIGMENT_HEADER]
					@FECHA_INICIAL = '2014-10-13 00:00:00.000',
					@FECHA_FIN = '2017-10-13 23:59:59.59'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CONSIGMENT_HEADER] (
	@FECHA_INICIAL DATETIME,
	@FECHA_FIN DATETIME)
AS
BEGIN

  DECLARE 
		@DEFAULT_DISPLAY_DECIMALS INT
		,@QUERY NVARCHAR(2000)
		,@KPI NVARCHAR(50)

	-- ----------------------------------------------------------------------------------------------------------------
	-- Coloca parametros iniciales
	-------------------------------------------------------------------------------------------------------------------
	SELECT @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')
	
	-- ----------------------------------------------------------------------------------------------------------------
	-- Se Obtiene el Parametro de Dias Restantes para el KPI
	-- ----------------------------------------------------------------------------------------------------------------
	SELECT @KPI = [SONDA].[SWIFT_FN_GET_PARAMETER]('CONSIGNMENT','WARNING_DUE_DATE_CONSIGNMENT')
  
  SET @QUERY = N'


  SELECT
    [CH].[CONSIGNMENT_ID]
   ,[CH].[CUSTOMER_ID]
   ,AC.NAME_CUSTOMER
   ,[CH].[DATE_CREATE]
   ,[CH].[DATE_UPDATE]
   ,CASE [CH].[STATUS]
		WHEN ''VOID'' THEN ''ANULADA''
		WHEN ''CANCELLED'' THEN ''CANCELADA''
		WHEN ''ACTIVE'' THEN ''ACTIVA''
	END AS [STATUS]
   ,[CH].[POSTED_BY]
   ,[CH].[IS_POSTED]
   ,[CH].[POS_TERMINAL]
   ,[CH].[GPS_URL]
   ,SUBSTRING(CH.GPS_URL, 1, CHARINDEX('','', CH.GPS_URL) - 1)  AS LATITUDE
   ,SUBSTRING(CH.GPS_URL, CHARINDEX('','', CH.GPS_URL) + 1, LEN(CH.GPS_URL)) AS LONGITUDE
   ,[CH].[DOC_DATE]
   ,[CH].[CLOSED_ROUTE_DATETIME]
   ,[CH].[IS_ACTIVE_ROUTE]
   ,[CH].[DUE_DATE]
   ,[CH].[CONSIGNMENT_HH_NUM]
   , CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([CH].[TOTAL_AMOUNT])) [TOTAL_AMOUNT]   
   ,[CH].[DOC_SERIE]
   ,[CH].[DOC_NUM]
   ,[CH].[IMG]
   ,[CH].[IS_CLOSED]
   ,CASE CH.IS_CLOSED
    	WHEN 1 THEN ''CERRADO''
    	WHEN 0 THEN ''ABIERTO''
    END AS IS_CLOSED_DESCRIPTION
   ,[CH].[REASON]
   ,CASE 
		WHEN DATEDIFF(DAY,GETDATE(),CH.DUE_DATE) < 0 THEN 1 
		WHEN DATEDIFF(DAY,GETDATE(),CH.DUE_DATE) < ' + @KPI +' THEN 2
		WHEN  DATEDIFF(DAY,GETDATE(),CH.DUE_DATE) >' + @KPI +' THEN 3
	END AS [KPI]
  FROM [SONDA].[SWIFT_CONSIGNMENT_HEADER] [CH]
  INNER JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER AC
    ON CH.CUSTOMER_ID = AC.CODE_CUSTOMER
  WHERE CONVERT(DATE,[CH].[DATE_CREATE]) Between CONVERT(DATE,''' + CONVERT(VARCHAR(25),@FECHA_INICIAL,101) + ''') AND CONVERT(DATE,''' + CONVERT(VARCHAR(25),@FECHA_FIN,101) + ''')
  '
  PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'
END
