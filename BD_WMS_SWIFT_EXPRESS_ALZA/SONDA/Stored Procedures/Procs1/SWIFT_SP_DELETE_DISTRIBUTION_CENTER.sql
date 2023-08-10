-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		11-07-2016 @ Sprint  ζ
-- Description:			    SP que elimina el centro de distibucion

-- Modificacion: 13-07-2016 @ Sprint  ζ
--			Autor: diego.as
--			Descripcion: Se cambio a VARCHAR el parametro DbData debido a problemas al momento de implementar el SP en el Servicio del BO

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_DELETE_DISTRIBUTION_CENTER]
			@DISTRIBUTION_CENTER_ID = 2
		--
		SELECT * FROM [SONDA].[SWIFT_DISTRIBUTION_CENTER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_DISTRIBUTION_CENTER] (
	@DISTRIBUTION_CENTER_ID INT
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		--
		DELETE FROM [SONDA].[SWIFT_DISTRIBUTION_CENTER]
		WHERE [DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID
		--
		IF @@error = 0 
		BEGIN		
			SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
		END		
		ELSE BEGIN		
			SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
		END
	END TRY
	BEGIN CATCH     
		 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
	END CATCH
END
