﻿CREATE PROC [SONDA].SWIFT_SP_UPDATE_TAG
@TAG_COLOR VARCHAR(8),
@TAG_VALUE_TEXT VARCHAR(50),
@TAG_PRIORITY INT,
@TAG_COMMENTS VARCHAR(150),
@LAST_UPDATE_BY VARCHAR(20),
@TYPE VARCHAR(20)
AS
UPDATE [SONDA].[SWIFT_TAGS]
   SET 
       [TAG_VALUE_TEXT] = @TAG_VALUE_TEXT
      ,[TAG_PRIORITY] = @TAG_PRIORITY
      ,[TAG_COMMENTS] = @TAG_COMMENTS
      ,[LAST_UPDATE] = CURRENT_TIMESTAMP
      ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
	  ,[TYPE] = @TYPE
 WHERE [TAG_COLOR] = @TAG_COLOR
