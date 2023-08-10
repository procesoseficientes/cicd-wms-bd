-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/27/2017 @ Sprint Bearbeitung
-- Description:			Agrega un registro a la tabla SWIFT_HISTORY_BY_PROMO por XML

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_ADD_HISTORY_BY_PROMO_BY_XML]
@XML = '<?xml version="1.0"?>
<Data>
    <historialDePromociones>
        <docSerie>136</docSerie>
        <docNum>2</docNum>
        <codeRoute>136</codeRoute>
        <codeCustomer>SO-151144</codeCustomer>
        <historyDateTime>2017-08-23T04:36:49.716Z</historyDateTime>
        <promoId>2124</promoId>
        <promoName>Promo Desc x sku hec1</promoName>
        <frequency>ALWAYS</frequency>
    </historialDePromociones>
    <historialDePromociones>
        <docSerie>136</docSerie>
        <docNum>3</docNum>
        <codeRoute>136</codeRoute>
        <codeCustomer>SO-151144</codeCustomer>
        <historyDateTime>2017-08-23T03:46:47.191Z</historyDateTime>
        <promoId>3183</promoId>
        <promoName>Promo boni x escalas hec1</promoName>
        <frequency>DAY</frequency>
    </historialDePromociones>
    <historialDePromociones>
        <docSerie>136</docSerie>
        <docNum>4</docNum>
        <codeRoute>136</codeRoute>
        <codeCustomer>SO-151144</codeCustomer>
        <historyDateTime>2017-08-23T03:46:47.191Z</historyDateTime>
        <promoId>3193</promoId>
        <promoName>promo boni x multi hec1</promoName>
        <frequency>ALWAYS</frequency>
    </historialDePromociones>
    <historialDePromociones>
        <docSerie>136</docSerie>
        <docNum>5</docNum>
        <codeRoute>136</codeRoute>
        <codeCustomer>SO-151144</codeCustomer>
        <historyDateTime>2017-08-23T04:36:49.716Z</historyDateTime>
        <promoId>3185</promoId>
        <promoName>boni BMG hec1</promoName>
        <frequency>WEEK</frequency>
    </historialDePromociones>
    <historialDePromociones>
        <docSerie>136</docSerie>
        <docNum>6</docNum>
        <codeRoute>136</codeRoute>
        <codeCustomer>SO-151144</codeCustomer>
        <historyDateTime>2017-08-23T04:36:49.716Z</historyDateTime>
        <promoId>2124</promoId>
        <promoName>Promo Desc x sku hec1</promoName>
        <frequency>ALWAYS</frequency>
    </historialDePromociones>
    <historialDePromociones>
        <docSerie>136</docSerie>
        <docNum>7</docNum>
        <codeRoute>136</codeRoute>
        <codeCustomer>SO-151144</codeCustomer>
        <historyDateTime>2017-08-23T04:36:49.716Z</historyDateTime>
        <promoId>3193</promoId>
        <promoName>promo boni x multi hec1</promoName>
        <frequency>ALWAYS</frequency>
    </historialDePromociones>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>136</routeid>
