-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/21/2017 @ A-TEAM Sprint Khalid 
-- Description:			SP que actualiza el estado de un scouting de la tabla SONDA_CUSTOMER_NEW

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SONDA_CUSTOMER_NEW_STATUS]
					@
				-- 
				SELECT * FROM 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SONDA_CUSTOMER_NEW_STATUS](
	@STATUS VARCHAR(20),
	@LOGIN VARCHAR(50),
	@CUSTOMER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @HAS_TAG INT = 0

		SELECT TOP 1 @HAS_TAG = 1
		FROM [SONDA].[SONDA_TAG_X_CUSTOMER_NEW] CN
		WHERE CN.[CUSTOMER_ID] = @CUSTOMER_ID
		IF @HAS_TAG = 0 
		BEGIN
			SELECT  -1 as Resultado , 'El Cliente seleccionado no tiene Etiquetas asignadas, por favor agregue por lo menos una etiqueta.' Mensaje ,  @@ERROR Codigo
		END
		ELSE
		BEGIN
			SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData

			UPDATE [SONDA].[SONDA_CUSTOMER_NEW]
  			SET 
  				[LAST_UPDATE] = GETDATE()
  				,[LAST_UPDATE_BY] = @LOGIN
  				,[STATUS] = @STATUS
				,[UPDATED_FROM_BO] = 1
  			WHERE [CUSTOMER_ID] = @CUSTOMER_ID
			--
  			IF @@error = 0 BEGIN
  				SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
  			END		
  			ELSE BEGIN		
  				SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
  			END
		END
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
