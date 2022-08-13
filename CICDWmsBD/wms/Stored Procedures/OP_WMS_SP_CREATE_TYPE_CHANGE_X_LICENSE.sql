CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_TYPE_CHANGE_X_LICENSE]	
	@LICENCESE_ID numeric(18,0),	
	@TYPE_CHARGE_ID int,
	@QTY numeric(18,0),
	@LAST_UPDATED_BY varchar(25),
	@TYPE_TRANS AS VARCHAR(25),
	@pResult varchar(250) OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;	
	BEGIN TRAN
		BEGIN
			DELETE [wms].OP_WMS_TYPE_CHARGE_X_LICENSE
			WHERE LICENCESE_ID = @LICENCESE_ID
			AND TYPE_CHARGE_ID = @TYPE_CHARGE_ID 
			AND TYPE_TRANS = @TYPE_TRANS
			
			IF @QTY > 0 BEGIN
		
			INSERT INTO [wms].OP_WMS_TYPE_CHARGE_X_LICENSE
				   (
					LICENCESE_ID
				   ,TYPE_CHARGE_ID
				   ,QTY
				   ,LAST_UPDATED_BY				   				   
				   ,LAST_UPDATED
				   , TYPE_TRANS
				   )
			 VALUES
				   (
				    @LICENCESE_ID
				   ,@TYPE_CHARGE_ID
				   ,@QTY
				   ,@LAST_UPDATED_BY
				   ,GetDate()
				   , @TYPE_TRANS
				   )	
			END		   
		END	
	IF @@error = 0 BEGIN
		SET @pResult = 'OK'
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST('' AS VARCHAR) DbData
		COMMIT TRAN
	END
	ELSE
		BEGIN

			SELECT 
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@@error AS [Codigo]
			,'' AS [DbData]
			ROLLBACK TRAN
			SET	@pResult	= ERROR_MESSAGE()
		END
		
END