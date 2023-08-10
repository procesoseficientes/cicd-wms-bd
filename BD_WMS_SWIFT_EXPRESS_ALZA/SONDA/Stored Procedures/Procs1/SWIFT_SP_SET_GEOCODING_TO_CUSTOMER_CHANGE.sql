-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/1/2017 @ A-TEAM Sprint Jibade 
-- Description:			Actualiza columna de departamento, municipaldiad y colonia para modificaciones de clientes

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER_CHANGE]
					@CODE_CUSTOMER = 'SO-169001'
					,@DEPARTAMENT = 'guatemala'
					,@MUNICIPALITY = 'mixco'
					,@COLONY = 'CONDADO naranjo
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER_CHANGE](
	@CODE_CUSTOMER VARCHAR(50)
	,@DEPARTMENT VARCHAR(250)
	,@MUNICIPALITY VARCHAR(250)
	,@COLONY VARCHAR(250)	
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	UPDATE [SONDA].[SWIFT_CUSTOMER_CHANGE]
	SET [DEPARTMENT] = UPPER(@DEPARTMENT)
		,MUNICIPALITY = UPPER(@MUNICIPALITY)
		,COLONY = UPPER(@COLONY)
	WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
END
