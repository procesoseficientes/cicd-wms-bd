--USE [OP_WMS]
--GO

--/****** Object:  StoredProcedure [wms].[OP_WMS_SP_START_CAMPAIGN]    Script Date: 06/02/2011 11:02:24 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO




CREATE PROCEDURE  [wms].[OP_WMS_SP_SAVE_PROFILE] 
(
	@pProfileModuleID varchar(25),
	@pProfileName varchar(100),
	@pUser varchar(30),
	@pLayoutID varchar(max)
)
AS
Declare
@xvar varchar(5000);
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
	
	--set @xvar = @pLayoutID;
	
	
   INSERT INTO OP_WMS_MAIN_PROFILES (PROFILE_MODULE_ID, PROFILE_NAME, PROFILE_USER, PROFILE_LAYOUT_ID)
   --VALUES (@pProfileModuleID, @pProfileName, @pUser, @pLayoutID);
   --VALUES (@pProfileModuleID, @pProfileName, @pUser, convert(varbinary(max),@pLayoutID));
   --VALUES (@pProfileModuleID, @pProfileName, @pUser, ENCRYPTBYKEY(KEY_GUID('DBTestSymmKey'), @pLayoutID));
   VALUES (@pProfileModuleID, @pProfileName, @pUser, cast(@pLayoutID as varbinary(5000)));
	
	COMMIT TRANSACTION;
	
END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	
END CATCH;

END





--GO