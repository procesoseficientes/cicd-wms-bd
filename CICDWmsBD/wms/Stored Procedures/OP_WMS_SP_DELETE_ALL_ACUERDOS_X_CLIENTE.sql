﻿CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_ALL_ACUERDOS_X_CLIENTE]
	@CLIENT_ID VARCHAR(50),	
	@pResult varchar(250) OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;	
	BEGIN TRAN
		BEGIN
			DELETE [wms].OP_WMS_ACUERDOS_X_CLIENTE
			WHERE CLIENT_ID = @CLIENT_ID			
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