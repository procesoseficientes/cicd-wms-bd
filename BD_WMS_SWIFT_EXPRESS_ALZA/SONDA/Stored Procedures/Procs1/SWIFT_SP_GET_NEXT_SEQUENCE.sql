﻿

CREATE PROC [SONDA].[SWIFT_SP_GET_NEXT_SEQUENCE]
@SEQUENCE_NAME VARCHAR(50),
@pResult NUMERIC(18,0) OUTPUT
AS
BEGIN TRY
--STORED PROCEDURE QUE DEVUELVE UNA RESPUESTA
DECLARE @COUNT INT
SET  @COUNT = (SELECT COUNT([SEQUENCE_NAME]) FROM [SONDA].[SWIFT_SEQUENCES] WHERE [SEQUENCE_NAME] = @SEQUENCE_NAME)

BEGIN TRAN t1
IF(@COUNT = 0)
BEGIN
	INSERT INTO [SONDA].[SWIFT_SEQUENCES] (
		[SEQUENCE_NAME]
		, [CURRENT_NUMBER])
	VALUES
	(@SEQUENCE_NAME
	, 1)
	SET @pResult = 1
END
ELSE
BEGIN
	SET @pResult = (SELECT TOP 1 [CURRENT_NUMBER] FROM [SONDA].[SWIFT_SEQUENCES] WHERE [SEQUENCE_NAME] = @SEQUENCE_NAME ORDER BY [CURRENT_NUMBER] DESC) + 1
	UPDATE [SONDA].[SWIFT_SEQUENCES] SET [CURRENT_NUMBER] = @pResult WHERE [SEQUENCE_NAME] = @SEQUENCE_NAME
END
IF @@error = 0 BEGIN		
	COMMIT TRAN t1
END
ELSE
BEGIN
	ROLLBACK TRAN t1
END
END TRY
BEGIN CATCH
     ROLLBACK TRAN t1
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
