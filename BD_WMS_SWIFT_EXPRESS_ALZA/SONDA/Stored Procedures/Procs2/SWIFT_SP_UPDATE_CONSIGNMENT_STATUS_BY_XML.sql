-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-12-19 @REBORN-Team - Sprint Quiterio
-- Description:	   sp que inserta 

-- Modificacion 1/19/2018 @ Reborn-Team Sprint Strom
					-- diego.as
					-- Se agrega validacion de identificador de dispositivo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_ADD_INVOICE_BY_XML]
					@XML = '<?xml version="1.0"?>
<Data>
    <consignment>
        <ConsignmentId>29</ConsignmentId>
        <CustomerId>SO-1223321</CustomerId>
        <DateCreate>2017/03/31 17:15:52</DateCreate>
        <DateUpdate>1020</DateUpdate>
        <Status>TIENDA ESPERANZA</Status>
        <PostedBy>7</PostedBy>
        <IsPosted>0,0</IsPosted>
        <PosTerminal>50</PosTerminal>
        <GpsUrl>0</GpsUrl>
        <DocDate>1</DocDate>
        <ClosedRouteDatetime></ClosedRouteDatetime>        
        <IsActiveRoute>null</IsActiveRoute>
        <DueDate>1</DueDate>
        <ConsignmentBoNum>0</ConsignmentBoNum>
        <DocSerie>1323123</DocSerie>
        <DocNum>Serie de R</DocNum>
        <TotalAmount>0</TotalAmount>
        <ConsignmentRows>null</ConsignmentRows>        
    </consignment>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <battery>100</battery>
    <routeid>7</routeid>
    <uuid>2b9cd997e9ffcd98</uuid>
    <warehouse>R006</warehouse>
	<deviceId>3b396881f40a8de3</deviceId>
</Data>'					
				--
				SELECT * FROM [SONDA].[SONDA_POS_INVOICE_HEADER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_CONSIGNMENT_STATUS_BY_XML] (@XML XML)
AS
BEGIN
  BEGIN TRY
    DECLARE @CONSIGNMENT_ID INT
           ,@CUSTOMER_ID VARCHAR(50)
           ,@CODE_ROUTE VARCHAR(25)
           ,@DOC_SERIE VARCHAR(50)
           ,@DOC_NUM INT
           ,@LOG_MESSAGE VARCHAR(100)
		   ,@DEVICE_ID VARCHAR(50);

    --

    DECLARE @CONSIGNMENTS TABLE (
      [CONSIGNMENT_ID] INT
     ,[CUSTOMER_ID] VARCHAR(50)
     ,[CODE_ROUTE] VARCHAR(25)
     ,[DOC_SERIE] VARCHAR(50)
     ,[DOC_NUM] INT
    );

    DECLARE @CONSIGNMENTS_RESULT TABLE (
      [CONSIGNMENT_ID] INT
     ,[CUSTOMER_ID] VARCHAR(50)
     ,[CODE_ROUTE] VARCHAR(25)
     ,[DOC_SERIE] VARCHAR(50)
     ,[DOC_NUM] INT
    );

	-- --------------------------------------------------------------------------------------------------------
	SELECT
		@DEVICE_ID = X.[REC].query('./deviceId').value('.','varchar(50)')
		,@CODE_ROUTE = X.[REC].query('./routeid').value('.','varchar(50)')
	FROM @XML.nodes('Data') AS X(REC)

	-- --------------------------------------------------------------------------------------------------------
	EXEC [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION] @CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
		@DEVICE_ID = @DEVICE_ID -- varchar(50)
	

    -- --------------------------------------------------------------------------------------------------------
    INSERT INTO @CONSIGNMENTS ([CONSIGNMENT_ID],
    [CUSTOMER_ID],
    [CODE_ROUTE],
    [DOC_SERIE],
    [DOC_NUM])
      SELECT
        CASE
          WHEN x.Rec.query('./ConsignmentId').value('.', 'int') < 0 THEN x.Rec.query('./ConsignmentBoNum').value('.', 'int')
          ELSE x.Rec.query('./ConsignmentId').value('.', 'int')
        END

       ,x.Rec.query('./CustomerId').value('.', 'varchar(50)')
       ,x.Rec.query('./PosTerminal').value('.', 'varchar(25)')
       ,x.Rec.query('./DocSerie').value('.', 'varchar(250)')
       ,x.Rec.query('./DocNum').value('.', 'int')
      FROM @XML.nodes('Data/consignment') AS x (Rec)

    -- ----------------------------------------------------------------------------------------------------------


    WHILE EXISTS (SELECT TOP 1
          1
        FROM @CONSIGNMENTS)
    BEGIN

      SELECT TOP 1
        @CONSIGNMENT_ID = [D].[CONSIGNMENT_ID]
       ,@CUSTOMER_ID = [D].[CUSTOMER_ID]
       ,@CODE_ROUTE = [D].[CODE_ROUTE]
       ,@DOC_SERIE = [D].[DOC_SERIE]
       ,@DOC_NUM = [D].[DOC_NUM]
      FROM @CONSIGNMENTS AS D

    --      
    BEGIN TRY


      UPDATE [SONDA].[SWIFT_CONSIGNMENT_HEADER]
      SET [STATUS] = 'CANCELLED'
         ,[DATE_UPDATE] = GETDATE()
      WHERE [CONSIGNMENT_ID] = @CONSIGNMENT_ID
      AND [CUSTOMER_ID] = @CUSTOMER_ID
      AND [POS_TERMINAL] = @CODE_ROUTE
      AND [DOC_SERIE] = @DOC_SERIE
      AND [DOC_NUM] = @DOC_NUM

      --      

      INSERT INTO @CONSIGNMENTS_RESULT ([CONSIGNMENT_ID], [CUSTOMER_ID], [CODE_ROUTE], [DOC_SERIE], [DOC_NUM])
        VALUES (@CONSIGNMENT_ID, @CUSTOMER_ID, @CODE_ROUTE, @DOC_SERIE, @DOC_NUM);


    END TRY
    BEGIN CATCH
      SET @LOG_MESSAGE = ERROR_MESSAGE()
      EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = @CODE_ROUTE
                                                           ,@LOGIN = @CUSTOMER_ID
                                                           ,@SOURCE_ERROR = 'SWIFT_SP_UPDATE_CONSIGNMENT_STATUS_BY_XML'
                                                           ,@DOC_RESOLUTION = NULL
                                                           ,@DOC_SERIE = @DOC_SERIE
                                                           ,@DOC_NUM = @DOC_NUM
                                                           ,@MESSAGE_ERROR = @LOG_MESSAGE
                                                           ,@SEVERITY_CODE = 10

    END CATCH

      DELETE FROM @CONSIGNMENTS
      WHERE [CONSIGNMENT_ID] = @CONSIGNMENT_ID

    END

    --

    SELECT
      1 AS RESULTADO
     ,[CONSIGNMENT_ID]
     ,[CUSTOMER_ID]
     ,[CODE_ROUTE]
     ,[DOC_SERIE]
     ,[DOC_NUM]
    FROM @CONSIGNMENTS_RESULT

  END TRY
  BEGIN CATCH
    --    


    SELECT
      -1 AS [RESULTADO]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo]
     ,0 [DbData];

  END CATCH
END
