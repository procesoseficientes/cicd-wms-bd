--USE [OP_WMS]
--GO

--/****** Object:  StoredProcedure [wms].[OP_WMS_SP_START_CAMPAIGN]    Script Date: 06/02/2011 11:02:24 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO



CREATE PROCEDURE  [wms].[OP_WMS_SP_UPDATE_PROFILE] 
(
	@pProfileModuleID varchar(25),
	@pProfileName varchar(100),
	@pUser varchar(30),
	@pLayoutID varchar(5000)	
)
AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

BEGIN TRANSACTION

BEGIN TRY
	
	UPDATE OP_WMS_MAIN_PROFILES SET PROFILE_LAYOUT_ID = @pLayoutID
	WHERE PROFILE_MODULE_ID = @pProfileModuleID and PROFILE_NAME = @pProfileName and PROFILE_USER = @pUser;
	
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