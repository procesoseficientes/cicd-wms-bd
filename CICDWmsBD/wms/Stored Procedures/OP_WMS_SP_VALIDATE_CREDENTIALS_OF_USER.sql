-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	2/16/2018 @ Reborn-TEAM Sprint Ulrich
-- Description:			SP que valida las credenciales (dominio, usuario y contraseña) del operador

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190204 GForce@Rinoceronte
-- Description:			
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_CREDENTIALS_OF_USER]
				@LOGIN_ID = 'ADMIN'
				,@DOMAIN = 'ALZAQA'
				,@PASSWORD = '@wms**'
				,@VERSION_BO='2022.10.0349'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_CREDENTIALS_OF_USER] (
		@LOGIN_ID VARCHAR(50)
		,@DOMAIN VARCHAR(50)
		,@PASSWORD VARCHAR(50)
		,@VERSION_BO VARCHAR(12)=''
	)
AS
BEGIN
	--
	SET NOCOUNT ON;
	
	--
	DECLARE	@ERROR VARCHAR(MAX)
	
	DECLARE @VERSION_QA VARCHAR(12);
	DECLARE @VERSION_PROD VARCHAR(12);
	SELECT @VERSION_QA = VALUE FROM [wms].[OP_WMS_PARAMETER] WHERE [IDENTITY] = 50
	SELECT @VERSION_PROD = VALUE FROM [wms].[OP_WMS_PARAMETER] WHERE [IDENTITY] = 47
	PRINT @VERSION_QA + @VERSION_PROD
	-- ------------------------------------------------------------------------------------
	-- valido si esta activo el usuario
	-- ------------------------------------------------------------------------------------
	IF (SELECT
			1
		FROM
			[wms].[OP_WMS_LOGINS]
		WHERE
			[LOGIN_ID] = @LOGIN_ID
			AND [LOGIN_STATUS] != 'ACTIVO') = 1
	BEGIN
		SET @ERROR = 'El usuario ' + @LOGIN_ID
			+ ' esta bloqueado';
		RAISERROR(@ERROR,16,1);
	END;
	-- ----------------------------------------------------------------------
	-- Se valida el dominio
	-- ----------------------------------------------------------------------
	IF (SELECT
			1
		FROM
			[dbo].[OP_WMS_DOMAINS]
		WHERE
			[DOMAIN] = @DOMAIN) = 1
	BEGIN
		-- ----------------------------------------------------------------------
		-- Se valida si el usuario pertenece al dominio
		-- ----------------------------------------------------------------------
		IF (SELECT
				1
			FROM
				[wms].[OP_WMS_LOGINS] AS [L]
			INNER JOIN [dbo].[OP_WMS_DOMAINS] AS [D] ON ([D].[ID] = [L].[DOMAIN_ID])
			WHERE
				[L].[LOGIN_ID] = @LOGIN_ID
				AND [D].[DOMAIN] = @DOMAIN) = 1
		BEGIN
			-- ----------------------------------------------------------------------
			-- Se validan las credenciales del usuario
			-- ----------------------------------------------------------------------
			IF (SELECT
					1
				FROM
					[wms].[OP_WMS_LOGINS] AS [L]
				WHERE
					[L].[LOGIN_ID] = @LOGIN_ID
					AND [L].[LOGIN_PWD] = @PASSWORD) = 1
			BEGIN
			IF(@VERSION_QA = @VERSION_BO OR @VERSION_PROD = @VERSION_BO) 
				BEGIN
				SELECT
					1 AS [Resultado]
					,'Proceso Exitoso' [Mensaje]
					,1 [Codigo];
			END;
			ELSE
			BEGIN
			SET @ERROR = 'ACTUALIZAR A LA ÚLTIMA VERSIÓN'
				RAISERROR(@ERROR,16,1);
			END;
			END;
			ELSE
			BEGIN
				SET @ERROR = 'Los datos de inicio de sesión son incorrectos, por favor, verifique y vuelva a intentar';
				RAISERROR(@ERROR,16,1);
			END;	
		END;
		ELSE
		BEGIN
			SET @ERROR = 'El usuario proporcionado no pertenece al dominio '
				+ @DOMAIN
				+ ', por favor, verifique y vuelva a intentar';
			RAISERROR(@ERROR,16,1);
		END;
	END;
	ELSE
	BEGIN
		SET @ERROR = 'El dominio ' + @DOMAIN
			+ ' no es válido, por favor, verifique y vuelva a intentar';
		RAISERROR(@ERROR,16,1);
	END;
END;
