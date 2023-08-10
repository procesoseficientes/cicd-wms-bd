-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que obtiene todos los cliente de un canal

-- Modificacion 30-May-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Se agregan campos de login y nombre de usuario

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_CUSTOMER_ASSOCIATED_BY_CHANNEL
					@CHANNEL_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CUSTOMER_ASSOCIATED_BY_CHANNEL(
	@CHANNEL_ID INT
)
AS
BEGIN
	SELECT
		[VC].[CODE_CUSTOMER]
		,[VC].[NAME_CUSTOMER]
		,[VC].[ADRESS_CUSTOMER]
		,[VC].[SELLER_DEFAULT_CODE]
		,ISNULL([S].[SELLER_NAME], 'Sin vendedor asociado') [SELLER_NAME]
		,ISNULL([U].[LOGIN], 'Sin Usuario') [LOGIN]
		,ISNULL([U].[NAME_USER], 'Sin Usuario') [NAME_USER]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VC]
	INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC] ON ([VC].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER])
	LEFT JOIN [SONDA].[SWIFT_SELLER] [S] ON ([S].[SELLER_CODE] = [VC].[SELLER_DEFAULT_CODE])
	LEFT JOIN [SONDA].[USERS] [U] ON ([VC].[SELLER_DEFAULT_CODE] = [U].[RELATED_SELLER])
	WHERE [CC].[CHANNEL_ID] = @CHANNEL_ID;
END
