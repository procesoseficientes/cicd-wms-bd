-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-05-30 ErgonTeam@Sheik
-- Description:	  funcion debe de devolver el valor de la convercion que esta en configuraciones




/*
-- Ejemplo de Ejecucion:
			SELECT [wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]( 10, 'KG') CONVERSION
*/
-- =============================================

CREATE FUNCTION [wms].OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT (@QTY DECIMAL(18, 6),
@UNIT VARCHAR(50))
RETURNS DECIMAL(18, 6)
AS

BEGIN
  DECLARE @CONVERSION DECIMAL(18, 6) = 0
  SELECT
    @CONVERSION =
                 CASE
                   WHEN [C].[DECIMAL_VALUE] = 0 THEN 0
                   ELSE ISNULL(@QTY / [C].[DECIMAL_VALUE], 0)
                 END
  FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
  WHERE [C].[PARAM_TYPE] = 'SISTEMA'
  AND [C].[PARAM_GROUP] = 'UNIDAD_PESO'
  AND [C].[PARAM_NAME] = @UNIT
  RETURN @CONVERSION;
END