</Data>'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_ADD_HISTORY_BY_PROMO_BY_XML (@XML XML)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @CODE_ROUTE VARCHAR(50)
         ,@CODE_CUSTOMER VARCHAR(50)
         ,@HISTORY_DATETIME DATETIME
         ,@PROMO_ID INT
         ,@PROMO_NAME VARCHAR(50)
         ,@FREQUENCY VARCHAR(50)
         ,@DOC_SERIE VARCHAR(100)
         ,@DOC_NUM INT
		 ,@SERVER_POSTED_DATETIME DATETIME = GETDATE()
		 ,@DEVICE_NETWORK_TYPE VARCHAR(50)
		 ,@IS_POSTED_OFFLINE INT
		 ,@SALES_ORDER_DOCUMENT_NUMBER INT
		 ,@SALES_ORDER_DOCUMENT_SERIES VARCHAR(250)
	--
	DECLARE @RESULT AS TABLE(
		DOC_SERIE VARCHAR(100)
		, DOC_NUM INT		
		, RESULT INT
		, [ERROR_MESSAGE] VARCHAR(MAX)
		, SERVER_POSTED_DATETIME DATETIME
	);
  
  --
  SELECT
    [x].[Rec].[query]('./docSerie').[value]('.', 'VARCHAR(100)') [DOC_SERIE]
   ,[x].[Rec].[query]('./docNum').[value]('.', 'INT') [DOC_NUM]
   ,[x].[Rec].[query]('./codeRoute').[value]('.', 'VARCHAR(50)') [CODE_ROUTE]
   ,[x].[Rec].[query]('./codeCustomer').[value]('.', 'VARCHAR(50)') [CODE_CUSTOMER]
   ,[x].[Rec].[query]('./historyDateTime').[value]('.', 'DATETIME') [HISTORY_DATETIME]
   ,[x].[Rec].[query]('./promoId').[value]('.', 'INT') [PROMO_ID]
   ,[x].[Rec].[query]('./promoName').[value]('.', 'VARCHAR(50)') [PROMO_NAME]
   ,[x].[Rec].[query]('./frequency').[value]('.', 'VARCHAR(50)') [FREQUENCY]
   ,[x].Rec.query('./deviceNetworkType').value('.', 'varchar(15)') DEVICE_NETWORK_TYPE
   ,CASE [x].Rec.query('./isPostedOffLine').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE [x].Rec.query('./isPostedOffLine').value('.', 'int') END AS IS_POSTED_OFFLINE
   ,[x].[Rec].[query]('./salesOrderDocumentNumber').[value]('.', 'INT') [SALES_ORDER_DOCUMENT_NUMBER]
   ,[x].[Rec].[query]('./salesOrderDocumentSeries').[value]('.', 'VARCHAR(250)') [SALES_ORDER_DOCUMENT_SERIES]
  INTO [#XMLMATERIAL]
  FROM @XML.[nodes]('/Data/historialDePromociones') AS [x] ([Rec]);
  
  --
  CREATE NONCLUSTERED INDEX IN_#XMLMATERIAL_CODE_CUSTOMER_PROMO_ID
  ON [#XMLMATERIAL] ([CODE_CUSTOMER], [PROMO_ID])

  -- ------------------------------------------------------------------------------------
  -- Lee los registros del XML y los inserta en la tabla SWIFT_HISTORY_BY_PROMO
  -- ------------------------------------------------------------------------------------
  WHILE EXISTS (SELECT TOP 1 1 FROM [#XMLMATERIAL])
  BEGIN
    SELECT TOP 1
      @DOC_SERIE = [DOC_SERIE]
     ,@DOC_NUM = [DOC_NUM]
     ,@CODE_ROUTE = [CODE_ROUTE]
     ,@CODE_CUSTOMER = [CODE_CUSTOMER]
     ,@HISTORY_DATETIME = [HISTORY_DATETIME]
     ,@PROMO_ID = [PROMO_ID]
     ,@PROMO_NAME = [PROMO_NAME]
     ,@FREQUENCY = [FREQUENCY]
	 ,@IS_POSTED_OFFLINE = [IS_POSTED_OFFLINE]
	 ,@DEVICE_NETWORK_TYPE = [DEVICE_NETWORK_TYPE]
	 ,@SALES_ORDER_DOCUMENT_NUMBER = [SALES_ORDER_DOCUMENT_NUMBER]
	 ,@SALES_ORDER_DOCUMENT_SERIES = [SALES_ORDER_DOCUMENT_SERIES]
    FROM [#XMLMATERIAL]

	
	--
	BEGIN TRY
   BEGIN TRAN
    UPDATE [SONDA].[SWIFT_HISTORY_BY_PROMO]
    SET [LAST_APPLIED] = 0
    WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
    AND [PROMO_ID] = @PROMO_ID;


		INSERT	INTO [SONDA].[SWIFT_HISTORY_BY_PROMO]
				(
					[DOC_SERIE]
					,[DOC_NUM]
					,[CODE_ROUTE]
					,[CODE_CUSTOMER]
					,[HISTORY_DATETIME]
					,[PROMO_ID]
					,[PROMO_NAME]
					,[FREQUENCY]
					,[LAST_APPLIED]
					,[IS_POSTED]
					,[IS_POSTED_OFFLINE]
					,[DEVICE_NETWORK_TYPE]
					,[SERVER_POSTED_DATETIME]
					,SALES_ORDER_DOCUMENT_NUMBER 
					,SALES_ORDER_DOCUMENT_SERIES 
				)	 
		VALUES
				(
					@DOC_SERIE
					,@DOC_NUM
					,@CODE_ROUTE
					,@CODE_CUSTOMER
					,@HISTORY_DATETIME
					,@PROMO_ID
					,@PROMO_NAME
					,@FREQUENCY
					,1
					,2
					,@IS_POSTED_OFFLINE
					,@DEVICE_NETWORK_TYPE
					,@SERVER_POSTED_DATETIME
					,@SALES_ORDER_DOCUMENT_NUMBER
					,@SALES_ORDER_DOCUMENT_SERIES
				);
		
    --
		INSERT INTO @RESULT
				(
					[DOC_SERIE]
					,[DOC_NUM]
					,[RESULT]
					,[ERROR_MESSAGE]
					,[SERVER_POSTED_DATETIME]
				)
		VALUES
				(
					@DOC_SERIE  -- DOC_SERIE - varchar(100)
					,@DOC_NUM  -- DOC_NUM - int
					,1  -- RESULT - int
					,NULL  -- ERROR_MESSAGE - varchar(250)
					,@SERVER_POSTED_DATETIME
				);
    COMMIT
	END TRY
	BEGIN CATCH
		IF(@@ERROR = 2627) BEGIN
			INSERT INTO @RESULT
					(
						[DOC_SERIE]
						,[DOC_NUM]
						,[RESULT]
						,[ERROR_MESSAGE]
						,[SERVER_POSTED_DATETIME]
					)
			VALUES
					(
						@DOC_SERIE  -- DOC_SERIE - varchar(100)
						,@DOC_NUM  -- DOC_NUM - int
						,1  -- RESULT - int
						,NULL  -- ERROR_MESSAGE - varchar(250)
						,(SELECT [SERVER_POSTED_DATETIME] FROM [SONDA].[SWIFT_HISTORY_BY_PROMO] WHERE [DOC_SERIE] = @DOC_SERIE AND [DOC_NUM] = @DOC_NUM)
					);
		END
		ELSE BEGIN
			INSERT INTO @RESULT
					(
						[DOC_SERIE]
						,[DOC_NUM]
						,[RESULT]
						,[ERROR_MESSAGE]
					)
			VALUES
					(
						@DOC_SERIE  -- DOC_SERIE - varchar(100)
						,@DOC_NUM  -- DOC_NUM - int
						,0  -- RESULT - int
						,('ERROR: ' + CAST(@@ERROR AS VARCHAR(50)) + ' ' + ERROR_MESSAGE())  -- ERROR_MESSAGE - varchar(250)
					);
		END
		ROLLBACK
	END CATCH   

	--
    DELETE FROM [#XMLMATERIAL]
    WHERE [DOC_SERIE] = @DOC_SERIE
      AND [DOC_NUM] = @DOC_NUM
  END

  --
  SELECT [DOC_SERIE]
		,[DOC_NUM]
		,[RESULT]
		,[ERROR_MESSAGE]
		,[SERVER_POSTED_DATETIME] 
  FROM @RESULT
  WHERE RESULT = 1

END
