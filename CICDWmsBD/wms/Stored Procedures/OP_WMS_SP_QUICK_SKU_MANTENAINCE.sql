CREATE PROCEDURE [wms].[OP_WMS_SP_QUICK_SKU_MANTENAINCE]
	-- Add the parameters for the stored procedure here
	@pCLIENT_OWNER			varchar(25),
	@pMATERIAL_NAME			varchar(150),
	@pBARCODE				varchar(25),
	@pLAST_LOGIN			varchar(25),
	@pIMAGE_1				image,
	@pResult				varchar(250) OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
		
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	
	BEGIN TRY
			
		IF EXISTS(SELECT * FROM [wms].OP_WMS_FUNC_GETMATERIAL_DESC(@pBARCODE, @pCLIENT_OWNER))

		BEGIN
			UPDATE [wms].[OP_WMS_MATERIALS]
			SET 
				MATERIAL_NAME	=	@pMATERIAL_NAME,
				IMAGE_1			=	@pIMAGE_1
			WHERE
				[CLIENT_OWNER]		=	@pCLIENT_OWNER AND 
				[MATERIAL_ID]		=	@pCLIENT_OWNER + '/' + @pBARCODE
			  
		END
		ELSE
			BEGIN
				   
			INSERT INTO [wms].[OP_WMS_MATERIALS]
           ([CLIENT_OWNER]
           ,[MATERIAL_ID]
           ,[BARCODE_ID]
           ,[ALTERNATE_BARCODE]
           ,[MATERIAL_NAME]
           ,[SHORT_NAME]
           ,[VOLUME_FACTOR]
           ,[MATERIAL_CLASS]
           ,[HIGH]
           ,[LENGTH]
           ,[WIDTH]
           ,[MAX_X_BIN]
           ,[SCAN_BY_ONE]
           ,[REQUIRES_LOGISTICS_INFO]
           ,[WEIGTH]
           ,[IMAGE_1]
           ,[IMAGE_2]
           ,[IMAGE_3], LAST_UPDATED, LAST_UPDATED_BY)
     VALUES
           (@pCLIENT_OWNER
           ,@pCLIENT_OWNER + '/' + @pBARCODE
           ,@pBARCODE
           ,@pBARCODE
           ,@pMATERIAL_NAME
           ,@pMATERIAL_NAME
           ,0
           ,NULL
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,@pIMAGE_1
           ,NULL
           ,NULL, CURRENT_TIMESTAMP, @pLAST_LOGIN)
			
			SELECT	@pResult	= 'OK'
		END	
		
	END TRY
	BEGIN CATCH
		SELECT	@pResult	= ERROR_MESSAGE()
	END CATCH
   
END