-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/31/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que obtiene los primeros 10 cambios de clientes para geocoding

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_CHANGE_TO_GEOCODING]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP10_CUSTOMERS_CHANGE_TO_GEOCODING]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT TOP 10
		[C].[CODE_CUSTOMER]
		,[C].[GPS]
		,SUBSTRING([C].[GPS], 1,Charindex(',', [C].[GPS])-1) as LOGITUDE
		,SUBSTRING([C].[GPS], Charindex(',', [C].[GPS])+1, LEN([C].[GPS])) as  LATITUDE
		,'CUSTOMER_CHANGE' AS [TYPE_CUSTOMER]
	FROM [SONDA].[SWIFT_CUSTOMER_CHANGE] [C]
	WHERE [C].[DEPARTMENT] = 'NO ESPECIFICADO'
		 AND [C].[GPS] != '0,0'
	ORDER BY [C].[CUSTOMER] DESC	
END
