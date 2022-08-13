-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-09 @ Team REBORN - Sprint Ramsey
-- Description:	        Sp para actualizar el estado 

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_CHANGE_STATUS_DELIVERED_DISPATCH_HEADER] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CHANGE_STATUS_DELIVERED_DISPATCH_HEADER]
    (
     @DELIVERED_DISPATCH_HEADER_ID INT
    ,@STATUS VARCHAR(50)
    ,@LAST_UPDATE_BY VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;

		DECLARE @WAVE_PICKING_ID INT

		SELECT TOP 1
			@WAVE_PICKING_ID = [DDH].[WAVE_PICKING_ID]
		FROM [wms].[OP_WMS_DELIVERED_DISPATCH_HEADER] [DDH]
		WHERE [DDH].[DELIVERED_DISPATCH_HEADER_ID] = @DELIVERED_DISPATCH_HEADER_ID;
  --

        BEGIN TRY
  	
            UPDATE  [wms].[OP_WMS_DELIVERED_DISPATCH_HEADER]
            SET     [STATUS] = @STATUS
                   ,[LAST_UPDATE] = GETDATE()
                   ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
            WHERE   [DELIVERED_DISPATCH_HEADER_ID] = @DELIVERED_DISPATCH_HEADER_ID;		
  			
			IF @STATUS = 'PARTIAL'
			BEGIN
				UPDATE [wms].[OP_WMS_PICKING_LABELS]
				SET [LABEL_STATUS] = 'DELIVERED'
				WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
			END
  	
            SELECT  1 AS [Resultado]
                   ,'Proceso Exitoso' [Mensaje]
                   ,0 [Codigo]
                   ,CAST(@DELIVERED_DISPATCH_HEADER_ID AS VARCHAR) [DbData];
        END TRY
        BEGIN CATCH
            SELECT  -1 AS [Resultado]
                   ,ERROR_MESSAGE() [Mensaje]
                   ,@@error [Codigo];
        END CATCH;

    END;