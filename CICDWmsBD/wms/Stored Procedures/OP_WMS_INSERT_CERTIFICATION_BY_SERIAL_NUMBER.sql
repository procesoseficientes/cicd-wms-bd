-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	06-Nov-17 @ Team Reborn - Sprint Eberhard
-- Description:	 Sp que inserta el numero de serie ingresado en la certificacion

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[[OP_WMS_INSERT_CERTIFICATION_BY_SERIAL_NUMBER]] @CERTIFICATION_HEADER_ID = 1
                                       ,@MANIFEST_HEDAER_ID = 2
                                       ,@MATERIAL_ID = 'arium/prueba'
                                       ,@SERIAL_NUMBER = '485366'                                       
			SELECT * FROM [wms].[OP_WMS_TASK] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_CERTIFICATION_BY_SERIAL_NUMBER]
    @CERTIFICATION_HEADER_ID INT
   ,@MANIFEST_HEDAER_ID INT
   ,@MATERIAL_ID VARCHAR(50)
   ,@SERIAL_NUMBER VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @COUNT INT = 0;
    -- ------------------------------------------------------------
    -- Validamos el numero de serie si pertenece al manifiesto.
    -- ------------------------------------------------------------
        IF NOT EXISTS ( SELECT TOP 1
                            1
                        FROM
                            [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
                        INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID])
                        INNER JOIN [wms].[OP_WMS_PICKING_LABELS_BY_SERIAL_NUMBER] [PLSN] ON ([PLSN].[LABEL_ID] = [PLM].[LABEL_ID])
                        WHERE
                            [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEDAER_ID
                            AND [PLM].[MATERIAL_ID] = @MATERIAL_ID
                            AND [PLSN].[SERIAL_NUMBER] = @SERIAL_NUMBER )
        BEGIN

      -- ------------------------------------------------------------
      -- Retornamos el mensaje de que el numero de serie no pertenece al manifiesto.
      -- ------------------------------------------------------------
            SELECT
                -1 AS [Resultado]
               ,'El numero de serie ingresado no pertenece al manifiesto.' [Mensaje]
               ,1001 [Codigo]
               ,CAST(@SERIAL_NUMBER AS VARCHAR) [DbData];

            RETURN;
        END;

    -- ------------------------------------------------------------
    -- Validamos que la serie no haya sido utilizada
    -- ------------------------------------------------------------
        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
                    INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID])
                    INNER JOIN [wms].[OP_WMS_PICKING_LABELS_BY_SERIAL_NUMBER] [PLSN] ON ([PLM].[LABEL_ID] = [PLM].[LABEL_ID])
                    INNER JOIN [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN] ON ([CSN].[SERIAL_NUMBER] = [PLSN].[SERIAL_NUMBER])
                    WHERE
                        [CSN].[CERTIFICATION_HEADER_ID] <> @CERTIFICATION_HEADER_ID
                        AND [CSN].[SERIAL_NUMBER] = @SERIAL_NUMBER
                        AND [CSN].[MATERIAL_ID] = @MATERIAL_ID )
        BEGIN
      -- ------------------------------------------------------------
      -- Retornamos el mensaje de que el numero de serie ya fue utilizado.
      -- ------------------------------------------------------------
            SELECT
                -1 AS [Resultado]
               ,'El numero de serie ya fue utilizado en otro manifiesto.' [Mensaje]
               ,1704 [Codigo]
               ,CAST(@SERIAL_NUMBER AS VARCHAR) [DbData];

            RETURN;
        END;
    -- ------------------------------------------------------------
    -- Validamos que si ya fue ingresado la serie
    -- ------------------------------------------------------------
        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN]
                    WHERE
                        [CSN].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                        AND [CSN].[MATERIAL_ID] = @MATERIAL_ID
                        AND [CSN].[SERIAL_NUMBER] = @SERIAL_NUMBER )
        BEGIN

      -- ------------------------------------------------------------
      -- Retornamos el mensaje de que el numero de serie ya fue ingresado.
      -- ------------------------------------------------------------
            SELECT
                2 AS [Resultado]
               ,'El numero de serie ya fue escaneada, ¿Desea eliminarlar?' [Mensaje]
               ,0 [Codigo]
               ,CAST(@SERIAL_NUMBER AS VARCHAR) [DbData];

            RETURN;
        END;

        INSERT  INTO [OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER]
                (
                 [CERTIFICATION_HEADER_ID]
                ,[MATERIAL_ID]
                ,[SERIAL_NUMBER]
                )
        VALUES
                (
                 @CERTIFICATION_HEADER_ID
                ,@MATERIAL_ID
                ,@SERIAL_NUMBER
                );

        SELECT
            @COUNT = COUNT([CSN].[SERIAL_NUMBER])
        FROM
            [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN]
        WHERE
            [CSN].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [CSN].[MATERIAL_ID] = @MATERIAL_ID;

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