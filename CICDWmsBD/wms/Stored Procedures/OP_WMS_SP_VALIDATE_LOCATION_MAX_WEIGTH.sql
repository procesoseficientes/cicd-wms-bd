-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        Sp que valida si la ubicacion se sobrepasa de peso

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_VALIDATE_LOCATION_MAX_WEIGTH] @LOCATION_SPOT = 'B01-R01-C01-NC'
                                                          , @LICENCE_ID = 257730
                                                          

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LOCATION_MAX_WEIGTH] (@LOCATION_SPOT VARCHAR(25)
, @LICENCE_ID NUMERIC)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @LOCATION_WEIGHT DECIMAL(18, 2)
         ,@MAX_WEIGHT DECIMAL(18, 2)

  SELECT
    @LOCATION_WEIGHT = [WEIGHT_IN_TONS]
   ,@MAX_WEIGHT = [MAX_WEIGHT]
  FROM [wms].[OP_WMS_VW_GET_LOCATIONS_WITH_WEIGHT]
  WHERE [LOCATION_SPOT] = @LOCATION_SPOT

  SELECT
    [wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](SUM([IL].[QTY]), MAX([M].[WEIGHT_MEASUREMENT])) PESO_MATERIAL 
    INTO #PESOS_LICENCIA
  FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]

  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON (
    [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
    )
  WHERE ([IL].[LICENSE_ID] = @LICENCE_ID)
  GROUP BY [IL].[MATERIAL_ID]


  SELECT
    CASE
      WHEN @MAX_WEIGHT < (@LOCATION_WEIGHT + SUM(PESO_MATERIAL)) THEN 'SI'
      ELSE 'NO'
    END AS [RESULT]
   ,(@LOCATION_WEIGHT + SUM(PESO_MATERIAL)) AS [WEIGHT]
  FROM [#PESOS_LICENCIA] [PL]


END