-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		3/17/2017 @ A-Team Sprint Ebonne
-- Description:			    Obtiene el device id asociado al usuario

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_GET_DEVICE_ID]('rudi@SONDA');
*/
-- =============================================

CREATE FUNCTION [SONDA].[SWIFT_FN_GET_DEVICE_ID]
    (@LOGIN AS VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @DEVICE_ID VARCHAR(50)

	SELECT @DEVICE_ID = [DEVICE_ID] 
	FROM [SONDA].[USERS]
	WHERE [LOGIN] = @LOGIN

    RETURN @DEVICE_ID
END
