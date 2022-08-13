-- =============================================
-- Author:		  hector.gonzalez
-- Create date: 08-12-2016 @TEAM-A 6
-- Description:	devuelve los tipos de cobro relacionados al acuerdo comercial del cliente que pertence a la licencia

/*
-- Ejemplo de Ejecucion:      
				EXEC [wms].OP_WMS_GET_TYPE_CHARGE_BY_MOBILE
					@LICENSE_ID = 147625
				--
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_TYPE_CHARGE_BY_MOBILE] 
  @LICENSE_ID AS INT,
  @TYPE_TRANS AS VARCHAR(25)

AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @CLIENT_OWNER VARCHAR(25)
  SELECT TOP 1
    @CLIENT_OWNER = CLIENT_OWNER
  FROM [wms].OP_WMS_LICENSES
  WHERE LICENSE_ID = @LICENSE_ID

  SELECT DISTINCT
    [TC].[TYPE_CHARGE_ID]
   ,[TC].[CHARGE]
   ,[TC].[DESCRIPTION]
   ,[TC].[WAREHOUSE_WEATHER]
   ,[TC].[REGIMEN]
   ,[TC].[COMMENT]
   ,[TC].[DAY_TRIP]
   ,[TC].[SERVICE_CODE]
   ,[TC].[TO_MOVIL]
   ,ISNULL([L].[QTY],0) AS QTY
  FROM [wms].[OP_WMS_TYPE_CHARGE] [TC]
  INNER JOIN [wms].[OP_WMS_TARIFICADOR_DETAIL] [TD]
    ON [TC].[TYPE_CHARGE_ID] = [TD].[TYPE_CHARGE_ID]
  INNER JOIN [wms].[OP_WMS_ACUERDOS_X_CLIENTE] [AC]
    ON [AC].[ACUERDO_COMERCIAL] = [TD].[ACUERDO_COMERCIAL]
  INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH]
    ON [TH].[ACUERDO_COMERCIAL_ID] = [TD].[ACUERDO_COMERCIAL]
  LEFT JOIN [wms].[OP_WMS_TYPE_CHARGE_X_LICENSE] [L]
    ON  [L].[TYPE_CHARGE_ID] = [TC].[TYPE_CHARGE_ID] AND   [L].[LICENCESE_ID] = @LICENSE_ID 
    AND [L].[TYPE_TRANS] = @TYPE_TRANS
  WHERE [AC].[CLIENT_ID] = @CLIENT_OWNER
  AND [TC].[TO_MOVIL] = 1
  
  AND GETDATE() BETWEEN [TH].[VALID_FROM] AND [TH].[VALID_TO]
  ORDER BY [TC].[DESCRIPTION]

END