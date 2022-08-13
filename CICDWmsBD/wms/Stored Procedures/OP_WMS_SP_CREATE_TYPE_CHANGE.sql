CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_TYPE_CHANGE]	
	@CHARGE varchar(100),	
	@DESCRIPTION varchar(250),
	@WAREHOUSE_WEATHER varchar(60),
	@REGIMEN varchar(25),
	@COMMENT varchar(200),
	@DAY_TRIP VARCHAR(40),
	@SERVICE_CODE VARCHAR(25),
	@TO_MOVIL NUMERIC(18,0),
	@pResult varchar(250) OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;	
	BEGIN TRAN
		BEGIN
			INSERT INTO [wms].OP_WMS_TYPE_CHARGE
				   (
					CHARGE
				   ,[DESCRIPTION]
				   ,WAREHOUSE_WEATHER
				   ,REGIMEN				   				   
				   ,COMMENT
				   ,DAY_TRIP
				   ,SERVICE_CODE
				   ,TO_MOVIL
				   )
			 VALUES
				   (
				    @CHARGE
				   ,@DESCRIPTION
				   ,@WAREHOUSE_WEATHER
				   ,@REGIMEN
				   ,@COMMENT
				   ,@DAY_TRIP				   
				   ,@SERVICE_CODE
				   ,@TO_MOVIL
				   )				   
		END	
	IF @@error = 0 BEGIN
		SET @pResult = 'OK'
		COMMIT TRAN
	END
	ELSE
		BEGIN
			ROLLBACK TRAN
			SET	@pResult	= ERROR_MESSAGE()
		END
		
END