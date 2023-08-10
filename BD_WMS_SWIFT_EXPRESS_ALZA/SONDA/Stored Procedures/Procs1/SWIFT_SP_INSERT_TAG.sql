CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_TAG
@TAG_COLOR VARCHAR(8),
@TAG_VALUE_TEXT VARCHAR(50),
@TAG_PRIORITY INT,
@TAG_COMMENTS VARCHAR(150),
@LAST_UPDATE_BY VARCHAR(20),
@TYPE VARCHAR(20),
@pResult varchar(250) OUTPUT
AS
IF ((SELECT COUNT(A.TAG_COLOR) FROM SWIFT_TAGS AS A WHERE A.TAG_COLOR =  @TAG_COLOR )) = 0
BEGIN 
	INSERT INTO [SWIFT_TAGS]
           ([TAG_COLOR]
           ,[TAG_VALUE_TEXT]
           ,[TAG_PRIORITY]
           ,[TAG_COMMENTS]
           ,[LAST_UPDATE]
           ,[LAST_UPDATE_BY]
		   ,[TYPE]
		   )
     VALUES
           (@TAG_COLOR
           ,@TAG_VALUE_TEXT
           ,@TAG_PRIORITY
           ,@TAG_COMMENTS
           ,CURRENT_TIMESTAMP
           ,@LAST_UPDATE_BY
		   ,@TYPE
		   )
	SELECT @pResult = ''
END
ELSE
	BEGIN
		SELECT @pResult = 'No se puede crear debido a que el color ya está siendo utilizado'
	END
