-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/2/2017 @ A-TEAM Sprint Balder 
-- Description:			SP que borra de ambas tablas de usuario utilizando @LOGIN

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[USERS]
				SELECT * FROM [dbo].[SWIFT_USER]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_USER]
					@LOGIN = 'oper31@SONDA'
				-- 
				SELECT * FROM [SONDA].[USERS]
				SELECT * FROM [dbo].[SWIFT_USER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_USER](
	@LOGIN VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY

    --
    DECLARE @CORRELATIVE INT
	  --
	  SELECT @CORRELATIVE = CORRELATIVE FROM [SONDA].[USERS] WHERE [LOGIN] = @LOGIN

		DELETE [SONDA].SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS 
    WHERE USER_CORRELATIVE = @CORRELATIVE  

    DELETE FROM [SONDA].[USERS]
		WHERE
			@LOGIN = [LOGIN]

		DELETE FROM [dbo].[SWIFT_USER]
		WHERE 
			@LOGIN = [LOGIN]

    

		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
