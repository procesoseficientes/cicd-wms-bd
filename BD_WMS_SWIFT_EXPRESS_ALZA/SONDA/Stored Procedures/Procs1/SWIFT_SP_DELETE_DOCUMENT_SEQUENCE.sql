
-- =============================================
-- Autor:				PEDRO LOUKOTA
-- Fecha de Creacion: 	07-12-2015
-- Description:			Elimina la secuencia de documentos
--                      
/*
-- Ejemplo de Ejecucion:				


		EXECUTE  [SONDA].[SWIFT_SP_DELETE_DOCUMENT_SEQUENCE]
			@ID_DOCUMENT_SECUENCE= ''

				--				
*/
-- =============================================


CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_DOCUMENT_SEQUENCE]
	@ID_DOCUMENT_SECUENCE varchar(50)
AS
BEGIN TRY
		
		DELETE FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE]
		WHERE ID_DOCUMENT_SECUENCE = @ID_DOCUMENT_SECUENCE		
			
	IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
