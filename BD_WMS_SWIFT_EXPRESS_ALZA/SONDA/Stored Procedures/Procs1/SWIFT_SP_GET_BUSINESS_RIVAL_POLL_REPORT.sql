
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	05-ENE-17 @ A-TEAM Sprint Balder
-- Description:			    

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_BUSINESS_RIVAL_POLL_REPORT
					@START_DATETIME = '20170101 00:00:00.000'
					,@END_DATETIME = '20170606 00:00:00.000'
					,@CODE_ROUTE = '42|43'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_BUSINESS_RIVAL_POLL_REPORT (@START_DATETIME DATETIME
, @END_DATETIME DATETIME
, @CODE_ROUTE VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @DELIMITER CHAR(1) = '|'
         ,@QUERY NVARCHAR(MAX)
         ,@DEFAULT_DISPLAY_DECIMALS INT

  -- ----------------------------------------------------------------------------------------------------------------
  -- Coloca parametros iniciales
  -------------------------------------------------------------------------------------------------------------------
  SELECT
    @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES', 'DEFAULT_DISPLAY_DECIMALS')

  -- ----------------------------------------------------------------------------------------------------------------
  -- Ejecutamos cuery
  -------------------------------------------------------------------------------------------------------------------
  SET @QUERY = N' 

  SELECT
    sbrp.BUSINESS_RIVAL_POLL
   ,sbrp.INVOICE_RESOLUTION
   ,sbrp.INVOICE_SERIE
   ,sbrp.INVOICE_NUM
   ,sbrp.CODE_CUSTOMER
   ,svac.NAME_CUSTOMER
   ,sbrp.BUSSINESS_RIVAL_NAME   
  , CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(sbrp.BUSSINESS_RIVAL_TOTAL_AMOUNT)) [BUSSINESS_RIVAL_TOTAL_AMOUNT]
  , CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(sbrp.CUSTOMER_TOTAL_AMOUNT)) [CUSTOMER_TOTAL_AMOUNT]
   ,sbrp.COMMENT
   ,sbrp.ROUTE
   ,svar.CODE_ROUTE
   ,sbrp.POSTED_DATETIME
   ,CASE
      WHEN (sbrp.CUSTOMER_TOTAL_AMOUNT - sbrp.BUSSINESS_RIVAL_TOTAL_AMOUNT) < 0 THEN ''-''
      WHEN (sbrp.CUSTOMER_TOTAL_AMOUNT - sbrp.BUSSINESS_RIVAL_TOTAL_AMOUNT) = 0 THEN ''=''
      WHEN (sbrp.CUSTOMER_TOTAL_AMOUNT - sbrp.BUSSINESS_RIVAL_TOTAL_AMOUNT) > 0 THEN ''+''
    END AS COLOR
  FROM [SONDA].SONDA_BUSINESS_RIVAL_POLL sbrp
      INNER JOIN [SONDA].SWIFT_FN_SPLIT_2( ''' + @CODE_ROUTE + ''' , ''' + @DELIMITER + ''') [CR] 
    ON ([CR].VALUE = CAST(sbrp.ROUTE as VARCHAR))
      LEFT JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER svac 
    ON sbrp.CODE_CUSTOMER = svac.CODE_CUSTOMER
      LEFT JOIN [SONDA].SWIFT_VIEW_ALL_ROUTE svar
    ON sbrp.ROUTE = svar.ROUTE
  WHERE CONVERT(DATE,sbrp.POSTED_DATETIME) Between CONVERT(DATE,''' + CONVERT(VARCHAR(25), @START_DATETIME, 101) + ''') AND CONVERT(DATE,''' + CONVERT(VARCHAR(25), @END_DATETIME, 101) + ''')
  '
  PRINT '----> @QUERY: ' + @QUERY
  --
  EXEC (@QUERY)
--
END
