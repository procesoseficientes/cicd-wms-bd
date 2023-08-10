
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	15-01-2016
-- Description:			Disminuye la cantedad del lote
/*
-- Ejemplo de Ejecucion:				
				-- 
				EXEC [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE] 
					@BATCH_ID = 40
					,@QTY = 1
					,@LAST_UPDATE_BY = 'OPER1@SONDA'
					,@IS_SUM = 1
				--
				SELECT * from [SONDA].[SWIFT_BATCH] B WHERE B.BATCH_ID = 40

				--
				EXEC [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE] 
					@BATCH_ID = 40
					,@QTY = 1
					,@LAST_UPDATE_BY = 'OPER1@SONDA'
					,@IS_SUM = 0
				--
				SELECT * from [SONDA].[SWIFT_BATCH] B WHERE B.BATCH_ID = 40
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE]
	@BATCH_ID INT
   ,@QTY INT
   ,@LAST_UPDATE_BY VARCHAR(50)
   ,@IS_SUM INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @QTY_NEW INT
	--
	SELECT @QTY_NEW = 
		CASE @IS_SUM
			WHEN 1 THEN (B.QTY + @QTY)
			ELSE (B.QTY - @QTY)
		END
	FROM [SONDA].[SWIFT_BATCH] B
	WHERE [BATCH_ID] = @BATCH_ID

	UPDATE [SONDA].[SWIFT_BATCH]
	SET
		[QTY] = @QTY_NEW
		,LAST_UPDATE = GETDATE()
		,LAST_UPDATE_BY = @LAST_UPDATE_BY
	WHERE [BATCH_ID] = @BATCH_ID
END
