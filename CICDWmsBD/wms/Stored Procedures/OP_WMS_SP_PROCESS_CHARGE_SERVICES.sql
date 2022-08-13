-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	28-Oct-16 @ A-TEAM Sprint 4 
-- Description:			SP que obtienen todos los servicios a cobrar de picking 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-27 Team ERGON - Sprint ERGON HYPER
-- Description:	Se agrega como resultado de la consulta el codigo del acuerdo comercial utilizado para el cobro

/*
-- Ejemplo de Ejecucion:
	      exec [wms].[OP_WMS_SP_PROCESS_CHARGE_SERVICES] @TYPE  = 'ON_DEMAND'
, @LAST_UPDATED_BY  = 'DU'
        SELECT * FROM   [wms].OP_WMS_SERVICES_TO_BILL ORDER BY PROCESS_DATE DESC
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_PROCESS_CHARGE_SERVICES (@TYPE VARCHAR(25) = 'AUTOMATIC_SERVICE'
, @LAST_UPDATED_BY VARCHAR(25) = 'PROCESO_AUTOMATICO')
AS
BEGIN

  BEGIN TRY
    BEGIN TRAN

    DECLARE @INICIAL_DATE DATETIME = DATEADD(D, DATEDIFF(D, 0, GETDATE()) - 1, 0)
           ,@FINAL_DATE DATETIME = DATEADD(D, DATEDIFF(D, 0, GETDATE()), 0)
           ,@PROCESS_DATE DATETIME = DATEADD(D, DATEDIFF(D, 0, GETDATE()) - 1, 0)

    IF @TYPE = 'ON_DEMAND'
    BEGIN
      SELECT
        @FINAL_DATE = GETDATE()
       ,@INICIAL_DATE = DATEADD(D, DATEDIFF(D, 0, GETDATE()), 0)
       ,@PROCESS_DATE = DATEADD(D, DATEDIFF(D, 0, GETDATE()), 0)
    END


    -- ------------------------------------------------------------------------------------
    -- Eliminar registros NO cancelados de cobro SIN FRECUENCIA
    -- ------------------------------------------------------------------------------------
    DELETE [wms].[OP_WMS_SERVICES_TO_BILL]
    WHERE [IS_CHARGED] = 0
      AND [PROCESS_DATE] = @PROCESS_DATE
      AND [BILLING_FRECUENCY] IS NULL

    -- ------------------------------------------------------------------------------------
    -- Eliminar registros NO cancelados de cobro MENSUAL
    -- ------------------------------------------------------------------------------------
    DELETE [wms].[OP_WMS_SERVICES_TO_BILL]
    WHERE [BILLING_FRECUENCY] = 30
      AND DATEPART(YEAR, [PROCESS_DATE]) = DATEPART(YEAR, @PROCESS_DATE)
      AND DATEPART(MONTH, [PROCESS_DATE]) = DATEPART(MONTH, @PROCESS_DATE)
      AND [IS_CHARGED] = 0

    -- ------------------------------------------------------------------------------------
    -- Eliminar registros NO cancelados de cobro primera quincena
    -- ------------------------------------------------------------------------------------
    DELETE [wms].[OP_WMS_SERVICES_TO_BILL]
    WHERE [BILLING_FRECUENCY] = 15
      AND DATEPART(DAY, @PROCESS_DATE) <= 15
      AND [PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_MONTH](@PROCESS_DATE)
      AND [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT](@PROCESS_DATE)
      AND [IS_CHARGED] = 0
    -- ------------------------------------------------------------------------------------
    -- Eliminar registros NO cancelados de cobro segunda quincena
    -- ------------------------------------------------------------------------------------
    DELETE [wms].[OP_WMS_SERVICES_TO_BILL]
    WHERE [BILLING_FRECUENCY] = 15
      AND DATEPART(DAY, @PROCESS_DATE) > 15
      AND [PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT](@PROCESS_DATE)
      AND [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH](@PROCESS_DATE)
      AND [IS_CHARGED] = 0

    -- ------------------------------------------------------------------------------------
    -- Eliminar registros NO cancelados de cobro semanal
    -- --------------------------------------------------------------------------------------  
    DELETE [wms].[OP_WMS_SERVICES_TO_BILL]
    WHERE [BILLING_FRECUENCY] = 7 -- FRECUENCIA SEMANAL
      AND DATEDIFF(WEEK, @PROCESS_DATE, [PROCESS_DATE]) = 0
      AND [IS_CHARGED] = 0
    -- ------------------------------------------------------------------------------------
    -- Eliminar registros NO cancelados de cobro diario
    -- --------------------------------------------------------------------------------------  
    DELETE [wms].[OP_WMS_SERVICES_TO_BILL]
    WHERE [BILLING_FRECUENCY] = 1 -- FRECUENCIA diaria
      AND [PROCESS_DATE] = @PROCESS_DATE
      AND [IS_CHARGED] = 0

    CREATE TABLE #DAY_SERVICES_TO_BILL (
      [QTY] INT
     ,[TRANSACTION_TYPE] VARCHAR(25)
     ,[PRICE] NUMERIC(18, 2)
     ,[TOTAL_AMOUNT] NUMERIC(18, 2)
     ,[PROCESS_DATE] DATETIME
     ,[CREATED_DATE] DATETIME NOT NULL
     ,[LAST_UPDATED_DATE] DATETIME
     ,[LAST_UPDATED_BY] VARCHAR(25)
     ,[TYPE_CHARGE_ID] INT
     ,[TYPE_CHARGE_DESCRIPTION] VARCHAR(250)
     ,[CLIENT_CODE] VARCHAR(25)
     ,[CLIENT_NAME] VARCHAR(250)
     ,[IS_CHARGED] INT
     ,[INVOICE_REFERENCE] VARCHAR(30)
     ,[CHARGED_DATE] DATETIME
     ,[LICENSE_ID] NUMERIC(9, 0)
     ,[LOCATION] VARCHAR(25)
     ,[SERVICE_ID] INT
     ,[SERVICE_CODE] VARCHAR(25)
     ,[SERVICE_DESCRIPTION] VARCHAR(250)
     ,[REGIMEN] VARCHAR(25)
     ,[DOC_NUM] INT
     ,[TRANSACTION_ID] INT
     ,[HAS_ADJUST] INT DEFAULT 0
     ,[BILLING_FRECUENCY] INT DEFAULT 0
     ,[ACUERDO_COMERCIAL] INT
    )

    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE PALLET POSITION
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [HAS_ADJUST], [BILLING_FRECUENCY], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_PALLET_POSITION] @PROCESS_DATE = @PROCESS_DATE
                                                               ,@LAST_UPDATED_BY = @LAST_UPDATED_BY
                                                               ,@TYPE = @TYPE

    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE METROS CUADRADOS
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [HAS_ADJUST], [BILLING_FRECUENCY], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_MT2] @PROCESS_DATE = @PROCESS_DATE
                                                   ,@LAST_UPDATED_BY = @LAST_UPDATED_BY
                                                   ,@TYPE = @TYPE


    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE AUDITORIA DE DESPACHO
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_AUDIT_DISPATCH] @INICIAL_DATE = @INICIAL_DATE
                                                              ,@END_DATE = @FINAL_DATE
                                                              ,@LAST_UPDATED_BY = @LAST_UPDATED_BY

    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE AUDITORIA DE RECEPCIÓN
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_AUDIT_RECEPTION] @INICIAL_DATE = @INICIAL_DATE
                                                               ,@END_DATE = @FINAL_DATE
                                                               ,@LAST_UPDATED_BY = @LAST_UPDATED_BY

    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE PICKING
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_PICKING] @INICIAL_DATE = @INICIAL_DATE
                                                       ,@END_DATE = @FINAL_DATE
                                                       ,@LAST_UPDATED_BY = @LAST_UPDATED_BY

    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE RECEPCION
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_RECEPTION] @INICIAL_DATE = @INICIAL_DATE
                                                         ,@END_DATE = @FINAL_DATE
                                                         ,@LAST_UPDATED_BY = @LAST_UPDATED_BY


    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE TIPO DE COBRO POR LICENCIA
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_TYPE_CHARGE_BY_LICENCE] @INICIAL_DATE = @INICIAL_DATE
                                                                      ,@END_DATE = @FINAL_DATE
                                                                      ,@LAST_UPDATED_BY = @LAST_UPDATED_BY


    -- ------------------------------------------------------------------------------------
    -- OBTENER SERVICIO A COBRAR DE TIPO DE COBRO POR LICENCIA
    -- ------------------------------------------------------------------------------------
    INSERT INTO [#DAY_SERVICES_TO_BILL] ([QTY], [TRANSACTION_TYPE], [PRICE], [TOTAL_AMOUNT], [PROCESS_DATE], [CREATED_DATE], [LAST_UPDATED_DATE], [LAST_UPDATED_BY], [TYPE_CHARGE_ID], [TYPE_CHARGE_DESCRIPTION], [CLIENT_CODE], [CLIENT_NAME], [IS_CHARGED], [INVOICE_REFERENCE], [CHARGED_DATE], [LICENSE_ID], [LOCATION], [SERVICE_ID], [SERVICE_CODE], [SERVICE_DESCRIPTION], [REGIMEN], [DOC_NUM], [TRANSACTION_ID], [BILLING_FRECUENCY], [ACUERDO_COMERCIAL])
    EXEC [wms].[OP_WMS_GET_SERVICE_TO_BILL_TYPE_CHARGE_BY_FREQUENCY] @PROCESS_DATE = @PROCESS_DATE
                                                                        ,@LAST_UPDATED_BY = @LAST_UPDATED_BY
                                                                        ,@TYPE = @TYPE


    UPDATE [#DAY_SERVICES_TO_BILL]
    SET [PROCESS_DATE] = @PROCESS_DATE
    --
    INSERT INTO [wms].[OP_WMS_SERVICES_TO_BILL]
      SELECT
        [QTY]
       ,[TRANSACTION_TYPE]
       ,[PRICE]
       ,[TOTAL_AMOUNT]
       ,[PROCESS_DATE]
       ,[CREATED_DATE]
       ,[LAST_UPDATED_DATE]
       ,[LAST_UPDATED_BY]
       ,[TYPE_CHARGE_ID]
       ,[TYPE_CHARGE_DESCRIPTION]
       ,[CLIENT_CODE]
       ,[CLIENT_NAME]
       ,[IS_CHARGED]
       ,[INVOICE_REFERENCE]
       ,[CHARGED_DATE]
       ,[LICENSE_ID]
       ,[LOCATION]
       ,[SERVICE_ID]
       ,[SERVICE_CODE]
       ,[SERVICE_DESCRIPTION]
       ,[REGIMEN]
       ,[DOC_NUM]
       ,[TRANSACTION_ID]
       ,[HAS_ADJUST]
       ,[BILLING_FRECUENCY]
       ,[ACUERDO_COMERCIAL]
      FROM [#DAY_SERVICES_TO_BILL]
    COMMIT;
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData

  END TRY
  BEGIN CATCH
    ROLLBACK
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH


END