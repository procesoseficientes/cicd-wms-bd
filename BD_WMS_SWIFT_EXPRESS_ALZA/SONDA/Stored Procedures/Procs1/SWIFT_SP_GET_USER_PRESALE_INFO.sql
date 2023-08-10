-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-04-2016
-- Description:			Busca los clientes que sea similar el codigo de cliente o nombre

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_USER_PRESALE_INFO]
			@LOGIN = 'gerente@SONDA'

*/		
-- =============================================
CREATE  PROCEDURE [SONDA].SWIFT_SP_GET_USER_PRESALE_INFO
		@LOGIN VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos de los clientes 
	-- ------------------------------------------------------------------------------------
	SELECT
		[U].[CORRELATIVE]
		,[U].[LOGIN]
		,[U].[NAME_USER]
		,[U].[TYPE_USER]
		,[U].[PASSWORD]
		,[U].[ENTERPRISE]
		,[U].[IMAGE]
		,[U].[RELATED_SELLER]
		,[U].[SELLER_ROUTE]
		,[U].[USER_TYPE]
		,[U].[DEFAULT_WAREHOUSE]
		,[U].[USER_ROLE]
		,[U].[PRESALE_WAREHOUSE]
		,[U].[ROUTE_RETURN_WAREHOUSE]
		,[D].[SERIE] AS [DOC_SERIE]
		,[D].[CURRENT_DOC] AS [DOC_NUM]
		,([D].[DOC_TO] - [D].[CURRENT_DOC]) [DOC_LEFT]
		,CASE
			WHEN ((CONVERT(NUMERIC(18,6),[SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER', 'DOC_SEQUENCE_ALERT')) * [D].[DOC_TO]) / 100) >= ([D].[DOC_TO] - [D].[CURRENT_DOC])
				THEN 1
			ELSE 0
		END [HAVE_ALERT]
	FROM [SONDA].[USERS] [U]
	LEFT JOIN [SONDA].[SWIFT_DOCUMENT_SEQUENCE] [D] ON (
		[D].[ASSIGNED_TO] = [U].[SELLER_ROUTE] AND [D].[DOC_TYPE] = 'SALES_ORDER'
	)
	WHERE [U].[LOGIN] = @LOGIN
		
END
