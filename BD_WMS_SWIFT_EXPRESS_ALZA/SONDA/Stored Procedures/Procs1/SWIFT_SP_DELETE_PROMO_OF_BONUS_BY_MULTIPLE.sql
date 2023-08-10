-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/13/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que borra un registro de la tabla SWIFT_PROMO_BONUS_BY_MULTIPLE

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].SWIFT_PROMO_BONUS_BY_MULTIPLE
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_MULTIPLE]
					@PROMO_BONUS_BY_MULTIPLE_ID = 149
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO_BONUS_BY_MULTIPLE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_MULTIPLE](
	@PROMO_BONUS_BY_MULTIPLE_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE]
		WHERE [PROMO_BONUS_BY_MULTIPLE_ID] = @PROMO_BONUS_BY_MULTIPLE_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
