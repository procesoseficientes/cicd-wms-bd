-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-08 @ Team REBORN - Sprint Ramsey
-- Description:	        borra un registro de etiquetas entregadas

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_DELETE_DELIVERED_DISPATCH_DETAIL] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_DELIVERED_DISPATCH_DETAIL]
    (
     @LABEL_ID INT
    ,@STATUS VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;
  --
        BEGIN TRY
            DELETE  FROM [wms].[OP_WMS_DELIVERED_DISPATCH_DETAIL]
            WHERE   [LABEL_ID] = @LABEL_ID;
  	
            UPDATE  [wms].[OP_WMS_PICKING_LABELS]
            SET     [LABEL_STATUS] = @STATUS
            WHERE   [LABEL_ID] = @LABEL_ID;

            SELECT  1 AS [Resultado]
                   ,'Proceso Exitoso' [Mensaje]
                   ,0 [Codigo]
                   ,CAST(@LABEL_ID AS VARCHAR) [DbData];
        END TRY
        BEGIN CATCH
            SELECT  -1 AS [Resultado]
                   ,ERROR_MESSAGE() [Mensaje]
                   ,@@error [Codigo];
        END CATCH;

    END;