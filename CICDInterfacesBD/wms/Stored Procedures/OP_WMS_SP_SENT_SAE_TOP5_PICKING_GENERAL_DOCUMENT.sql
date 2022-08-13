-- =============================================
-- Autor:	            Pablo.aguilar
-- Fecha de Creacion: 	17/07/2019
-- Description:	        Sp que trae el top 5 de los documentos de recepcion y envia a SAE


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_SENT_SAE_TOP5_DEMAND_DOCUMENT]
				@OWNER = 'ALZA'
				UPDATE [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]  SET IS_SENDING=0 
				WHERE PICKING_DEMAND_HEADER_ID IN (58982)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SENT_SAE_TOP5_PICKING_GENERAL_DOCUMENT]
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


    -- SELECT * FROM  [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] ORDER BY 1 DESC
	--TRUNCATE TABLE [#PICKING_DOCUMENT]
    SELECT TOP 5
           CAST([PDH].PICKING_ERP_DOCUMENT_ID AS VARCHAR) [PICKING_HEADER]
    INTO [#PICKING_DOCUMENT]
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_PICKING_ERP_DOCUMENT] [PDH]
    WHERE ISNULL([PDH].[IS_POSTED_ERP], 0) <> 1
          AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) < 2
          AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1;

    DECLARE @RESPONSE VARCHAR(500),
            @REFERENCE VARCHAR(50),
            @SUCCESS INT;

PRINT 2
    WHILE EXISTS (SELECT TOP 1 1 FROM [#PICKING_DOCUMENT])
    BEGIN
        DECLARE @HEADER_ID INT = 0;
        BEGIN TRY
            SELECT TOP 1
                   @HEADER_ID = [PICKING_HEADER]
            FROM [#PICKING_DOCUMENT]
            ORDER BY [PICKING_HEADER];

			PRINT 3
            INSERT INTO @OPERACION
            (
                [Resultado],
                [Mensaje],
                [Codigo],
                [DbData]
            )
			
            EXEC [ASPEL_INTERFACES].[dbo].[SAE_CREATE_REMISION_BY_GENERAL] @NEXT_PICKING_DEMAND_HEADER = @HEADER_ID;

            SELECT TOP 1
                   @RESPONSE = [Mensaje],
                   @REFERENCE = [DbData],
                   @SUCCESS = [Resultado]
            FROM @OPERACION;

            IF (@SUCCESS = 1)
            BEGIN

			PRINT 4
                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_SEND_GENERAL] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                @POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
                                                                                @ERP_REFERENCE = @REFERENCE,            -- varchar(50)
                                                                                @POSTED_STATUS = @SUCCESS,              -- int
                                                                                @OWNER = @OWNER,                        -- varchar(50)
                                                                                @IS_INVOICE = 0;                        -- int


            END;
            ELSE
            BEGIN
			PRINT 5
                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_GENERAL] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
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
			PRINT @MENSAJE_ERROR 
            EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_GENERAL] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                  @POSTED_RESPONSE = @MENSAJE_ERROR,           -- varchar(500)
                                                                                  @POSTED_STATUS = @SUCCESS,              -- int
                                                                                  @OWNER = @OWNER;  
        END CATCH;
    END;

END;




