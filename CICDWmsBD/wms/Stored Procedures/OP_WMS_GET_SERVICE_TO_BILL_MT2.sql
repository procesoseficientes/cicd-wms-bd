-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	28-Oct-16 @ A-TEAM Sprint 4 
-- Description:			SP que obtienen todos los servicios a cobrar de mt2 

-- Modificación:				pablo.aguilar
-- Fecha de Modificación: 	09-Ene-17 @ A-TEAM Sprint Balder 
-- Description:			Se agrega parametro de tipo, y se realizan modificaciones para que maneje la frecuencia. 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-27 Team ERGON - Sprint ERGON HYPER
-- Description:	Se agrega como resultado de la consulta el codigo del acuerdo comercial utilizado para el cobro  

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_MT2] @PROCESS_DATE = '2017-03-29 00:00:000'
     ,@LAST_UPDATED_BY = 'PABS'
     ,@TYPE = 'ON_DEMAND'
  --B04-TA-C08-NU	1	MT2	Metros cuadrados en piso	GENERAL	49362

    SELECT
     *
    FROM [wms].[OP_WMS_FN_GET_CUSTOMERS_TO_BILL_BY_TRADE_AGREEMENT](1, 'ON_DEMAND', '2017-03-29 00:00:000', 'MT2', 0) [C]

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SERVICE_TO_BILL_MT2] (@PROCESS_DATE DATETIME
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
    FROM [wms].[OP_WMS_FN_GET_CUSTOMERS_TO_BILL_BY_TRADE_AGREEMENT](1, @TYPE, @PROCESS_DATE, 'MT2', 0) [C]
  -- 

  SELECT
    [L].[USED_MT2] [QTY]
   ,[C].[SERVICE_CODE] [TRANSACTION_TYPE]
   ,[C].[UNIT_PRICE] * [wms].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE](@TYPE, @PROCESS_DATE, [L].[LAST_UPDATED], [C].[BILLING_FRECUENCY]) [PRICE]
   ,[C].[UNIT_PRICE] * [L].[USED_MT2] * [wms].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE](@TYPE, @PROCESS_DATE, [L].[LAST_UPDATED], [C].[BILLING_FRECUENCY]) [TOTAL_AMOUNT]
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
   ,[L].[LICENSE_ID]
   ,[L].[LAST_UPDATED]
   ,[L].[CURRENT_LOCATION] [LOCATION]
   ,[C].[SERVICE_ID]
   ,[C].[SERVICE_CODE]
   ,[C].[SERVICE_DESCRIPTION]
   ,[L].[REGIMEN] [REGIMEN]
   ,[PH].[DOC_ID] [DOC_NUM]
   ,CAST(NULL AS INT) [TRANSACTION_ID]
   ,CASE CAST([wms].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE](@TYPE, @PROCESS_DATE, [L].[LAST_UPDATED], [C].[BILLING_FRECUENCY]) AS INT)
      WHEN 1 THEN 0
      ELSE 1
    END [HAS_ADJUST]
   ,[C].[BILLING_FRECUENCY]
   ,[C].[ACUERDO_COMERCIAL] INTO #PRE_RESULT
  FROM [wms].[OP_WMS_LICENSES] [L]
  INNER JOIN [#CLIENT_TO_BILL] [C]
    ON ([C].[CLIENT_CODE] = [L].[CLIENT_OWNER])
  INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
    ON ([L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
    AND [PH].[WAREHOUSE_REGIMEN] = [L].[REGIMEN])
  INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
    ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID]
    AND CAST([IL].[TERMS_OF_TRADE] AS INT) = [C].[ACUERDO_COMERCIAL]
    )
  WHERE [IL].[QTY] > 0
  AND [L].[USED_MT2] IS NOT NULL
  AND [L].[USED_MT2] > 0
  AND [C].[REGIMEN] = [PH].[WAREHOUSE_REGIMEN]
  GROUP BY [L].[LICENSE_ID]
          ,[C].[BILLING_FRECUENCY]
          ,[L].[LAST_UPDATED]
          ,[C].[CLIENT_CODE]
          ,[L].[USED_MT2]
          ,[C].[SERVICE_CODE]
          ,[C].[UNIT_PRICE]
          ,[C].[TYPE_CHARGE_ID]
          ,[C].[TYPE_CHARGE_DESCRIPTION]
          ,[C].[CLIENT_NAME]
          ,[L].[CURRENT_LOCATION]
          ,[C].[SERVICE_ID]
          ,[C].[SERVICE_DESCRIPTION]
          ,[L].[REGIMEN]
          ,[PH].[DOC_ID]
          ,[C].[ACUERDO_COMERCIAL]

  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro mensual 
  -- ------------------------------------------------------------------------------------
  DELETE [R]
    FROM [#PRE_RESULT] [R]
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON (S.[LICENSE_ID] = R.[LICENSE_ID]
      AND [R].[LOCATION] = [S].[LOCATION]
      AND [R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY])
  WHERE [R].[BILLING_FRECUENCY] = 30
    AND S.[SERVICE_CODE] = 'MT2'
    AND DATEPART(YEAR, [S].[PROCESS_DATE]) = DATEPART(YEAR, [R].[PROCESS_DATE])
    AND DATEPART(MONTH, [S].[PROCESS_DATE]) = DATEPART(MONTH, [R].[PROCESS_DATE])
    AND [S].[IS_CHARGED] = 1

  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro primera quincena
  -- ------------------------------------------------------------------------------------
  DELETE [R]
    FROM [#PRE_RESULT] [R]
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON (
      [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = 'MT2'
      AND [S].[LICENSE_ID] = [R].[LICENSE_ID]
      AND [R].[LOCATION] = [S].[LOCATION]
      AND [R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
      )
  WHERE [R].[BILLING_FRECUENCY] = 15
    AND DATEPART(DAY, [R].[PROCESS_DATE]) <= 15
    AND [S].[PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_MONTH]([R].[PROCESS_DATE])
    AND [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]([R].[PROCESS_DATE])



  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro segunda quincena
  -- ------------------------------------------------------------------------------------
  DELETE [R]
    FROM [#PRE_RESULT] [R]
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON (S.[LICENSE_ID] = R.[LICENSE_ID]
      AND [R].[LOCATION] = [S].[LOCATION]
      AND [R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
      AND [S].[SERVICE_CODE] = 'MT2')
  WHERE [R].[BILLING_FRECUENCY] = 15
    AND DATEPART(DAY, [R].[PROCESS_DATE]) > 15
    AND [S].[PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]([R].[PROCESS_DATE])
    AND [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]([R].[PROCESS_DATE])
    AND [S].[IS_CHARGED] = 1



  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro semanal
  -- --------------------------------------------------------------------------------------  
  DELETE [R]
    FROM [#PRE_RESULT] [R]
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON (
      [S].[IS_CHARGED] = 1
      AND [S].[SERVICE_CODE] = 'MT2'
      AND S.[LICENSE_ID] = R.[LICENSE_ID]
      AND [R].[LOCATION] = [S].[LOCATION]
      AND [R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
      )
  WHERE [R].[BILLING_FRECUENCY] = 7 -- FRECUENCIA SEMANAL
    AND DATEDIFF(WEEK, R.[PROCESS_DATE], S.[PROCESS_DATE]) = 0


  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro diario
  -- --------------------------------------------------------------------------------------  
  DELETE [R]
    FROM [#PRE_RESULT] [R]
    INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S]
      ON (S.[LICENSE_ID] = R.[LICENSE_ID]
      AND [R].[LOCATION] = [S].[LOCATION]
      AND [R].[CLIENT_CODE] = [S].[CLIENT_CODE]
      AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
      AND [S].[SERVICE_CODE] = 'MT2')
  WHERE [R].[BILLING_FRECUENCY] = 1 -- FRECUENCIA diaria
    AND [R].[PROCESS_DATE] = [S].[PROCESS_DATE]
    AND [S].[IS_CHARGED] = 1

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
   ,[PR].[HAS_ADJUST]
   ,[PR].[BILLING_FRECUENCY]
   ,[PR].[ACUERDO_COMERCIAL]
  FROM [#PRE_RESULT] [PR]

END