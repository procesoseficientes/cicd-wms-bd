-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	11/9/2017 @ Reborn-TEAM Sprint Eberhard
-- Description:			SP que obtiene los registros de el historico de posiciones gps de una ruta en especifico

/*
-- Ejemplo de Ejecucion:
		DECLARE @INITIAL_DATE DATETIME = GETDATE() -1
				,@END_DATE DATETIME = GETDATE();

			EXEC [SONDA].[SWIFT_SP_GET_HISTORICAL_GPS_SELLER]
			@CODE_ROUTE = '46'
			,@INIT_DATE = @INITIAL_DATE
			,@END_DATE = @END_DATE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_HISTORICAL_GPS_SELLER](
	@CODE_ROUTE VARCHAR(50)
	,@INIT_DATE DATETIME
	,@END_DATE DATETIME
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT TOP 100
		[HISTORICAL_ID]
		,[CODE_ROUTE]
		,[GPS]
		,[LONGITUDE]
		,[LATITUDE]
		,[POSTED_DATE]
		,[WEEK_NUMBER]
		,[DAY_NUMBER]
		,[MONTH_NUMBER]
		,[YEAR_NUMBER] 
	FROM [SONDA].[SONDA_HISTORICAL_GPS_SELLER]
	WHERE [CODE_ROUTE] = @CODE_ROUTE
	AND [POSTED_DATE] BETWEEN @INIT_DATE AND @END_DATE
	ORDER BY [POSTED_DATE] ASC
END
