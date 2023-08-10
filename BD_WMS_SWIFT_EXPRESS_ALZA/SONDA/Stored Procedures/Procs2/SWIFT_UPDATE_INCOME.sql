﻿CREATE PROCEDURE [SONDA].[SWIFT_UPDATE_INCOME]
@OBSERVATION VARCHAR(MAX),
@INCOME_HEADER INT
AS
UPDATE SWIFT_RECEPTION_HEADER SET COMMENTS=@OBSERVATION, STATUS='CLOSED'
WHERE RECEPTION_HEADER = @INCOME_HEADER

UPDATE SWIFT_TASKS SET ACTION='CLOSED'
WHERE RECEPTION_NUMBER=@INCOME_HEADER
