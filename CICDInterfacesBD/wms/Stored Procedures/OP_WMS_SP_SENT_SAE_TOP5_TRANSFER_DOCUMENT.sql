-- =============================================
-- Autor:	            gustavo.garcia
-- Fecha de Creacion: 	11-Feb-2021
-- Description:	        Sp que trae el top 5 de los documentos de transferencia (salida) de WMS


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_SENT_SAE_TOP5_TRANSFER_DOCUMENT]
				@OWNER = 'ALZA'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SENT_SAE_TOP5_TRANSFER_DOCUMENT]
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
	--TRUNCATE TABLE [#PICKING_DOCUMENT]
    SELECT TOP 5
           CAST([PDH].[PICKING_DEMAND_HEADER_ID] AS VARCHAR) [PICKING_HEADER]
    INTO [#PICKING_DOCUMENT]
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    WHERE ISNULL([PDH].[IS_POSTED_ERP], 0) <> 1
          AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) < 2
          AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1
          AND [PDH].[IS_FROM_ERP] = 1
          AND [PDH].[IS_SENDING] = 0
		  AND [PDH].[DEMAND_TYPE] = 'TRANSFER_REQUEST';


    UPDATE [PDH]
    SET [PDH].[IS_SENDING] = 1,
        [PDH].[LAST_UPDATE_IS_SENDING] = GETDATE()
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
        INNER JOIN [#PICKING_DOCUMENT] [PD]
            ON ([PD].[PICKING_HEADER] = [PDH].[PICKING_DEMAND_HEADER_ID]);



    DECLARE @RESPONSE VARCHAR(500),
            @REFERENCE VARCHAR(50),
            @SUCCESS INT;


    WHILE EXISTS (SELECT TOP 1 1 FROM [#PICKING_DOCUMENT])
    BEGIN
        DECLARE @HEADER_ID INT = 0;
        BEGIN TRY
            SELECT TOP 1
                   @HEADER_ID = [PICKING_HEADER]
            FROM [#PICKING_DOCUMENT]
            ORDER BY [PICKING_HEADER];

            INSERT INTO @OPERACION
            (
                [Resultado],
                [Mensaje],
                [Codigo],
                [DbData]
            )
            EXEC [ASPEL_INTERFACES].[dbo].[SAE_CREATE_REMISION_BY_TRANSFER] @NEXT_PICKING_DEMAND_HEADER = @HEADER_ID;

            SELECT TOP 1
                   @RESPONSE = [Mensaje],
                   @REFERENCE = [DbData],
                   @SUCCESS = [Resultado]
            FROM @OPERACION;

            IF (@SUCCESS = 1)
            BEGIN


                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_SEND_TO_R3] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                @POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
                                                                                @ERP_REFERENCE = @REFERENCE,            -- varchar(50)
                                                                                @POSTED_STATUS = @SUCCESS,              -- int
                                                                                @OWNER = @OWNER,                        -- varchar(50)
                                                                                @IS_INVOICE = 0;                        -- int


            END;
            ELSE
            BEGIN

                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                  @POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
                                                                                  @POSTED_STATUS = @SUCCESS,              -- int
                                                                                  @OWNER = @OWNER;                        -- varchar(50)


            END;

            DELETE [#PICKING_DOCUMENT]
            WHERE [PICKING_HEADER] = @HEADER_ID;
            DELETE @OPERACION;


        END TRY
        BEGIN CATCH


            DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE();
            EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_RECEPTION_AS_FAILED_TO_ERP] @RECEPTION_DOCUMENT_ID = @HEADER_ID, -- int
                                                                                 @POSTED_RESPONSE = @MENSAJE_ERROR;   -- varchar(500)
        END CATCH;
    END;

END;




