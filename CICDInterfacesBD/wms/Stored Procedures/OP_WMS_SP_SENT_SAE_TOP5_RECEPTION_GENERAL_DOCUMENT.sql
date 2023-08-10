
-- =============================================
-- Autor:	            Gustavo Garcia
-- Fecha de Creacion: 	12/02/2021
-- Description:	        Sp que trae el top 5 de los documentos de recepcion y envia a SAE


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_SENT_SAE_TOP5_RECEPTION_TRANSFER_DOCUMENT]
				@OWNER = 'ALZA'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SENT_SAE_TOP5_RECEPTION_GENERAL_DOCUMENT]
(@OWNER VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OPERACION TABLE
    (
        [Resultado] INT,
        [Mensaje] VARCHAR(MAX),
        [Codigo] INT,
        [DbData] VARCHAR(MAX)
    );


    --
    SELECT [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] AS [DocNum],
           [RDH].[DOC_ID],
           [RDH].[TYPE],
           [RDH].[CODE_SUPPLIER],
           [RDH].[CODE_CLIENT],
           [RDH].[ERP_DATE],
           [RDH].[LAST_UPDATE],
           [RDH].[LAST_UPDATE_BY],
           [RDH].[ATTEMPTED_WITH_ERROR],
           [RDH].[IS_POSTED_ERP],
           [RDH].[POSTED_ERP],
           [RDH].[POSTED_RESPONSE],
           [RDH].[ERP_REFERENCE],
           [RDH].[IS_AUTHORIZED],
           [RDH].[IS_COMPLETE],
           [RDH].[TASK_ID],
           [RDH].[EXTERNAL_SOURCE_ID],
           0 [ENVIADA]
   INTO [#RECEPTION_DOCUMENT]
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
    WHERE [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] > 0
          AND ISNULL([RDH].[IS_POSTED_ERP], 0) = 0
          AND ISNULL([RDH].[ATTEMPTED_WITH_ERROR], 0) = 0
          AND ISNULL([RDH].[IS_AUTHORIZED], 0) = 1
		  AND ISNULL([RDH].[IS_COMPLETE],0)=1
          AND ISNULL([RDH].[SOURCE],'') <> 'INVOICE'
          AND [RDH].[OWNER] = @OWNER
          AND [RDH].[IS_VOID] = 0
          AND ISNULL([RDH].[IS_SENDING], 0) = 0
          AND ISNULL([RDH].[SOURCE],'') = 'RECEPCION_GENERAL' --AND 1 = 2
		  AND RDH.TYPE <> 'RECEPCION_TRASLADO';

    UPDATE [RDH]
    SET [RDH].[IS_SENDING] = 1,
        [RDH].[LAST_UPDATE_IS_SENDING] = GETDATE(),
		[RDH].[IS_COMPLETE] = 1
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
        INNER JOIN [#RECEPTION_DOCUMENT] [RD]
            ON ([RD].[DocNum] = [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]);

    DECLARE @RESPONSE VARCHAR(500),
            @REFERENCE VARCHAR(50),
            @SUCCESS INT;


    WHILE EXISTS (SELECT TOP 1 1 FROM [#RECEPTION_DOCUMENT] WHERE [ENVIADA] = 0)
    BEGIN
        DECLARE @HEADER_ID INT = 0;
        BEGIN TRY
            SELECT TOP 1
                   @HEADER_ID = [DocNum]
            FROM [#RECEPTION_DOCUMENT]
            WHERE [ENVIADA] = 0;

            INSERT INTO @OPERACION
            (
                [Resultado],
                [Mensaje],
                [Codigo],
                [DbData]
            )
            EXEC [ASPEL_INTERFACES].[dbo].[SAE_CREATE_INVENTORY_INCOME_GENERAL] @RECEPTION_DOCUMENT_HEADER = @HEADER_ID;

            SELECT TOP 1
                   @RESPONSE = [Mensaje],
                   @REFERENCE = [DbData],
                   @SUCCESS = [Resultado]
            FROM @OPERACION;

            IF (@SUCCESS = 1)
            BEGIN


                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_RECEPTION_AS_SEND_TO_ERP_R3] @RECEPTION_DOCUMENT_ID = @HEADER_ID, -- int
                                                                                      @POSTED_RESPONSE = @RESPONSE,        -- varchar(500)
                                                                                      @ERP_REFERENCE = @REFERENCE;         -- varchar(50)

            END;
            ELSE
            BEGIN

                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_RECEPTION_AS_FAILED_TO_ERP] @RECEPTION_DOCUMENT_ID = @HEADER_ID, -- int
                                                                                     @POSTED_RESPONSE = @RESPONSE;        -- varchar(500)

            END;

            UPDATE [#RECEPTION_DOCUMENT]
            SET [ENVIADA] = 1
            WHERE [DocNum] = @HEADER_ID;
            DELETE @OPERACION;


        END TRY
        BEGIN CATCH


            DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE();
            EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_RECEPTION_AS_FAILED_TO_ERP] @RECEPTION_DOCUMENT_ID = @HEADER_ID, -- int
                                                                                 @POSTED_RESPONSE = @MENSAJE_ERROR;   -- varchar(500)
        END CATCH;
    END;


END;


