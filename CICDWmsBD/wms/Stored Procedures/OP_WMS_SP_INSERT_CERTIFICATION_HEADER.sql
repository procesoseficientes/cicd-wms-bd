-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        Sp que crea la certificacion.

-- Modificacion 11/10/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Actualiza el estado del manifiesto de carga a "CERTIFYING"

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_CERTIFICATION_HEADER] @CERTIFICATION_HEADER_ID = 1                                                
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_CERTIFICATION_HEADER]
    (
     @MANIFEST_HEADER_ID INT
    ,@CREATE_BY VARCHAR(25)
    )
AS
BEGIN
    SET NOCOUNT ON;
  --

    BEGIN TRY

        DECLARE
            @ID INT
           ,@CODE INT = 0;

        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [wms].[OP_WMS_MANIFEST_HEADER]
                    WHERE
                        [STATUS] NOT IN ('CREATED', 'CERTIFYING')
                        AND [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID )
        BEGIN
            SET @CODE = 1702;
            RAISERROR('El manifiesto no se encuentra en un estado válido para la certificación.',16,1);
        END;

        INSERT  INTO [wms].[OP_WMS_CERTIFICATION_HEADER]
                (
                 [MANIFEST_HEADER_ID]
                ,[CREATE_DATE]
                ,[CREATE_BY]
                ,[STATUS]
                )
        VALUES
                (
                 @MANIFEST_HEADER_ID
                ,GETDATE()
                ,@CREATE_BY
                ,'CREATED'
                );

        SET @ID = SCOPE_IDENTITY();

        UPDATE
            [wms].[OP_WMS_MANIFEST_HEADER]
        SET
            [STATUS] = 'CERTIFYING'
        WHERE
            [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,CAST(@ID AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,IIF(@CODE > 0, @CODE, @@error) [Codigo];
    END CATCH;

END;