

CREATE PROCEDURE [wms].[OP_WMS_SP_ALLOC_LICENSE]
	-- Add the parameters for the stored procedure here
			@pLICENSE_ID				numeric(18,0)
           ,@pTARGET_LOCATION			varchar(25)
           ,@pLOGIN_ID					varchar(25)
           ,@pRESULT					varchar(300) OUTPUT

AS
BEGIN
	
	SET NOCOUNT ON;
		
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;

	BEGIN TRY
	
			UPDATE [wms].OP_WMS_LICENSES 
			SET 
				LAST_LOCATION		= CURRENT_LOCATION, 
				CURRENT_LOCATION	= @pTARGET_LOCATION, 
				LAST_UPDATED_BY		= @pLOGIN_ID,
				CURRENT_WAREHOUSE	= 
			ISNULL((
				SELECT ISNULL(ZONE,'BODEGA_DEF') FROM 
				[wms].OP_WMS_SHELF_SPOTS WHERE LOCATION_SPOT = @pTARGET_LOCATION),'BODEGA_DEF'),
			STATUS = 'ALLOCATED'
            WHERE 
				LICENSE_ID			= @pLICENSE_ID

			SELECT	@pResult	= 'OK'								

	END TRY
	BEGIN CATCH
		SELECT	@pResult	= ERROR_MESSAGE()
	END CATCH
   
END