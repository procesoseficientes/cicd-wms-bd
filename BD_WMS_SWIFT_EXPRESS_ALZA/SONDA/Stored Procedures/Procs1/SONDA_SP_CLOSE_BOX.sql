-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	27-Oct-16 @ A-TEAM Sprint 4
-- Description:			SP que obtiene la ruta del usuario para marcarla con cerrada

-- Modificacion 17-Nov-16 @ A-Team Sprint 5
					-- alberto.ruiz
					-- Se cambio para que no llame al SP SONDA_UPDATE_ACTIVE_ROUTE y que ahora llame al SP SONDA_SP_SET_LIQUIDATION_TO_ACTIVE_ROUTE

-- Modificacion 1/19/2018 @ Reborn-Team Sprint Strom
					-- diego.as
					-- Se agrega validacion de identificador de dispositivo
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_CLOSE_BOX]
					@LOGIN = 'RUDI@SONDA'
					,@DEVICE_ID = '3b396881f40a8de3'
				--
				SELECT * FROM [SONDA].[SONDA_LIQUIDATION]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_CLOSE_BOX](
	@LOGIN VARCHAR(50)
	,@DEVICE_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @CODE_ROUTE VARCHAR(50)
		--
		SELECT @CODE_ROUTE = [U].[SELLER_ROUTE]
		FROM [SONDA].[USERS] [U]
		WHERE [U].[LOGIN] = @LOGIN

		-- ----------------------------------------------------------------
		-- Se valida identificador de dispositivo
		-- ----------------------------------------------------------------
		EXEC [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION] @CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
			@DEVICE_ID = @DEVICE_ID -- varchar(50)
		

		--
		EXEC [SONDA].[SONDA_SP_SET_LIQUIDATION_TO_ACTIVE_ROUTE] 
			@CODE_ROUTE = @CODE_ROUTE
			,@LOGIN = @LOGIN
	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(MAX);
		SET @ERROR = ERROR_MESSAGE()
		RAISERROR(@ERROR,16,1);
	END CATCH

END
