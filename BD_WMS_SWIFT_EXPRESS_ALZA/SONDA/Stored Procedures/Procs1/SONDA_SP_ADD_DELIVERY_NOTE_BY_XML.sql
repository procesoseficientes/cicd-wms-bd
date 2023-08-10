-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	11/13/2017 @ Reborn - TEAM Sprint Eberhard
-- Description:			SP que agrega el nuevo registro de Nota de Entrega

-- Modificacion 12/11/2017 @ Reborn-Team Sprint Pannen
					-- diego.as
					-- Se agrega insercion de columnas IS_CANCELED y REASON_CANCEL

-- Modificacion 12/14/2017 @ Reborn - Team Sprint Pannen
					-- diego.as
					-- Se agrega insercion de columna DISCOUNT

-- Modificacion 1/19/2018 @ Reborn-Team Sprint Strom
					-- diego.as
					-- Se agrega validacion de identificador de dispositivo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_ADD_DELIVERY_NOTE_BY_XML]
				@XML = '
					
<Data>
    <notasDeEntrega>
        <detalleNotaDeEntrega>
            <deliveryNoteDetailId>null</deliveryNoteDetailId>
            <deliveryNoteId>-1</deliveryNoteId>
            <codeSku>100036</codeSku>
            <qty>1</qty>
            <price>9</price>
            <totalLine>9</totalLine>
            <isBonus>0</isBonus>
            <appliedDiscount>null</appliedDiscount>
            <createdDateTime>2017/11/16 20:01:04</createdDateTime>
            <postedDateTime>null</postedDateTime>
        </detalleNotaDeEntrega>
        <detalleNotaDeEntrega>
            <deliveryNoteDetailId>null</deliveryNoteDetailId>
            <deliveryNoteId>-1</deliveryNoteId>
            <codeSku>100040</codeSku>
            <qty>1</qty>
            <price>9</price>
            <totalLine>9</totalLine>
            <isBonus>0</isBonus>
            <appliedDiscount>null</appliedDiscount>
            <createdDateTime>2017/11/16 20:01:04</createdDateTime>
            <postedDateTime>null</postedDateTime>
        </detalleNotaDeEntrega>
        <detalleNotaDeEntrega>
            <deliveryNoteDetailId>null</deliveryNoteDetailId>
            <deliveryNoteId>-1</deliveryNoteId>
            <codeSku>100069</codeSku>
            <qty>3</qty>
            <price>15</price>
            <totalLine>45</totalLine>
            <isBonus>0</isBonus>
            <appliedDiscount>null</appliedDiscount>
            <createdDateTime>2017/11/16 20:01:04</createdDateTime>
            <postedDateTime>null</postedDateTime>
        </detalleNotaDeEntrega>
        <deliveryNoteId>-1</deliveryNoteId>
        <docSerie>Nota De Entrega</docSerie>
        <docNum>1</docNum>
        <codeCustomer>SO-155137</codeCustomer>
        <deliveryNoteIdHh>-1</deliveryNoteIdHh>
        <totalAmount>63</totalAmount>
        <isPosted>0</isPosted>
        <createdDateTime>2017/11/16 20:01:04</createdDateTime>
        <postedDateTime>null</postedDateTime>
        <taskId>430866</taskId>
        <invoiceId>146</invoiceId>
        <consignmentId>null</consignmentId>
        <devolutionId>null</devolutionId>
		<billedFromSonda>1</billedFromSonda>
		<isCanceled>0</isCanceled>
		<reasonCancel>null</reasonCancel>
        <deliveryImage>data:image/jpeg;base64,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</deliveryImage>
    </notasDeEntrega>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>46</routeid>
    <loginId>Adolfo@SONDA</loginId>
	<deviceId>3b396881f40a8de3</deviceId>
</Data>
				
				'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_ADD_DELIVERY_NOTE_BY_XML] (@XML XML)
