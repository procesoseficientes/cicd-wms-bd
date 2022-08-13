-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 @ Team ERGON - Sprint ERGON 1
-- Description:	        Obtiene las configuraciones dependiendo de los parametros

-- Modificacion 9/11/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega el parametro @PARAM_NAME

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-02 @ Team REBORN - Sprint 
-- Description:	   Se modifico parametro PARAM_NAME ya que no es sufisiente varchar(25)

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_CONFIGURATIONS 
  exec [wms].OP_WMS_SP_GET_CONFIGURATIONS @PARAM_TYPE='SISTEMA',@PARAM_GROUP='RECEPCION',@PARAM_NAME='AÑOS_A_AGREGAR_A_FECHA_DE_VENCIMIENTO_DE_LOTE'

*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_CONFIGURATIONS (@PARAM_TYPE VARCHAR(25)
, @PARAM_GROUP VARCHAR(25)
, @PARAM_NAME VARCHAR(50) = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [PARAM_TYPE]
   ,[PARAM_GROUP]
   ,[PARAM_GROUP_CAPTION]
   ,[PARAM_NAME]
   ,[PARAM_CAPTION]
   ,[NUMERIC_VALUE]
   ,[MONEY_VALUE]
   ,[TEXT_VALUE]
   ,[DATE_VALUE]
   ,[RANGE_NUM_START]
   ,[RANGE_NUM_END]
   ,[RANGE_DATE_START]
   ,[RANGE_DATE_END]
   ,[SPARE1]
   ,[SPARE2]
   ,[DECIMAL_VALUE]
   ,[SPARE3]
   ,[SPARE4]
   ,[SPARE5]
   ,[COLOR]
  FROM [wms].[OP_WMS_CONFIGURATIONS]
  WHERE [PARAM_TYPE] = @PARAM_TYPE
  AND [PARAM_GROUP] = @PARAM_GROUP
  AND (@PARAM_NAME IS NULL
  OR [PARAM_NAME] = @PARAM_NAME);

END;