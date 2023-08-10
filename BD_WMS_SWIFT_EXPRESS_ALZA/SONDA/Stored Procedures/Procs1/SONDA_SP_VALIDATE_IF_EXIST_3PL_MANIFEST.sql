-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	10/23/2017 @ Reborn - TEAM Sprint Drache 
-- Description:			SP que valida si existe el manifiesto proporcionado

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_IF_EXIST_3PL_MANIFEST] @MANIFEST_HEADER_ID = 1108, @LOGIN_ID = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_IF_EXIST_3PL_MANIFEST](
	@MANIFEST_HEADER_ID INT
	,@LOGIN_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @DATABASE_NAME VARCHAR(50)
	,@SCHEMA_NAME VARCHAR(50)
	,@QUERY VARCHAR(MAX);

	SELECT @DATABASE_NAME = ES.[DATABASE_NAME], @SCHEMA_NAME = ES.[SCHEMA_NAME] FROM [SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS ES WHERE ES.[EXTERNAL_SOURCE_ID] > 0;

	SELECT @QUERY = '
		DECLARE @EXIST_MANIFEST INT = NULL
		, @EXTERNAL_LOGIN_ID VARCHAR(50) = NULL;

		SELECT @EXIST_MANIFEST = 1 FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.OP_WMS_MANIFEST_HEADER
		WHERE MANIFEST_HEADER_ID = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + ';

		IF(@EXIST_MANIFEST IS NULL) BEGIN
			RAISERROR(''El manifiesto proporcionado no existe, por favor, verifique y vuelva a intentar'',16,1)
		END

		SELECT @EXTERNAL_LOGIN_ID = L.[EXTERNAL_USER_LOGIN] 
		FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_MANIFEST_HEADER] MH
		INNER JOIN ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_USER_X_PILOT] UXP
		ON UXP.[PILOT_CODE] = MH.[DRIVER]
		INNER JOIN ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_LOGINS] AS L
		ON L.[LOGIN_ID] = UXP.[USER_CODE]
		 WHERE [MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + ';

		 IF(@EXTERNAL_LOGIN_ID IS NULL) 
			BEGIN
				RAISERROR(''El manifiesto proporcionado no tiene un piloto asociado, por favor, comuníquese con su administrador de bodega.'',16,1)
			END
		ELSE IF (@EXTERNAL_LOGIN_ID <> ''' + @LOGIN_ID +''')
			BEGIN
				RAISERROR(''El manifiesto proporcionado no está asociado a su operador, por favor, verifique y vuelva a intentar'',16,1)
			END
	';
	
	EXEC(@QUERY);
END
