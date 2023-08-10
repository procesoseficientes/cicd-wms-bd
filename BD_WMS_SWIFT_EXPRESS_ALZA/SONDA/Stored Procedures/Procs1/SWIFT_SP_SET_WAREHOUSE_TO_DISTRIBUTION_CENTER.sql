-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/28/2016 @ A-TEAM Sprint Balder
-- Description:			SP que actualiza 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[]
					@DISTRIBUTION_CENTER_ID = 1
					,@CODE_WAREHOUSE = 'BODEGA_CENTRAL'
				-- 
				SELECT * FROM SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_WAREHOUSE_TO_DISTRIBUTION_CENTER](
	@DISTRIBUTION_CENTER_ID INT
	,@CODE_WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER 
		WHERE @CODE_WAREHOUSE = [CODE_WAREHOUSE]
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH

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
			WHEN '2627' THEN 'Error al insertar datos a la tabla SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH

END
