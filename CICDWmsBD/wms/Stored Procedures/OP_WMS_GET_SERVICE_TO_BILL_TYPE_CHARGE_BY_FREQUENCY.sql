-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	09-Ene-2017 @ A-TEAM Sprint Balder 
-- Description:			SP que obtienen todos los servicios con frecuencia a cobrar


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-27 Team ERGON - Sprint ERGON HYPER
-- Description:	Se agrega como resultado de la consulta el codigo del acuerdo comercial utilizado para el cobro
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_TYPE_CHARGE_BY_FREQUENCY]  @PROCESS_DATE = '2017-03-02 00:00:000'
 ,@LAST_UPDATED_BY = 'PABS'
 ,@TYPE = 'ON_DEMAND'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SERVICE_TO_BILL_TYPE_CHARGE_BY_FREQUENCY] (@PROCESS_DATE DATETIME
, @LAST_UPDATED_BY VARCHAR(25)
, @TYPE VARCHAR(25) --"ON_DEMAND", "AUTOMATIC_SERVICE"
)
AS
BEGIN

  SET NOCOUNT ON;
  SET LANGUAGE us_english

  CREATE TABLE [#CLIENT_TO_BILL] (
    [CLIENT_CODE] [nvarchar](15) NOT NULL
   ,[CLIENT_NAME] [nvarchar](100) NULL
   ,[ACUERDO_COMERCIAL] [int] NOT NULL
   ,[TYPE_CHARGE_ID] [int] NULL
   ,[TYPE_CHARGE_DESCRIPTION] [varchar](250) NULL
   ,[SERVICE_ID] [int] NOT NULL
   ,[SERVICE_CODE] [varchar](25) NULL
   ,[SERVICE_DESCRIPTION] [varchar](250) NULL
   ,[UNIT_PRICE] [int] NULL
   ,[REGIMEN] [varchar](25) NULL
   ,[BILLING_FRECUENCY] [int] NULL
  )

  INSERT INTO [#CLIENT_TO_BILL] ([CLIENT_CODE], [CLIENT_NAME], [ACUERDO_COMERCIAL], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [UNIT_PRICE], [REGIMEN], [BILLING_FRECUENCY])
    SELECT
      [C].[CLIENT_CODE]
     ,[C].[CLIENT_NAME]
     ,[C].[ACUERDO_COMERCIAL]
     ,[C].[TYPE_CHARGE_ID]
     ,[C].[TYPE_CHARGE_DESCRIPTION]
     ,[C].[SERVICE_ID]
     ,[C].[SERVICE_CODE]
     ,[C].[SERVICE_DESCRIPTION]
     ,[C].[UNIT_PRICE]
     ,[C].[REGIMEN]
     ,[C].[BILLING_FRECUENCY]
    FROM [wms].[OP_WMS_FN_GET_CUSTOMERS_TO_BILL_BY_TRADE_AGREEMENT](1, @TYPE, @PROCESS_DATE, NULL, 1) [C]


  SELECT
    CAST(1 AS NUMERIC(18, 2)) [QTY]
   ,[C].[SERVICE_CODE] [TRANSACTION_TYPE]
   ,[C].[UNIT_PRICE] [PRICE]
   ,[C].[UNIT_PRICE] * CAST(1 AS NUMERIC(18, 2)) [TOTAL_AMOUNT]
   ,@PROCESS_DATE [PROCESS_DATE]
   ,GETDATE() [CREATED_DATE]
   ,GETDATE() [LAST_UPDATED_DATE]
   ,@LAST_UPDATED_BY [LAST_UPDATED_BY]
   ,[C].[TYPE_CHARGE_ID] [TYPE_CHARGE_ID]
   ,[C].[TYPE_CHARGE_DESCRIPTION] [TYPE_CHARGE_DESCRIPTION]
   ,[C].[CLIENT_CODE]
   ,[C].[CLIENT_NAME]
   ,CAST(0 AS INT) [IS_CHARGED]
   ,CAST(NULL AS VARCHAR(30)) [INVOICE_REFERENCE]
   ,CAST(NULL AS DATETIME) [CHARGED_DATE]
   ,CAST(NULL AS NUMERIC) [LICENSE_ID]
   ,CAST(NULL AS NUMERIC) [LOCATION]
   ,[C].[SERVICE_ID]
   ,[C].[SERVICE_CODE]
   ,[C].[SERVICE_DESCRIPTION]
   ,[C].[REGIMEN] [REGIMEN]
   ,CAST(NULL AS INT) [DOC_NUM]
   ,CAST(NULL AS INT) [TRANSACTION_ID]
   ,[BILLING_FRECUENCY]
   ,[C].[ACUERDO_COMERCIAL] INTO #PRE_RESULT
  FROM [#CLIENT_TO_BILL] [C]

  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro mensual 
  -- ------------------------------------------------------------------------------------
  DELETE R
    FROM [#PRE_RESULT] R
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON ([R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = [R].SERVICE_CODE
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY])
  WHERE DATEPART(YEAR, [S].[PROCESS_DATE]) = DATEPART(YEAR, [R].[PROCESS_DATE])
    AND DATEPART(MONTH, [S].[PROCESS_DATE]) = DATEPART(MONTH, [R].[PROCESS_DATE])
    AND [R].[BILLING_FRECUENCY] = 30



  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro primera quincena
  -- ------------------------------------------------------------------------------------

  DELETE R
    FROM [#PRE_RESULT] R
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON ([R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = [R].SERVICE_CODE
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY])
  WHERE [R].[BILLING_FRECUENCY] = 15
    AND DATEPART(DAY, [R].[PROCESS_DATE]) <= 15
    AND [S].[PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_MONTH]([R].[PROCESS_DATE])
    AND [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]([R].[PROCESS_DATE])

  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro segunda quincena
  -- ------------------------------------------------------------------------------------

  DELETE R
    FROM [#PRE_RESULT] R
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON ([R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = [R].SERVICE_CODE
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY])
  WHERE [R].[BILLING_FRECUENCY] = 15
    AND DATEPART(DAY, [R].[PROCESS_DATE]) > 15
    AND [S].[PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]([R].[PROCESS_DATE])
    AND [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]([R].[PROCESS_DATE])

  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro semanal
  -- --------------------------------------------------------------------------------------  
  DELETE R
    FROM [#PRE_RESULT] R
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON ([R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = [R].SERVICE_CODE
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY])
  WHERE [R].[BILLING_FRECUENCY] = 7
    AND DATEDIFF(WEEK, R.[PROCESS_DATE], S.[PROCESS_DATE]) = 0


  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro diario
  -- --------------------------------------------------------------------------------------  
  DELETE R
    FROM [#PRE_RESULT] R
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON ([R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = [R].SERVICE_CODE
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY])
  WHERE [R].[BILLING_FRECUENCY] = 1
    AND CAST([S].[PROCESS_DATE] AS DATE) = CAST([R].[PROCESS_DATE] AS DATE)

  SELECT
    [PR].[QTY]
   ,[PR].[TRANSACTION_TYPE]
   ,[PR].[PRICE]
   ,[PR].[TOTAL_AMOUNT]
   ,[PR].[PROCESS_DATE]
   ,[PR].[CREATED_DATE]
   ,[PR].[LAST_UPDATED_DATE]
   ,[PR].[LAST_UPDATED_BY]
   ,[PR].[TYPE_CHARGE_ID]
   ,[PR].[TYPE_CHARGE_DESCRIPTION]
   ,[PR].[CLIENT_CODE]
   ,[PR].[CLIENT_NAME]
   ,[PR].[IS_CHARGED]
   ,[PR].[INVOICE_REFERENCE]
   ,[PR].[CHARGED_DATE]
   ,[PR].[LICENSE_ID]
   ,[PR].[LOCATION]
   ,[PR].[SERVICE_ID]
   ,[PR].[SERVICE_CODE]
   ,[PR].[SERVICE_DESCRIPTION]
   ,[PR].[REGIMEN]
   ,[PR].[DOC_NUM]
   ,[PR].[TRANSACTION_ID]
   ,[PR].[BILLING_FRECUENCY]
   ,[PR].[ACUERDO_COMERCIAL]
  FROM [#PRE_RESULT] [PR]

END