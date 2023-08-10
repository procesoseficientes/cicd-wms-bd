-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade
-- Description:			Obtiene una o todos los registros de la tabla SWIFT_PROMO filtrados por PROMO_TYPE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PROMO_TYPE]
					@PROMO_TYPE = 'BONUS_BY_SCALE'
				--
				EXEC [SONDA].[SWIFT_SP_GET_PROMO_TYPE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PROMO_TYPE](
	@PROMO_TYPE VARCHAR(50) = NULL	
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [PROMO_ID]
			,[PROMO_NAME]
			,[PROMO_TYPE] 
	FROM [SONDA].[SWIFT_PROMO] WHERE [PROMO_TYPE] = @PROMO_TYPE OR @PROMO_TYPE IS NULL
END
