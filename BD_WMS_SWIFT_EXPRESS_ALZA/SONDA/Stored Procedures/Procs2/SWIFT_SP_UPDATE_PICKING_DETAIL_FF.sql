﻿CREATE PROC [SONDA].[SWIFT_SP_UPDATE_PICKING_DETAIL_FF]
@PICKING_DETAIL INT,
@RESULT FLOAT
AS
UPDATE [SONDA].SWIFT_PICKING_DETAIL
	SET
		RESULT = @RESULT
	WHERE
		PICKING_DETAIL = @PICKING_DETAIL
