
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa bodegas

-- MODIFICADO:		19-08-2016
-- Autor:			diego.as
-- Descripcion:		Se modifico la tabla con la que hace el merge para que vea la tabla directamente de SWIFT_EXPRESS


/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_WAREHOUSE]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_WAREHOUSE]
AS
BEGIN
  SET NOCOUNT ON;
  --
  MERGE [SWIFT_EXPRESS].[wms].[SWIFT_WAREHOUSES] SW
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_WAREHOUSE]) WVH
  ON SW.[CODE_WAREHOUSE] = WVH.[CODE_WAREHOUSE]
  WHEN MATCHED
    THEN UPDATE
      SET SW.[DESCRIPTION_WAREHOUSE] = WVH.[DESCRIPTION]
         ,SW.[WEATHER_WAREHOUSE] = WVH.[WEATHER_WAREHOUSE]
         ,SW.[STATUS_WAREHOUSE] = WVH.[STATUS_WAREHOUSE]
         ,SW.[LAST_UPDATE] = WVH.[LAST_UPDATE]
         ,SW.[LAST_UPDATE_BY] = WVH.[LAST_UPDATE_BY]
         ,SW.[IS_EXTERNAL] = WVH.[IS_EXTERNAL]
  WHEN NOT MATCHED
    THEN INSERT ([CODE_WAREHOUSE]
      , [DESCRIPTION_WAREHOUSE]
      , [WEATHER_WAREHOUSE]
      , [STATUS_WAREHOUSE]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [IS_EXTERNAL])
        VALUES (WVH.[CODE_WAREHOUSE], WVH.[DESCRIPTION], WVH.[WEATHER_WAREHOUSE], WVH.[STATUS_WAREHOUSE], WVH.[LAST_UPDATE], WVH.[LAST_UPDATE_BY], WVH.[IS_EXTERNAL]);
END


