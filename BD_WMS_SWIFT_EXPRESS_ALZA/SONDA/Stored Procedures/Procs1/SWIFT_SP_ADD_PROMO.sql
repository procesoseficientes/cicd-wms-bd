-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade
-- Description:			SP agrega un registro en la tabla SWIFT_PROMO

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	11/08/2017 @ A-TEAM Sprint Bearbeitung
-- Description:			    se cambio el mensaje de error

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_PROMO]
					@PROMO_NAME = 'Promo 001'
					, @PROMO_TYPE = 'BONUS_BY_SCALE'
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_ADD_PROMO(
	@PROMO_NAME VARCHAR(250)
	, @PROMO_TYPE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_PROMO]
				([PROMO_NAME], [PROMO_TYPE])
		VALUES
				(@PROMO_NAME  -- PROMO_NAME - varchar(250)
					, @PROMO_TYPE  -- PROMO_TYPE - varchar(50)
					)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al insertar promocion, ya existe una promoción con el mismo nombre.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
