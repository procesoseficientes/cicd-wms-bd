-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que obtiene las bodegas asociadas a una zona 

/*
-- Ejemplo de Ejecucion:
				EXEC  [SONDA].[SWIFT_SP_GET_AVAILABLE_WAREHOUSE_BY_ZONE] @ID_ZONE = 2
SELECT * FROM [SONDA].[SWIFT_WAREHOUSE_X_ZONE] 

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_AVAILABLE_WAREHOUSE_BY_ZONE] (@ID_ZONE INT )
AS
BEGIN
  SET NOCOUNT ON;
  --

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
 SELECT 
      [W].[WAREHOUSE]
     ,[W].[CODE_WAREHOUSE]
     ,[W].[DESCRIPTION_WAREHOUSE]
     ,[W].[WEATHER_WAREHOUSE]
     ,[W].[STATUS_WAREHOUSE]
     ,[W].[LAST_UPDATE]
     ,[W].[LAST_UPDATE_BY]
     ,[W].[IS_EXTERNAL]
     ,[W].[BARCODE_WAREHOUSE]
     ,[W].[SHORT_DESCRIPTION_WAREHOUSE]
     ,[W].[TYPE_WAREHOUSE]
     ,[W].[ERP_WAREHOUSE]
     ,[W].[ADDRESS_WAREHOUSE]
     ,[W].[GPS_WAREHOUSE] 
  FROM [SONDA].[SWIFT_WAREHOUSES] [W]
    LEFT JOIN [SONDA].[SWIFT_WAREHOUSE_X_ZONE] [SWXZ] ON [W].[CODE_WAREHOUSE] = [SWXZ].[CODE_WAREHOUSE] AND @ID_ZONE = [SWXZ].[ID_ZONE]
  WHERE  [SWXZ].[WAREHOUSE_X_ZONE_ID] IS NULL


END
