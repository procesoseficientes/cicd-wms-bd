-- =============================================
-- Author:		FRM
-- Create date: MARCH,20,2010
-- Description:	MIMICS SEQUENCES FUNCTION.
-- =============================================
CREATE PROCEDURE [wms].[GET_SEQ]
	@pSEQ_ID varchar(25),
	@pSEQ_VALUE decimal(18,0) OUTPUT
AS
 UPDATE OP_WMS_SEQUENCES 
	SET @pSEQ_VALUE = SEQ_VALUE = SEQ_VALUE+1,
	LAST_UPDATED = CURRENT_TIMESTAMP
 WHERE 
	SEQ_ID = @pSEQ_ID
 RETURN @pSEQ_VALUE