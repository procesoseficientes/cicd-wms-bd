-- =============================================
-- Autor:	            jonatan.palacios
-- Fecha de Creacion: 	12/11/2021 SPRINT 33
-- Description:	        Sp que trae el top 5 de los documentos de recepcion y envia a SAE


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_SENT_SAE_TOP5_MASTERPACK_HEADER]
				@OWNER = 'ALZA'
				UPDATE [OP_WMS_ALZA].[wms].[OP_WMS_SP_SENT_SAE_TOP5_MASTERPACK_HEADER]  SET IS_SENDING=0 
				WHERE PICKING_DEMAND_HEADER_ID IN (63750)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SENT_SAE_TOP5_MASTERPACK_HEADER]
(@OWNER VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @HEADER_ID INT = 0;
    DECLARE @OPERACION TABLE(
        [Resultado] INT,
        [Mensaje] VARCHAR(MAX),
        [Codigo] INT,
        [DbData] VARCHAR(MAX)
    );

    -- SELECT * FROM  [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] ORDER BY 1 DESC
	--TRUNCATE TABLE [#PICKING_DOCUMENT]
    SELECT TOP 10 CAST([MPH].[MASTER_PACK_HEADER_ID] AS VARCHAR) [MASTERPACK_HEADER]
		INTO [#MASTERPACK_DOCUMENT]
			FROM [OP_WMS_ALZA].[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH] WHERE 
			ISNULL([MPH].[IS_POSTED_ERP], 0) <> 1 AND 
			ISNULL([MPH].[ATTEMPTED_WITH_ERROR], 0) < 2 AND 
			ISNULL([MPH].[IS_AUTHORIZED], 0) = 1 AND
			--[MPH].[EXPLODED] = 1 AND
			[MPH].[IS_IMPLOSION] = 0 AND
			--[MPH].[IS_FROM_ERP] = 1; AND 
			--ISNULL([MPH].[IS_SENDING], 0) = 0 AND 
			[MPH].[IS_AUTHORIZED] = 1;

PRINT 1
    UPDATE [MPH] SET 
		[MPH].[IS_SENDING] = 1,
        [MPH].[LAST_UPDATE_IS_SENDING] = GETDATE()
			FROM [OP_WMS_ALZA].[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
				INNER JOIN [#MASTERPACK_DOCUMENT] [MD] ON ([MD].[MASTERPACK_HEADER] = [MPH].[MASTER_PACK_HEADER_ID]);

    DECLARE @RESPONSE VARCHAR(500),
            @REFERENCE VARCHAR(50),
            @SUCCESS INT;

PRINT 2
    WHILE EXISTS (SELECT TOP 1 1 FROM [#MASTERPACK_DOCUMENT])
		BEGIN
			BEGIN TRY
				SELECT TOP 1 @HEADER_ID = [MASTERPACK_HEADER] FROM [#MASTERPACK_DOCUMENT] ORDER BY [MASTERPACK_HEADER];

				PRINT 3
					INSERT INTO @OPERACION(
						[Resultado],
						[Mensaje],
						[Codigo],
						[DbData]
					)

					EXEC [ASPEL_INTERFACES].[dbo].[SAE_CREATE_EXPLOSION_BY_MASTERPACK] @MATERPACK_ID = @HEADER_ID;
					
					SELECT TOP 1
					@RESPONSE = [Mensaje],
					@REFERENCE = [DbData],
					@SUCCESS = [Resultado]
					FROM @OPERACION;

					IF (@SUCCESS = 1) 
						BEGIN
							PRINT 4

							EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MASTERPACK_AS_SEND] @MASTERPACK_DEMAND_HEADER_ID = @HEADER_ID, -- int
																							@POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
																							@ERP_REFERENCE = @REFERENCE,            -- varchar(50)
																							@POSTED_STATUS = @SUCCESS,              -- int
																							@IS_INVOICE = 0;                        -- int
						END;
					ELSE
						BEGIN
							PRINT 5
							
							EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MASTERPACK_AS_FAILED] @MASTERPACK_DEMAND_HEADER_ID = @HEADER_ID, -- int
																							  @POSTED_RESPONSE = @RESPONSE,           -- varchar(500)
																							  @POSTED_STATUS = @SUCCESS;              -- int
																							  
						END;

						DELETE [#MASTERPACK_DOCUMENT] WHERE [MASTERPACK_HEADER] = @HEADER_ID;
						DELETE @OPERACION;
			END TRY
			BEGIN CATCH
				PRINT 3.1
				--rollback;
				DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE();
				PRINT @MENSAJE_ERROR 
				--EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MASTERPACK_AS_FAILED_TO_R3]
				EXEC [OP_WMS_ALZA].[wms].[OP_WMS_SP_MASTERPACK_AS_FAILED] @MASTERPACK_DEMAND_HEADER_ID = @HEADER_ID, -- int
                                                                                  @POSTED_RESPONSE = @MENSAJE_ERROR,           -- varchar(500)
                                                                                  @POSTED_STATUS = @SUCCESS
			END CATCH;
		END;
END;




