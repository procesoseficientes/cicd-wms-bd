/*===============================================

-- MODIFICADO 09-03-2016
	-- diego.as
	-- Se corrigieron errores ortograficos en la linea No. 58
		ademas, se agrego el ejemplo de ejecucion, tomar en cuenta
		el cambiar el valor de la serie al ejecutar el ejemplo.

Ejemplo de Ejecucion:

	EXEC [SONDA].[SWIFT_SP_CREATE_QR_CODE_LABEL] 
		@pTASK_ID = 16574
		,@pCUSTOMER_NAME = 'Ruta Despacho 01'
		,@pCODE_SKU = '100017'
		,@pSERIE = '1000000005'
		,@pERP_DOC = null
		,@pShipTo = null
		,@pRESULT = null

===============================================*/

CREATE PROC [SONDA].[SWIFT_SP_CREATE_QR_CODE_LABEL] 
	@pTASK_ID int,
	@pCUSTOMER_NAME varchar(max),
	@pCODE_SKU varchar(50),
	@pSERIE varchar(75),
	@pERP_DOC varchar(50),
	@pShipTo varchar(max) OUTPUT,
	@pRESULT varchar(250) OUTPUT
AS
BEGIN
  DECLARE @SQL varchar(8000)
  DECLARE @return_value int
          ,@pID numeric(18, 0)
        

  DECLARE @out TABLE (
    out varchar(100)
  )
  BEGIN TRY

       
    SET @SQL = 'select SHIP_TO_ADDRESSES from openquery ([ERPSERVER],''SELECT PO.Address2 AS SHIP_TO_ADDRESSES
				FROM    [Prueba].dbo.ORDR AS PO 
				WHERE  po.DocStatus=''''O''''  AND (PO.DocType = ''''I'''') AND (PO.DocNum = ' + @pERP_DOC + ')  '')'

    INSERT INTO @out
    EXEC (@SQL)

    SELECT
      @pShipTo =isnull(out,'N\A')
    FROM @out
    
    set @pShipTo  = ISNULL(@pShipTo,'N\A')


    EXEC @return_value = [SONDA].[SWIFT_SP_GET_NEXT_SEQUENCE] 
		@SEQUENCE_NAME = 'QR_CODE_LABEL'
        ,@pRESULT = @pID OUTPUT

    INSERT INTO [SONDA].SWIFT_QR_CODE_LABEL (
		ID
		, TASK_ID
		, CUSTOMER_NAME
		, CODE_SKU
		, SERIE
		, ERP_DOC
		, SHIP_TO_ADDRESSES
		, CREATE_DATE
		)
      VALUES (
		@pID
		, @pTASK_ID
		, @pCUSTOMER_NAME
		, @pCODE_SKU
		, @pSERIE
		, @pERP_DOC
		, @pShipTo
		, GETDATE()
		)

    SELECT @pRESULT = 'PROCESO EXITOSO';

    --RETURN 0
  END TRY

  BEGIN CATCH
    SELECT @pRESULT = ERROR_MESSAGE()
    --RETURN -1
  END CATCH

END
