-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/16/2017 @ A-TEAM Sprint Jibade 
-- Description:			Valida si el scouting ya existe y cambia su IS_READY_TO_SEND a 1

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_SCOUTING_BY_XML] 
				@XML = N'
					<Data>
					<scouting>
						<clientId>SO-1320</clientId>
						<docSerie>ADOLFO@SONDA</docSerie>
						<docNum>1</docNum>
						<postedDatetime>2017/06/16 10:21:33</postedDatetime>
						<tagsQty>5</tagsQty>
						<syncId>46|Adolfo@SONDA|2017/06/16 10:21:33|-2</syncId>
					</scouting>
					<scouting>
						<clientId>SO-1321</clientId>
						<docSerie>ADOLFO@SONDA</docSerie>
						<docNum>2</docNum>
						<postedDatetime>2017/06/16 10:22:58</postedDatetime>
						<tagsQty>10</tagsQty>
						<syncId>46|Adolfo@SONDA|2017/06/16 10:22:58|-3</syncId>
					</scouting>
					<scouting>
						<clientId>SO-1322</clientId>
						<docSerie>ADOLFO@SONDA</docSerie>
						<docNum>3</docNum>
						<postedDatetime>2017/06/16 10:24:19</postedDatetime>
						<tagsQty>10</tagsQty>
						<syncId>46|Adolfo@SONDA|2017/06/16 10:24:19|-4</syncId>
					</scouting>
					<dbuser>USONDA</dbuser>
					<dbuserpass>SONDAServer1237710</dbuserpass>
					<routeid>46</routeid>
					<loginId>Adolfo@SONDA</loginId>
					</Data>',
				@JSON = '{"Data":{"scouting":[{"clientId":"-2","docSerie":"ADOLFO@SONDA","docNum":"1","postedDatetime":"2017/06/16 10:21:33","tagsQty":"5","syncId":"46|Adolfo@SONDA|2017/06/16 10:21:33|-2"},{"clientId":"-3","docSerie":"ADOLFO@SONDA","docNum":"2","postedDatetime":"2017/06/16 10:22:58","tagsQty":"10","syncId":"46|Adolfo@SONDA|2017/06/16 10:22:58|-3"},{"clientId":"-4","docSerie":"ADOLFO@SONDA","docNum":"3","postedDatetime":"2017/06/16 10:24:19","tagsQty":"10","syncId":"46|Adolfo@SONDA|2017/06/16 10:24:19|-4"}],"dbuser":"USONDA","dbuserpass":"SONDAServer1237710","routeid":"46","loginId":"Adolfo@SONDA"}}'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_SCOUTING_BY_XML](
	@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@SCOUTING TABLE (
		[CODE_CUSTOMER] VARCHAR(50)
		,[DOC_SERIE] VARCHAR(50)
		,[DOC_NUM] INT
		,[SYNC_ID] VARCHAR(250)
		,[POSTED_DATIME] DATETIME
		,[TAG_QTY] INT
	);
	--
	DECLARE @RESULT_VALIDATION TABLE (
		[EXISTS] [INT]
		,[ID] [INT]
		,[CODE_CUSTOMER] VARCHAR(50)
		,[DOC_SERIE] VARCHAR(50)
		,[DOC_NUM] INT
	)
	--
	DECLARE 
		@CODE_ROUTE VARCHAR(50)
		,@DOC_SERIE VARCHAR(50)
		,@DOC_NUM INT
		,@SYNC_ID VARCHAR(250)
		,@POSTED_DATIME DATETIME
		,@TAG_QTY INT
		,@SCOUTING_XML XML
		,@CODE_CUSTOMER VARCHAR(50);
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos generales de la ruta
	-- ------------------------------------------------------------------------------------
	SELECT 
		@CODE_ROUTE = [x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)')
	FROM @xml.[nodes]('/Data') as [x]([Rec])

	-- ------------------------------------------------------------------------------------
	-- Obtiene los scoutings a validar
	-- ------------------------------------------------------------------------------------
	INSERT INTO @SCOUTING
			(
				[CODE_CUSTOMER]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[SYNC_ID]
				,[POSTED_DATIME]
				,[TAG_QTY]
			)
	SELECT
		[x].[Rec].[query]('./clientId').[value]('.', 'varchar(50)')
		,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(50)')
		,CASE [x].[Rec].[query]('./docNum').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./docNum').[value]('.', 'int') END
		,[x].[Rec].[query]('./syncId').[value]('.', 'varchar(250)')
		,[x].[Rec].[query]('./postedDatetime').[value]('.', 'datetime')
		,CASE [x].[Rec].[query]('./tagsQty').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./tagsQty').[value]('.', 'int') END
	FROM @xml.[nodes]('/Data/scouting') as [x]([Rec])
	PRINT('1')

	-- ------------------------------------------------------------------------------------
	-- Ciclo para validar scoutings
	-- ------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP 1 1 FROM @SCOUTING)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Se toma factura a valdiar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@DOC_SERIE = [DOC_SERIE]
			,@DOC_NUM = [DOC_NUM]
			,@SYNC_ID = [SYNC_ID]
			,@POSTED_DATIME = [POSTED_DATIME]
			,@TAG_QTY = [TAG_QTY]
			,@CODE_CUSTOMER = [CODE_CUSTOMER]
		FROM @SCOUTING
		PRINT('2')
		-- ------------------------------------------------------------------------------------
		-- Valida si existe el scouting
		-- ------------------------------------------------------------------------------------
		SELECT @SCOUTING_XML = (
			SELECT 
				[x].[Rec].[query]('./clientId').[value]('.', 'varchar(50)') CodeCustomer
				,[x].[Rec].[query]('./docSerie').[value]('.', 'varchar(50)') DocSerie
				,CASE [x].[Rec].[query]('./docNum').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocNum').[value]('.', 'int') END DocNum
				,[x].[Rec].[query]('./syncId').[value]('.', 'varchar(250)') SyncId
				,[x].[Rec].[query]('./postedDatetime').[value]('.', 'datetime') PostedDatetime
				,CASE [x].[Rec].[query]('./tagsQty').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./TagQty').[value]('.', 'int') END TagQty
			FROM @xml.[nodes]('/Data/scouting') as [x]([Rec])
			WHERE [x].[Rec].[query]('./clientId').[value]('.', 'VARCHAR(50)') = @CODE_CUSTOMER
			FOR XML PATH ('Scouting'),ROOT('Data')
		)
		PRINT('3')
		--
		INSERT INTO @RESULT_VALIDATION
		EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SCOUTING] 
			@CODE_ROUTE = @CODE_ROUTE, -- varchar(50)
			@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
			@DOC_SERIE = @DOC_SERIE, -- varchar(50)
			@DOC_NUM = @DOC_NUM, -- int
			@SYNC_ID = @SYNC_ID, -- varchar(250)
			@POSTED_DATIME = @POSTED_DATIME, -- datetime
			@TAG_QTY = @TAG_QTY, -- int
			@XML = @SCOUTING_XML, -- xml
			@JSON = @JSON -- varchar(max)
		

		-- ------------------------------------------------------------------------------------
		-- Se elimina factura validada
		-- ------------------------------------------------------------------------------------
		DELETE FROM @SCOUTING WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER OR (
			[CODE_CUSTOMER] IS NULL
			AND
			@CODE_CUSTOMER IS NULL
		)
	END
	-- ------------------------------------------------------------------------------------
	-- Muestra resultado final
	-- ------------------------------------------------------------------------------------
	SELECT [EXISTS]
			,[ID]
			,[CODE_CUSTOMER]
			,[DOC_SERIE]
			,[DOC_NUM]
	FROM @RESULT_VALIDATION
END
