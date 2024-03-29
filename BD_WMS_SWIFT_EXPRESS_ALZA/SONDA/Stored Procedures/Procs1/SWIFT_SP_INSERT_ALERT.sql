﻿CREATE PROC [SONDA].[SWIFT_SP_INSERT_ALERT]
	  @ALERT_NAME VARCHAR(50)
	, @ALERT_PERC INT
	, @ALERT_MESSAGE VARCHAR(200)
	, @pResult VARCHAR(250) OUTPUT
AS
BEGIN TRY
BEGIN
	IF EXISTS (SELECT 1 FROM [SONDA].SONDA_ALERTS WHERE ALERT_NAME = @ALERT_NAME) BEGIN
		SELECT @pResult = 'El codigo ya fue ingresado.'
		RETURN -1
	END
	BEGIN TRAN t1
		BEGIN		
			INSERT INTO [SONDA].SONDA_ALERTS(
				  ALERT_NAME
				, ALERT_PERC
				, ALERT_MESSAGE
			)
			VALUES(
				  @ALERT_NAME
				, @ALERT_PERC
				, @ALERT_MESSAGE
			)
			
		END	
	
	IF @@error = 0 BEGIN
		SELECT @pResult = 'OK'
		COMMIT TRAN t1
	END		
	ELSE BEGIN
		ROLLBACK TRAN t1
		SELECT	@pResult	= ERROR_MESSAGE()
	END
END
END TRY
BEGIN CATCH
     ROLLBACK TRAN t1
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
