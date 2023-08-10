
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Inserta las ordenes de venta en ERP_SALES_ORDER_HEADER_CHANNEL_MODERN y devuelve el ID de secuencia.

-- Modificacion 22-Sep-17 @ Nexus Team Sprint DuckHunt
-- alberto.ruiz
-- Se agrego condficion del docstatus y u_ruta

-- Modificacion 20-Nov-17 @ Reborn Team Sprint Nach
-- rudi.garcia
-- Se agrego join con la tabla [OSHP] par abtener el tipo de despacho

--Modificacion 26-Dic-19 @Alza Team
--diego.espinoza
--Se comento query al final que devuelve los pedidos a visualizar en Swift para incluir los pendientes de Aprobacion en ERP / SAE. 


/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [wms].[ERP_SP_INSERT_SALES_ORDER_HEADER] 
					@START_DATE = @START_DATE -- varchar(100)
					,@WAREHOUSE = '1',
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
				select * from [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] where  [Sequence] = @ID
				delete [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] where  [Sequence] = @ID

*/
-- =============================================
CREATE PROCEDURE [wms].[ERP_SP_INSERT_SALES_ORDER_HEADER]
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
            @ID INT,
            @ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION VARCHAR(1) = '0',
            @GET_TYPE_OF_DEMAND VARCHAR(1) = '0';

    DECLARE @START_DATE_SAE DATETIME = CAST(@START_DATE AS DATETIME),
            @END_DATE_SAE DATETIME = CAST(@END_DATE AS DATETIME);

    INSERT INTO [wms].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN]
    (
        [StartDate],
        [EndDate]
    )
    VALUES
    (   CAST(@START_DATE AS DATETIME), -- StartDate - datetime
        CAST(@END_DATE AS DATETIME)    -- EndDate - datetime
        );
    SELECT @ID = SCOPE_IDENTITY(),
           @SEQUENCE = SCOPE_IDENTITY();


	/*	Comentado Dic. 26th 2019. DEM. Para poder ver pedidos en Proceso de Aprobacion en Swift.	*/
    /*
	SELECT @SQL
        = '
		INSERT INTO [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
		([Sequence],
       [DocDate],
       [DocNum],
       [U_Serie],
       [U_NoDocto],
       [CardCode],
       [CardName],
       [U_MasterIDCustomer],
       [U_OwnerCustomer],
       [SlpName],
       [U_oper],
       [DESCUENTO_FACTURA],
       [STATUS],
       [Comments],
       [DiscPrcnt],
       [Address],
       [Address2],
       [ShipToAddressType],
       [ShipToStreet],
       [ShipToState],
       [ShipToCountry],
       [DocEntry],
       [SlpCode],
       [DocCur],
       [DocRate],
       [DocDueDate],
       [Owner],
       [OwnerSlp],
       [MasterIdSlp],
       [WhsCode],
       [DocStatus],
       [DocTotal],
       [TYPE_DEMAND_CODE],
       [TYPE_DEMAND_NAME],
       [PROJECT],
	   [MIN_DAYS_EXPIRATION_DATE])
		SELECT
			' + CAST(@ID AS VARCHAR)
          + '
		  ,*
		FROM OPENQUERY([ERP_SERVER], ''
		SELECT DISTINCT
      
       [FACT].[FECHA_DOC] [DocDate],
       ltrim(rtrim([FACT].[CVE_DOC])) AS [DocNum],
       [FACT].[SERIE] [U_Serie],
       [FACT].[FOLIO] [U_NoDocto],
      ltrim(rtrim([FACT].[CVE_CLPV])) [CardCode],
       [CLIE].[NOMBRE] [CardName],
       ltrim(rtrim([FACT].[CVE_CLPV])) [U_MasterIDCustomer],
       ''''alza'''' [U_OwnerCustomer],
       [VEND].[NOMBRE] [SlpName],
       [FACT].[CVE_VEND] [U_oper],
       [FACT].[DES_TOT_PORC] AS [DESCUENTO_FACTURA], --T0.DiscPrcnt,
       [FACT].[STATUS] AS [STATUS],
       [C].[STR_OBS] [Comments],
       [FACT].[DES_TOT_PORC] [DiscPrcnt],
       [CLIE].[CALLE] [Address],
       [CLIE].[COLONIA] + '''' '''' + [CLIE].[MUNICIPIO] + '''' '''' + [CLIE].[ESTADO] [Address2],
       1 AS [ShipToAddressType],
       [CLIE].[CALLE] AS [ShipToStreet],
       ''''0'''' AS [ShipToState],
       [CLIE].[PAIS] AS [ShipToCountry],
       ltrim([FACT].[CVE_DOC]) [DocEntry],
       [FACT].[CVE_VEND] [SlpCode],
       [FACT].[NUM_MONED] [DocCur],
       [FACT].[TIPCAMB] [DocRate],
       [FACT].[FECHA_ENT] [DocDueDate],
       ''''alza'''' [Owner],
       ''''alza'''' [OwnerSlp],
       [FACT].[CVE_VEND] [MasterIdSlp],
       [FACT].[NUM_ALMA] [WhsCode],
       [FACT].[STATUS] [DocStatus],
       [FACT].[CAN_TOT] [DocTotal],
       0 [TYPE_DEMAND_CODE],
       '''''''' [TYPE_DEMAND_NAME],
       '''''''' [PROJECT],
	   ISNULL([CLIELIB].[CAMPLIB39] , 0) MIN_DAYS_EXPIRATION_DATE
FROM [SAE70EMPRESA01].[dbo].[FACTP01] [FACT]
    LEFT JOIN [SAE70EMPRESA01].[dbo].[FACTP_CLIB01] [FACTCLIB]
        ON ([FACT].[CVE_DOC] = [FACTCLIB].[CLAVE_DOC])
    LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE01] [CLIE]
        ON [CLIE].[CLAVE] = [FACT].[CVE_CLPV]
	LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE_CLIB01] [CLIELIB]
        ON [CLIE].[CLAVE] = [CLIELIB].[CVE_CLIE]

    LEFT JOIN [SAE70EMPRESA01].[dbo].[VEND01] [VEND]
        ON ([FACT].[CVE_VEND] = [VEND].[CVE_VEND])
    LEFT JOIN [SAE70EMPRESA01].[dbo].[OBS_DOCF01] [C]
        ON [C].[CVE_OBS] = [FACT].[CVE_OBS]
WHERE [FACT].[FECHA_ENT]
      
	    BETWEEN CONVERT(DATETIME,''''' + CONVERT(VARCHAR, @START_DATE_SAE, 121)
          + ''''' , 121) AND CONVERT(DATETIME,''''' + CONVERT(VARCHAR, @END_DATE_SAE, 121)
          + ''''' , 121)
		  AND [FACT].[NUM_ALMA] = ''''' + @WAREHOUSE
          + '''''
	 AND [FACT].[STATUS] <> ''''C''''
	AND [FACT].[TIP_DOC] = ''''P''''
	AND [FACT].[BLOQ] <> ''''S''''          
	AND [FACT].[ESCFD] <> ''''A''''
	AND [FACT].[ESCFD] <> ''''D''''
	AND [FACT].[ENLAZADO] <> ''''T''''
	AND ISNULL([FACTCLIB].[CAMPLIB23], '''''''') <> ''''REVISION''''
   '' )
    ';
	*/


	/* Dic. 26th 2019. DEM. Para poder ver pedidos en Proceso de Aprobacion en Swift.	*/
	--OPENQUERY
		INSERT INTO [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
		([Sequence],
       [DocDate],
       [DocNum],
       [U_Serie],
       [U_NoDocto],
       [CardCode],
       [CardName],
       [U_MasterIDCustomer],
       [U_OwnerCustomer],
       [SlpName],
       [U_oper],
       [DESCUENTO_FACTURA],
       [STATUS],
       [Comments],
       [DiscPrcnt],
       [Address],
       [Address2],
       [ShipToAddressType],
       [ShipToStreet],
       [ShipToState],
       [ShipToCountry],
       [DocEntry],
       [SlpCode],
       [DocCur],
       [DocRate],
       [DocDueDate],
       [Owner],
       [OwnerSlp],
       [MasterIdSlp],
       [WhsCode],
       [DocStatus],
       [DocTotal],
       [TYPE_DEMAND_CODE],
       [TYPE_DEMAND_NAME],
       [PROJECT],
	   [MIN_DAYS_EXPIRATION_DATE])
		SELECT
			@ID [Sequence],
       [FACT].[FECHA_DOC] [DocDate],
       ltrim(rtrim([FACT].[CVE_DOC])) AS [DocNum],
       [FACT].[SERIE] [U_Serie],
       [FACT].[FOLIO] [U_NoDocto],
      ltrim(rtrim([FACT].[CVE_CLPV])) [CardCode],
       [CLIE].[NOMBRE] [CardName],
       ltrim(rtrim([FACT].[CVE_CLPV])) [U_MasterIDCustomer],
       'alza' [U_OwnerCustomer],
       [VEND].[NOMBRE] [SlpName],
       [FACT].[CVE_VEND] [U_oper],
       [FACT].[DES_TOT_PORC] AS [DESCUENTO_FACTURA], --T0.DiscPrcnt,
       [FACT].[STATUS] AS [STATUS],
       [C].[STR_OBS] [Comments],
       [FACT].[DES_TOT_PORC] [DiscPrcnt],
       [CLIE].[CALLE] [Address],
       [CLIE].[COLONIA] + ' ' + [CLIE].[MUNICIPIO] + ' ' + [CLIE].[ESTADO] [Address2],
       1 AS [ShipToAddressType],
       [CLIE].[CALLE] AS [ShipToStreet],
       '0' AS [ShipToState],
       [CLIE].[PAIS] AS [ShipToCountry],
       ltrim([FACT].[CVE_DOC]) [DocEntry],
       [FACT].[CVE_VEND] [SlpCode],
       [FACT].[NUM_MONED] [DocCur],
       [FACT].[TIPCAMB] [DocRate],
       [FACT].[FECHA_ENT] [DocDueDate],
       'alza' [Owner],
       'alza' [OwnerSlp],
       [FACT].[CVE_VEND] [MasterIdSlp],
       [FACT].[NUM_ALMA] [WhsCode],
       [FACT].[STATUS] [DocStatus],
       [FACT].[CAN_TOT] [DocTotal],
       0 [TYPE_DEMAND_CODE],
       '' [TYPE_DEMAND_NAME],
       '' [PROJECT],
	   ISNULL([CLIELIB].[CAMPLIB39] , 0) MIN_DAYS_EXPIRATION_DATE
FROM [SAE70EMPRESA01].[dbo].[FACTP01] [FACT]
    LEFT JOIN [SAE70EMPRESA01].[dbo].[FACTP_CLIB01] [FACTCLIB]
        ON ([FACT].[CVE_DOC] = [FACTCLIB].[CLAVE_DOC] COLLATE DATABASE_DEFAULT)
    LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE01] [CLIE]
        ON [CLIE].[CLAVE]   = [FACT].[CVE_CLPV] COLLATE DATABASE_DEFAULT
	LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE_CLIB01] [CLIELIB]
        ON [CLIE].[CLAVE]  = [CLIELIB].[CVE_CLIE] COLLATE DATABASE_DEFAULT

    LEFT JOIN [SAE70EMPRESA01].[dbo].[VEND01] [VEND]
        ON ([FACT].[CVE_VEND] = [VEND].[CVE_VEND] )--COLLATE DATABASE_DEFAULT
    LEFT JOIN [SAE70EMPRESA01].[dbo].[OBS_DOCF01] [C]
        ON [C].[CVE_OBS] =  [FACT].[CVE_OBS] --COLLATE DATABASE_DEFAULT
WHERE [FACT].[FECHA_ENT]
      
	    BETWEEN @START_DATE_SAE
         AND @END_DATE_SAE
		  AND [FACT].[NUM_ALMA] =  @WAREHOUSE COLLATE DATABASE_DEFAULT

	AND [FACT].[TIP_DOC] = 'P'
	AND [FACT].[BLOQ] <> 'S'    
	AND [FACT].[ESCFD] <> 'A'
	AND [FACT].[ESCFD] <> 'D'
	AND [FACT].[ENLAZADO] <> 'T'
	AND ( [FACT].[STATUS] <> 'C' OR ([FACT].[STATUS] = 'C' AND ISNULL([FACTCLIB].[CAMPLIB23], '') = 'REVISION' ) )
    ;


    RETURN;
END;











