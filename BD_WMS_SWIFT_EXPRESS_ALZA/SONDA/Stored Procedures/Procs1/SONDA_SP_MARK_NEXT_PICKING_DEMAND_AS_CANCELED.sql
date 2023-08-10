-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-11-14 @ Team REBORN - Sprint Eberhard
-- Description:	        Sp que marca un picking demand header como cancelado

/*
-- Ejemplo de Ejecucion:
			EXEC alsersa.SONDA_SP_MARK_NEXT_PICKING_DEMAND_AS_CANCELED 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_MARK_NEXT_PICKING_DEMAND_AS_CANCELED] (@PICKING_DEMAND_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @EXTERNAL_SOURCE_ID INT
         ,@DATABASE_NAME VARCHAR(50)
         ,@SCHEMA_NAME VARCHAR(50)
         ,@QUERY VARCHAR(MAX)

  SELECT
    @EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
   ,@DATABASE_NAME = [ES].[DATABASE_NAME]
   ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
  FROM [SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] [ES]
  WHERE [ES].[DATABASE_NAME] = 'OP_WMS_ALSERSA'
  AND [ES].[EXTERNAL_SOURCE_ID] > 0;


  SELECT
    @QUERY = '
    UPDATE ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_NEXT_PICKING_DEMAND_HEADER] 
    SET 
    [IS_CANCELED_FROM_SONDA_SD] = 1
    WHERE [PICKING_DEMAND_HEADER_ID] = ' + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR) + '
    AND [PICKING_DEMAND_HEADER_ID] > 0;
	';
  PRINT @QUERY
  EXEC (@QUERY);




END
