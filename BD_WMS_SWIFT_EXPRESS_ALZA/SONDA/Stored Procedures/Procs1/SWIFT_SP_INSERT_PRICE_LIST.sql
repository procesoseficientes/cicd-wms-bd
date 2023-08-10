﻿CREATE PROC [SONDA].[SWIFT_SP_INSERT_PRICE_LIST]
	@CODE_PRICE_LIST VARCHAR(25)
	, @NAME_PRICE_LIST VARCHAR(50)
	, @COMMENT VARCHAR(250)
	, @LAST_UPDATE_BY VARCHAR(50)
	, @pResult VARCHAR(250) OUTPUT
AS
BEGIN TRY
BEGIN
	IF EXISTS (SELECT 1 FROM [SONDA].SWIFT_PRICE_LIST WHERE CODE_PRICE_LIST = @CODE_PRICE_LIST) BEGIN
		SELECT @pResult = 'El codigo ya fue ingresado.'
		RETURN -1
	END
	BEGIN TRAN t1
		BEGIN		
			INSERT INTO [SONDA].SWIFT_PRICE_LIST(
				CODE_PRICE_LIST
				, NAME_PRICE_LIST
				, COMMENT
				, LAST_UPDATE
				, LAST_UPDATE_BY
			)
			VALUES(
				@CODE_PRICE_LIST
				, @NAME_PRICE_LIST
				, @COMMENT
				, GETDATE()
				, @LAST_UPDATE_BY
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
