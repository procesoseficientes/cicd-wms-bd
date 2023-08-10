-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	14-Nov-2017 @Reborn - TEAM Sprint Eberhard
-- Description:			SP que obtiene el detalle de las ordenes de compra

-- Modificacion 11/20/2017 @ Reborn-Team Sprint Nache
					-- diego.as
					-- Se agrega columna IS_BONUS y se agrega openquery

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_NEXT_PICKING_DEMAND_DETAIL_BY_MANIFEST] @MANIFEST_HEADER_ID = 2153
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_NEXT_PICKING_DEMAND_DETAIL_BY_MANIFEST] (@MANIFEST_HEADER_ID INT)
AS
BEGIN
  --
  SET NOCOUNT ON;

  DECLARE @DATABASE_NAME VARCHAR(MAX)
         ,@SCHEMA_NAME VARCHAR(MAX)
         ,@QUERY VARCHAR(MAX)
         ,@CLIENT_CODE VARCHAR(50)
         ,@TASK_ID INT
         ,@TASK_STATUS VARCHAR(50)
         ,@GPS_WAREHOUSE VARCHAR(50);

  SELECT TOP 1
    @DATABASE_NAME = [S].[DATABASE_NAME]
   ,@SCHEMA_NAME = [S].[SCHEMA_NAME]
  FROM [SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS [S]
  WHERE [S].[EXTERNAL_SOURCE_ID] > 0;
  --
  
  SET
    @QUERY = '	SELECT * FROM OPENQUERY( [MOBILITYSERVER],''  
        SELECT
          [PDD].[PICKING_DEMAND_DETAIL_ID]
         ,[PDD].[PICKING_DEMAND_HEADER_ID]
         ,(SUBSTRING([PDD].[MATERIAL_ID], CHARINDEX(''''/'''', [PDD].[MATERIAL_ID]) + 1, LEN([PDD].[MATERIAL_ID]))) AS [MATERIAL_ID]
		 ,[M].[MATERIAL_NAME]  AS [MATERIAL_DESCRIPTION]
		 ,[M].[SERIAL_NUMBER_REQUESTS] AS [REQUERIES_SEERIE]
         ,[PDD].[QTY]
         ,[PDD].[LINE_NUM]
         ,[PDD].[ERP_OBJECT_TYPE]
         ,[PDD].[PRICE]
         ,[PDD].[WAS_IMPLODED]
         ,[PDD].[QTY_IMPLODED]
         ,[PDD].[MASTER_ID_MATERIAL]
         ,[PDD].[MATERIAL_OWNER]
         ,[PDD].[ATTEMPTED_WITH_ERROR]
         ,[PDD].[IS_POSTED_ERP]
         ,[PDD].[POSTED_ERP]
         ,[PDD].[ERP_REFERENCE]
         ,[PDD].[POSTED_STATUS]
         ,[PDD].[POSTED_RESPONSE]
         ,[PDD].[INNER_SALE_STATUS]
         ,[PDD].[INNER_SALE_RESPONSE]
         ,[PDD].[TONE]
         ,[PDD].[CALIBER]
		 ,[PDD].[IS_BONUS]
		 ,[PDD].[DISCOUNT]
        FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD] 
        INNER JOIN ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_MANIFEST_DETAIL] [MD]
         ON (
          [MD].[PICKING_DEMAND_HEADER_ID] = [PDD].[PICKING_DEMAND_HEADER_ID]
          AND [MD].[MATERIAL_ID] = [PDD].[MATERIAL_ID]          
         )
		INNER JOIN ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_MATERIALS] [M] ON(
			[M].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
		)
        WHERE [MD].[MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + '		
		    '')';
	--
	PRINT (@QUERY)
 
	--
	EXEC(@QUERY);
--		
END;
