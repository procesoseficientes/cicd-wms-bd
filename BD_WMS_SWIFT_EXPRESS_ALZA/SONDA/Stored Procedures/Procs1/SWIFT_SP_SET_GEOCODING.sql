-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-May-17 @ A-TEAM Sprint Issa 
-- Description:			SP que actualiza los clientes despues del geocoding

-- Modificacion 6/1/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrego el parametro TYPE_CUSTOMER, y valida si el tipo es SCOUTING o CUSTOMER_CHANGE para enviar el geocoding
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_SET_GEOCODING]
					@IS_FOR_SCOUTING = 1
					,@CODE_CUSTOMER = '172'
					,@DEPARTAMENT = 'guatemala'
					,@MUNICIPALITY = 'mixco'
					,@COLONY = 'CONDADO naranjo'
				--
				EXEC [SONDA].[SWIFT_SP_SET_GEOCODING]
					@IS_FOR_SCOUTING = 0
					,@CODE_CUSTOMER = '172'
					,@DEPARTAMENT = 'guatemala'
					,@MUNICIPALITY = 'mixco'
					,@COLONY = 'CONDADO naranjo'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_GEOCODING](
	@IS_FOR_SCOUTING INT
	,@CODE_CUSTOMER VARCHAR(50)
	,@DEPARTAMENT VARCHAR(250)
	,@MUNICIPALITY VARCHAR(250)
	,@COLONY VARCHAR(250)
	,@TYPE_CUSTOMER VARCHAR(50) = NULL	
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF @IS_FOR_SCOUTING = 1
	BEGIN
		IF @TYPE_CUSTOMER = 'SCOUTING'
		BEGIN
			EXEC [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER_NEW] 
				@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
				@DEPARTAMENT = @DEPARTAMENT, -- varchar(250)
				@MUNICIPALITY = @MUNICIPALITY, -- varchar(250)
				@COLONY = @COLONY -- varchar(250)
		END
		ELSE IF @TYPE_CUSTOMER = 'CUSTOMER_CHANGE'
		BEGIN
			EXEC [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER_CHANGE] 
				@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
				@DEPARTMENT = @DEPARTAMENT, -- varchar(250)
				@MUNICIPALITY = @MUNICIPALITY, -- varchar(250)
				@COLONY = @COLONY -- varchar(250)
			
		END
	END
	ELSE
	BEGIN
		EXEC [SONDA].[SWIFT_SP_SET_GEOCODING_TO_CUSTOMER] 
			@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
			@DEPARTAMENT = @DEPARTAMENT, -- varchar(250)
			@MUNICIPALITY = @MUNICIPALITY, -- varchar(250)
			@COLONY = @COLONY -- varchar(250)
	END
END
