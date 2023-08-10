-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/7/2017 @ A-TEAM Sprint Mussa 
-- Description:			SP que valida si los documentos de ordenes de venta de Sonda Core estan posteados

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_SALES_ORDERS_BY_XML]
				@XML = N'<?xml version=''1.0''?>
						<Data>
							<OrdenesDeVenta>
								<SalesOrderIdBo>48442</SalesOrderIdBo>
								<SalesOrderId>-4</SalesOrderId>
								<DocSerie>134</DocSerie>
								<DocNum>25</DocNum>
								<DetailNum>3</DetailNum>
							</OrdenesDeVenta>
							<OrdenesDeVenta>
								<SalesOrderIdBo>48440</SalesOrderIdBo>
								<SalesOrderId>-3</SalesOrderId>
								<DocSerie>134</DocSerie>
								<DocNum>24</DocNum>
								<DetailNum>4</DetailNum>
							</OrdenesDeVenta>
							<OrdenesDeVenta>
								<SalesOrderIdBo>48441</SalesOrderIdBo>
								<SalesOrderId>-2</SalesOrderId>
								<DocSerie>134</DocSerie>
								<DocNum>23</DocNum>
								<DetailNum>5</DetailNum>
							</OrdenesDeVenta>
							<dbuser>USONDA</dbuser>
							<dbuserpass>SONDAServer1237710</dbuserpass>
							<routeid>134</routeid>
							<Source></Source>
						</Data>'
				,@JSON = ''
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATE_SALES_ORDERS_BY_XML(
	@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SALES_ORDER_ID_BO INT
			, @SALES_ORDER_ID INT
			, @DOC_SERIE VARCHAR(50)
			, @DOC_NUM INT
			, @DETAIL_QTY INT
			, @DOCUMENT_XML XML;
	--
	DECLARE @SALES_ORDERS TABLE(
		SALES_ORDER_ID_BO INT
		, SALES_ORDER_ID INT
		, DOC_SERIE VARCHAR(50)
		, DOC_NUM INT
		, DETAIL_QTY INT
	);
	--
	DECLARE @RESULT_VALIDATION TABLE(
	 [EXISTS] INT
     ,[SALES_ORDER_ID] INT
     ,[DOC_SERIE] VARCHAR(50)
     ,[DOC_NUM] INT
	 );
	--
		-- ------------------------------------------------------------------------------------
		-- Obtiene las ordenes de venta
		-- ------------------------------------------------------------------------------------
		INSERT INTO @SALES_ORDERS
			(
				SALES_ORDER_ID_BO
				, SALES_ORDER_ID 
				, DOC_SERIE 
				, DOC_NUM 
				, DETAIL_QTY 
			)
		SELECT
			x.Rec.query('./SalesOrderIdBo').value('.', 'int')
			,x.Rec.query('./SalesOrderId').value('.', 'int')
			,x.Rec.query('./DocSerie').value('.', 'varchar(50)')
			,x.Rec.query('./DocNum').value('.', 'int')
			,x.Rec.query('./DetailNum').value('.', 'int')
		FROM @XML.nodes('Data/OrdenesDeVenta') AS x(Rec)

		-- ------------------------------------------------------------------------------------
		-- Se recorre cada orden de venta
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS(SELECT TOP 1 1 FROM @SALES_ORDERS)
		BEGIN
			SELECT TOP 1
				@SALES_ORDER_ID_BO = SO.[SALES_ORDER_ID_BO]
				, @SALES_ORDER_ID = SO.[SALES_ORDER_ID]
				, @DOC_SERIE = SO.[DOC_SERIE]
				, @DOC_NUM = SO.[DOC_NUM] 
				, @DETAIL_QTY = SO.[DETAIL_QTY]
			FROM @SALES_ORDERS [SO]
			
			-- ------------------------------------------------------------------------------------
			-- Valida si existe orden de venta
			-- ------------------------------------------------------------------------------------
			SELECT @DOCUMENT_XML = (
				SELECT 
					CASE [x].[Rec].[query]('./SalesOrderIdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./SalesOrderIdBo').[value]('.', 'int') END SalesOrderIdBo
					,CASE [x].[Rec].[query]('./SalesOrderId').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./SalesOrderId').[value]('.', 'int') END SalesOrderId
					,[x].[Rec].[query]('./DocSerie').[value]('.', 'varchar(50)') DocSerie
					,[x].[Rec].[query]('./DocNum').[value]('.', 'int') DocNum
					,[x].[Rec].[query]('./DetailNum').[value]('.', 'int') DetailNum
				FROM @xml.[nodes]('/Data/OrdenesDeVenta') as [x]([Rec])
				WHERE CASE [x].[Rec].[query]('./SalesOrderId').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./SalesOrderId').[value]('.', 'int') END = @SALES_ORDER_ID
				FOR XML PATH ('OrdenesDeVenta'),ROOT('Data')
			)
			--
			INSERT INTO @RESULT_VALIDATION(
						[EXISTS]
						 ,[SALES_ORDER_ID]
						 ,[DOC_SERIE]
						 ,[DOC_NUM]
			)
			EXEC [SONDA].[SONDA_SP_VALIDATE_SALE_ORDER_IS_POSTED] 
				@SALES_ORDER_ID = @SALES_ORDER_ID_BO
				,@SALES_ORDER_ID_HH = @SALES_ORDER_ID
				,@DOC_SERIE = @DOC_SERIE
				,@DOC_NUM = @DOC_NUM
				,@DETAIL_NUM = @DETAIL_QTY
				,@XML = @DOCUMENT_XML
				,@JSON = @JSON

			-- ------------------------------------------------------------------------------------
			-- Elimina la orden de venta
			-- ------------------------------------------------------------------------------------
			DELETE FROM @SALES_ORDERS WHERE [DOC_SERIE] = @DOC_SERIE AND [DOC_NUM] = @DOC_NUM
		END
		-- ------------------------------------------------------------------------------------
		-- Envia resultado de validaciones
		-- ------------------------------------------------------------------------------------
		SELECT 
			[EXISTS] AS RESULT
			 ,[SALES_ORDER_ID]
			 ,[DOC_SERIE]
			 ,[DOC_NUM]
		FROM @RESULT_VALIDATION
		--WHERE [EXISTS] = 0
END
