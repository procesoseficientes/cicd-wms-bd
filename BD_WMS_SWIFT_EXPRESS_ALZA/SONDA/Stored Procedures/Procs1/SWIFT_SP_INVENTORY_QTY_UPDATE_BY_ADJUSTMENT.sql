-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	16-1-2016
-- Description:			Actualiza el iventario por el pallet
-- =============================================
/*
-- Ejemplo de Ejecucion:				
				SELECT * from [SONDA].[SWIFT_INVENTORY] I WHERE PALLET_ID = 42
				--
				EXEC [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]
						@PALLET_ID = 42
						,@QTY = 1
						,@LAST_UPDATE_BY = 'OPER2@SONDA'
						,@TXN_ID = 483
						,@IS_SUM = 1
				--
				SELECT * from [SONDA].[SWIFT_INVENTORY] I WHERE PALLET_ID = 42

				--
				EXEC [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]
						@PALLET_ID = 42
						,@QTY = 1
						,@LAST_UPDATE_BY = 'OPER2@SONDA'
						,@TXN_ID = 483
						,@IS_SUM = 0
				--
				SELECT * from [SONDA].[SWIFT_INVENTORY] I WHERE PALLET_ID = 42
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]
	@PALLET_ID INT
	,@QTY INT
	,@LAST_UPDATE_BY VARCHAR(50)
	,@TXN_ID INT
	,@IS_SUM INT = 0
AS
BEGIN	
	SET NOCOUNT ON;
	--
	DECLARE @ON_HAND_NEW INT
	--
	SELECT @ON_HAND_NEW = 
		CASE @IS_SUM
			WHEN 1 THEN (I.ON_HAND + @QTY)
			ELSE (I.ON_HAND - @QTY)
		END
	FROM [SONDA].[SWIFT_INVENTORY] I
	WHERE PALLET_ID = @PALLET_ID

    UPDATE [SONDA].[SWIFT_INVENTORY] SET
		ON_HAND = @ON_HAND_NEW
		,LAST_UPDATE = GETDATE()
		,LAST_UPDATE_BY = @LAST_UPDATE_BY
		,TXN_ID = @TXN_ID
	WHERE PALLET_ID = @PALLET_ID
END
