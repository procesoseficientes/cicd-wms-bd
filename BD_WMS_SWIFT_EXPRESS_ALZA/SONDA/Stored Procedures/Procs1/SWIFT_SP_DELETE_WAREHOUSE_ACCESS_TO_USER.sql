-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/29/2016 @ A-TEAM Sprint  
-- Description:			SP que borra un registro de la tabla SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_WAREHOUSE_ACCESS_TO_USER]
					@USER_CORRELATIVE = 1
					, @CODE_WAREHOUSE = 'BODEGA_CENTRAL'
				-- 
				SELECT * FROM [SONDA].SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_WAREHOUSE_ACCESS_TO_USER](
		@USER_CORRELATIVE INT
	,@CODE_WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS]
		WHERE [USER_CORRELATIVE] = @USER_CORRELATIVE AND [CODE_WAREHOUSE] = @CODE_WAREHOUSE
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
