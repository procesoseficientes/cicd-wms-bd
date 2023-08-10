;
-- =====================================================
-- Author:         alberto.ruiz
-- Create date:    16-04-2016
-- Description:    valida si el documento ya fue enviado a SAP

-- Modificacion 22-06-2016
-- alberto.ruiz
-- Se cambio filtro para validar que existe o no la orden de venta

-- Modificacion 27-06-2016
-- alberto.ruiz
-- Se cambio para que colocara la orden de venta negativa para que pueda agregar la nueva
-- ESTE CAMBIO DEBE DE SER TEMPORAL

-- Modificacion 05-07-2016
-- alberto.ruiz
-- Se agrego log

-- Modificacion 12-01-2017
-- alberto.ruiz
-- Se agrego parametro y validacion de cantidad de lines del detalle

-- Modificacion 16-Mar-17 @ A-Team Sprint Ebonne
-- alberto.ruiz
-- Se agrearon los parametros de xml y json


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-05 Nexus@
-- Description:	 Se modifica where a tablas de SaleOrder para que consulte por indices y se agrega log de errores. 



/*
-- EJEMPLO DE EJECUCION: 
		--
		EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER_2]
			@DOC_SERIE = 'ESC0003@SONDA'
			,@DOC_NUM = 4102
			,@CODE_ROUTE = 'ESC0003@SONDA'
			,@CODE_CUSTOMER = 'SO-164853'
			,@POSTED_DATETIME = '2017-01-11 09:26:33.000'
			,@DETAIL_QTY = 3
			,@XML = '<?xml version="1.0"?>
<Data>
    <salesOrder>
        <SalesOrderId>-2</SalesOrderId>
        <Terms>null</Terms>
        <PostedDatetime>2017/03/16 08:43:55</PostedDatetime>
        <ClientId>2373</ClientId>
        <PosTerminal>6</PosTerminal>
        <GpsUrl>14.6500982,-90.5397046</GpsUrl>
        <TotalAmount>305</TotalAmount>
        <Status>0</Status>
        <PostedBy>Alberto@SONDA</PostedBy>
        <Image1>data:image/png;base64,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</Image1>
        <Image2></Image2>
        <Image3>null</Image3>
        <DeviceBatteryFactor>26</DeviceBatteryFactor>
        <VoidDatetime>null</VoidDatetime>
        <VoidReason>null</VoidReason>
        <VoidNotes>null</VoidNotes>
        <Voided>null</Voided>
        <ClosedRouteDatetime>null</ClosedRouteDatetime>
        <IsActiveRoute>1</IsActiveRoute>
        <GpsExpected>14.3936039,-90.7068193</GpsExpected>
        <SalesOrderIdBo>0</SalesOrderIdBo>
        <DeliveryDate>2017/3/17</DeliveryDate>
        <IsParent>1</IsParent>
        <ReferenceId>Alberto@SONDA2017/03/16 08:43:55-2</ReferenceId>
        <TimesPrinted>0</TimesPrinted>
        <DocSerie>SO1</DocSerie>
        <DocNum>25</DocNum>
        <IsVoid>0</IsVoid>
        <SalesOrderType>CREDIT</SalesOrderType>
        <Discount>0</Discount>
        <IsDraft>0</IsDraft>
        <TaskId>57094</TaskId>
        <Comment></Comment>
        <IsPosted>1</IsPosted>
        <Sinc>0</Sinc>
        <IsPostedVoid>2</IsPostedVoid>
        <IsUpdated>1</IsUpdated>
        <PaymentTimesPrinted>0</PaymentTimesPrinted>
        <PaidToDate>305</PaidToDate>
        <ToBill>0</ToBill>
        <Authorized>0</Authorized>
        <DetailQty>3</DetailQty>
        <SaleDetails>
            <SalesOrderId>-2</SalesOrderId>
            <Sku>100020</Sku>
            <LineSeq>1</LineSeq>
            <Qty>11</Qty>
            <Price>5</Price>
            <Discount>0</Discount>
            <TotalLine>55</TotalLine>
            <PostedDatetime>2017/03/16 08:43:55</PostedDatetime>
            <Serie>0</Serie>
            <Serie2>0</Serie2>
            <RequeriesSerie>0</RequeriesSerie>
            <ComboReference>100020</ComboReference>
            <ParentSeq>1</ParentSeq>
            <IsActiveRoute>1</IsActiveRoute>
            <CodePackUnit>Manual</CodePackUnit>
            <IsBonus>0</IsBonus>
            <IsPostedVoid>2</IsPostedVoid>
            <Long>null</Long>
        </SaleDetails>
        <SaleDetails>
            <SalesOrderId>-2</SalesOrderId>
            <Sku>100002</Sku>
            <LineSeq>2</LineSeq>
            <Qty>12</Qty>
            <Price>10</Price>
            <Discount>0</Discount>
            <TotalLine>120</TotalLine>
            <PostedDatetime>2017/03/16 08:43:55</PostedDatetime>
            <Serie>0</Serie>
            <Serie2>0</Serie2>
            <RequeriesSerie>0</RequeriesSerie>
            <ComboReference>100002</ComboReference>
            <ParentSeq>1</ParentSeq>
            <IsActiveRoute>1</IsActiveRoute>
            <CodePackUnit>Manual</CodePackUnit>
            <IsBonus>0</IsBonus>
            <IsPostedVoid>2</IsPostedVoid>
            <Long>null</Long>
        </SaleDetails>
        <SaleDetails>
            <SalesOrderId>-2</SalesOrderId>
            <Sku>100003</Sku>
            <LineSeq>3</LineSeq>
            <Qty>13</Qty>
            <Price>10</Price>
            <Discount>0</Discount>
            <TotalLine>130</TotalLine>
            <PostedDatetime>2017/03/16 08:43:55</PostedDatetime>
            <Serie>0</Serie>
            <Serie2>0</Serie2>
            <RequeriesSerie>0</RequeriesSerie>
            <ComboReference>100003</ComboReference>
            <ParentSeq>1</ParentSeq>
            <IsActiveRoute>1</IsActiveRoute>
            <CodePackUnit>Manual</CodePackUnit>
            <IsBonus>0</IsBonus>
            <IsPostedVoid>2</IsPostedVoid>
            <Long>null</Long>
        </SaleDetails>
    </salesOrder>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <battery>23</battery>
    <routeid>6</routeid>
    <warehouse>BODEGA_CENTRAL</warehouse>
    <uuid>ec26a682181b8186</uuid>
</Data>'
			,@JSON = '{"salesOrder":{"SalesOrderId":-2,"Terms":"null","PostedDatetime":"2017/03/16 08:43:55","ClientId":"2373","PosTerminal":"6","GpsUrl":"14.6500982,-90.5397046","TotalAmount":305,"Status":"0","PostedBy":"Alberto@SONDA","Image1":"data:image/png;base64,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","Image2":"","Image3":null,"DeviceBatteryFactor":"26","VoidDatetime":null,"VoidReason":null,"VoidNotes":null,"Voided":null,"ClosedRouteDatetime":null,"IsActiveRoute":1,"GpsExpected":"14.3936039,-90.7068193","SalesOrderIdBo":0,"DeliveryDate":"2017/3/17","IsParent":1,"ReferenceId":"Alberto@SONDA2017/03/16 08:43:55-2","TimesPrinted":0,"DocSerie":"SO1","DocNum":25,"IsVoid":0,"SalesOrderType":"CREDIT","Discount":0,"IsDraft":0,"TaskId":57094,"Comment":"","IsPosted":1,"Sinc":0,"IsPostedVoid":2,"IsUpdated":1,"PaymentTimesPrinted":0,"PaidToDate":305,"ToBill":0,"Authorized":0,"DetailQty":3,"SaleDetails":[{"SalesOrderId":-2,"Sku":"100020","LineSeq":1,"Qty":11,"Price":5,"Discount":0,"TotalLine":55,"PostedDatetime":"2017/03/16 08:43:55","Serie":"0","Serie2":"0","RequeriesSerie":"0","ComboReference":"100020","ParentSeq":"1","IsActiveRoute":1,"CodePackUnit":"Manual","IsBonus":0,"IsPostedVoid":2,"Long":null},{"SalesOrderId":-2,"Sku":"100002","LineSeq":2,"Qty":12,"Price":10,"Discount":0,"TotalLine":120,"PostedDatetime":"2017/03/16 08:43:55","Serie":"0","Serie2":"0","RequeriesSerie":"0","ComboReference":"100002","ParentSeq":"1","IsActiveRoute":1,"CodePackUnit":"Manual","IsBonus":0,"IsPostedVoid":2,"Long":null},{"SalesOrderId":-2,"Sku":"100003","LineSeq":3,"Qty":13,"Price":10,"Discount":0,"TotalLine":130,"PostedDatetime":"2017/03/16 08:43:55","Serie":"0","Serie2":"0","RequeriesSerie":"0","ComboReference":"100003","ParentSeq":"1","IsActiveRoute":1,"CodePackUnit":"Manual","IsBonus":0,"IsPostedVoid":2,"Long":null}]},"dbuser":"USONDA","dbuserpass":"SONDAServer1237710","battery":23,"routeid":"6","warehouse":"BODEGA_CENTRAL","uuid":"ec26a682181b8186"}'
			,@COMMITTED_INVENTORY = 0
*/
-- =====================================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER_2 (@DOC_SERIE VARCHAR(100)
, @DOC_NUM INT
, @CODE_ROUTE VARCHAR(50)
, @CODE_CUSTOMER VARCHAR(50)
, @POSTED_DATETIME DATETIME
, @DETAIL_QTY INT
, @XML XML
, @JSON VARCHAR(MAX)
, @COMMITTED_INVENTORY INT = 1)
AS
BEGIN
  SET NOCOUNT ON;


  BEGIN TRY
    --
    DECLARE @EXISTS INT = 0
           ,@SALES_ORDER_ID INT
           ,@SALES_ORDER_POSTED_DATETIME DATETIME
           ,@INSERT INT = 0
           ,@DETAIL_QTY_IN_DB INT = 0
    --
    SELECT TOP 1
      @EXISTS = 1
     ,@SALES_ORDER_ID = [H].[SALES_ORDER_ID]
     ,@SALES_ORDER_POSTED_DATETIME = MAX([H].[POSTED_DATETIME])
     ,@DETAIL_QTY_IN_DB = COUNT(D.SALES_ORDER_ID)
    FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [H]
    INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] [D]
      ON (
      [H].[SALES_ORDER_ID] = [D].[SALES_ORDER_ID]
      )
    WHERE /*[H].[IS_ACTIVE_ROUTE] = 1 --> TEMPORAL
  		AND */
    [H].[DOC_SERIE] = @DOC_SERIE
    AND [H].[DOC_NUM] = @DOC_NUM
    --AND [H].[IS_READY_TO_SEND] = 1
    GROUP BY [H].[SALES_ORDER_ID]

    -- ------------------------------------------------------------------------------------
    -- TEMPORAL -------> Valida si existe y le coloca una secuencia negativa
    -- ------------------------------------------------------------------------------------
    --IF @EXISTS = 1
    --AND @SALES_ORDER_POSTED_DATETIME != @POSTED_DATETIME
    --BEGIN
   
    --
    --      UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
    --      SET DOC_NUM = NEXT VALUE FOR [SONDA].[SALES_ORDER_NEGATIVE_SEQUENCE]
    --      WHERE [POS_TERMINAL] = @CODE_ROUTE
    --      AND [CLIENT_ID] = @CODE_CUSTOMER
    --      AND DOC_SERIE = @DOC_SERIE
    --      AND DOC_NUM = @DOC_NUM


    --SELECT
    -- @EXISTS = 0
    --@INSERT = 1
    --
    --      INSERT INTO [SONDA].[SONDA_SALES_ORDER_LOG_EXISTS] ([LOG_DATETIME]
    --      , [EXISTS_SALES_ORDER]
    --      , [DOC_SERIE]
    --      , [DOC_NUM]
    --      , [CODE_ROUTE]
    --      , [CODE_CUSTOMER]
    --      , [POSTED_DATETIME]
    --      , [SET_NEGATIVE_SEQUENCE]
    --      , [XML]
    --      , [JSON])
    --        VALUES (GETDATE()  -- LOG_DATETIME - datetime
    --        , @EXISTS  -- EXISTS_SALES_ORDER - int
    --        , @DOC_SERIE  -- DOC_SERIE - varchar(100)
    --        , @DOC_NUM  -- DOC_NUM - int
    --        , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)
    --        , @CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
    --        , GETDATE()  -- POSTED_DATETIME - datetime
    --        , 1  -- SET_NEGATIVE_SEQUENCE - int
    --        , @XML, @JSON)
    --END

    -- ------------------------------------------------------------------------------------
    -- Inserta el registro
    -- ------------------------------------------------------------------------------------
