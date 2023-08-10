CREATE PROCEDURE [SONDA].[SWIFT_SP_CANCEL_SCAN]
@pTXN_ID	int
,@pSKU		varchar(75)
,@pResult	varchar(250) OUTPUT
AS
	DECLARE 
		@cantInventory		int
		,@cantTxns			int
		,@HEADER_REFERENCE	int

	BEGIN TRY
		select @cantInventory = i.ON_HAND 
		from [SONDA].[SWIFT_INVENTORY] i 
		where i.TXN_ID = @pTXN_ID
		--
		select @cantTxns = t.TXN_QTY 
			,@HEADER_REFERENCE = HEADER_REFERENCE
		from [SONDA].[SWIFT_TXNS] t 
		where t.TXN_ID = @pTXN_ID
		

		delete from [SONDA].[SWIFT_INVENTORY] where TXN_ID = @pTXN_ID
		--
		if (@cantTxns - @cantInventory) > 1
		BEGIN
			update [SONDA].[SWIFT_TXNS] 
			set TXN_QTY = (@cantTxns - @cantInventory)
			where TXN_ID = @pTXN_ID
		END
		else
		BEGIN
			delete from [SONDA].[SWIFT_TXNS] where TXN_ID = @pTXN_ID
		END
		--
		update [SONDA].[SWIFT_RECEPTION_DETAIL] 
		set [ALLOCATED] = ([ALLOCATED] - @cantInventory)
		where RECEPTION_HEADER = @HEADER_REFERENCE
			and CODE_SKU = @pSKU

		
		SELECT @pResult = 'OK';
		RETURN 0  
	END TRY
	BEGIN CATCH
		SELECT @pResult = ERROR_MESSAGE()
		RETURN -1
	END CATCH
