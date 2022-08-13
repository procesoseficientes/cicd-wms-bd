-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-22 @ Team ERGON - Sprint ERGON 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_UPDATE_ASSIGNED_OPERATOR_TO_COUNT_DETAIL]  @PHYSICAL_COUNT_DETAIL_ID = 8, 
                                                                            @ASSIGNED_TO ='BCORADO'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_UPDATE_ASSIGNED_OPERATOR_TO_COUNT_DETAIL (@PHYSICAL_COUNT_DETAIL_ID INT
, @ASSIGNED_TO VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @RESULT VARCHAR(125) = ''

  BEGIN TRY
    BEGIN TRANSACTION

    DECLARE @OLD_WAREHOUSE VARCHAR(25)
           ,@MISMA_BODEGA VARCHAR(25) = 'NO'

    SELECT
      @OLD_WAREHOUSE = [CD].[WAREHOUSE_ID]
    FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [CD]
    WHERE [CD].[PHYSICAL_COUNT_DETAIL_ID] = @PHYSICAL_COUNT_DETAIL_ID

    SELECT
      @MISMA_BODEGA = [WU].[WAREHOUSE_ID]
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
    WHERE [WU].[LOGIN_ID] = @ASSIGNED_TO
    AND [WU].[WAREHOUSE_ID] = @OLD_WAREHOUSE

    IF @MISMA_BODEGA <> 'NO'
    BEGIN
      UPDATE [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL]
      SET [ASSIGNED_TO] = @ASSIGNED_TO
      WHERE PHYSICAL_COUNT_DETAIL_ID = @PHYSICAL_COUNT_DETAIL_ID
      AND [STATUS] = 'CREATED';
    END
    ELSE
    BEGIN
      SET @RESULT = 'EL OPERADOR DEBE TENER ASIGNADA LA BODEGA DE LA TAREA DE CONTEO'
    END
    IF @RESULT <> '' BEGIN
      SELECT
        -1 AS Resultado
       ,@RESULT Mensaje
       ,0 Codigo
       ,'0' DbData
    END
    ELSE BEGIN
      SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
    END    
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION    
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH;
END