--    IF @INSERT = 0
--    BEGIN
--      IF @EXISTS = 1
--        AND @DETAIL_QTY = @DETAIL_QTY_IN_DB
--      BEGIN
--        PRINT 'Existe'
--        --
--        INSERT INTO [SONDA].[SONDA_SALES_ORDER_LOG_EXISTS] ([LOG_DATETIME]
--        , [EXISTS_SALES_ORDER]
--        , [DOC_SERIE]
--        , [DOC_NUM]
--        , [CODE_ROUTE]
--        , [CODE_CUSTOMER]
--        , [POSTED_DATETIME]
--        , [SET_NEGATIVE_SEQUENCE]
--        , [XML]
--        , [JSON])
--          VALUES (GETDATE()  -- LOG_DATETIME - datetime
--          , @EXISTS  -- EXISTS_SALES_ORDER - int
--          , @DOC_SERIE  -- DOC_SERIE - varchar(100)
--          , @DOC_NUM  -- DOC_NUM - int
--          , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)
--          , @CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
--          , GETDATE()  -- POSTED_DATETIME - datetime
--          , 0  -- SET_NEGATIVE_SEQUENCE - int
--          , @XML, @JSON)
--
--        -- ------------------------------------------------------------------------------------
--        -- Valida si debe de reservar el inventario y colocar como lisa la orden de venta
--        -- ------------------------------------------------------------------------------------
--        IF (@COMMITTED_INVENTORY = 1)
--        BEGIN
--        BEGIN TRY
--          BEGIN TRAN
--          --
--          EXEC [SONDA].[SONDA_SP_COMMIT_INVENTORY_BY_SALES_ORDER_ID] @SALE_ORDER_ID = @SALES_ORDER_ID
--          --
--          UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
--          SET [IS_READY_TO_SEND] = 1
--          WHERE [SALES_ORDER_ID] = @SALES_ORDER_ID
--          --
--          COMMIT
--        END TRY
--        BEGIN CATCH
--          ROLLBACK
--          DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
--          PRINT 'CATCH: ' + @ERROR
--          RAISERROR (@ERROR, 16, 1)
--        END CATCH
--        END
--      END
--      ELSE
--      BEGIN
--        PRINT 'No Existe'
--        --
--        SET @EXISTS = 0
--        --
--        INSERT INTO [SONDA].[SONDA_SALES_ORDER_LOG_EXISTS] ([LOG_DATETIME]
--        , [EXISTS_SALES_ORDER]
--        , [DOC_SERIE]
--        , [DOC_NUM]
--        , [CODE_ROUTE]
--        , [CODE_CUSTOMER]
--        , [POSTED_DATETIME]
--        , [SET_NEGATIVE_SEQUENCE]
--        , [XML]
--        , [JSON])
--          VALUES (GETDATE()  -- LOG_DATETIME - datetime
--          , @EXISTS  -- EXISTS_SALES_ORDER - int
--          , @DOC_SERIE  -- DOC_SERIE - varchar(100)
--          , @DOC_NUM  -- DOC_NUM - int
--          , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)
--          , @CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
--          , GETDATE()  -- POSTED_DATETIME - datetime
--          , NULL  -- SET_NEGATIVE_SEQUENCE - int
--          , @XML, @JSON)
--      END
--    END

    -- ------------------------------------------------------------------------------------
    -- Muestra resultado
    -- ------------------------------------------------------------------------------------
    SELECT
      @EXISTS AS [EXISTS]
     ,@SALES_ORDER_ID AS SALES_ORDER_ID

  END TRY
  BEGIN CATCH

    DECLARE @SP_ERROR VARCHAR(1000) = ERROR_MESSAGE();
    PRINT 'SP_CATCH: ' + @SP_ERROR;

    EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = @CODE_ROUTE
                                                         ,@LOGIN = NULL
                                                         ,@SOURCE_ERROR = 'SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER_2'
                                                         ,@DOC_RESOLUTION = NULL
                                                         ,@DOC_SERIE = @DOC_SERIE
                                                         ,@DOC_NUM = @DOC_NUM
                                                         ,@MESSAGE_ERROR = @SP_ERROR
                                                         ,@SEVERITY_CODE = 10



    RAISERROR (@SP_ERROR, 16, 1);

  END CATCH;

END
