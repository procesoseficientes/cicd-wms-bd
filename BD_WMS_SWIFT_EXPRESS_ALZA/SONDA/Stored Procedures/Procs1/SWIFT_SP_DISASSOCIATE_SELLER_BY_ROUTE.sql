-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	26-Dec-16 @ A-TEAM Sprint Balder
-- Description:			Eliminar el Vendedor de la Tabla [SWIFT_ROUTES] y lo deja en NULL con parametro @SELLER_CODE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_DISASSOCIATE_SELLER_BY_ROUTE]
					@SELLER_CODE = '1'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DISASSOCIATE_SELLER_BY_ROUTE](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_ROUTES]
		SET	
			[SELLER_CODE] = NULL
		WHERE 
			[CODE_ROUTE] = @CODE_ROUTE
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error: La ruta no tiene vendedor asignado'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
