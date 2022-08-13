-- ==============================================================================================================================

-- Modificacion 		3/01/2020 @ G-Force Team Sprint Oklahoma@Swift
-- Autor: 				michael.mazariegos
-- Historia/Bug:		34681 - Auditoria de Apertura contenedor Fiscal
-- Descripcion: 		Se agregan parámetros para recibir un base64 y agregarla a campo IMAGEN

-- ==============================================================================================================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AGREGA_IMAGEN_POLIZA]
    -- Add the parameters for the stored procedure here
    @pCODIGO_BARRAS_ID VARCHAR(50),
    @pIMAGE IMAGE = NULL,
    @B64IMAGE VARCHAR(MAX),
    @USEBASE64 INT = 0,
    @pUPLOADED_BY VARCHAR(25) = NULL,
    @AUDIT_ID NUMERIC(18, 0) = NULL,
    @AUDIT_TYPE VARCHAR(20) = NULL,
    @pResult VARCHAR(250) = NULL OUTPUT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @IMAGE_TO_PROCESS VARBINARY(MAX);

    BEGIN TRY

        IF (@pIMAGE IS NOT NULL)
        BEGIN
            INSERT INTO [wms].[OP_WMS_IMAGENES_POLIZA]
            (
                CODIGO_POLIZA,
                [IMAGEN],
                [UPLOADED_BY],
                [UPLOADED_DATE],
                [AUDIT_ID],
                [AUDIT_TYPE]
            )
            VALUES
            (@pCODIGO_BARRAS_ID, @pIMAGE, @pUPLOADED_BY, CURRENT_TIMESTAMP, @AUDIT_ID, @AUDIT_TYPE);
        END;
        ELSE
        BEGIN

            INSERT INTO [wms].[OP_WMS_IMAGENES_POLIZA]
            (
                [CODIGO_POLIZA],
                [IMAGE_64],
                [UPLOADED_BY],
                [UPLOADED_DATE],
                [AUDIT_ID],
                [AUDIT_TYPE]
            )
            VALUES
            (@pCODIGO_BARRAS_ID, @B64IMAGE, @pUPLOADED_BY, CURRENT_TIMESTAMP, @AUDIT_ID, @AUDIT_TYPE);



        END;

        SELECT @pResult = 'OK';
        SELECT @pResult AS [Resultado];

    END TRY
    BEGIN CATCH
        SELECT @pResult = ERROR_MESSAGE();
    END CATCH;

END;