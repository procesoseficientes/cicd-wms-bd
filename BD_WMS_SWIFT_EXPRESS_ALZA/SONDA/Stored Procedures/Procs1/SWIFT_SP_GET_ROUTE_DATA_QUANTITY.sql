-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-12-2015
-- Description:			Selecciona las cantidades ingresdas por ruta
--                      
/*
-- Ejemplo de Ejecucion:				
				EXECUTE [SONDA].[SWIFT_SP_GET_ROUTE_DATA_QUANTITY] @CODE_ROUTE = '001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROUTE_DATA_QUANTITY]
	@CODE_ROUTE varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		 @CLIENT_QTY INT = 0
		,@TASK_QTY INT = 0
		,@SKU_SALE_QTY INT = 0
		,@SKU_PRESALE_QTY INT = 0
		,@INVOICE_QTY INT = 0
		,@SALES_ORDER_QTY INT = 0
		,@PRICE_LIST VARCHAR(25)
	--
	SELECT @PRICE_LIST = [SONDA].[SWIFT_FN_GET_PRICE_LIST](DEFAULT)

	-- ------------------------------
	-- Obtener total de Tareas
	-- ------------------------------
    SELECT	@TASK_QTY = COUNT(T.[TASK_ID])
	FROM [SONDA].[SWIFT_TASKS] AS T
	INNER JOIN [SONDA].[SWIFT_VIEW_USERS] AS U 	ON (T.[ASSIGEND_TO] = U.[LOGIN])
	WHERE U.[SELLER_ROUTE] = @CODE_ROUTE
		AND T.TASK_DATE = CONVERT(DATE,GETDATE())

	-- ------------------------------
	-- Obtener total de Clientes
	-- ------------------------------
	 SELECT @CLIENT_QTY = COUNT(C.CODE_CUSTOMER) 
	 FROM [SONDA].[SWIFT_FN_GET_CUSTUMER_FOR_ROUTE](@CODE_ROUTE) C

	-- ------------------------------
	-- Obtener total de Productos de venta
	-- ------------------------------
	SELECT @SKU_SALE_QTY = ISNULL(SUM(I.ON_HAND),0)
	FROM [SONDA].SWIFT_INVENTORY I
	INNER JOIN [SONDA].SWIFT_VIEW_ALL_SKU S on (S.CODE_SKU =  I.SKU)
	INNER JOIN [SONDA].SWIFT_PRICE_LIST_BY_SKU P on (P.CODE_SKU = I.SKU)
	INNER JOIN [SONDA].USERS U ON (U.DEFAULT_WAREHOUSE = i.WAREHOUSE)
	WHERE u.SELLER_ROUTE = @CODE_ROUTE
		and P.CODE_PRICE_LIST = @PRICE_LIST

	-- ------------------------------
	-- Obtener total de Productos de PREventa
	-- ------------------------------
	SELECT @SKU_PRESALE_QTY = ISNULL(SUM([ON_HAND] - [IS_COMITED]),0)
	FROM [SONDA].[SWIFT_VIEW_PRESALE_SKU] I
	INNER JOIN SWIFT_EXPRESS.[SONDA].SWIFT_PRICE_LIST_BY_SKU p on (p.CODE_SKU = I.SKU)
	INNER JOIN [SONDA].USERS U ON (U.PRESALE_WAREHOUSE = i.WAREHOUSE)
	WHERE u.SELLER_ROUTE = @CODE_ROUTE
		AND p.CODE_PRICE_LIST = @PRICE_LIST

	-- ------------------------------
	-- Obtener total de Facturas disponibles
	-- ------------------------------
	SELECT @INVOICE_QTY = (F.AUTH_DOC_TO - F.AUTH_CURRENT_DOC)
	FROM [SONDA].[SONDA_POS_RES_SAT] AS F
	WHERE F.AUTH_ASSIGNED_TO = @CODE_ROUTE

	-- ------------------------------
	-- Obtener total de Ordenes de Venta
	-- ------------------------------
	SELECT @SALES_ORDER_QTY = ISNULL((DOC_TO - CURRENT_DOC),0)
	FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] S
	WHERE S.ASSIGNED_TO = @CODE_ROUTE
		AND DOC_TYPE = 'SALES_ORDER'

	SELECT 
		@TASK_QTY AS TASK_QTY 
		,@CLIENT_QTY AS CLIENT_QTY
		,@SKU_SALE_QTY AS SKU_SALE_QTY
		,@SKU_PRESALE_QTY AS SKU_PRESALE_QTY
		,@INVOICE_QTY AS INVOICE_QTY
		,@SALES_ORDER_QTY AS SALES_ORDER_QTY 

END
