﻿CREATE PROC [SONDA].[SWIFT_SP_UPDATE_PICKING_FREIGHT]
@PICKING_HEADER INT
AS
UPDATE [SONDA].SWIFT_PICKING_HEADER SET FF = '1', FF_STATUS='ASSIGNED'
WHERE PICKING_HEADER = @PICKING_HEADER
