﻿-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	28-Oct-16 @ A-TEAM Sprint 4 
-- Description:			SP que obtienen todos los servicios a cobrar de recepciones 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-27 Team ERGON - Sprint ERGON HYPER
-- Description:	Se agrega como resultado de la consulta el codigo del acuerdo comercial utilizado para el cobro

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_RECEPTION]  @INICIAL_DATE = '2016-11-02 00:00:00.000'
  , @END_DATE = '2016-11-02 23:59:59.850', @LAST_UPDATED_BY = 'PAGUILAR'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SERVICE_TO_BILL_RECEPTION] (@INICIAL_DATE DATETIME
, @END_DATE DATETIME
, @LAST_UPDATED_BY VARCHAR(25))
AS
BEGIN

  SELECT
    [C].[CLIENT_CODE]
   ,[C].[CLIENT_NAME]
   ,[AC].[ACUERDO_COMERCIAL]
   ,[T].[TYPE_CHARGE_ID]
   ,[TC].[DESCRIPTION] [TYPE_CHARGE_DESCRIPTION]
   ,[S].[SERVICE_ID]
   ,[TC].[SERVICE_CODE]
   ,[S].[SERVICE_DESCRIPTION]
   ,[T].[UNIT_PRICE]
   ,[H].[REGIMEN] INTO #CLIENT_TO_BILL
  FROM [wms].[OP_WMS_TARIFICADOR_DETAIL] [T]
  INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [H]
    ON [T].[ACUERDO_COMERCIAL] = [H].[ACUERDO_COMERCIAL_ID]
  INNER JOIN [wms].[OP_WMS_TYPE_CHARGE] [TC]
    ON [TC].[TYPE_CHARGE_ID] = [T].[TYPE_CHARGE_ID]
  INNER JOIN [wms].[OP_WMS_ACUERDOS_X_CLIENTE] [AC]
    ON [T].[ACUERDO_COMERCIAL] = [AC].[ACUERDO_COMERCIAL]
  INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C]
    ON [C].[CLIENT_CODE] = [AC].[CLIENT_ID]
  INNER JOIN [wms].[OP_WMS_SERVICE] [S]
    ON [S].[SERVICE_CODE] = [TC].[SERVICE_CODE]
  WHERE [TC].[SERVICE_CODE] = 'RECEPCION'
--  AND @INICIAL_DATE >= [H].[VALID_FROM]
--  AND @END_DATE <= [H].[VALID_TO]

  SELECT
    CAST(1 AS NUMERIC(18, 2)) [QTY]
   ,[C].[SERVICE_CODE] [TRANSACTION_TYPE]
   ,[C].[UNIT_PRICE] [PRICE]
   ,[C].[UNIT_PRICE] * CAST(1 AS NUMERIC(18, 2)) [TOTAL_AMOUNT]
   ,CAST(NULL AS DATETIME) [PROCESS_DATE]
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
   ,CAST(NULL AS NUMERIC(9, 0)) [LICENSE_ID]
   ,CAST(NULL AS VARCHAR(25)) [LOCATION]
   ,[C].[SERVICE_ID]
   ,[C].[SERVICE_CODE]
   ,[C].[SERVICE_DESCRIPTION]
   ,[TL].[REGIMEN] [REGIMEN]
   ,[TL].[DOC_ID_SOURCE] [DOC_NUM]
   ,[TL].[SERIAL_NUMBER] [TRANSACTION_ID]
   ,[C].[ACUERDO_COMERCIAL]
  FROM [wms].[OP_WMS_TASK_LIST] TL
  INNER JOIN [#CLIENT_TO_BILL] [C]
    ON (
    [TL].[CLIENT_OWNER] = [C].[CLIENT_CODE]
    )
  INNER JOIN [wms].[OP_WMS_TRANS]  [T]
    ON (
    [T].[TASK_ID]  = [TL].[SERIAL_NUMBER]
    AND [T].[TERMS_OF_TRADE] = [C].[ACUERDO_COMERCIAL]
    )
  WHERE [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
  AND [C].[REGIMEN] = [TL].[REGIMEN]
  AND [T].[QUANTITY_UNITS] > 0
  AND ([TL].[COMPLETED_DATE] BETWEEN @INICIAL_DATE AND @END_DATE)


END