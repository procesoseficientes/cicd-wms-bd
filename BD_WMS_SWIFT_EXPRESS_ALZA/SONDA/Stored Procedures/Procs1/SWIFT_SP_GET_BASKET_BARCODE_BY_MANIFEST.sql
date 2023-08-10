-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-11-23 @ Team REBORN - Sprint NACH
-- Description:	        Sp que devuelve los barcode de las canastas de un manifiesto

/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].SWIFT_SP_GET_BASKET_BARCODE_BY_MANIFEST @MANIFEST_HEADER_ID =2151
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_BASKET_BARCODE_BY_MANIFEST (@MANIFEST_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @DATABASE_NAME VARCHAR(MAX)
         ,@SCHEMA_NAME VARCHAR(MAX)
         ,@QUERY VARCHAR(MAX)
         ,@SHOW_BASKETS_OF_MANIFEST VARCHAR(MAX)
  -- -----------------------------------------------------------------------
  -- Se obtiene el nombre de la BD y el Esquema de la implementacion de 3PL
  -- -----------------------------------------------------------------------
  SELECT
    @DATABASE_NAME = [S].[DATABASE_NAME]
   ,@SCHEMA_NAME = [S].[SCHEMA_NAME]
  FROM [SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS [S]
  WHERE [S].[EXTERNAL_SOURCE_ID] > 0;

  -- ---------------------------------------------------------------------------------
  -- Se obtienen los distintos clientes para generar las tareas de entrega de Sonda SD
  -- ---------------------------------------------------------------------------------
  IF EXISTS (SELECT
      TOP 1
        1
      FROM [SONDA].[SWIFT_PARAMETER] [SP]
      WHERE [SP].[PARAMETER_ID] = 'SHOW_BASKETS_OF_MANIFEST'
      AND [SP].[VALUE] = 1)
  BEGIN

    DECLARE @RESULT TABLE (
      [MANIFEST_HEADER_ID] INT
     ,[PICKING_DEMAND_HEADER_ID] INT
     ,BARCODE VARCHAR(50)
     ,[DOC_NUM] INT
     ,[ERP_REFERENCE_DOC_NUM] INT
    )

    SELECT
      @QUERY = '      
      SELECT 
        [MANIFEST_HEADER_ID]
       ,[PICKING_DEMAND_HEADER_ID]
       ,BARCODE
       ,[DOC_NUM]
       ,[ERP_REFERENCE_DOC_NUM]  
      FROM OPENQUERY( [MOBILITYSERVER] ,''
  EXEC ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_SP_GET_BASKET_BARCODE_BY_MANIFEST] @MANIFEST_HEADER_ID = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + ' 
   '' )';

    PRINT @QUERY;

    INSERT INTO @RESULT
    EXEC (@QUERY);

    SELECT
      [MANIFEST_HEADER_ID]
     ,[PICKING_DEMAND_HEADER_ID]
     ,[BARCODE]
     ,[DOC_NUM]
     ,[ERP_REFERENCE_DOC_NUM]
    FROM @RESULT

  END

END
