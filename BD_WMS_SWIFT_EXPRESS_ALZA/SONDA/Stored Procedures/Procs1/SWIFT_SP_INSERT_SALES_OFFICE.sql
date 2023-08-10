-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Donkor
-- Description:			Agrega una Oficina de Ventas

-- Modificacion 4/4/2017 @ A-Team Sprint Garai
					-- rodrigo.gomez
					-- Se establece el valor de @SALES_ORGANIZATION_ID como NULL

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_SALES_OFFICE]
				@SALES_ORGANIZATION_ID = 1
				,@NAME_SALES_OFFICE = 'PRUEBA OFIVENTAS'
				,@DESCRIPTION_SALES_OFFICE = 'PRUEBA OFIVENTAS'
				-- 
				SELECT * FROM [SONDA].[SWIFT_SALES_OFFICE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_SALES_OFFICE](
	@SALES_ORGANIZATION_ID INT = NULL
	,@NAME_SALES_OFFICE VARCHAR(50)
	,@DESCRIPTION_SALES_OFFICE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_SALES_OFFICE]
				(
					[SALES_ORGANIZATION_ID]
					,[NAME_SALES_OFFICE]
					,[DESCRIPTION_SALES_OFFICE]
					,[SOURCE]
				)
		VALUES
				(
					@SALES_ORGANIZATION_ID
			,@NAME_SALES_OFFICE
			,@DESCRIPTION_SALES_OFFICE
			,'BO'
				) 
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Registro ya existe.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
