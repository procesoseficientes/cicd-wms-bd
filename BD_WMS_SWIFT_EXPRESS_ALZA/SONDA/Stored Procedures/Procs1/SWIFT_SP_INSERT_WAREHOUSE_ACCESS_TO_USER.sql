-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/29/2016 @ A-TEAM Sprint Balder
-- Description:			Inserta una relacion entre el usuario y la bodega

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_WAREHOUSE_ACCESS_TO_USER]
					@USER_CORRELATIVE = 1
					, @CODE_WAREHOUSE = 'BODEGA_CENTRAL'
				-- 
				SELECT * FROM [SONDA].[SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_WAREHOUSE_ACCESS_TO_USER](
	@USER_CORRELATIVE INT
	,@CODE_WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS]
				(
					[USER_CORRELATIVE]
					,[CODE_WAREHOUSE]
				)
		VALUES
				(
					@USER_CORRELATIVE  -- USER_CORRELATIVE - int
					,@CODE_WAREHOUSE -- CODE_WAREHOUSE - varchar(50)
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al insertar a la tabla SWIFT_WAREHOUSE_BY_USER_WITH_ACCESS'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
