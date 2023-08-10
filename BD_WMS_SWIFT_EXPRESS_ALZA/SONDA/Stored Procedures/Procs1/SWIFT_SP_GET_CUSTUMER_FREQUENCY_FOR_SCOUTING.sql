-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		5/3/2017 @ A-Team Sprint Hondo
-- Description:			    Obtiene las frecuencias de los clientes

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_CUSTUMER_FREQUENCY_FOR_SCOUTING] @CODE_ROUTE = 'GUA0017@ARIUM'
*/
-- =============================================
CREATE PROC [SONDA].[SWIFT_SP_GET_CUSTUMER_FREQUENCY_FOR_SCOUTING]
	@CODE_ROUTE varchar(50)	
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SELLER_CODE VARCHAR(50);
	--
	SELECT @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE);
	--
	SELECT 
		[CODE_FREQUENCY]
		,[CF].[CODE_CUSTOMER]
		,[CF].[SUNDAY]
		,[CF].[MONDAY]
		,[CF].[TUESDAY]
		,[CF].[WEDNESDAY]
		,[CF].[THURSDAY]
		,[CF].[FRIDAY]
		,[CF].[SATURDAY]
		,[CF].[FREQUENCY_WEEKS]		
	FROM [SONDA].[SWIFT_CUSTOMER_FREQUENCY]  [CF]
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VC] ON ([CF].[CODE_CUSTOMER] = [VC].[CODE_CUSTOMER])
	WHERE [VC].[SELLER_DEFAULT_CODE] = @SELLER_CODE;
END
