-- =============================================
-- Autor:                pablo.aguilar
-- Fecha de Creacion:     2017-09-19 @ NEXUS-Team Sprint@DuckHunt
-- Description:           Realiza un rollback de todas las operaciones que estaba realizando el operador. 
/*
-- Ejemplo de Ejecucion:
                EXEC [wms].[OP_WMS_SP_ROLLBACK_IMPLOSION_IN_PROGRESS]  @LICENSE_ID = 378262 , @MASTER_PACK_CODE = 'autovanguard/VAD1001', @LOGIN = 'ADMIN'
                SELECT * FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H] WHERE     [H].[IS_IMPLOSION] = 1
                SELECT * FROM [wms].[OP_WMS_TASK_LIST]
                    WHERE [LICENSE_ID_TARGET] IS NOT NULL
                SELECT * FROM [wms].OP_WMS_LICENSES WHERE LICENSE_ID = 378262
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ROLLBACK_IMPLOSION_IN_PROGRESS] (@LICENSE_ID NUMERIC
, @MASTER_PACK_CODE VARCHAR(50)
, @LOGIN VARCHAR(50))
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION


    DECLARE @MASTER_PACK_HEADER_ID INT
           ,@TASK_TYPE VARCHAR(25) = 'IMPLOSION_INVENTARIO'
           ,@TASK_SUBTYPE VARCHAR(25) = 'IMPLOSION_MANUAL';

    SELECT TOP 1
      @MASTER_PACK_HEADER_ID = [H].[MASTER_PACK_HEADER_ID]
    FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
    WHERE [H].[LICENSE_ID] = @LICENSE_ID
    AND [H].[MATERIAL_ID] = @MASTER_PACK_CODE
    AND [H].[IS_IMPLOSION] = 1
    AND [H].[IS_AUTHORIZED] = 0



    DELETE [wms].[OP_WMS_MASTER_PACK_DETAIL]
    WHERE [MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID

    DELETE [wms].[OP_WMS_MASTER_PACK_HEADER]
    WHERE [MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID

    DELETE [wms].[OP_WMS_TASK_LIST]
    WHERE [LICENSE_ID_TARGET] = @LICENSE_ID
      AND [IS_COMPLETED] = 0
      AND [TASK_TYPE] = @TASK_TYPE
      AND [TASK_SUBTYPE] = @TASK_SUBTYPE

    DELETE [wms].[OP_WMS_LICENSES]
    WHERE [LICENSE_ID] = @LICENSE_ID
      AND [CURRENT_LOCATION] IS NULL
    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,'0' [DbData];
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];

  END CATCH;






END