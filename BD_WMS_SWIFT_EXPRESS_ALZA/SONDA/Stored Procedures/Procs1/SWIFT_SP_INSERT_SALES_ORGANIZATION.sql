-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Chatuluka
-- Description:			Insercion a la tabla SWIFT_SALES_ORGANIZATION

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_SALES_ORGANIZATION]
					@NAME_SALES_ORGANIZATION = 'Organizacion de Ventas 1'
					, @DESCRIPTION_SALES_ORGANIZATION = 'Organizacion de Ventas 1'
				-- 
				SELECT * FROM [SONDA].[SWIFT_SALES_ORGANIZATION] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_SALES_ORGANIZATION](
	@NAME_SALES_ORGANIZATION VARCHAR(50)
	,@DESCRIPTION_SALES_ORGANIZATION VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_SALES_ORGANIZATION]
				(
					[NAME_SALES_ORGANIZATION]
					,[DESCRIPTION_SALES_ORGANIZATION]
				)
		VALUES
				(
					@NAME_SALES_ORGANIZATION  -- NAME_SALES_ORGANIZATION - varchar(50)
					,@DESCRIPTION_SALES_ORGANIZATION  -- DESCRIPTION_SALES_ORGANIZATION - varchar(50)
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
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
