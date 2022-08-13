

CREATE PROCEDURE [wms].[OP_WMS_SP_SET_GRID_LAYOUT]
	-- Add the parameters for the stored procedure here
	@pGRID_ID				varchar(250),
	@pLOGIN_ID				varchar(25),
	@pLAYOUT_XML			varchar(2500),
	@pGRID_CRITERIA_FILTER	varchar(500),
	@pResult				varchar(250) OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
		
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @pALLOW_REALLOC INT;
	BEGIN TRY
			
		BEGIN
		--UPDATE OR INSERT?
		IF EXISTS(SELECT 1 FROM 
			[wms].OP_SETUP_GRIDS_LAYOUT 
			WHERE GRID_ID = @pGRID_ID AND LOGIN_ID = @pLOGIN_ID) 
		BEGIN
			
			UPDATE 
				OP_SETUP_GRIDS_LAYOUT 
			SET 
				LAYOUT_XML				= @pLAYOUT_XML, 
				GRID_CRITERIA_FILTER	= @pGRID_CRITERIA_FILTER
			WHERE
				GRID_ID		= @pGRID_ID AND
				LOGIN_ID	= @pLOGIN_ID
			
			SELECT	@pResult	= 'OK'
		END
		ELSE BEGIN
			INSERT INTO [wms].[OP_SETUP_GRIDS_LAYOUT]
           ([GRID_ID]
           ,[LOGIN_ID]
           ,[LAYOUT_XML]
           ,[LAYOUT_XML_APPERANCE]
           ,[GRID_CRITERIA_FILTER])
			 VALUES
				   (@pGRID_ID
				   ,@pLOGIN_ID
				   ,@pLAYOUT_XML
				   ,NULL
				   ,@pGRID_CRITERIA_FILTER)

			SELECT @pResult = 'OK'
		END
	END
	END TRY
	BEGIN CATCH
		SELECT	@pResult	= ERROR_MESSAGE()
	END CATCH
   
END