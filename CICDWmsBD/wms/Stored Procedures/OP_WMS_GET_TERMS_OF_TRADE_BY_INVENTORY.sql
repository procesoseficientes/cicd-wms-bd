-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	09-01-2017 @ A-TEAM Sprint Balder
-- Description:			SP que obtiene el inventario por acuerdo comercial en base a un rango de fechas 

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego bodegas de usuario logueado

/*
-- Ejemplo de Ejecucion:
				EXEC  [wms].[OP_WMS_GET_TERMS_OF_TRADE_BY_INVENTORY]
          @CLIENT_ID = 'C00030|C00012|C00021'
          ,@START_DATE = '2/22/2010 2:52:51 PM'
          ,@END_DATE = '10/22/2016 2:52:51 PM'

*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_GET_TERMS_OF_TRADE_BY_INVENTORY (@CLIENT_ID VARCHAR(MAX)
, @START_DATE DATE
, @END_DATE DATE,
@LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @DELIMITER CHAR(1) = '|'

  -- SE OBTIENEN BODEGAS DE USUARIO LOGUEADO

  CREATE TABLE #WAREHOUSES (
    WAREHOUSE_ID VARCHAR(25)
   ,NAME VARCHAR(50)
   ,COMMENTS VARCHAR(150)
   ,ERP_WAREHOUSE VARCHAR(50)
   ,ALLOW_PICKING NUMERIC
   ,DEFAULT_RECEPTION_LOCATION VARCHAR(25)
   ,SHUNT_NAME VARCHAR(25)
   ,WAREHOUSE_WEATHER VARCHAR(50)
   ,WAREHOUSE_STATUS INT
   ,IS_3PL_WAREHUESE INT
   ,WAHREHOUSE_ADDRESS VARCHAR(250)
   ,GPS_URL VARCHAR(100)
   ,WAREHOUSE_BY_USER_ID INT
  )

  INSERT INTO #WAREHOUSES
  EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN

  -- -------------------------------------------------------------
  -- Obtiene los Clientes
  -- -------------------------------------------------------------
  SELECT
    VC.CLIENT_CODE AS CLIENT_OWNER
   ,VC.CLIENT_NAME INTO #CLIENTS
  FROM [wms].[OP_WMS_FN_SPLIT](@CLIENT_ID, @DELIMITER) [owfs]
  INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC]
    ON (
    owfs.[VALUE] = VC.[CLIENT_CODE]
    )

  -- --------------------------------------------------------------
  -- Se obtiene la informacion del inventario
  -- --------------------------------------------------------------

  SELECT
    [owvc].[CLIENT_CODE]
   ,[owvc].[CLIENT_NAME]
   ,[TH].[ACUERDO_COMERCIAL_ID]
   ,[TH].[ACUERDO_COMERCIAL_NOMBRE]
   ,[owph].[WAREHOUSE_REGIMEN] AS REGIMEN
   ,[TH].[VALID_FROM]
   ,[TH].[VALID_TO]
   ,(CASE [TH].[STATUS]
      WHEN 'ACTIVE' THEN 'ACTIVO'
      ELSE 'INACTIVO'
    END) AS [STATUS]
   ,SUM(owvv.[QTY]) AS INVENTORY_QTY
   ,SUM(owvv.[TOTAL_VALOR]) AS VALOR_TOTAL
  FROM [wms].[OP_WMS_VIEW_VALORIZACION] [owvv]
  INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [owph]
    ON (
    [owvv].[CODIGO_POLIZA] = [owph].[CODIGO_POLIZA]
    )
  INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] TH
    ON (
    TH.[ACUERDO_COMERCIAL_ID] = owph.[ACUERDO_COMERCIAL]
    )
  INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [owvc]
    ON (
    [owvv].[CLIENT_NAME] = [owvc].[CLIENT_NAME]
    )
  INNER JOIN [#CLIENTS] [c]
    ON (
    c.CLIENT_OWNER = [owvv].[CLIENT_OWNER]
    )
  INNER JOIN [#WAREHOUSES] [W]
    ON([owvv].[CURRENT_WAREHOUSE] = W.[WAREHOUSE_ID])
  WHERE owph.[LAST_UPDATED] BETWEEN @START_DATE AND @END_DATE
  GROUP BY [owvc].[CLIENT_CODE]
          ,[owvc].[CLIENT_NAME]
          ,[TH].[ACUERDO_COMERCIAL_ID]
          ,[TH].[ACUERDO_COMERCIAL_NOMBRE]
          ,[owph].[WAREHOUSE_REGIMEN]
          ,[TH].[VALID_FROM]
          ,[TH].[VALID_TO]
          ,[TH].[STATUS]
END