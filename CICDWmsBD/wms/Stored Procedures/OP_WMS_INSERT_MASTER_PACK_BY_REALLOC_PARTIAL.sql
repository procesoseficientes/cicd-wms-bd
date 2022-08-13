-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-03-13 @ Team ERGON - Sprint ERGON V
-- Description:	 Sp que insertar en master pack header y detail en caso ocurrió una reubicación parcial de este moviendo todas nuestras tablas de transacción.  

-- Modificacion 10/6/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se cambia el insert para que haga match la cantidad de parametros enviados.


/*
-- Ejemplo de Ejecucion:
		SELECT * FROM  [wms].[OP_WMS_MASTER_PACK_HEADER]
    SELECT * FROM [wms].[OP_WMS_MASTER_PACK_DETAIL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_MASTER_PACK_BY_REALLOC_PARTIAL] (@SOURCE_LICENSE INT
, @TARGET_LICENSE INT
, @MATERIAL_ID VARCHAR(50)
, @QTY_REALLOC INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @MASTER_PACK_HEADER_ID INT
  DECLARE @NEW_MASTER_PACK_HEADER_ID INT

  SELECT TOP 1
    @MASTER_PACK_HEADER_ID = [H].[MASTER_PACK_HEADER_ID]
  FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
  WHERE [H].[LICENSE_ID] = @SOURCE_LICENSE
  AND [H].[MATERIAL_ID] = @MATERIAL_ID
  PRINT 'LON 99.1'
  INSERT INTO [wms].[OP_WMS_MASTER_PACK_HEADER]
          ( [LICENSE_ID] ,
            [MATERIAL_ID] ,
            [POLICY_HEADER_ID] ,
            [LAST_UPDATED] ,
            [LAST_UPDATE_BY] ,
            [EXPLODED] ,
            [EXPLODED_DATE] ,
            [RECEPTION_DATE] ,
            [IS_AUTHORIZED] ,
            [ATTEMPTED_WITH_ERROR] ,
            [IS_POSTED_ERP] ,
            [POSTED_ERP] ,
            [POSTED_RESPONSE] ,
            [ERP_REFERENCE] ,
            [ERP_REFERENCE_DOC_NUM] ,
            [QTY] 
          )
    SELECT
      @TARGET_LICENSE [LICENSE_ID]
     ,[H].[MATERIAL_ID]
     ,[H].[POLICY_HEADER_ID]
     ,[H].[LAST_UPDATED]
     ,[H].[LAST_UPDATE_BY]
     ,0
     ,NULL [EXPLODED_DATE]
     ,[H].[RECEPTION_DATE]
     ,[H].[IS_AUTHORIZED]
     ,[H].[ATTEMPTED_WITH_ERROR]
     ,[H].[IS_POSTED_ERP]
     ,[H].[POSTED_ERP]
     ,[H].[POSTED_RESPONSE]
     ,[H].[ERP_REFERENCE]
     ,[H].[ERP_REFERENCE_DOC_NUM]
     ,@QTY_REALLOC
    FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
    WHERE @MASTER_PACK_HEADER_ID = [H].[MASTER_PACK_HEADER_ID]

  SET @NEW_MASTER_PACK_HEADER_ID = SCOPE_IDENTITY();
    PRINT 'LON 99.2'

  UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER]
  SET [QTY] = [QTY] - @QTY_REALLOC
  WHERE @MASTER_PACK_HEADER_ID = [MASTER_PACK_HEADER_ID]
    PRINT 'LON 99.3'

  INSERT INTO [wms].[OP_WMS_MASTER_PACK_DETAIL]

    SELECT
      @NEW_MASTER_PACK_HEADER_ID [MASTER_PACK_HEADER_ID]
     ,[D].[MATERIAL_ID]
     ,[D].[QTY]
     ,[D].[BATCH]
     ,[D].[DATE_EXPIRATION],null,null,null,null,null,null
    FROM [wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
    WHERE [D].[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID


END