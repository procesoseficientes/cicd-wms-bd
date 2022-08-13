-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-06-16 ERGON@BreathOfTheWild
-- Description:	 Obtener las series a escanear del picking discrecional




/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_GET_REQUESTED_SERIAL_NUMBERS_DISCRETIONAL_PICKING_BY_LICENSE] @LICENSE_ID = 167669 
                                                                    ,@MATERIAL_ID = 'wms/100003'
                                                                    , @WAVE_PICKING_ID = 25

  SELECT *        
      FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S] WHERE SERIAL = '201234567899'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_REQUESTED_SERIAL_NUMBERS_DISCRETIONAL_PICKING_BY_LICENSE] (@LICENSE_ID DECIMAL
, @MATERIAL_ID VARCHAR(50)
 , @WAVE_PICKING_ID INT )
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [S].[SERIAL]
  FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
  WHERE [S].[LICENSE_ID] = @LICENSE_ID
  AND [S].[MATERIAL_ID] = @MATERIAL_ID
  AND [S].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
  AND [S].[STATUS] = 1


END