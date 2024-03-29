﻿CREATE PROC [SONDA].[SWIFT_SP_INSERT_PORTFOLIO_BY_SKU]
	@CODE_PORTFOLIO VARCHAR(25)	
	, @CODE_SKU VARCHAR(50)
	, @pResult VARCHAR(250) OUTPUT
AS
BEGIN TRY
BEGIN	
	BEGIN TRAN t1
		BEGIN			
		
			INSERT INTO [SONDA].SWIFT_PORTFOLIO_BY_SKU(
				CODE_PORTFOLIO
				, CODE_SKU
			)
			VALUES(
				@CODE_PORTFOLIO
				, @CODE_SKU
			);
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
