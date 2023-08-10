-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-11-2015
-- Description:			Actualiza la ultima semana visitada de las frecuencias

--Modificacion 01-12-2015
				-- Se agrege se definiera el lenguaje

--Modificacion rudi.garcia
--Modificacion 24-07-2017
				-- Se remplazo el "-1" en la condicion de where para establecer el menos "FREQUENCY_WEEKS" 

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SONDA_SP_CALCULATE_CURRENT_WEEK_PLAN
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_CALCULATE_CURRENT_WEEK_PLAN]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SET LANGUAGE us_english
	--
	DECLARE @dia int = (select datepart(dw,GETDATE()))
	--
	IF (@dia = 1)
	BEGIN
		UPDATE F
		SET F.LAST_WEEK_VISITED = DATEADD(WEEK,F.FREQUENCY_WEEKS,F.LAST_WEEK_VISITED)
		FROM [SONDA].[SWIFT_FREQUENCY] F
		WHERE LAST_WEEK_VISITED = DATEADD(WEEK,-F.FREQUENCY_WEEKS,CONVERT(DATE,GETDATE()))
				
		UPDATE FC
		SET FC.LAST_WEEK_VISITED = F.[LAST_WEEK_VISITED]
		FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] FC
		INNER JOIN [SONDA].[SWIFT_FREQUENCY] F ON [F].[ID_FREQUENCY] = [FC].[ID_FREQUENCY]
		WHERE [F].[IS_BY_POLIGON]=0 AND [F].[REFERENCE_SOURCE]='BO'
	END
END
