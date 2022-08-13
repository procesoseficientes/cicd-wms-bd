
-- =============================================
-- Autor: pablo.aguilar
-- Fecha de Modificación: 2017-05-25 ErgonTeam@Sheik
-- Description:	 Se copia la funcionalidad del sp [wms].OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE y agrega que devuelva objeto operación por cambio de arquitectura


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE_BO @LOGIN_ID = 'ACAMACHO'
                                                        ,@WAVE_PICKING_ID = 4417
                                                        ,@MATERIAL_ID = 'wms/100003'

  
      SELECT * FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [OWNPDH]
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [L] ON [OWNPDH].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID]
        WHERE [L].[IS_COMPLETED] <> 1 AND [L].[WAVE_PICKING_ID]  = 4417
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE_BO (@LOGIN_ID VARCHAR(25)
, @WAVE_PICKING_ID INT
, @MATERIAL_ID VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN
  BEGIN TRY

    EXEC [wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE] @LOGIN_ID = @LOGIN_ID
                                                         ,@WAVE_PICKING_ID = @WAVE_PICKING_ID
                                                         ,@MATERIAL_ID = @MATERIAL_ID

    COMMIT TRANSACTION
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
    ROLLBACK TRANSACTION

  END CATCH;

END