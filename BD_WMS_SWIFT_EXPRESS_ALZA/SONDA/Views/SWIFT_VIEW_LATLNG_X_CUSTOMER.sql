
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-01-2016
-- Description:			Obtiene datos del cliente y la posicion

/*
-- Ejemplo de Ejecucion:
				--
				SELECT * FROM [SONDA].[SWIFT_VIEW_LATLNG_X_CUSTOMER]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_LATLNG_X_CUSTOMER]
AS
	SELECT 
		 C.[CODE_CUSTOMER]
		,C.[NAME_CUSTOMER]
		,C.[SCOUTING_ROUTE]
		,C.[FREQUENCY]
		,C.[SUNDAY]
		,C.[MONDAY]
		,C.[TUESDAY]
		,C.[WEDNESDAY]
		,C.[THURSDAY]
		,C.[FRIDAY]
		,C.[SATURDAY]
		,C.[LONGITUDE]
		,C.[LATITUDE]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS C
