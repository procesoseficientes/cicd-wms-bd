CREATE PROCEDURE [wms].[OP_WMS_WP_SP_RESET_PWD]
	-- Add the parameters for the stored procedure here
    @pAccountID varchar(140),
    @pPWD1 varchar(70),
    @pPWD2 varchar(70)
	
AS
BEGIN
	SET NOCOUNT ON;
			
	--INSERT OR UPDATE SERVICE?
	BEGIN TRAN
		BEGIN
			UPDATE [wms].[OP_WMS_WP_SYS_ACCOUNTS]
				  SET [PWD1] = @pPWD1,
				  [PWD2] = @pPWD2
			WHERE ACCOUNT_ID = @pAccountID
		END
	
	IF @@error = 0 
		COMMIT TRAN
	ELSE
		BEGIN
			ROLLBACK TRAN
			RETURN ERROR_MESSAGE()
		END
		
END