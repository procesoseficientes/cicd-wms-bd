-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que inserta una zona 

/*
-- Ejemplo de Ejecucion:
				EXEC  [SONDA].[SWIFT_SP_INSERT_ZONE] @CODE_ZONE = '2', @DESCRIPTION_ZONE = 'Zona 2'
SELECT * FROM [SONDA].[SWIFT_ZONE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_ZONE] (
  @CODE_ZONE VARCHAR(50)
  ,@DESCRIPTION_ZONE VARCHAR(200)
  , @LOGIN VARCHAR(50)
  )
AS
BEGIN
  SET NOCOUNT ON;


	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_ZONE] ([CODE_ZONE], [DESCRIPTION_ZONE], [LAST_UPDATED_BY], [LAST_UPDATE])
  VALUES (@CODE_ZONE, @DESCRIPTION_ZONE, @LOGIN, GETDATE() );

		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe una zona con el mismo codigo de zona'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH

END
