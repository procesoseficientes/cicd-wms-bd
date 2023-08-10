-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		21-06-2016
-- Description:			    SP que obtiene los primeros 10 scoutings para 

-- Modificacion 5/31/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrego origen de la data.
/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_NEW_TO_GEOCODING]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_NEW_TO_GEOCODING]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT TOP 10
		[C].[CODE_CUSTOMER]
		,[C].[GPS]
		,[C].[LATITUDE]
		,[C].[LONGITUDE]
		,'SCOUTING' AS [TYPE_CUSTOMER]
	FROM [SONDA].[SWIFT_CUSTOMERS_NEW] [C]
	WHERE [C].[DEPARTAMENT] = 'NO ESPECIFICADO'
		AND [C].[GPS] != '0,0'
	ORDER BY [C].[CUSTOMER]
END
