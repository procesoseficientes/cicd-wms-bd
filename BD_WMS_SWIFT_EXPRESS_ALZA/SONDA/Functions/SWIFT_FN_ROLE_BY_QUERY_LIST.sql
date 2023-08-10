CREATE FUNCTION [SONDA].[SWIFT_FN_ROLE_BY_QUERY_LIST] (@QUERY_LIST_ID INT)
RETURNS VARCHAR(MAX)
AS 
BEGIN 

  DECLARE @ROLE VARCHAR(10) ='';
  DECLARE @ROLE_QTY INT = 0;
  DECLARE @srole VARCHAR(max) = '';
  DECLARE @ID_ROLE VARCHAR(10) = '';
  

 DECLARE	@TEAM_ROLE TABLE
			(
				[TEAM_ROLE] INT IDENTITY(1 ,1)
				,[TEAM_ID] INT
			);

  INSERT INTO @TEAM_ROLE
  SELECT QR.TEAM_ID	
  FROM [SONDA].[SWIFT_QUERY_LIST_BY_ROLE] [QR]
  WHERE [QR].[QUERY_LIST_ID] = @QUERY_LIST_ID
  	
  -- ---------------------------------------------------------------------------------------
	-- Se obtiene la cantidad de permisos asociados al query
	-- ---------------------------------------------------------------------------------------
				SELECT
					@ROLE_QTY = COUNT(*)
				FROM
					@TEAM_ROLE AS [UOT]
				WHERE
					[UOT].[TEAM_ROLE] > 0;

	
	---------------------------------------------------------------------------------------------
	---Para cada team seleccionado insertamos armamos el string de permisos
	---------------------------------------------------------------------------------------------
			WHILE EXISTS ( SELECT TOP 1
									1
								FROM
									@TEAM_ROLE ) 
			BEGIN
			
			SELECT TOP 1
						@ID_ROLE = CONVERT(INT,[UOT].[TEAM_ID])
					FROM
						@TEAM_ROLE AS [UOT]
					WHERE
						[UOT].[TEAM_ROLE] > 0;			  

				SET @srole = @srole +';'+ @ID_ROLE

				-- -------------------------------------------------------------------------------------------
					DELETE FROM
						@TEAM_ROLE
					WHERE
						[TEAM_ID] = CONVERT(INT,@ID_ROLE);
			END	  
			RETURN SUBSTRING(RTRIM(@srole),2,LEN(RTRIM(@srole)))
END
