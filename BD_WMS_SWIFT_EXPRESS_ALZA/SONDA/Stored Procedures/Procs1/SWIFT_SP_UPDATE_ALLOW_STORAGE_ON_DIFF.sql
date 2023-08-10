﻿CREATE PROC [SONDA].[SWIFT_SP_UPDATE_ALLOW_STORAGE_ON_DIFF]
@VALUE INT,
@TASK_ID INT
AS
UPDATE [SONDA].SWIFT_TASKS
SET ALLOW_STORAGE_ON_DIFF = @VALUE WHERE TASK_ID = @TASK_ID
