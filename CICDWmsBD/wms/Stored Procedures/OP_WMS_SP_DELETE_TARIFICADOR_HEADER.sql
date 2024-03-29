﻿CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_TARIFICADOR_HEADER]	
	@ACUERDO_COMERCIAL_ID INT, 	
	@pResult varchar(250) OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;	
	BEGIN TRAN
		BEGIN
			DELETE [wms].OP_WMS_TARIFICADOR_HEADER			
			WHERE ACUERDO_COMERCIAL_ID = @ACUERDO_COMERCIAL_ID
			
			DELETE [wms].OP_WMS_TARIFICADOR_DETAIL
			WHERE  ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL_ID
			
			DELETE [wms].OP_WMS_ACUERDOS_X_CLIENTE
			WHERE ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL_ID
		END	
	IF @@error = 0 BEGIN
		SELECT @pResult = 'OK'
		COMMIT TRAN
	END
	ELSE
		BEGIN
			ROLLBACK TRAN
			SELECT	@pResult	= ERROR_MESSAGE()
		END
		
END