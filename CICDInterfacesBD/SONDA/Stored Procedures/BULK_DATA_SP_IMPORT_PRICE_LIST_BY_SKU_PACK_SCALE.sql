-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	12-05-2016
-- Description:			SP que importa los precios por escalas y unidad de medidas

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_PRICE_LIST_BY_SKU_PACK_SCALE]
				--
				SELECT * FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_PRICE_LIST_BY_SKU_PACK_SCALE]
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Se limpia la tabla SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE [SWIFT_EXPRESS].[SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE]

  -- ------------------------------------------------------------------------------------
  -- Se crea la tabla comun
  -- ------------------------------------------------------------------------------------
  CREATE TABLE #TEMP (
    CODE_PRICE_LIST VARCHAR(5000)
   ,CODE_SKU VARCHAR(80)
   ,CODE_PACK_UNIT VARCHAR(80)
   ,LIMIT NUMERIC(18, 0)
   ,COST NUMERIC(18, 6)
   ,[PRIORITY] NUMERIC(18, 0)
   ,[OWNER] VARCHAR(30)
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene SKU y precio base
  -- ------------------------------------------------------------------------------------
  INSERT INTO #TEMP
    SELECT
      CODE_PRICE_LIST
     ,CODE_SKU
     ,CODE_PACK_UNIT
     ,1 AS LIMIT
     ,COST
     ,0
     ,'SONDA'
    FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_PRICE_LIST_BY_SKU]


  -- ------------------------------------------------------------------------------------
  -- Obtiene el precio base por SKU de los paquetes que no son por defecto
  -- ------------------------------------------------------------------------------------
  --INSERT INTO #TEMP
  --  SELECT
  --    CODE_PRICE_LIST
  --   ,CODE_SKU
  --   ,CODE_PACK_UNIT
  --   ,1 AS LIMIT
  --   ,COST
  --   ,0
  --   ,'SONDA'
  --  FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_SKU_BASE_PRICE_BY_PACK]


  -- ------------------------------------------------------------------------------------
  -- Obtiene los precios por escala y paquete de los SKU
  -- ------------------------------------------------------------------------------------
  INSERT INTO #TEMP
    SELECT
      CODE_PRICE_LIST
     ,CODE_SKU
     ,CODE_PACK_UNIT
     ,LIMIT
     ,COST
     ,1
     ,'SONDA'
    FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_PRICE_LIST_BY_SKU_PACK_SCALE]


  -- ------------------------------------------------------------------------------------
  -- Se define los limites superiores e inferiores
  -- ------------------------------------------------------------------------------------
  SELECT
    CODE_PRICE_LIST
   ,CODE_SKU
   ,CODE_PACK_UNIT
   ,[PRIORITY]
   ,LIMIT LOW_LIMIT
   ,ISNULL((LEAD(LIMIT) OVER (
    PARTITION BY
    CODE_PRICE_LIST
    , CODE_SKU
    , CODE_PACK_UNIT
    ORDER BY
    CODE_PRICE_LIST
    , CODE_SKU
    , CODE_PACK_UNIT
    , [PRIORITY] DESC
    , LIMIT
    ) - 1), 1000000) HIGH_LIMIT
   ,COST PRICE
   ,[OWNER] INTO #TEMP2
  FROM #TEMP
  ORDER BY CODE_PRICE_LIST
  , CODE_SKU
  , CODE_PACK_UNIT
  , [PRIORITY] DESC
  , LIMIT

  -- ------------------------------------------------------------------------------------
  -- Inserta el resultado final
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SWIFT_EXPRESS].[SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE] (CODE_PRICE_LIST
  , CODE_SKU
  , CODE_PACK_UNIT
  , [PRIORITY]
  , LOW_LIMIT
  , HIGH_LIMIT
  , PRICE
  , [OWNER])
    SELECT DISTINCT
      CODE_PRICE_LIST
     ,CODE_SKU
     ,CODE_PACK_UNIT
     ,[PRIORITY]
     ,LOW_LIMIT
     ,CASE HIGH_LIMIT
        WHEN 0 THEN 1000000
        ELSE HIGH_LIMIT
      END HIGH_LIMIT
     ,PRICE
     ,[OWNER]
    FROM #TEMP2
    ORDER BY CODE_PRICE_LIST
    , CODE_SKU
    , CODE_PACK_UNIT
    , [PRIORITY]
    , LOW_LIMIT


END