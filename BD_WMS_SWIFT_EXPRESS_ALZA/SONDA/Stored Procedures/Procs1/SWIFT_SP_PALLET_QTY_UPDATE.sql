
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	15-01-2016
-- Description:			Disminuye la cantedad del pallet
/*
-- Ejemplo de Ejecucion:				
				-- 
				EXEC [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE] 
					@PALLET_ID = 41
					,@QTY = 1
					,@LAST_UPDATE_BY = 'OPER1@SONDA'
					,@IS_SUM = 1
				--
				SELECT * FROM [SONDA].[SWIFT_PALLET] P WHERE P.[PALLET_ID] = 41

				-- 
				EXEC [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE] 
					@PALLET_ID = 41
					,@QTY = 1
					,@LAST_UPDATE_BY = 'OPER1@SONDA'
					,@IS_SUM = 0
				--
				SELECT * FROM [SONDA].[SWIFT_PALLET] P WHERE P.[PALLET_ID] = 41
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE]
	@PALLET_ID INT
   ,@QTY INT
   ,@LAST_UPDATE_BY VARCHAR(50)
   ,@IS_SUM INT = 0
AS
BEGIN
	SET NOCOUNT ON
	--
	DECLARE @QTY_NEW INT
	--
	SELECT @QTY_NEW = 
		CASE @IS_SUM
			WHEN 1 THEN (P.QTY + @QTY)
			ELSE (P.QTY - @QTY)
		END
	FROM [SONDA].[SWIFT_PALLET] P
	WHERE [PALLET_ID] = @PALLET_ID
	
	UPDATE [SONDA].[SWIFT_PALLET]
	SET
		[QTY] = @QTY_NEW
		,LAST_UPDATE = GETDATE()
		,LAST_UPDATE_BY = @LAST_UPDATE_BY
	WHERE [PALLET_ID] = @PALLET_ID
END
