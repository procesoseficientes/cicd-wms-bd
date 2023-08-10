-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	29-Nov-2016 @ A-TEAM Sprint 5
-- Description:			Funcion que obtiene el codigo rga de cliente

/*
-- Ejemplo de Ejecucion:
				-- 
				SELECT [SONDA].SWIFT_FN_GET_RGA_CODE_BY_CUSTOMER('')
*/
-- =============================================
CREATE FUNCTION [SONDA].SWIFT_FN_GET_RGA_CODE_BY_CUSTOMER
(
	@CODE_CUSTOMER VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RGA_CODE VARCHAR(150) = NULL
	--
	SELECT TOP 1 @RGA_CODE = RGA_CODE
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER svac
	WHERE svac.CODE_CUSTOMER = @CODE_CUSTOMER
	--
	RETURN @RGA_CODE

END
