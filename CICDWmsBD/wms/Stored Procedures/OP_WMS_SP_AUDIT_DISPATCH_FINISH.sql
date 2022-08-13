

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AUDIT_DISPATCH_FINISH] 
	@pAUDIT_ID			numeric(18,0),
	@pSTATUS			VARCHAR(15),
	@pLOGIN_ID			VARCHAR(25),
	@pResult			varchar(250) OUTPUT
AS
BEGIN
	BEGIN TRY
	BEGIN
		UPDATE [wms].[OP_WMS_AUDIT_DISPATCH_CONTROL]
				   SET [STATUS] = @pSTATUS,
				   [LAST_UPDATED] = CURRENT_TIMESTAMP
				   ,[LAST_UPDATED_BY] = @pLOGIN_ID
		WHERE AUDIT_ID = @pAUDIT_ID
				   
		IF @@ERROR = 0 BEGIN
			SELECT	@pResult	= 'OK'
		END
		ELSE
			SELECT	@pResult	= ERROR_MESSAGE()
		END
		
	END TRY
	BEGIN CATCH
		SELECT	@pResult	= ERROR_MESSAGE()
	END CATCH

END