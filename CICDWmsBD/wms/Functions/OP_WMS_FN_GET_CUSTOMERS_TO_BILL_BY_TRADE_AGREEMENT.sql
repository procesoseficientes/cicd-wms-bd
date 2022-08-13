-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-10 A-TEAM SPRINT BALDER
-- Description:	 fUNCIÓN para obtener los clientes que tiene cobros por acuerdo comercial.


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-29 Team ERGON - Sprint ERGON HYPER
-- Description:	 Se modifica la validación por vigencia del acuerdo ya que este debe de generar el cobro aun vencido. 





/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[OP_WMS_FN_GET_CUSTOMERS_TO_BILL_BY_TRADE_AGREEMENT]( 1
					, 'ON_DEMAND'
					, '20170110 00:00:00.000'
					, 'PP', 0)
*/
-- =============================================    
CREATE FUNCTION [wms].OP_WMS_FN_GET_CUSTOMERS_TO_BILL_BY_TRADE_AGREEMENT (@USE_FRECUENCY INT = 0
, @TYPE VARCHAR(25)
, @PROCESS_DATE DATETIME
, @SERVICE_CODE VARCHAR(25)
, @IS_EXTERNAL_SERVICE INT)
RETURNS @CLIENT_TO_BILL TABLE (
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
AS
BEGIN

  --

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CLIENT_TO_BILL ([CLIENT_CODE]
  , [CLIENT_NAME]
  , [ACUERDO_COMERCIAL]
  , [TYPE_CHARGE_ID]
  , [TYPE_CHARGE_DESCRIPTION]
  , [SERVICE_ID]
  , [SERVICE_CODE]
  , [SERVICE_DESCRIPTION]
  , [UNIT_PRICE]
  , [REGIMEN]
  , [BILLING_FRECUENCY])
    SELECT
      [C].[CLIENT_CODE]
     ,[C].[CLIENT_NAME]
     ,[AC].[ACUERDO_COMERCIAL]
     ,[T].[TYPE_CHARGE_ID]
     ,[TC].[DESCRIPTION]
     ,[S].[SERVICE_ID]
     ,[TC].[SERVICE_CODE]
     ,[S].[SERVICE_DESCRIPTION]
     ,[T].[UNIT_PRICE]
     ,[H].[REGIMEN]
     ,[T].[BILLING_FRECUENCY]
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
    WHERE --@PROCESS_DATE BETWEEN [H].[VALID_FROM] AND [H].[VALID_TO]
    (@SERVICE_CODE IS NULL
    OR [TC].[SERVICE_CODE] = @SERVICE_CODE)
    AND [S].[IS_EXTERNAL_SERVICE] = @IS_EXTERNAL_SERVICE

  --

  -- ------------------------------------------------------------------------------------
  -- Valida si usa frecuencia y de que tipo se quiere obtener
  -- ------------------------------------------------------------------------------------
  IF @USE_FRECUENCY = 1
  BEGIN
    IF @TYPE = 'AUTOMATIC_SERVICE'
    BEGIN
      DELETE @CLIENT_TO_BILL
      WHERE [BILLING_FRECUENCY] = 30 --FRECUENCIA MENSUAL
        AND (DATEPART(DAY, [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH](@PROCESS_DATE)) <> DATEPART(DAY, @PROCESS_DATE))
      --
      DELETE @CLIENT_TO_BILL
      WHERE [BILLING_FRECUENCY] = 15 --FRECUENCIA QUINCENAL
        AND NOT (
        DATEPART(DAY, @PROCESS_DATE) = 15
        OR DATEPART(DAY, [wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH](@PROCESS_DATE)) = DATEPART(DAY, @PROCESS_DATE)
        )
      --
      DELETE @CLIENT_TO_BILL
      WHERE [BILLING_FRECUENCY] = 7 -- FRECUENCIA SEMANAL
        AND (DATEPART(DW, @PROCESS_DATE) <> 7)
    END

    -- ------------------------------------------------------------------------------------
    -- Borra los que no tienen frecuencia
    -- ------------------------------------------------------------------------------------
    DELETE @CLIENT_TO_BILL
    WHERE [BILLING_FRECUENCY] = 0
      OR [BILLING_FRECUENCY] IS NULL
  END


  RETURN
END