-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	30-Apr-2018 @ A-TEAM Sprint Caribú  
-- Description:			SP que obtine las familias disponiblea descuentos de escala por familia.

-- Autor:				marvin.garcia
-- Fecha de Creacion: 	19-Jun @ A-TEAM Sprint Caribú  
-- Description:			Se modifica SP para obtener todas las familias (sin join)

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_FAMILY_SKU_FOR_DISCOUNT_OF_SCALE_BY_FAMILY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_FAMILY_SKU_FOR_DISCOUNT_OF_SCALE_BY_FAMILY] (@PROMO_ID INT = NULL)
AS
BEGIN
  SELECT
  DISTINCT
    [FS].[FAMILY_SKU]
   ,[FS].[CODE_FAMILY_SKU]
   ,[FS].[DESCRIPTION_FAMILY_SKU]
   ,[FS].[ORDER]
   ,[FS].[LAST_UPDATE]
   ,[FS].[LAST_UPDATE_BY]
  FROM [SONDA].[SWIFT_FAMILY_SKU] [FS]
END;
