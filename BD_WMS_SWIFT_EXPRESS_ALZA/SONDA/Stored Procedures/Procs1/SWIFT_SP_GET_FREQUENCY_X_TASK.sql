-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-11-2015
-- Description:			Obtiene las frecuencias que corresponden a una fecha

--Modificacion 30-11-2015
				-- Se agrege se definiera el lenguaje
/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SWIFT_SP_GET_FREQUENCY_X_TASK @DATE = '20151111'
				--
				exec [SONDA].SWIFT_SP_GET_FREQUENCY_X_TASK @DATE = '20151111', @CODE_FREQUENCY = '00111101SALE001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_FREQUENCY_X_TASK]
	@DATE DATETIME
	,@CODE_FREQUENCY VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--
	SET LANGUAGE us_english
	--
	DECLARE 
		@query nvarchar(1000) = N'SELECT F.ID_FREQUENCY FROM [SONDA].SWIFT_FREQUENCY F'
		,@dia int = (select datepart(dw,@DATE))
	--
	SELECT @query = @query + CASE 
								WHEN @CODE_FREQUENCY IS NOT NULL THEN ' INNER JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] X ON (F.ID_FREQUENCY = X.ID_FREQUENCY)' 
								ELSE ''
							END
	--
	SELECT @query = @query 
			+ ' WHERE '
			+ CASE 
				WHEN @CODE_FREQUENCY IS NOT NULL THEN 'F.CODE_FREQUENCY = ''' + @CODE_FREQUENCY +''' AND '
				ELSE ''
				END
			+ CASE @dia
				WHEN 1 THEN 'SUNDAY = 1'
				WHEN 2 THEN 'MONDAY = 1'
				WHEN 3 THEN 'TUESDAY = 1'
				WHEN 4 THEN 'WEDNESDAY = 1'
				WHEN 5 THEN 'THURSDAY = 1'
				WHEN 6 THEN 'FRIDAY = 1'
				WHEN 7 THEN 'SATURDAY = 1'
			END
	--
	print '@query: ' + @query
	--
	EXECUTE sp_executesql @query
END
