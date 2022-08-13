-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	06-Nov-17 @ Team Reborn - Sprint Eberhard
-- Description:	 Sp que elimina el numero de serie de la certificacion

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_CERTIFICATION_BY_SERIAL_NUMBER] @CERTIFICATION_HEADER_ID = 1
                                       ,@MATERIAL_ID = 'arium/prueba'
                                       ,@SERIAL_NUMBER = '258636'                                       
			SELECT * FROM [wms].[OP_WMS_TASK] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_CERTIFICATION_BY_SERIAL_NUMBER]
    (
     @CERTIFICATION_HEADER_ID INT
    ,@MATERIAL_ID VARCHAR(50)
    ,@SERIAL_NUMBER VARCHAR(50)
    )
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @COUNT INT = 0;

        DELETE
            [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER]
        WHERE
            [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [MATERIAL_ID] = @MATERIAL_ID
            AND [SERIAL_NUMBER] = @SERIAL_NUMBER;

    
        SELECT
            @COUNT = COUNT([CSN].[SERIAL_NUMBER])
        FROM
            [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN]
        WHERE
            [CSN].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [CSN].[MATERIAL_ID] = @MATERIAL_ID;


        UPDATE
            [wms].[OP_WMS_CERTIFICATION_DETAIL]
        SET
            [QTY] = @COUNT
        WHERE
            [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [MATERIAL_ID] = @MATERIAL_ID;

        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,CAST(@COUNT AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@error [Codigo];
    END CATCH;

END;