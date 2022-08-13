-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Se inserta el detalle del pedido en ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN y se devuelve la secuencia

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se cambia el filtro por DocDueDate en lugar de Docdate

-- Modificacion 03-Nov-17 @ Nexus Team Sprint F-Zero
-- alberto.ruiz
-- Se agrega descuento

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-1
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [wms].[ERP_SP_INSERT_SALES_ORDER_DETAIL] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT,	-- int
					@WAREHOUSE ='1'

				SELECT @ID
				SELECT * FROM [wms].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]  WHERE SEQUENCE = @ID 
				DELETE [wms].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] WHERE SEQUENCE = @ID 

*/
-- =============================================
CREATE PROCEDURE [wms].[ERP_SP_INSERT_SALES_ORDER_DETAIL_SAE_PRUEBAS]
(
    @START_DATE VARCHAR(100),
    @END_DATE VARCHAR(100),
    @WAREHOUSE VARCHAR(100),
    @SEQUENCE INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @SQL VARCHAR(4000) = '',
            @ID INT;

    INSERT INTO [wms].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN]
    (
        [StartDate],
        [EndDate]
    )
    VALUES
    (   @START_DATE, -- StartDate - datetime
        @END_DATE    -- EndDate - datetime
        );
    SELECT @ID = SCOPE_IDENTITY(),
           @SEQUENCE = SCOPE_IDENTITY();

    DECLARE @START_DATE_SAE DATETIME = CAST(@START_DATE AS DATETIME),
            @END_DATE_SAE DATETIME = CAST(@END_DATE AS DATETIME);

    SELECT @SQL
        = '
		INSERT INTO [wms].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]

			(
				[Sequence]
				,[DocDate]
				,[DocNum]
				,[U_Serie]
				,[U_NoDocto]
				,[CardCode]
				,[CardName]
				,[SlpName]
				,[U_oper]
				,[ItemCode]
				,[U_MasterIdSKU]
				,[U_OwnerSKU]
				,[Dscription]
				,[Quantity]
				,[PRECIO_CON_IVA]
				,[TOTAL_LINEA_SIN_DESCUENTO]
				,[TOTAL_LINEA_CON_DESCUENTO_APLICADO]
				,[WhsCode]
				,[DESCUENTO_FACTURA]
				,[STATUS]
				,[NUMERO_LINEA]
				,[U_MasterIDCustomer]
				,[U_OwnerCustomer]
				,[Owner]
				,[OpenQty]
				,[LINE_DISCOUNT]
				,[unitMsr]
				, statusOfMaterial
			)

		SELECT
			' + CAST(@ID AS VARCHAR)
          + '
		  ,*
		
		FROM OPENQUERY
     ([ERP_SERVER],
      ''
SELECT DISTINCT
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
       ''''alza'''' [U_OwnerSKU],
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
       ''''alza'''' [U_OwnerCustomer],
       ''''alza'''' [Owner],
       [D].[CANT] [OpenQty],
       [D].[DESC1] [LineDiscPrcnt],
       [D].[UNI_VENTA] [unitMsr],
       '''''''' [statusOfMaterial]
FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTP04] [FACT]
    INNER JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTP04] [D]
        ON [D].[CVE_DOC] = [FACT].[CVE_DOC]
		INNER JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[INVE04] [m] ON [m].[CVE_ART] = [D].[CVE_ART]
    LEFT JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[CLIE04] [CLIE]
        ON [CLIE].[CLAVE] = [FACT].[CVE_CLPV]
    LEFT JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[VEND04] [VEND]
        ON ([FACT].[CVE_VEND] = [VEND].[CVE_VEND])
    LEFT JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[OBS_DOCF04] [C]
        ON [C].[CVE_OBS] = [FACT].[CVE_OBS]

		WHERE
			[FACT].[FECHA_ENT]
      
	    BETWEEN  CONVERT( DATETIME ,''''' + CONVERT(VARCHAR, @START_DATE_SAE, 121) + ''''', 121) AND CONVERT( DATETIME ,'''''
          + CONVERT(VARCHAR, @END_DATE_SAE, 121) + ''''' , 121)	
		  AND [FACT].[NUM_ALMA] = ''''' + @WAREHOUSE + '''''
   AND [FACT].[STATUS] <> ''''C'''' '' )	';
    --
    PRINT (@SQL);
    --
    EXEC (@SQL);
    --





    RETURN;
END;








