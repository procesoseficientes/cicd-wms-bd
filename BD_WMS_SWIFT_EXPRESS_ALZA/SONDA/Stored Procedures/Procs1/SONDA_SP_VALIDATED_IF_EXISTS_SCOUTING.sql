-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/16/2017 @ A-TEAM Sprint Jibade 
-- Description:			Valida si existe un scouting

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SCOUTING]
					@CODE_ROUTE = '46', -- varchar(50)
					@CODE_CUSTOMER = 'SO-1322', -- varchar(50)
					@DOC_SERIE = 'ADOLFO@SONDA', -- varchar(50)
					@DOC_NUM = 3, -- int
					@SYNC_ID = '46|Adolfo@SONDA|2017/06/16 10:24:19|-4', -- varchar(250)
					@POSTED_DATIME = '2017-06-16 10:24:19.000', -- datetime
					@TAG_QTY = 10, -- int
					@XML = 
						N'<Data>
						  <Scouting>
							<CodeCustomer>SO-1322</CodeCustomer>
							<DocSerie>ADOLFO@SONDA</DocSerie>
							<DocNum>3</DocNum>
							<SyncId>46|Adolfo@SONDA|2017/06/16 10:24:19|-4</SyncId>
							<PostedDatetime>2017-06-16 10:24:19.000</PostedDatetime>
							<TagQty>10</TagQty>
						  </Scouting>
						</Data>', -- xml
					@JSON = '{"Data":{"scouting":[{"clientId":"-2","docSerie":"ADOLFO@SONDA","docNum":"1","postedDatetime":"2017/06/16 10:21:33","tagsQty":"5","syncId":"46|Adolfo@SONDA|2017/06/16 10:21:33|-2"},{"clientId":"-3","docSerie":"ADOLFO@SONDA","docNum":"2","postedDatetime":"2017/06/16 10:22:58","tagsQty":"10","syncId":"46|Adolfo@SONDA|2017/06/16 10:22:58|-3"},{"clientId":"-4","docSerie":"ADOLFO@SONDA","docNum":"3","postedDatetime":"2017/06/16 10:24:19","tagsQty":"10","syncId":"46|Adolfo@SONDA|2017/06/16 10:24:19|-4"}],"dbuser":"USONDA","dbuserpass":"SONDAServer1237710","routeid":"46","loginId":"Adolfo@SONDA"}}'
*/			
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SCOUTING](
	@CODE_ROUTE VARCHAR(50)
	,@CODE_CUSTOMER VARCHAR(50)
	,@DOC_SERIE VARCHAR(50)
	,@DOC_NUM INT
	,@SYNC_ID VARCHAR(250)
	,@POSTED_DATIME DATETIME
	,@TAG_QTY INT
	,@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	--
	DECLARE 
		@EXISTS INT = 0
		,@ID VARCHAR(50)
		,@TAG_QTY_IN_DB INT = 0
		,@MENSAJE VARCHAR(50) = 'Validacion de Scouting'
	--
	SELECT TOP 1
		@EXISTS = 1
		,@ID = [CN].[CUSTOMER_ID]
	FROM [SONDA].[SONDA_CUSTOMER_NEW] [CN] WITH(ROWLOCK,XLOCK,HOLDLOCK)
	WHERE [CN].[CODE_ROUTE] = @CODE_ROUTE
		AND [CN].[CODE_CUSTOMER] = @CODE_CUSTOMER
		AND [CN].[DOC_SERIE] = @DOC_SERIE
		AND [CN].[DOC_NUM] = @DOC_NUM
		AND [CN].[SYNC_ID] = @SYNC_ID
		AND [CN].[POSTED_DATETIME] = @POSTED_DATIME
		AND [CN].[IS_READY_TO_SEND] = 1
	GROUP BY [CN].[CUSTOMER_ID];

	IF @EXISTS = 1
	BEGIN
		GOTO EXISTE;
	END
	ELSE
	BEGIN
		DECLARE @ID_FROM_XML VARCHAR(50);
		SELECT
			@ID_FROM_XML = [x].[Rec].[query]('./CodeCustomer').[value]('.', 'VARCHAR(50)')
		FROM @xml.[nodes]('/Data/Scouting') as [x]([Rec])
		--
		SELECT TOP 1
			@ID = [CN].[CUSTOMER_ID]
			,@EXISTS = 1
		FROM [SONDA].[SONDA_CUSTOMER_NEW] [CN] WITH(ROWLOCK,XLOCK,HOLDLOCK)
		WHERE [CN].[CODE_CUSTOMER] = @ID_FROM_XML
		GROUP BY [CN].[CUSTOMER_ID];
		--
		SELECT TOP 1
			@TAG_QTY_IN_DB = COUNT([T].[CUSTOMER_ID])
		FROM [SONDA].[SONDA_CUSTOMER_NEW] [CN] WITH(ROWLOCK,XLOCK,HOLDLOCK)
		INNER JOIN [SONDA].[SONDA_TAG_X_CUSTOMER_NEW] [T] ON ([T].[CUSTOMER_ID] = [CN].[CUSTOMER_ID])
		WHERE [CN].[CODE_CUSTOMER] = @ID_FROM_XML
		GROUP BY [CN].[CUSTOMER_ID];
	END

	-- ------------------------------------------------------------------------------------
	-- Valida el resultado
	-- ------------------------------------------------------------------------------------
	IF @EXISTS = 1 AND @TAG_QTY != @TAG_QTY_IN_DB
	BEGIN
		PRINT 'No Existe'
		SET @MENSAJE += ' no Existe'
		--
		SET @EXISTS = 0
		--
		GOTO EXISTE;
	END

	-- ------------------------------------------------------------------------------------
	-- Marca IS_READY_TO_SEND como 1
	-- ------------------------------------------------------------------------------------
	UPDATE [SONDA].[SONDA_CUSTOMER_NEW]
	SET [IS_READY_TO_SEND] = 1
	WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
		AND [DOC_SERIE] = @DOC_SERIE
		AND [DOC_NUM] = @DOC_NUM

	EXISTE:
	-- ------------------------------------------------------------------------------------
	-- Inserta el log
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SONDA_SP_CUSTOMER_NEW_INSERT_LOG] 
		@EXISTS_SCOUTING = @EXISTS, -- int
		@DOC_SERIE = @DOC_SERIE, -- varchar(50)
		@DOC_NUM = @DOC_NUM, -- int
		@CODE_ROUTE = @CODE_ROUTE, -- varchar(50)
		@POSTED_DATETIME = @POSTED_DATIME, -- datetime
		@XML = @XML, -- xml
		@JSON = @JSON, -- varchar(max)
		@SET_NEGATIVE_SEQUENCE = 0, -- int
		@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
		@IS_SUCCESSFUL = 1,
		@MESSAGE = @MENSAJE
	-- ------------------------------------------------------------------------------------
	-- Muestra resultado
	-- ------------------------------------------------------------------------------------
	SELECT 
		@EXISTS AS [EXISTS]
		,@ID AS [ID]
		,@CODE_CUSTOMER [CODE_CUSTOMER]
		,@DOC_SERIE [DOC_SERIE]
		,@DOC_NUM [DOC_NUM]
END
