

-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	10-11-2016 @ Team-A Sprint 4
-- Description:			Obtiene el LOGIN por Codigo de Ruta

/*
-- Ejemplo de Ejecucion:
	SELECT [SONDA].[SWIFT_FN_GET_LOGIN_BY_ROUTE] ('RUDI@SONDA') AS VALUE
*/
-- =============================================
CREATE FUNCTION [SONDA].SWIFT_FN_GET_LOGIN_BY_ROUTE (
  @CODEROUTE VARCHAR(50)
  )
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @VALUE VARCHAR(50)
  --
  SELECT
    @VALUE = U.LOGIN
  FROM [SONDA].USERS AS U
  WHERE U.SELLER_ROUTE = @CODEROUTE
  --
  RETURN @VALUE
END
