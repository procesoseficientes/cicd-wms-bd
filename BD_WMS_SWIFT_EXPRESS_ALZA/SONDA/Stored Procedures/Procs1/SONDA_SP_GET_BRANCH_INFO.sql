-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	11/17/2017 @ Reborn - TEAM Sprint Eberhard
-- Description:			SP que obtiene los registros de la informacion de la empresa del operador

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_BRANCH_INFO]
				@AUTH_ASSIGNED_TO = '46'
				,@INVOICE_IN_ROUTE = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_BRANCH_INFO](
	@AUTH_ASSIGNED_TO VARCHAR(100)
	,@INVOICE_IN_ROUTE INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 
		[E].[CODE_ENTERPRISE]
		,[E].[NAME_ENTERPRISE]
		,[E].[NIT] [NIT_ENTERPRISE]
		,[E].[ENTERPRISE_EMAIL_ADDRESS]
		,[E].[PHONE_NUMBER]
		,[U].[NAME_USER]
		,@INVOICE_IN_ROUTE [INVOICE_IN_ROUTE]
	FROM [SONDA].[USERS] [U]
	INNER JOIN [dbo].[SWIFT_ENTERPRISE] [E] ON (
		[E].[CODE_ENTERPRISE] = [U].[ENTERPRISE]
	)
	WHERE [U].[RELATED_SELLER] = @AUTH_ASSIGNED_TO;
END
