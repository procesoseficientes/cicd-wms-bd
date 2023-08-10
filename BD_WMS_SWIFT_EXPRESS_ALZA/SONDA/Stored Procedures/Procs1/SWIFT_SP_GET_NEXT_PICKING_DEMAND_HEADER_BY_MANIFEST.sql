-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	14-Nov-2017 @Reborn - TEAM Sprint Eberhard
-- Description:			SP que obtiene las orden de compra

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	12-Dec-2017 @Reborn - TEAM Sprint Pannen
-- Description:			Se agrego la columna [DISCOUNT]


/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_NEXT_PICKING_DEMAND_HEADER_BY_MANIFEST] @MANIFEST_HEADER_ID = 2145
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_NEXT_PICKING_DEMAND_HEADER_BY_MANIFEST (@MANIFEST_HEADER_ID INT)
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
    @DATABASE_NAME = [S].[database_name]
   ,@SCHEMA_NAME = [S].[schema_name]
  FROM [SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS [S]
  WHERE [S].[EXTERNAL_SOURCE_ID] > 0;
  --

  SELECT
    @QUERY = '	      
        SELECT DISTINCT
          [PDH].[PICKING_DEMAND_HEADER_ID]
         ,[PDH].[DOC_NUM]
         ,[PDH].[CLIENT_CODE]
         ,[PDH].[CODE_ROUTE]
         ,[PDH].[CODE_SELLER]
         ,[PDH].[TOTAL_AMOUNT]
         ,[PDH].[SERIAL_NUMBER]
         ,[PDH].[DOC_NUM_SEQUENCE]
         ,[PDH].[EXTERNAL_SOURCE_ID]
         ,[PDH].[IS_FROM_ERP]
         ,[PDH].[IS_FROM_SONDA]
         ,[PDH].[LAST_UPDATE]
         ,[PDH].[LAST_UPDATE_BY]
         ,[PDH].[IS_COMPLETED]
         ,[PDH].[WAVE_PICKING_ID]
         ,[PDH].[CODE_WAREHOUSE]
         ,[PDH].[IS_AUTHORIZED]
         ,[PDH].[ATTEMPTED_WITH_ERROR]
         ,[PDH].[IS_POSTED_ERP]
         ,[PDH].[POSTED_ERP]
         ,[PDH].[POSTED_RESPONSE]
         ,[PDH].[ERP_REFERENCE]
         ,[PDH].[CLIENT_NAME]
         ,[PDH].[CREATED_DATE]
         ,[PDH].[ERP_REFERENCE_DOC_NUM]
         ,[PDH].[DOC_ENTRY]
         ,[PDH].[IS_CONSOLIDATED]
         ,[PDH].[PRIORITY]
         ,[PDH].[HAS_MASTERPACK]
         ,[PDH].[POSTED_STATUS]
         ,[PDH].[OWNER]
         ,[PDH].[CLIENT_OWNER]
         ,[PDH].[MASTER_ID_SELLER]
         ,[PDH].[SELLER_OWNER]
         ,[PDH].[SOURCE_TYPE]
         ,[PDH].[INNER_SALE_STATUS]
         ,[PDH].[INNER_SALE_RESPONSE]
         ,[PDH].[DEMAND_TYPE]
         ,[PDH].[TRANSFER_REQUEST_ID]
         ,[PDH].[ADDRESS_CUSTOMER]
         ,[PDH].[STATE_CODE]
         ,[MD].[MANIFEST_HEADER_ID]
         ,[PDH].[DISCOUNT]
        FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] 
        INNER JOIN ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_MANIFEST_DETAIL] [MD]
          ON (
          [MD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
            AND
          [MD].[PICKING_DEMAND_HEADER_ID] > 0
          )
        WHERE [MD].[MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + '		
		    ';

  PRINT (@QUERY)
  EXEC (@QUERY);
--		
END;