AS
BEGIN
  BEGIN TRY
    DECLARE @ID INT
           ,@DELIVERY_NOTE_ID_HH INT
           ,@DELIVERY_NOTE_DOC_SERIE VARCHAR(250)
           ,@DELIVERY_NOTE_DOC_NUM INT
           ,@INVOICE_ID INT = NULL
           ,@CONSIGNMENT_ID INT = NULL
           ,@DEVOLUTION_ID INT = NULL
           ,@DELIVERY_NOTE_BY_INVOICE_ID INT
           ,@DELIVERY_NOTE_BY_CONSIGNMENT_ID INT
           ,@DELIVERY_NOTE_BY_DEVOLUTION_ID INT
		   ,@CODE_ROUTE VARCHAR(50)
		   ,@DEVICE_ID VARCHAR(50);

    --

    DECLARE @DELIVERY_NOTE_HEADER TABLE (
      [DOC_SERIE] [VARCHAR](250) NOT NULL
     ,[DOC_NUM] [INT] NOT NULL
     ,[CODE_CUSTOMER] [VARCHAR](250) NOT NULL
     ,[DELIVERY_NOTE_ID_HH] [INT] NOT NULL
     ,[TOTAL_AMOUNT] [NUMERIC](18, 6) NOT NULL
     ,[CREATED_DATETIME] [DATETIME] NOT NULL
     ,[TASK_ID] [INT] NULL
     ,[INVOICE_ID] [INT] NULL
     ,[CONSIGNMENT_ID] [INT] NULL
     ,[DEVOLUTION_ID] [INT] NULL
     ,[DELIVERY_IMAGE] [VARCHAR](MAX)
     ,[BILLED_FROM_SONDA] INT
	 ,[IS_CANCELED] INT
	 ,[REASON_CANCEL] VARCHAR(250)
	 ,[DISCOUNT] NUMERIC(18,6)
     ,UNIQUE ([DOC_SERIE], [DOC_NUM])
    );

    --

    DECLARE @DELIVERY_NOTE_DETAIL TABLE (
      [DELIVERY_NOTE_ID] [INT] NOT NULL
     ,[CODE_SKU] [VARCHAR](250) NOT NULL
     ,[QTY] [NUMERIC](18, 6) NOT NULL
     ,[PRICE] [NUMERIC](18, 6) NOT NULL
     ,[TOTAL_LINE] [NUMERIC](18, 6) NOT NULL
     ,[IS_BONUS] [INT] NOT NULL
     ,[APPLIED_DISCOUNT] [NUMERIC](18, 6) NOT NULL
     ,[CREATED_DATETIME] [DATETIME] NOT NULL
     ,[POSTED_DATETIME] [DATETIME] NULL
     ,[PICKING_DEMAND_HEADER_ID] INT
    );

    --

    DECLARE @DELIVERY_NOTE_RESULT TABLE (
      DELIVERY_NOTE_ID INT
     ,DELIVERY_NOTE_BY_INVOICE_ID INT
     ,DELIVERY_NOTE_BY_CONSIGNMENT_ID INT
     ,DELIVERY_NOTE_BY_DEVOLUTION_ID INT
     ,DELIVERY_NOTE_DOC_SERIE VARCHAR(250)
     ,DELIVERY_NOTE_DOC_NUM INT
     ,IS_POSTED INT
    );

    -- --------------------------------------------------------------------------------------------------------
	SELECT 
		@CODE_ROUTE = x.[Rec].query('./routeid').value('.','varchar(50)')
		,@DEVICE_ID = x.[Rec].query('./deviceId').value('.','varchar(50)')
	FROM @XML.nodes('Data') AS x (Rec)

	-- --------------------------------------------------------------------------------------------------------
	EXEC [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION] @CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
		@DEVICE_ID = @DEVICE_ID -- varchar(50)
	

	-- --------------------------------------------------------------------------------------------------------
    INSERT INTO @DELIVERY_NOTE_HEADER ([DOC_SERIE]
    , [DOC_NUM]
    , [CODE_CUSTOMER]
    , [DELIVERY_NOTE_ID_HH]
    , [TOTAL_AMOUNT]
    , [CREATED_DATETIME]
    , [TASK_ID]
    , [INVOICE_ID]
    , [CONSIGNMENT_ID]
    , [DEVOLUTION_ID]
    , [DELIVERY_IMAGE]
    , [BILLED_FROM_SONDA]
	, [IS_CANCELED]
	, [REASON_CANCEL]
	, [DISCOUNT])
      SELECT
        x.Rec.query('./docSerie').value('.', 'varchar(250)')
       ,x.Rec.query('./docNum').value('.', 'int')
       ,x.Rec.query('./codeCustomer').value('.', 'varchar(250)')
       ,x.Rec.query('./deliveryNoteIdHh').value('.', 'int')
       ,x.Rec.query('./totalAmount').value('.', 'numeric(18,6)')
       ,x.Rec.query('./createdDateTime').value('.', 'varchar(50)')
       ,x.Rec.query('./taskId').value('.', 'int')
       ,CASE [x].[Rec].[query]('./invoiceId').value('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./invoiceId').value('.', 'int')
        END
       ,CASE [x].[Rec].[query]('./consignmentId').value('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./consignmentId').value('.', 'int')
        END
       ,CASE [x].[Rec].[query]('./devolutionId').value('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./devolutionId').value('.', 'int')
        END
       ,x.Rec.query('./deliveryImage').value('.', 'varchar(MAX)')
       ,CASE [x].[Rec].[query]('./billedFromSonda').value('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./billedFromSonda').value('.', 'int')
        END
		,CASE [x].[Rec].[query]('./isCanceled').value('.', 'varchar(50)')
          WHEN 'NULL' THEN 0
          WHEN 'UNDEFINED' THEN 0
          ELSE [x].[Rec].[query]('./isCanceled').value('.', 'int')
        END
		,CASE [x].[Rec].[query]('./reasonCancel').value('.', 'varchar(250)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./reasonCancel').value('.', 'varchar(250)')
        END
		,CASE [x].[Rec].[query]('./discount').[value]('.', 'varchar(50)') 
			WHEN 'NULL' THEN 0 
			WHEN 'UNDEFINED' THEN 0 
			ELSE [x].[Rec].[query]('./discount').[value]('.', 'numeric(18,6)') 
		END
      FROM @XML.nodes('Data/notasDeEntrega') AS x (Rec)

    -- ----------------------------------------------------------------------------------------------------------

    INSERT INTO @DELIVERY_NOTE_DETAIL ([DELIVERY_NOTE_ID]
    , [CODE_SKU]
    , [QTY]
    , [PRICE]
    , [TOTAL_LINE]
    , [IS_BONUS]
    , [APPLIED_DISCOUNT]
    , [CREATED_DATETIME]
    , [PICKING_DEMAND_HEADER_ID])
      SELECT
        x.Rec.query('./deliveryNoteId').value('.', 'int')
       ,x.Rec.query('./codeSku').value('.', 'varchar(250)')
       ,x.Rec.query('./qty').value('.', 'numeric(18,6)')
       ,x.Rec.query('./price').value('.', 'numeric(18,6)')
       ,x.Rec.query('./totalLine').value('.', 'numeric(18,6)')
       ,x.Rec.query('./isBonus').value('.', 'int')
       ,CASE [x].[Rec].[query]('./appliedDiscount').value('.', 'varchar(50)')
          WHEN 'NULL' THEN 0
          WHEN 'UNDEFINED' THEN 0
          ELSE [x].[Rec].[query]('./appliedDiscount').value('.', 'numeric(18,6)')
        END
       ,x.Rec.query('./createdDateTime').value('.', 'varchar(50)')
       ,CASE [x].[Rec].[query]('./relatedPickingDemandHeaderId').value('.', 'varchar(50)')
          WHEN 'NULL' THEN 0
          WHEN 'UNDEFINED' THEN 0
          ELSE [x].[Rec].[query]('./relatedPickingDemandHeaderId').value('.', 'int')
        END
      FROM @XML.nodes('Data/notasDeEntrega/detalleNotaDeEntrega') AS x (Rec)

    -- ----------------------------------------------------------------------------------------------------------

    WHILE EXISTS (SELECT TOP 1
          1
        FROM @DELIVERY_NOTE_HEADER)
    BEGIN

      SELECT TOP 1
        @DELIVERY_NOTE_ID_HH = DN.[DELIVERY_NOTE_ID_HH]
       ,@DELIVERY_NOTE_DOC_NUM = DN.[DOC_NUM]
       ,@DELIVERY_NOTE_DOC_SERIE = DN.[DOC_SERIE]
       ,@INVOICE_ID = DN.[INVOICE_ID]
       ,@CONSIGNMENT_ID = DN.[CONSIGNMENT_ID]
       ,@DEVOLUTION_ID = DN.[DEVOLUTION_ID]
      FROM @DELIVERY_NOTE_HEADER AS DN

      --
      BEGIN TRAN INSERT_DELIVERY_NOTE_TRANS

    --
    BEGIN TRY
      --
      INSERT INTO [SONDA].[SONDA_DELIVERY_NOTE_HEADER] ([DOC_SERIE]
      , [DOC_NUM]
      , [CODE_CUSTOMER]
      , [DELIVERY_NOTE_ID_HH]
      , [TOTAL_AMOUNT]
      , [IS_POSTED]
      , [CREATED_DATETIME]
      , [TASK_ID]
      , [INVOICE_ID]
      , [CONSIGNMENT_ID]
      , [DEVOLUTION_ID]
      , [DELIVERY_IMAGE]
      , [BILLED_FROM_SONDA]
	  , [IS_CANCELED]
	  , [REASON_CANCEL]
	  , [DISCOUNT])
        SELECT
          [DOC_SERIE]
         ,[DOC_NUM]
         ,[CODE_CUSTOMER]
         ,[DELIVERY_NOTE_ID_HH]
         ,[TOTAL_AMOUNT]
         ,2
         ,[CREATED_DATETIME]
         ,[TASK_ID]
         ,[INVOICE_ID]
         ,[CONSIGNMENT_ID]
         ,[DEVOLUTION_ID]
         ,[DELIVERY_IMAGE]
         ,[BILLED_FROM_SONDA]
		 ,[IS_CANCELED]
		 ,[REASON_CANCEL]
		 ,[DISCOUNT]
        FROM @DELIVERY_NOTE_HEADER
        WHERE [DOC_NUM] = @DELIVERY_NOTE_DOC_NUM
        AND [DOC_SERIE] = @DELIVERY_NOTE_DOC_SERIE

      --
      SET @ID = SCOPE_IDENTITY();

      --
      INSERT INTO [SONDA].[SONDA_DELIVERY_NOTE_DETAIL] ([DELIVERY_NOTE_ID]
      , [CODE_SKU]
      , [QTY]
      , [PRICE]
      , [TOTAL_LINE]
      , [IS_BONUS]
      , [APPLIED_DISCOUNT]
      , [CREATED_DATETIME]
      , [PICKING_DEMAND_HEADER_ID])
        SELECT
          @ID
         ,[DND].[CODE_SKU]
         ,[DND].[QTY]
         ,[DND].[PRICE]
         ,[DND].[TOTAL_LINE]
         ,[DND].[IS_BONUS]
         ,[DND].[APPLIED_DISCOUNT]
         ,[DND].[CREATED_DATETIME]
         ,[DND].[PICKING_DEMAND_HEADER_ID]
        FROM @DELIVERY_NOTE_DETAIL AS DND
        WHERE DND.[DELIVERY_NOTE_ID] = @DELIVERY_NOTE_ID_HH

      --
      IF (@INVOICE_ID IS NOT NULL)
      BEGIN
        --
        EXEC [SONDA].[SONDA_SP_ADD_DELIVERY_NOTE_BY_INVOICE] @DELIVERY_NOTE_DOC_SERIE = @DELIVERY_NOTE_DOC_SERIE
                                                          ,@DELIVERY_NOTE_DOC_NUM = @DELIVERY_NOTE_DOC_NUM
                                                          ,@INVOICE_ID = @INVOICE_ID
                                                          ,@DELIVERY_NOTE_BY_INVOICE_ID = @DELIVERY_NOTE_BY_INVOICE_ID OUTPUT
      --
      END

      --
      INSERT INTO @DELIVERY_NOTE_RESULT ([DELIVERY_NOTE_ID]
      , [DELIVERY_NOTE_DOC_SERIE]
      , [DELIVERY_NOTE_DOC_NUM]
      , [IS_POSTED]
      , [DELIVERY_NOTE_BY_INVOICE_ID]
      , [DELIVERY_NOTE_BY_CONSIGNMENT_ID]
      , [DELIVERY_NOTE_BY_DEVOLUTION_ID])
        VALUES (@ID, @DELIVERY_NOTE_DOC_SERIE, @DELIVERY_NOTE_DOC_NUM, 2, @DELIVERY_NOTE_BY_INVOICE_ID, @DELIVERY_NOTE_BY_CONSIGNMENT_ID, @DELIVERY_NOTE_BY_DEVOLUTION_ID)
      --
      COMMIT TRANSACTION [INSERT_DELIVERY_NOTE_TRANS]

    END TRY
    BEGIN CATCH

		DECLARE @ERROR2 VARCHAR(MAX);
		SET @ERROR2 = ERROR_MESSAGE();

		PRINT(@ERROR2);

      --
      ROLLBACK TRANSACTION [INSERT_DELIVERY_NOTE_TRANS]

      --
      INSERT INTO @DELIVERY_NOTE_RESULT ([DELIVERY_NOTE_ID]
      , [DELIVERY_NOTE_DOC_SERIE]
      , [DELIVERY_NOTE_DOC_NUM]
      , [IS_POSTED]
      , [DELIVERY_NOTE_BY_INVOICE_ID]
      , [DELIVERY_NOTE_BY_CONSIGNMENT_ID]
      , [DELIVERY_NOTE_BY_DEVOLUTION_ID])
        VALUES (@ID, @DELIVERY_NOTE_DOC_SERIE, @DELIVERY_NOTE_DOC_NUM, 0, @DELIVERY_NOTE_BY_INVOICE_ID, @DELIVERY_NOTE_BY_CONSIGNMENT_ID, @DELIVERY_NOTE_BY_DEVOLUTION_ID)

    END CATCH

      --
      DELETE FROM @DELIVERY_NOTE_HEADER
      WHERE [DOC_NUM] = @DELIVERY_NOTE_DOC_NUM
        AND [DOC_SERIE] = @DELIVERY_NOTE_DOC_SERIE

      --
      DELETE FROM @DELIVERY_NOTE_DETAIL
      WHERE [DELIVERY_NOTE_ID] = @DELIVERY_NOTE_ID_HH

    END

    --
    SELECT
      [DELIVERY_NOTE_ID]
     ,[DELIVERY_NOTE_BY_INVOICE_ID]
     ,[DELIVERY_NOTE_BY_CONSIGNMENT_ID]
     ,[DELIVERY_NOTE_BY_DEVOLUTION_ID]
     ,[DELIVERY_NOTE_DOC_SERIE]
     ,[DELIVERY_NOTE_DOC_NUM]
     ,[IS_POSTED]
    FROM @DELIVERY_NOTE_RESULT

  END TRY
  BEGIN CATCH
    --
    DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();

    --
    RAISERROR (@ERROR, 16, 1);

  END CATCH
END
