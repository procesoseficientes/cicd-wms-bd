-- =============================================
-- Autor:				Jose Roberto
-- Fecha de Creacion: 	13-11-2015
-- Description:			ELIMINA LA FRECUENCIA POR CLIENTE

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SWIFT_SP_DELETE_FREQUENCY_BY_CUSTOMERS] @CODE_CUSTOMER = "0001011110001"
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_FREQUENCY_BY_CUSTOMERS]
	@CODE_CUSTOMER VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	--

DELETE FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] 
WHERE [CODE_CUSTOMER]=@CODE_CUSTOMER

END
