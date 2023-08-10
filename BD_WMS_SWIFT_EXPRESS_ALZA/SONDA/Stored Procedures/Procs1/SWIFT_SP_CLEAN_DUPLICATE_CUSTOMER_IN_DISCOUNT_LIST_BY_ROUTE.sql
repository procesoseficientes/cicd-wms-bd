-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de descuentos por acuerdo comercial de clientes

-- Modificacion 26-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se cambio la tabla #CUSTOMER por @CUSTOMER

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_DISCOUNT_LIST_BY_ROUTE]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_DISCOUNT_LIST_BY_ROUTE] (
	@CODE_ROUTE VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
	-- Obtiene valores iniciales
	-- ------------------------------------------------------------------------------------
	DECLARE @CUSTOMER TABLE (
		[CODE_CUSTOMER] VARCHAR(50) NOT NULL
		,UNIQUE([CODE_CUSTOMER])
	)
	--
	DECLARE @SELLER_CODE nVARCHAR(155)
	--
	SELECT @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes a eliminar
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CUSTOMER ([CODE_CUSTOMER])
	SELECT [DLC].[CODE_CUSTOMER]
	FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] [DLC]
	INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL] ON (
		[DL].[DISCOUNT_LIST_ID] = [DLC].[DISCOUNT_LIST_ID]
	)
	WHERE [DL].[CODE_ROUTE] = @CODE_ROUTE
	GROUP BY [DLC].[CODE_CUSTOMER]
	HAVING COUNT([DLC].[CODE_CUSTOMER]) > 1

	-- ------------------------------------------------------------------------------------
	-- Elimina los clientes repetidos
	-- ------------------------------------------------------------------------------------
	DELETE [DLC]
	FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] [DLC]
	INNER JOIN @CUSTOMER [C] ON (
		[DLC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
END
