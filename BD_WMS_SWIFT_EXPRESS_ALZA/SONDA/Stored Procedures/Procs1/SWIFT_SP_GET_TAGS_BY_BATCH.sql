﻿CREATE PROC [SONDA].[SWIFT_SP_GET_TAGS_BY_BATCH]
@BATCH_ID VARCHAR(150)
AS
SELECT DISTINCT
B.[TAG_COLOR],
(SELECT [TAG_VALUE_TEXT] FROM [SONDA].[SWIFT_TAGS] AS A WHERE A.TAG_COLOR = B.TAG_COLOR) AS TAG_VALUE_TEXT
FROM [SONDA].[SWIFT_TAGS_BY_BATCH] AS B
WHERE [BATCH_ID] = @BATCH_ID
