-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	03-Apr-17 @ A-TEAM Sprint Garai 
-- Description:			SP que valida las facturas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_INVOICE_IS_POSTED]
					@XML = '<?xml version="1.0"?>
<Data>
    <Invoices>
        <IdBo>417</IdBo>
        <InvoiceId>35</InvoiceId>
        <AuthId>1323123</AuthId>
        <SatSerie>Serie de R</SatSerie>
        <ClientId>1144</ClientId>
        <PostedDatetime>2017/04/03 12:43:20</PostedDatetime>
        <DetailNum>1</DetailNum>
    </Invoices>
    <Invoices>
        <IdBo>418</IdBo>
        <InvoiceId>36</InvoiceId>
        <AuthId>1323123</AuthId>
        <SatSerie>Serie de R</SatSerie>
        <ClientId>125</ClientId>
        <PostedDatetime>2017/04/03 12:43:51</PostedDatetime>
        <DetailNum>1</DetailNum>
    </Invoices>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>7</routeid>
    <Source></Source>
</Data>'
					,@JSON = '{
   "Data": {
      "Invoices": [
         {
            "IdBo": "417",
            "InvoiceId": "35",
            "AuthId": "1323123",
            "SatSerie": "Serie de R",
            "ClientId": "1144",
            "PostedDatetime": "2017/04/03 12:43:20",
            "DetailNum": "1"
         },
         {
            "IdBo": "418",
            "InvoiceId": "36",
            "AuthId": "1323123",
            "SatSerie": "Serie de R",
            "ClientId": "125",
            "PostedDatetime": "2017/04/03 12:43:51",
            "DetailNum": "1"
         }
      ],
      "dbuser": "USONDA",
      "dbuserpass": "SONDAServer1237710",
      "routeid": "7",
      "Source": ""
   }
}'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_INVOICE_IS_POSTED](
	@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@INVOICE TABLE (
		[ID] INT
		,[DOC_RESOLUTION] VARCHAR(100)
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		,[CODE_CUSTOMER] VARCHAR(50)
		,[POSTED_DATIME] DATETIME
		,[DETAIL_QTY] INT
	);
	--
	DECLARE @RESUTL_VALIDATION TABLE (
		[EXISTS] [INT]
		,[ID] [INT]
		,[DOC_RESOLUTION] VARCHAR(100)
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		
	)
	--
	DECLARE 
		@CODE_ROUTE VARCHAR(50)
		,@ID INT
		,@POSTED_DATIME DATETIME
		,@DETAIL_QTY INT
		,@DOC_RESOLUTION VARCHAR(100)
		,@DOC_SERIE VARCHAR(100)
		,@DOC_NUM INT
		,@CODE_CUSTOMER VARCHAR(50)
		,@INVOICE_XML XML;
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos generales de la ruta
	-- ------------------------------------------------------------------------------------
	SELECT 
		@CODE_ROUTE = [x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)')
	FROM @xml.[nodes]('/Data') as [x]([Rec])

	-- ------------------------------------------------------------------------------------
	-- Obtiene las facturas a validar
	-- ------------------------------------------------------------------------------------
	INSERT INTO @INVOICE
			(
				[ID]
				,[DOC_RESOLUTION]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[CODE_CUSTOMER]
				,[POSTED_DATIME]
				,[DETAIL_QTY]
			)
	SELECT
		CASE [x].[Rec].[query]('./IdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./IdBo').[value]('.', 'int') END
		,[x].[Rec].[query]('./AuthId').[value]('.', 'varchar(50)')
		,[x].[Rec].[query]('./SatSerie').[value]('.', 'varchar(50)')
		,[x].[Rec].[query]('./InvoiceId').[value]('.', 'int')
		,[x].[Rec].[query]('./ClientId').[value]('.', 'varchar(50)')
		,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime')
		,[x].[Rec].[query]('./DetailNum').[value]('.', 'int')
	FROM @xml.[nodes]('/Data/Invoices') as [x]([Rec])
	PRINT('1')
	-- ------------------------------------------------------------------------------------
	-- Ciclo para validar factuas
	-- ------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP 1 1 FROM @INVOICE)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Se toma factura a valdiar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@ID = [ID]
			,@DOC_RESOLUTION = [DOC_RESOLUTION]
			,@DOC_SERIE = [DOC_SERIE]
			,@DOC_NUM = [DOC_NUM]
			,@CODE_CUSTOMER = [CODE_CUSTOMER]
			,@POSTED_DATIME = [POSTED_DATIME]
			,@DETAIL_QTY = [DETAIL_QTY]
		FROM @INVOICE
		PRINT('2')
		-- ------------------------------------------------------------------------------------
		-- Valida si existe la factura
		-- ------------------------------------------------------------------------------------
		SELECT @INVOICE_XML = (
			SELECT 
				CASE [x].[Rec].[query]('./IdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./IdBo').[value]('.', 'int') END IdBo
				,[x].[Rec].[query]('./AuthId').[value]('.', 'varchar(50)') AuthId
				,[x].[Rec].[query]('./SatSerie').[value]('.', 'varchar(50)') SatSerie
				,[x].[Rec].[query]('./InvoiceId').[value]('.', 'int') InvoiceId
				,[x].[Rec].[query]('./ClientId').[value]('.', 'varchar(50)') ClientId
				,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime') PostedDatetime
				,[x].[Rec].[query]('./DetailNum').[value]('.', 'int') DetailNum
			FROM @xml.[nodes]('/Data/Invoices') as [x]([Rec])
			WHERE CASE [x].[Rec].[query]('./IdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./IdBo').[value]('.', 'int') END = @ID
			FOR XML PATH ('Invoices'),ROOT('Data')
		)
		PRINT('3')
		--
		INSERT INTO @RESUTL_VALIDATION
		EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_INVOICE] 
			@CODE_ROUTE = @CODE_ROUTE
			,@CODE_CUSTOMER = @CODE_CUSTOMER
			,@DOC_RESOLUTION = @DOC_RESOLUTION
			,@DOC_SERIE = @DOC_SERIE
			,@DOC_NUM = @DOC_NUM
			,@POSTED_DATETIME = @POSTED_DATIME
			,@DETAIL_QTY = @DETAIL_QTY
			,@DECREASE_INVENTORY = 1
			,@XML = @INVOICE_XML
			,@JSON = @JSON

		-- ------------------------------------------------------------------------------------
		-- Se elimina factura validada
		-- ------------------------------------------------------------------------------------
		DELETE FROM @INVOICE WHERE [ID] = @ID OR (
			ID IS NULL
			AND
			@ID IS NULL
		)
	END

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT
		[EXISTS] [RESULT]
		,[ID]
		,[DOC_RESOLUTION]
		,[DOC_SERIE]
		,[DOC_NUM]
	FROM @RESUTL_VALIDATION
END
