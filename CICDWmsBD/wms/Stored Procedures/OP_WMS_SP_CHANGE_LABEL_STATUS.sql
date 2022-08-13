-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-05 @ Team REBORN - Sprint Ramsey
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_CHANGE_LABEL_STATUS 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CHANGE_LABEL_STATUS]
    (
     @LABEL_ID INT
    ,@STATUS VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;
  --
        BEGIN TRY

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