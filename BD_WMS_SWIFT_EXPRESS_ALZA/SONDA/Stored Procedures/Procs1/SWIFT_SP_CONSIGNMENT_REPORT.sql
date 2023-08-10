/*======================================================
MODIFICADO:			28-08-2016
	Autor:			diego.as
	Descripcion:	Sp que obtiene los datos de consignaciones en base a un rango de fechas

MODIFICADO:			13-12-2016
	Autor:			  hector.gonzalez
	Descripcion:	Se agrego columna SERIAL_NUMBER


Ejemplo de Ejecucion:
	EXEC [SONDA].[SWIFT_SP_CONSIGNMENT_REPORT]
		@QTY = -1
		,@INIT_DATE = '7/28/2015 2:10:03 PM' 
		,@END_DATE = '10/31/2016 2:13:43 PM'
======================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_CONSIGNMENT_REPORT]
	@QTY		INT = -1
	,@INIT_DATE	DATETIME 
	,@END_DATE		DATETIME 
AS
BEGIN TRY
BEGIN
	DECLARE @query NVARCHAR(MAX);
	set @query = ''
	set @query += 'SELECT '
	set @query += 'h.CONSIGNMENT_ID'
	set @query += ' ,MAX(h.DATE_CREATE) [DATE_CREATE]'
	set @query += ' ,MAX(h.CUSTOMER_ID) [CUSTOMER_ID]'
	set @query += ' ,MAX(c.NAME_CUSTOMER) [NAME_CUSTOMER]'
	set @query += ' ,ISNULL(MAX(c.ADRESS_CUSTOMER),''SIN DIRECCION'') [ADDRESS_CUSTOMER]'
	set @query += ' ,MAX(R.[CODE_ROUTE]) AS CODE_ROUTE'
	set @query += ' ,MAX(R.[NAME_ROUTE]) AS NAME_ROUTE'
	set @query += ' ,ISNULL(MAX(h.TOTAL_AMOUNT),0)TOTAL_AMOUNT'
	set @query += ' ,DATEDIFF(DAY,GETDATE(),MAX(h.DUE_DATE))[REST_DAYS]'
	set @query += ' ,MAX(h.DUE_DATE) [DUE_DATE]'
	set @query += ' , CASE WHEN DATEDIFF(DAY,GETDATE(),MAX(h.DUE_DATE)) >= 0 THEN ''ACTIVA'' ELSE ''VENCIDA'' END AS [STATUS]'
	set @query += ' ,d.SKU'
	set @query += ' ,VS.DESCRIPTION_SKU'
	set @query += ' ,SUM(d.QTY) [QTY]'
	set @query += ' ,d.PRICE'
	set @query += ' ,SUM(d.TOTAL_LINE) [TOTAL_LINE]'
	set @query += ' ,DATEDIFF(DAY,MAX(h.DATE_CREATE),GETDATE()) [ELAPSED_DAYS]'
	set @query += ' ,SUBSTRING(MAX(h.GPS_URL), 1, CHARINDEX('','', MAX(h.GPS_URL)) - 1)  AS LATITUDE'
	set @query += ' ,SUBSTRING(MAX(h.GPS_URL), CHARINDEX('','', MAX(h.GPS_URL)) + 1, LEN(MAX(h.GPS_URL))) AS LONGITUDE'
	set @query += ' , CASE WHEN h.[STATUS] = ''VOID'' THEN ''ANULADO'' ELSE ''NO ANULADO'' END AS [VOID_STATUS]'
	set @query += ' , MAX(h.[REASON]) [REASON]'
  set @query += ' , CASE WHEN ISNULL(d.SERIAL_NUMBER,''0'') = ''0'' THEN ''N/A'' WHEN d.SERIAL_NUMBER = ''NULL'' THEN ''N/A'' ELSE d.SERIAL_NUMBER END AS [SERIAL_NUMBER]'
	set @query += ' FROM [SONDA].[SWIFT_CONSIGNMENT_HEADER] h'
	set @query += ' INNER JOIN [SONDA].[SWIFT_CONSIGNMENT_DETAIL] d ON (h.CONSIGNMENT_ID = d.CONSIGNMENT_ID)'
	set @query += ' INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] AS VS ON(d.SKU = VS.CODE_SKU)'
	set @query += ' INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] c ON (h.CUSTOMER_ID = c.CODE_CUSTOMER)'
	set @query += ' INNER JOIN [SONDA].[SWIFT_VIEW_ROUTES] R ON (R.[CODE_ROUTE] = H.POS_TERMINAL)'
	set @query += CASE WHEN @INIT_DATE != '' and @END_DATE != '' THEN ' WHERE H.STATUS=''ACTIVE'' AND h.DATE_CREATE BETWEEN @INIT_DATE AND @END_DATE' ELSE '' END
	set @query += ' GROUP BY h.CONSIGNMENT_ID, d.SKU,VS.DESCRIPTION_SKU, d.PRICE, h.[STATUS], d.SERIAL_NUMBER '
	set @query += CASE WHEN @QTY != -1 THEN ' HAVING DATEDIFF(DAY,GETDATE(),MAX(h.DUE_DATE)) < ' + CAST(@QTY AS varchar) ELSE '' END
	set @query += ' ORDER BY 5 ASC'
	--
	print '@INIT_DATE: ' + CAST(@INIT_DATE AS VARCHAR)
	print '@END_DATE: ' + CAST(@END_DATE AS VARCHAR)
	print '@QTY: ' + CAST(@QTY AS VARCHAR)
	print '@query: ' + @query
	
	--SELECT @query
	EXEC SP_EXECUTESQL @query , N'@INIT_DATE DATETIME, @END_DATE DATETIME, @QTY INT', @INIT_DATE = @INIT_DATE, @END_DATE = @END_DATE, @QTY = @QTY
END
END TRY
BEGIN CATCH
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH

SET QUOTED_IDENTIFIER ON
