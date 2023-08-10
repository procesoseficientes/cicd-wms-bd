
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		21-06-2016
-- Description:			    SP que actuliza las columnas de departamento, municipio y colonia

/*
-- Ejemplo de Ejecucion:
				--
				SELECT * FROM [SONDA].[SWIFT_CUSTOMERS_NEW] WHERE CODE_CUSTOMER = '172'
				--
				EXEC [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER_NEW]
					@CODE_CUSTOMER = '172'
					,@DEPARTAMENT = 'guatemala'
					,@MUNICIPALITY = 'mixco'
					,@COLONY = 'CONDADO naranjo'
				--
				SELECT * FROM [SONDA].[SWIFT_CUSTOMERS_NEW] WHERE CODE_CUSTOMER = '172'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER_NEW] (
	@CODE_CUSTOMER VARCHAR(50)
	,@DEPARTAMENT VARCHAR(250)
	,@MUNICIPALITY VARCHAR(250)
	,@COLONY VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
	SET DEPARTAMENT = UPPER(@DEPARTAMENT)
		,MUNICIPALITY = UPPER(@MUNICIPALITY)
		,COLONY = UPPER(@COLONY)
	WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
END
