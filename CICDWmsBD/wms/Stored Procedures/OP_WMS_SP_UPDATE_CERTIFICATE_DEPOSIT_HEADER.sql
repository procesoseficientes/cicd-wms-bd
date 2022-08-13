-- =============================================
-- Author:         rudi.garcia
-- Create date:    15-02-2016
-- Description:    Actualiza registros del certificado de deposito encabezado 
/*
Ejemplo de Ejecucion:
                --
                EXEC [wms].OP_WMS_SP_UPDATE_CERTIFICATE_DEPOSIT_HEADER 
                    @ID_DEPOSIT_HEADER = 0
                    ,@VALID_FROM = ""
                    ,@VALID_TO = ""
                    ,@LAST_UPDATED_BY = ""
                    ,@STATUS = ""
                SELECT * FROM [[wms]].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER]
                --    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_CERTIFICATE_DEPOSIT_HEADER] (
		@ID_DEPOSIT_HEADER INT
		,@VALID_FROM DATE
		,@VALID_TO DATE
		,@LAST_UPDATED_BY VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
    
	BEGIN TRAN [TransUpdate];
	BEGIN TRY
    -----------------------------------------
		UPDATE
			[wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER]
		SET	
			[VALID_FROM] = @VALID_FROM
			,[VALID_TO] = @VALID_TO
			,[LAST_UPDATED_BY] = @LAST_UPDATED_BY
			,[LAST_UPDATED] = GETDATE()
		WHERE
			[CERTIFICATE_DEPOSIT_ID_HEADER] = @ID_DEPOSIT_HEADER;    
		COMMIT TRAN [TransUpdate];    
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@ERROR VARCHAR(1000)= ERROR_MESSAGE();
		RAISERROR (@ERROR,16,1);
	END CATCH;
END;