-- =============================================
-- Author:         rudi.garcia
-- Create date:    2-15-2015
-- Description:    Borra todo el detalle de un certificado
/*
Ejemplo de Ejecucion:
                    EXEC [wms].OP_WMS_SP_DELETE_CERTIFICATE_DEPOSIT_DETAIL_FOR_CERTIFICATE_DEPOSIT_HEADER
                    @ID_DEPOSIT_HEADER = 1                    
                    ------------------------------------------------------------
                    SELECT * FROM [wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL]
                
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_CERTIFICATE_DEPOSIT_DETAIL_FOR_CERTIFICATE_DEPOSIT_HEADER] (
		@ID_DEPOSIT_HEADER INT    
	)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DELETE
			[wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL]
		WHERE
			[CERTIFICATE_DEPOSIT_ID_HEADER] = @ID_DEPOSIT_HEADER;        
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@ERROR VARCHAR(1000)= ERROR_MESSAGE();
		RAISERROR (@ERROR,16,1);
	END CATCH;
END;