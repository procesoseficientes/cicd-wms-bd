CREATE PROCEDURE [SONDA].[SWIFT_GET_ROLE_BY_QUERY_LIST] (@QUERY_LIST_ID INT)
AS 
BEGIN 

  DECLARE @ROLE VARCHAR(10) ='';
  DECLARE @ROLE_QTY INT = 0;
  DECLARE @srole VARCHAR(max) = '';
  DECLARE @ID_ROLE VARCHAR(10) = '';
  DECLARE @NAMEROLE VARCHAR(50)='';

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

			SELECT @NAMEROLE=NAME FROM SONDA.SWIFT_ROLE
			WHERE ROLE_ID=@ID_ROLE

				SET @srole = @srole +';' + @ID_ROLE +';'+ @NAMEROLE

				-- -------------------------------------------------------------------------------------------
					DELETE FROM
						@TEAM_ROLE
					WHERE
						[TEAM_ID] = CONVERT(INT,@ID_ROLE);
			END	  
			SELECT SUBSTRING(RTRIM(@srole),2,LEN(RTRIM(@srole))) AS ROLE_BY_QUERY
END
