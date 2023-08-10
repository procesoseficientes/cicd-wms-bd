-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	07-08-2018 @ G-Force Sprint Hormiga
-- Description:			Se que inserta o actualiza permisos para los queryes

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].SWIFT_INSERT_OR_UPDATE_QUERY_LIST_BY_ROLE
		 @QUERY_LIST_ID = 2114
		,@TEAM_ID = 'GERENTE@SONDA'
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_INSERT_OR_UPDATE_QUERY_LIST_BY_ROLE] (
		 @QUERY_LIST_ID INT
		,@TEAM_ID VARCHAR(max)
	)
AS
BEGIN
		DECLARE @TEAM_QTY INT=0;
		DECLARE @ID_T INT=0;
		DECLARE	@TEAM_SELECTED TABLE
			(
				[ID] INT IDENTITY(1 ,1)
				,[TEAM_ID] INT
			);

	BEGIN TRY

	INSERT INTO @TEAM_SELECTED	
	SELECT DATA FROM [SONDA].[Split](@TEAM_ID,';')
	WHERE ISNUMERIC(DATA)=1
	-- ---------------------------------------------------------------------------------------
	-- Se obtiene la cantidad de operadores asociados al equipo en base al tipo de meta
	-- ---------------------------------------------------------------------------------------
				SELECT
					@TEAM_QTY = COUNT(*)
				FROM
					@TEAM_SELECTED AS [UOT]
				WHERE
					[UOT].[ID] > 0;

    ---------------------------------------------------------------------------------------------
	---Eliminamos los datos----------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	DELETE FROM SONDA.SWIFT_QUERY_LIST_BY_ROLE
	WHERE QUERY_LIST_ID=@QUERY_LIST_ID
	--AND TEAM_ID in (SELECT DATA FROM [SONDA].[Split](@TEAM_ID,';'))
	---------------------------------------------------------------------------------------------
	---Para cada team seleccionado insertamos un registro en la tabla SWIFT_QUERY_LIST_BY_ROLE
	---------------------------------------------------------------------------------------------
			WHILE EXISTS ( SELECT TOP 1
									1
								FROM
									@TEAM_SELECTED ) BEGIN

		-- -------------------------------------------------------------------------------------------
		-- Obtenemos un Team
		-- -------------------------------------------------------------------------------------------
					SELECT TOP 1
						@ID_T = CONVERT(INT,[UOT].[TEAM_ID])
					FROM
						@TEAM_SELECTED AS [UOT]
					WHERE
						[UOT].[ID] > 0;

							IF NOT EXISTS ( SELECT TOP 1
												1
											FROM
												[SONDA].[SWIFT_QUERY_LIST_BY_ROLE]
											WHERE
												[QUERY_LIST_ID] = @QUERY_LIST_ID
												AND [TEAM_ID] = CONVERT(INT,@ID_T) )
							BEGIN
								INSERT	INTO [SONDA].[SWIFT_QUERY_LIST_BY_ROLE]
										(
											[QUERY_LIST_ID]
											,[TEAM_ID]						
										)
								VALUES
										(
											@QUERY_LIST_ID
											,CONVERT(INT,@ID_T)
										);
							END;
		
						ELSE
							BEGIN
								SELECT
									-1 AS [Resultado]
									,'El acceso ya existe para ese team' [Mensaje]; 
							END;
					-- -------------------------------------------------------------------------------------------
					-- Eliminamos el registro procesado
					-- -------------------------------------------------------------------------------------------
					DELETE FROM
						@TEAM_SELECTED
					WHERE
						[TEAM_ID] = CONVERT(INT,@ID_T);
					END

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje];    

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;


END;
