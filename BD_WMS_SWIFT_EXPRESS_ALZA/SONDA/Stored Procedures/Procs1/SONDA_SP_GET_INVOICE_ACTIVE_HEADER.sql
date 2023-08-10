-- =============================================
-- Author:     	rudi.garcia
-- Create date: 2016-02-24 09:03:26
-- Description: Obtiene las facturas encabezados activas de todos los cliente o de uno especifico

-- Modificacion 10-06-2016
-- jose.roberto
-- Se coloco el where afuera del openquery

-- Modificacion			
-- 18-07-2016
-- hector.gonzalez
-- Se agrego parametro GPS por problema con el inicio de ruta ya que SWIFT_SP_GET_CUSTUMER_FOR_SCOUTING devolvia GPS y este SP no lo tenia

-- Modificacion			
-- 12-12-2016 @ Sprint 6
-- alberto.ruiz
-- Se agregaron las columnas de lista de bonificacion y descuento

-- Modificacion			
-- 26-12-2016 @ Sprint 6
-- rodrigo.gomez
-- Se agregaro la columna de lista de precios

-- Modificacion			
-- 08-02-2017 @ Sprint Chatuluka
-- diego.as
-- Se agregaro la columna SALES_BY_MULTIPLE_LIST_ID

-- Modificacion 4/20/2017 @ A-Team Sprint Hondo
					-- diego.as
					-- Se agrega la columna PREVIUS_BALANCE

-- Modificacion 29-May-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Se agregaron campos de nit y nombre de facturacion

-- Modificacion 21-Jun-17 @ A-Team Sprint Khalid
					-- alberto.ruiz
					-- Se arreglo el tamaño de los varchas de la tabla [#CUSTOMER]

/*
Ejemplo de Ejecucion:
          -- Para obtener todas las facturas
            EXEC [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_HEADER @CODE_ROUTE = '46' ,@CODE_CUSTOMER = '1'
          -- Para obtener todas las facturas por cliente
			      EXEC [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_HEADER @CODE_ROUTE = '46', @CODE_CUSTOMER = 'BO-100018'
          --Obtien los clientes de la ruta
			      EXEC [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_HEADER @CODE_ROUTE = '46'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_INVOICE_ACTIVE_HEADER] (
	@CODE_ROUTE AS VARCHAR(50)
	,@CODE_CUSTOMER AS VARCHAR(50) = NULL
)AS
BEGIN
  --
	CREATE TABLE [#CUSTOMER] (
		[CODE_CUSTOMER] VARCHAR(50)
		,[NAME_CUSTOMER] VARCHAR(250)
		,[TAX_ID_NUMBER] VARCHAR(50)
		,[ADRESS_CUSTUMER] VARCHAR(250)
		,[PHONE_CUSTUMER] VARCHAR(250)
		,[CONTACT_CUSTUMER] VARCHAR(250)
		,[CREDIT_LIMIT] FLOAT
		,[EXTRA_DAYS] INT
		,[DISCOUNT] NUMERIC(18,6)
		,[GPS] VARCHAR(250)
		,[RGA_CODE] VARCHAR(150)
		,[DISCOUNT_LIST_ID] INT
		,[BONUS_LIST_ID] INT
		,[PRICE_LIST_ID] VARCHAR(50)
		,[SALES_BY_MULTIPLE_LIST_ID] INT
		,[PREVIUS_BALANCE] DECIMAL(18,6)
		,[LAST_PURCHASE] NUMERIC(18,6)
		,[INVOICE_NAME] VARCHAR(250)
	);
  --
  --DECLARE @CUSTUMERS VARCHAR(MAX) = ''
  --       ,@SQL VARCHAR(MAX)

  ---- ----------------------------------------------------------------------------------
  ---- Se valida si se obtienen todas las factuas o solo con un cliente especifico, con la siguiente validacion
  ---- ----------------------------------------------------------------------------------
  --IF @CODE_CUSTOMER IS NULL
  --BEGIN
	
  --  -- ----------------------------------------------------------------------------------
  --  -- Se obtienen todos los clientes de la ruta
  --  -- ----------------------------------------------------------------------------------
  --  INSERT INTO #CUSTOMER
  --  EXEC [SONDA].SWIFT_SP_GET_CUSTUMER_FOR_SCOUTING @CODE_ROUTE = @CODE_ROUTE

  --END
  --ELSE
  --BEGIN
  --  -- ----------------------------------------------------------------------------------
  --  -- Se estable el cliente para el openquery
  --  -- ----------------------------------------------------------------------------------
  --  INSERT INTO #CUSTOMER (CODE_CUSTOMER)
  --    VALUES (@CODE_CUSTOMER);

  --END

  --SELECT
  --  @SQL = ' 
	 --   SELECT
		--	  DOC_ENTRY
		--	  ,DOC_NUM
  --  		,DOC_TOTAL
  --  		,PAID_TO_DATE
  --  		,DOC_DUE_DATE
  --  		,CARD_CODE
		--	  ,SERIE
		--	  ,RESOLUTION
		--	  ,DOC_DATE
  --  	FROM openquery ([ERPSERVER],''    
  --        SELECT
  --          IV.DocEntry AS DOC_ENTRY
  --          ,IV.DocNum AS DOC_NUM
  --          ,IV.CardCode AS CAR_CODE
  --          ,IV.DocTotal AS DOC_TOTAL
  --          ,IV.PaidToDate AS PAID_TO_DATE
  --          ,IV.DocDueDate AS DOC_DUE_DATE
  --          ,IV.CardCode AS CARD_CODE
		--        ,null AS SERIE
		--        ,null AS RESOLUTION
		--        ,IV.DocDate AS DOC_DATE
  --        FROM [Prueba].dbo.OINV IV
  --        WHERE 
  --          IV.DocStatus = ''''O''''		      
		--      ORDER BY 
  --          IV.CardCode
  --          ,IV.DocDueDate
	 --   '')   WHERE  CAR_CODE IN ( SELECT CODE_CUSTOMER COLLATE SQL_Latin1_General_CP850_CI_AS  FROM #CUSTOMER  )'

  --PRINT '@SQL: ' + @SQL
  --EXEC (@SQL)
  SELECT * FROM [#CUSTOMER]

END
