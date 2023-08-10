-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	10/21/2017 @ Reborn-TEAM Sprint Drache
-- Description:			SP que actualiza el STATUS de un manifiesto de 3PL

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_CHANGE_STATUS_OF_3PL_MANIFEST]
					@MANIFEST_HEADER_ID = 1108
					,@STATUS = 'ASSIGNED'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CHANGE_STATUS_OF_3PL_MANIFEST]
	(
		@MANIFEST_HEADER_ID INT
		,@STATUS VARCHAR(50)
	)
AS
	BEGIN
	--
	SET NOCOUNT ON;
	--
		BEGIN TRY
			DECLARE
				@DATABASE_NAME VARCHAR(50)
				,@SCHEMA_NAME VARCHAR(50)
				,@QUERY VARCHAR(MAX);

		--
			SELECT
				@DATABASE_NAME = [DATABASE_NAME]
				,@SCHEMA_NAME = [SCHEMA_NAME]
			FROM
				[SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE]
			WHERE
				[EXTERNAL_SOURCE_ID] > 0;
		--
			SELECT @QUERY = '
				UPDATE ' + @DATABASE_NAME +'.' + @SCHEMA_NAME + '.[OP_WMS_MANIFEST_HEADER]
				SET [STATUS] = ''' + @STATUS + '''
				WHERE [MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + ';
			';
			--
			PRINT(@QUERY)
			EXEC(@QUERY);
			--
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,'' [DbData];
		END TRY
		BEGIN CATCH
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo]; 
		END CATCH;
	END;
