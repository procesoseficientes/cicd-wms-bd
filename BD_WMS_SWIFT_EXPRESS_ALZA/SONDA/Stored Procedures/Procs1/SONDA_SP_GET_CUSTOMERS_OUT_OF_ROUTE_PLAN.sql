-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	27-Jan-17 @ A-TEAM Sprint Bankole
-- Description:			SP para la busqueda de clientes fuera del plan de ruta de sonda pos

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_CUSTOMERS_OUT_OF_ROUTE_PLAN]
					@CODE_ROUTE = '4'
					,@FILTER = 'TIENDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_CUSTOMERS_OUT_OF_ROUTE_PLAN](
	@CODE_ROUTE VARCHAR(50)
	,@FILTER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SELLER_CODE VARCHAR(50)
	--
	SELECT @SELLER_CODE = U.[RELATED_SELLER]
	FROM [SONDA].[USERS] [U]
	WHERE [U].[SELLER_ROUTE] = @CODE_ROUTE
	--
	SELECT TOP 30
		[C].[CODE_CUSTOMER]
		,[C].[NAME_CUSTOMER]
		,[C].[PHONE_CUSTOMER]
		,[C].[ADRESS_CUSTOMER]
		,[C].[CONTACT_CUSTOMER]
		,[C].[TAX_ID_NUMBER] [NIT]
		,[C].[RGA_CODE]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	--LEFT JOIN [SONDA].[SONDA_ROUTE_PLAN] [R] ON (
	--	[C].[CODE_CUSTOMER] = [R].[RELATED_CLIENT_CODE]
	--	AND [R].[CODE_ROUTE] = @CODE_ROUTE
	--)
	WHERE --[C].[SELLER_DEFAULT_CODE] = @SELLER_CODE		AND
	--	 [R].[TASK_SEQ] IS NULL
		--AND (
			[C].[CODE_CUSTOMER] LIKE '%' + @FILTER + '%'
			OR [C].[NAME_CUSTOMER] LIKE '%' + @FILTER + '%'
			OR [C].[TAX_ID_NUMBER] LIKE '%' + @FILTER + '%'
			OR [C].[RGA_CODE] LIKE '%' + @FILTER + '%'
		--)
END
