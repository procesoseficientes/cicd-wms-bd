﻿
-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190204 GForce@Rinoceronte
-- Description:			Inserta las ordenes de venta en ERP_SALES_ORDER_HEADER_CHANNEL_MODERN y devuelve el ID de secuencia sin codigo de bodega


/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [wms].[ERP_SP_INSERT_SALES_ORDER_HEADER] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT,	-- int
					@WAREHOUSE = '1'
					SELECT * FROM [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] WHERE SEQUENCE = @ID
				SELECT @ID
*/
-- =============================================
CREATE PROCEDURE [wms].[ERP_SP_INSERT_SALES_ORDER_HEADER_WITHOUT_WAREHOUSE]
(
    @START_DATE VARCHAR(100),
    @END_DATE VARCHAR(100),
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
	   @ID,
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
      
	    BETWEEN @START_DATE_SAE AND @END_DATE_SAE;

    RETURN;
END;



