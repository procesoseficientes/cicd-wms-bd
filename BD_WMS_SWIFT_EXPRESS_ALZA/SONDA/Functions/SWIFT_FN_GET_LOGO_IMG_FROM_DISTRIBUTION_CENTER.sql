-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		13-05-2016
-- Description:			    Obtiene la imagen del centro de distribucion

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_GET_LOGO_IMG_FROM_DISTRIBUTION_CENTER](6)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_LOGO_IMG_FROM_DISTRIBUTION_CENTER]
(
	@DISTRIBUTION_CENTER_ID INT
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @VALUE VARCHAR(MAX)
	--
	SELECT @VALUE = ISNULL([DC].[LOGO_IMG],'')
	FROM [SONDA].[SWIFT_DISTRIBUTION_CENTER] [DC]
	WHERE [DC].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID
	--
	RETURN @VALUE
END
