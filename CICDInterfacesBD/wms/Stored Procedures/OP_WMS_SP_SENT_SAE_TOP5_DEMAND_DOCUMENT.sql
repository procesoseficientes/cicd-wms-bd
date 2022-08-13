-- =============================================
-- Autor:	            Pablo.aguilar
-- Fecha de Creacion: 	17/07/2019
-- Description:	        Sp que trae el top 5 de los documentos de recepcion y envia a SAE


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_SENT_SAE_TOP5_DEMAND_DOCUMENT]
				@OWNER = 'ALZA'
				UPDATE [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]  SET IS_SENDING=0 
				WHERE PICKING_DEMAND_HEADER_ID IN (63750)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SENT_SAE_TOP5_DEMAND_DOCUMENT]
(@OWNER VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;
	 DECLARE @HEADER_ID INT = 0;
    DECLARE @OPERACION TABLE
    (
        [Resultado] INT,
        [Mensaje] VARCHAR(MAX),
        [Codigo] INT,
        [DbData] VARCHAR(MAX)
    );


    -- SELECT * FROM  [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] ORDER BY 1 DESC
	--TRUNCATE TABLE [#PICKING_DOCUMENT]
    SELECT TOP 1
           CAST([PDH].[PICKING_DEMAND_HEADER_ID] AS VARCHAR) [PICKING_HEADER]
    INTO [#PICKING_DOCUMENT]
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    WHERE ISNULL([PDH].[IS_POSTED_ERP], 0) <> 1
          AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) < 2
          AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1
          AND [PDH].[IS_FROM_ERP] = 1
          AND [PDH].[IS_SENDING] = 0
		  AND [PDH].[DEMAND_TYPE] <> 'TRANSFER_REQUEST';

PRINT 1
    UPDATE [PDH]
    SET [PDH].[IS_SENDING] = 1,
        [PDH].[LAST_UPDATE_IS_SENDING] = GETDATE()
    FROM [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
        INNER JOIN [#PICKING_DOCUMENT] [PD]
            ON ([PD].[PICKING_HEADER] = [PDH].[PICKING_DEMAND_HEADER_ID]);



    DECLARE @RESPONSE VARCHAR(500),
            @REFERENCE VARCHAR(150),
            @SUCCESS INT;

PRINT 2
    WHILE EXISTS (SELECT TOP 1 1 FROM [#PICKING_DOCUMENT])
    BEGIN
       
        BEGIN TRY
            SELECT TOP 1
                   @HEADER_ID = [PICKING_HEADER]
            FROM [#PICKING_DOCUMENT]
            ORDER BY [PICKING_HEADER];
			DECLARE @HAS_MASTERPACK_IMPLODED INT=0
			SELECT TOP 1
				@HAS_MASTERPACK_IMPLODED = 1
			FROM
				[OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
			WHERE
				[D].[PICKING_DEMAND_HEADER_ID] = @HEADER_ID
				AND [D].[WAS_IMPLODED] = 1
				AND [D].[QTY_IMPLODED] > 0;
			IF(@HAS_MASTERPACK_IMPLODED=1)
			BEGIN
				INSERT INTO @OPERACION
				(
					[Resultado],
					[Mensaje],
					[Codigo],
					[DbData]
				)
				EXEC [ASPEL_INTERFACES].[dbo].[SAE_CREATE_IMPLOSION_BY_PICKING] @NEXT_PICKING_DEMAND_HEADER = @HEADER_ID;

				SELECT TOP 1
					   @RESPONSE = [Mensaje],
					   @REFERENCE = [DbData],
					   @SUCCESS = [Resultado]
				FROM @OPERACION;
				IF (@SUCCESS = 0)
				BEGIN
					EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
																					@POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
                                                                                  @POSTED_STATUS = @SUCCESS,              -- int
                                                                                  @OWNER = @OWNER;                        -- varchar(50)

					continue;
				end;
			END;

			PRINT 3
            INSERT INTO @OPERACION
            (
                [Resultado],
                [Mensaje],
                [Codigo],
                [DbData]
            )
            EXEC [ASPEL_INTERFACES].[dbo].[SAE_CREATE_REMISION_BY_SALE_ORDER] @NEXT_PICKING_DEMAND_HEADER = @HEADER_ID;

            SELECT TOP 1
                   @RESPONSE =@RESPONSE+' - '+ [Mensaje],
                   @REFERENCE = @REFERENCE+' - '+ [DbData],
                   @SUCCESS = [Resultado]
            FROM @OPERACION;

            IF (@SUCCESS = 1)
            BEGIN

			PRINT 4
                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_SEND_TO_R3] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                @POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
                                                                                @ERP_REFERENCE = @REFERENCE,            -- varchar(50)
                                                                                @POSTED_STATUS = @SUCCESS,              -- int
                                                                                @OWNER = @OWNER,                        -- varchar(50)
                                                                                @IS_INVOICE = 0;                        -- int

			PRINT 4.1
            END;
            ELSE
            BEGIN
			PRINT 5
                EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                  @POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
                                                                                  @POSTED_STATUS = @SUCCESS,              -- int
                                                                                  @OWNER = @OWNER;                        -- varchar(50)


            END;
			print 6
            DELETE [#PICKING_DOCUMENT]
            WHERE [PICKING_HEADER] = @HEADER_ID;
            DELETE @OPERACION;


        END TRY
        BEGIN CATCH
			PRINT 3.1
			--rollback;
            DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE();
			PRINT @MENSAJE_ERROR 
            EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3] @PICKING_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                  @POSTED_RESPONSE = @MENSAJE_ERROR,           -- varchar(500)
                                                                                  @POSTED_STATUS = @SUCCESS,              -- int
                                                                                  @OWNER = @OWNER;  
        END CATCH;
    END;

END;




