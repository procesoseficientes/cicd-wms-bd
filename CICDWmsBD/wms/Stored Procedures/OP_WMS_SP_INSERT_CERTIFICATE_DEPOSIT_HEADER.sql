-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Inserta registros en la Tabla 
--                   [[wms]].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER]
--                   con transacción y control de errores.
/*
Ejemplo de Ejecucion:
                    EXEC [[wms]].[OP_WMS_SP_INSERT_CERTIFICATE_DEPOSIT_HEADER] 
                    @VALID_FROM = '2016-02-10 12:19:04.323'
                    ,@VALID_TO = '2016-02-15 12:19:04.323'
                    ,@NAME_USER = 'ADMIN'
                    ,@STATUS = 'ACTIVO'
                    ,@CLIENT_NODE = NULL 
                    SELECT * FROM [[wms]].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER]
        
                
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_CERTIFICATE_DEPOSIT_HEADER] (
		@VALID_FROM DATE
		,@VALID_TO DATE
		,@NAME_USER VARCHAR(50)
		,@STATUS VARCHAR(25)
		,@CLIENT_NODE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
    --
	DECLARE	@ID INT;
	BEGIN TRAN [TransAdd];
	BEGIN TRY
        
		INSERT	INTO [wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER]
				(
					[VALID_FROM]
					,[VALID_TO]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
					,[STATUS]
					,[CLIENT_CODE]
				)
		VALUES
				(
					@VALID_FROM
					,@VALID_TO
					,GETDATE()
					,@NAME_USER
					,@STATUS
					,@CLIENT_NODE
				);
        --
		SET @ID = SCOPE_IDENTITY();
        --
		COMMIT TRAN [TransAdd];
        --
		SELECT
			@ID AS [ID];
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@ERROR VARCHAR(1000)= ERROR_MESSAGE();
		RAISERROR (@ERROR,16,1);
	END CATCH;
END;