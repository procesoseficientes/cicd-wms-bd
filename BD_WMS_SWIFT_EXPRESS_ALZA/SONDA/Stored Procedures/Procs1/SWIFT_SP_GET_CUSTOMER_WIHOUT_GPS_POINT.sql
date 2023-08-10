-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	8/22/2017 @ A-TEAM Sprint  
-- Description:			SP que obtiene los clientes con GPS 0,0

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_WIHOUT_GPS_POINT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMER_WIHOUT_GPS_POINT]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT TOP 100 
			CONVERT(INT,[CUSTOMER]) [CUSTOMER]
			,[CODE_CUSTOMER]
			,[NAME_CUSTOMER]
			,[PHONE_CUSTOMER]
			,[ADRESS_CUSTOMER]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS VC
	WHERE VC.[GPS] = '0,0'
	AND VC.[CODE_CUSTOMER] NOT IN(
		SELECT CODE_CUSTOMER FROM [SONDA].[SWIFT_CUSTOMER_CHANGE]
	)
END
