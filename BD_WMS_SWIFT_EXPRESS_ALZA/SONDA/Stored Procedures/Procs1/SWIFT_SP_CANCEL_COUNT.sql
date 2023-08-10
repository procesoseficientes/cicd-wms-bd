﻿CREATE PROC [SONDA].[SWIFT_SP_CANCEL_COUNT]
@COUNT_ID VARCHAR(50)
AS
UPDATE [SONDA].SWIFT_CYCLE_COUNT_HEADER SET
COUNT_CANCELED_DATETIME = GETDATE(),COUNT_STATUS = 'CANCELLED'
WHERE COUNT_ID = @COUNT_ID

UPDATE [SONDA].SWIFT_CYCLE_COUNT_DETAIL SET COUNT_STATUS = 'CANCELLED'
WHERE COUNT_ID = @COUNT_ID
