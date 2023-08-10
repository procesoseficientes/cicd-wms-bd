-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/27/2016 @ A-TEAM Sprint 
-- Description:			Inserta en la tabla SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_WAREHOUSE_X_DISTRIBUTION_CENTER]
					@DISTRIBUTION_CENTER_ID = 1
					,@CODE_WAREHOUSE = 'BODEGA_CENTRAL'
				-- 
				SELECT * FROM [SONDA].[] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_WAREHOUSE_X_DISTRIBUTION_CENTER](
	@DISTRIBUTION_CENTER_ID INT
	,@CODE_WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER]
				(
					[DISTRIBUTION_CENTER_ID]
					,[CODE_WAREHOUSE]
				)
		VALUES
				(
					@DISTRIBUTION_CENTER_ID  -- DISTRIBUTION_CENTER_ID - int
					,@CODE_WAREHOUSE  -- CODE_WAREHOUSE - varchar(50)
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al ingresar datos a la tabla SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
