CREATE PROC [wms].[OP_WMS_SP_CREATE_SAT_SERVICE]
			@XML varchar(max)
           ,@STATUS varchar(10)
           ,@TYPE varchar(25)
           ,@MESSAGE varchar(250)
           ,@MESSAGE_CODE varchar(15)
		   ,@ACUSE_DOC_ID varchar(15)
		   ,@pResult varchar(200) OUTPUT
           
AS
BEGIN TRY
INSERT INTO [wms].[OP_WMS_SAT_SERVICES]
           ([XML]
           ,[STATUS]
           ,[TYPE]
           ,[MESSAGE]
           ,[MESSAGE_CODE]
           ,[UPDATE_DATE]
           ,[NUMBER_OF_ATTEMPTS]
		   ,[ACUSE_DOC_ID])
     VALUES
           (@XML
           ,@STATUS
           ,@TYPE
           ,@MESSAGE
           ,@MESSAGE_CODE
           ,CURRENT_TIMESTAMP
           ,'1',
		   @ACUSE_DOC_ID)
		   SET @pResult = 'OK'
END TRY
BEGIN CATCH
	SET @pResult = ERROR_MESSAGE();
END CATCH