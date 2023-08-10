-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		12-07-2016
-- Description:			    SP que valida el login

-- Modificacion 3/9/2017 @ A-Team Sprint Ebonne
					-- rodrigo.gomez
					-- Se añadieron los campos DEVICE_ID y VALIDATION_TYPE

/*
-- Ejemplo de Ejecucion:
        EXEC [dbo].[SWIFT_LOGIN]
			@USER = 'OPER1@SONDA'
			,@PASSWORD = '123'
*/
-- =============================================
CREATE PROCEDURE [dbo].[SWIFT_LOGIN] (
	@USER VARCHAR(50)
	,@PASSWORD VARCHAR(50)
	,@IPADDRESS VARCHAR(20) = NULL
)
AS 
BEGIN
	DECLARE	@CODE_ENTERPRISE VARCHAR(100);
	SET @CODE_ENTERPRISE = SUBSTRING(@USER, CHARINDEX('@', @USER) + 1,LEN(@USER)); 

	IF NOT EXISTS (SELECT 1 FROM [dbo].[SWIFT_USER] WHERE [LOGIN] = @USER )
	BEGIN
		RAISERROR('Usuario no existe',16,1);
		RETURN -2;
	END;
	ELSE
	BEGIN
		SELECT
			[B].[CONNECTION_STRING]
			,[B].[IMAGE] [COMPANY_LOGO]
			,[A].[IMAGE] [PROFILE_IMAGE]
			,[A].[NAME_USER]
			,[A].[LOGIN]
			,[B].[USER] [DB_USER]
			,[B].[PASS] [DB_USER_PASS]
			,[A].[TYPE_USER]
			,[A].[SELLER_ROUTE] [ROUTE_ID]
			,[A].[DEFAULT_WAREHOUSE]
			,[E].[NAME_ENTERPRISE]
			,[E].[NIT]
			,[E].[URL_WS_INTERFACE]
			,[B].[CODE_ENTERPRISE] [CODE_ENTERPRISE]
			,[A].[PRESALE_WAREHOUSE]
			,[A].[ROUTE_RETURN_WAREHOUSE]
			,ISNULL([E].[LOGO_IMG],[B].[IMAGE]) [LOGO_IMG]
			,[A].[VALIDATION_TYPE]
			,[A].[DEVICE_ID]
		FROM [dbo].[SWIFT_USER] [A]
		INNER JOIN [dbo].[SWIFT_EXTERNAL_USER] [B] ON (			
			[A].[CODE_ENTERPRISE] = [B].[CODE_ENTERPRISE]
		)
		INNER JOIN [dbo].[SWIFT_ENTERPRISE] [E] ON (
			[B].[CODE_ENTERPRISE] = [E].[CODE_ENTERPRISE]
		)
		WHERE
			[LOGIN] = @USER
			AND [PASSWORD] = @PASSWORD
			AND [A].[CODE_ENTERPRISE] = @CODE_ENTERPRISE

		IF @@ROWCOUNT = 0
		BEGIN
			RETURN -3;
		END;
		ELSE
		BEGIN
			INSERT	INTO [dbo].[SWIFT_LOG]
					(
						[TYPE]
						,[CODE_ENTERPRISE]
						,[USER]
						,[LOG_STAMP]
						,[IP_ADDRESS]
					)
			VALUES
					(
						'LOGIN'
						,UPPER(@CODE_ENTERPRISE)
						,UPPER(@USER)
						,CURRENT_TIMESTAMP
						,@IPADDRESS
					);
			RETURN 0;
		END
	END
END
