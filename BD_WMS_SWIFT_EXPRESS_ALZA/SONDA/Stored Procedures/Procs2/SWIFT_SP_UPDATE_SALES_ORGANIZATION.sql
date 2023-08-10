-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que actualiza la tabla SWIFT_SALES_ORGANIZATION

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SALES_ORGANIZATION]
					@SALES_ORGANIZATION_ID = 1
					, @NAME_SALES_ORGANIZATION = 'Organizacion de Ventas 01'
					, @DESCRIPTION_SALES_ORGANIZATION = 'Organizacion de Ventas 01'
				-- 
				SELECT * FROM [SONDA].SWIFT_SALES_ORGANIZATION
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SALES_ORGANIZATION](
	@SALES_ORGANIZATION_ID INT
	, @NAME_SALES_ORGANIZATION VARCHAR(50)
	, @DESCRIPTION_SALES_ORGANIZATION VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_SALES_ORGANIZATION]
		SET	
			[NAME_SALES_ORGANIZATION] = @NAME_SALES_ORGANIZATION
			, [DESCRIPTION_SALES_ORGANIZATION] = @DESCRIPTION_SALES_ORGANIZATION
		WHERE [SALES_ORGANIZATION_ID] = @SALES_ORGANIZATION_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'El nombre de la organizacion de ventas no se puede repetir.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
