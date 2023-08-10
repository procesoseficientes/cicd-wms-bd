
-- =============================================
-- Autor:					
-- Fecha de Creacion: 		
-- Description:			    Vista de todos los clientes



/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[ERP_VIEW_SALES_ORDER_DETAIL]
*/
-- =============================================
CREATE VIEW [wms].[ERP_VIEW_SALES_ORDER_DETAIL]
AS
	SELECT 
       [FACT].[FECHA_DOC] [DocDate],
       ltrim(rtrim([FACT].[CVE_DOC])) [DocNum],
       [FACT].[SERIE] [U_Serie],   --[T0].[U_Serie]
       [FACT].[FOLIO] [U_NoDocto], --[T0].[U_NoDocto]
       ltrim(rtrim([FACT].[CVE_CLPV])) [CardCode],
       [CLIE].[NOMBRE] [CardName],
       [VEND].[NOMBRE] [SlpName],
       [FACT].[CVE_VEND] [U_oper],
       [D].[CVE_ART] [ItemCode],
       [D].[CVE_ART] [U_MasterIdSKU],
       'alza' [U_OwnerSKU],
       [m].[DESCR] [Dscription],
       [D].[CANT] AS [Quantity],
       [D].[PREC] AS [PRECIO_CON_IVA],
       0 AS [TOTAL_LINEA_SIN_DESCUENTO],
       0 AS [TOTAL_LINEA_CON_DESCUENTO_APLICADO],
       [FACT].[NUM_ALMA] [WhsCode],
       0 AS [DESCUENTO_FACTURA],
       [FACT].[STATUS] AS [STATUS],
       [D].[NUM_PAR] AS [NUMERO_LINEA],
      ltrim(rtrim( [FACT].[CVE_CLPV])) [U_MasterIDCustomer],
       'alza' [U_OwnerCustomer],
       'alza' [Owner],
       [D].[CANT] [OpenQty],
       [D].[DESC1] [LINE_DISCOUNT],
       [D].[UNI_VENTA] [unitMsr],
       '' [statusOfMaterial]
FROM [SAE70EMPRESA01].[dbo].[FACTP01] [FACT]
    INNER JOIN  [SAE70EMPRESA01].[dbo].[PAR_FACTP01] [D]
        ON [D].[CVE_DOC] = [FACT].[CVE_DOC] COLLATE DATABASE_DEFAULT
		INNER JOIN [SAE70EMPRESA01].[dbo].[INVE01] [m] ON [m].[CVE_ART] = [D].[CVE_ART] COLLATE DATABASE_DEFAULT
    LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE01] [CLIE]
        ON [CLIE].[CLAVE] = [FACT].[CVE_CLPV]  COLLATE DATABASE_DEFAULT
    LEFT JOIN [SAE70EMPRESA01].[dbo].[VEND01] [VEND]
        ON ([FACT].[CVE_VEND] = [VEND].[CVE_VEND] COLLATE DATABASE_DEFAULT)
    --LEFT JOIN [SAE70EMPRESA01].[dbo].[OBS_DOCF01] [C]
    --    ON [C].[CVE_OBS] = [FACT].[CVE_OBS] 

		WHERE
			--[FACT].[FECHA_ENT]
      
	  --  BETWEEN  CONVERT( DATETIME ,''''' + CONVERT(VARCHAR, @START_DATE_SAE, 121)
   --       + ''''', 121) AND CONVERT( DATETIME ,''''' + CONVERT(VARCHAR, @END_DATE_SAE, 121)
   --       + ''''' , 121)	
		   --[FACT].[NUM_ALMA] = ''''' + @WAREHOUSE COLLATE DATABASE_DEFAULT + '''''
    [FACT].[STATUS] <> 'C' 	
	AND [FACT].[FECHA_DOC] > = '2021-07-01'
