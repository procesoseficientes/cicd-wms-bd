-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/14/2018 @ NEXUS-Team Sprint  
-- Description:			Valida la compatibilidad de clases y si el material pertenece a una devolucion

-- Modificacion 5/30/2018 @ GFORCE-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Se agrega unidad de medida

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_BARCODE_FOR_LICENSE]
					@BARCODE_ID = 'autovanguard/VAA1001'
                    ,@CLIENT_OWNER = 'wms_ALMACENADORA'
                    ,@LICENSE_ID = 367930
                    ,@TASK_ID = 476464
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_BARCODE_FOR_LICENSE]
    (
     @BARCODE_ID VARCHAR(25)
    ,@CLIENT_OWNER VARCHAR(25)
    ,@LICENSE_ID NUMERIC
    ,@TASK_ID NUMERIC
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    DECLARE
        @RECEPTION_HEADER_ID INT = 0
       ,@MATERIAL_CLASS INT = 0
       ,@CURRENT_CLASS INT = 0
       ,@ERROR_CODE INT = 0
       ,@COMPANY_CODE VARCHAR(25) = NULL;
  --
    DECLARE @LICENSE_CLASSES TABLE
        (
         [CLASS_ID] INT
        ,[CLASS_NAME] VARCHAR(50)
        ,[CLASS_DESCRIPTION] VARCHAR(250)
        ,[CLASS_TYPE] VARCHAR(50)
        ,[CREATED_BY] VARCHAR(50)
        ,[CREATED_DATETIME] DATETIME
        ,[LAST_UPDATED_BY] VARCHAR(50)
        ,[LAST_UPDATED] DATETIME
        ,[PRIORITY] INT
        );
  --
    DECLARE @COMPATIBLE_CLASSES TABLE ([CLASS_ID] INT);
    BEGIN TRY
        SELECT TOP 1
            @COMPANY_CODE = [COMPANY_CODE]
        FROM
            [wms].[OP_SETUP_COMPANY];
	
        IF (@CLIENT_OWNER = @COMPANY_CODE)
        BEGIN
            SELECT TOP 1
                @CLIENT_OWNER = [M].[CLIENT_OWNER]
            FROM
                [wms].[OP_WMS_MATERIALS] [M]
            LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
            WHERE
                (
                 [M].[BARCODE_ID] = @BARCODE_ID
                 OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
                 OR [UMM].[BARCODE] = @BARCODE_ID
                 OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
                );
        END;
    -- ------------------------------------------------------------------------------------
    -- Valida que exista el codigo de barras para el owner enviado
    -- ------------------------------------------------------------------------------------
        IF NOT EXISTS ( SELECT TOP 1
                            1
                        FROM
                            [wms].[OP_WMS_MATERIALS] [M]
                        LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
                        WHERE
                            (
                             [M].[BARCODE_ID] = @BARCODE_ID
                             OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
                             OR [UMM].[BARCODE] = @BARCODE_ID
                             OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
                            )
                            AND (
                                 @CLIENT_OWNER IS NULL
                                 OR [M].[CLIENT_OWNER] = @CLIENT_OWNER
                                ) )
        BEGIN
            SELECT
                @ERROR_CODE = 1109;
            RAISERROR (N'El material escaneado no existe.', 16, 1);
        END;
    -- ------------------------------------------------------------------------------------
    -- Valida, si es una devolución, que el material pertenezca a la devolución.
    -- ------------------------------------------------------------------------------------
        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
                    WHERE
                        [RH].[TASK_ID] = @TASK_ID
                        AND [RH].[SOURCE] = 'INVOICE' )
        BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene el reception headerid
      -- ------------------------------------------------------------------------------------
            SELECT TOP 1
                @RECEPTION_HEADER_ID = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
            FROM
                [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
            WHERE
                [RH].[TASK_ID] = @TASK_ID;

            IF NOT EXISTS ( SELECT TOP 1
                                1
                            FROM
                                [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD]
                            INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RD].[MATERIAL_ID]
                            LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
                            WHERE
                                (
                                 [M].[BARCODE_ID] = @BARCODE_ID
                                 OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
                                 OR [UMM].[BARCODE] = @BARCODE_ID
                                 OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
                                )
                                AND [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID )
            BEGIN
                SELECT
                    @ERROR_CODE = 1110;
                RAISERROR (N'El material escaneado no pertenece a la devolucion.', 16, 1);
            END;
        END;

    -- ------------------------------------------------------------------------------------
    -- Valida las clases
    -- ------------------------------------------------------------------------------------

        SELECT TOP 1
            @MATERIAL_CLASS = [M].[MATERIAL_CLASS]
        FROM
            [wms].[OP_WMS_MATERIALS] [M]
        LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
        WHERE
            (
             [M].[BARCODE_ID] = @BARCODE_ID
             OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
             OR [UMM].[BARCODE] = @BARCODE_ID
             OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
            )
            AND [M].[CLIENT_OWNER] = @CLIENT_OWNER;

    -- ------------------------------------------------------------------------------------
    -- Valida la compatibilidad de clases
    -- ------------------------------------------------------------------------------------
        INSERT  INTO @LICENSE_CLASSES
        SELECT
            [CLASS_ID]
           ,[CLASS_NAME]
           ,[CLASS_DESCRIPTION]
           ,[CLASS_TYPE]
           ,[CREATED_BY]
           ,[CREATED_DATETIME]
           ,[LAST_UPDATED_BY]
           ,[LAST_UPDATED]
           ,[PRIORITY]
        FROM
            [wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@LICENSE_ID);
    --
        INSERT  INTO @COMPATIBLE_CLASSES
        SELECT
            [CLASS_ID]
        FROM
            [wms].[OP_WMS_CLASS];
    --
        WHILE EXISTS ( SELECT TOP 1
                        1
                       FROM
                        @LICENSE_CLASSES )
        BEGIN
            SELECT TOP 1
                @CURRENT_CLASS = [CLASS_ID]
            FROM
                @LICENSE_CLASSES;
      --
            DELETE
                [CC]
            FROM
                @COMPATIBLE_CLASSES [CC]
            LEFT JOIN [wms].[OP_WMS_CLASS_ASSOCIATION] [CA] ON [CC].[CLASS_ID] = [CA].[CLASS_ASSOCIATED_ID]
                                                              AND [CA].[CLASS_ID] = @CURRENT_CLASS
            WHERE
                [CA].[CLASS_ID] IS NULL;
      --
            DELETE FROM
                @LICENSE_CLASSES
            WHERE
                [CLASS_ID] = @CURRENT_CLASS;
        END;
    --
        INSERT  INTO @COMPATIBLE_CLASSES
        SELECT
            [CLASS_ID]
        FROM
            [wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@LICENSE_ID);
    --
        IF NOT EXISTS ( SELECT TOP 1
                            1
                        FROM
                            @COMPATIBLE_CLASSES
                        WHERE
                            [CLASS_ID] = @MATERIAL_CLASS )
        BEGIN
            SELECT
                @ERROR_CODE = 1105;
            RAISERROR (N'La clase del material no es compatible con las clases actualmente en la licencia.', 16, 1);
            RETURN;
        END;


        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,1 [Codigo]
           ,'' [DbData];
    END TRY
    BEGIN CATCH
        PRINT CAST(@@ERROR AS VARCHAR);
        SELECT
            @ERROR_CODE = IIF(@@error <> 0
            AND @@ERROR <> 50000, @@error, @ERROR_CODE);
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() AS [Mensaje]
           ,@ERROR_CODE AS [Codigo]
           ,'' AS [DbData];
    END CATCH;
END;