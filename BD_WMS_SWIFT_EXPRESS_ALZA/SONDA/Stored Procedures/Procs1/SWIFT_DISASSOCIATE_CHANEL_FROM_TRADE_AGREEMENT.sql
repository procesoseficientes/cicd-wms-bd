
/* ==============================================

Autor:				diego.as
Fecha de Creacion:  14-09-2016 @ TEAM-A Sprint 1
Descripcion:		Elimina el registro de un canal asociado a un acuerdo comercial

Ejemplo de Ejecucion:

	EXEC [SONDA].[SWIFT_DISASSOCIATE_CHANEL_FROM_TRADE_AGREEMENT]
		@CHANNEL_ID = 14
=================================================*/

CREATE PROCEDURE [SONDA].[SWIFT_DISASSOCIATE_CHANEL_FROM_TRADE_AGREEMENT]
(
	@CHANNEL_ID INT
) AS
BEGIN
	--
	SET NOCOUNT ON;
	
	--
	BEGIN TRY
		--
		DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL]
		WHERE [CHANNEL_ID] = @CHANNEL_ID

		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
