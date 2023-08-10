-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-May-17 @ A-Team Sprint Issa
-- Description:			    SP para obtener los clientes viejos para el geocoding

-- Modificacion 6/1/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrego columna TYPE_CUSTOMER
/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_TO_GEOCODING]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_TO_GEOCODING]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT TOP 10
		[C].[CODE_CUSTOMER]
		,[C].[GPS]
		,[C].[LATITUDE]
		,[C].[LONGITUDE]
		,'EXISTING_CUSTOMER' [TYPE_CUSTOMER]
	FROM [SONDA].[SWIFT_ERP_CUSTOMERS] [C]
	WHERE [C].[DEPARTAMENT] = 'NO ESPECIFICADO'
		AND [C].[GPS] != '0,0'
	ORDER BY [C].[CODE_CUSTOMER]
END
