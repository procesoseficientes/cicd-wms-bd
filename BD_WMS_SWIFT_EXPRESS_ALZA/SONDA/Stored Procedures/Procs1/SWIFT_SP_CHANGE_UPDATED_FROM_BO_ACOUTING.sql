
/* =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	05-07-2016 Sprint ζ 
-- Description: Actualiza la columna UPDATED_FROM_BO

-- Ejemplo de Ejecucion:
		exec [SONDA].[SWIFT_SP_CHANGE_UPDATED_FROM_BO_ACOUTING]
			@CODE_CUSTOMER = 3145
			,@COMMENTS = 'PRUEBA DE ACTUALIZACION DE COLUMNA UPDATED_FROM_BO'
			,@LOGIN = 'GERENTE@SONDA'
-- =============================================*/

CREATE PROCEDURE [SONDA].[SWIFT_SP_CHANGE_UPDATED_FROM_BO_ACOUTING]
(
	@CODE_CUSTOMER INT
	,@COMMENTS VARCHAR(250)
	,@LOGIN VARCHAR(250)
) AS
BEGIN
	--
	BEGIN TRY
		--
		UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
		SET 
			[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LOGIN
			,[COMMENTS] = @COMMENTS
			,[UPDATED_FROM_BO] = 1
		WHERE [CUSTOMER] = @CODE_CUSTOMER
		--
		IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje , 0 Codigo
		END		
		ELSE BEGIN		
			SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
		END
		--
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
	END CATCH
END
