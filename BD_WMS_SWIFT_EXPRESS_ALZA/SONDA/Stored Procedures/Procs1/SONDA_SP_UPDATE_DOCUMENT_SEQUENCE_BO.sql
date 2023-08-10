-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-02-2016
-- Description:			Actualiza el numero actual de un documento para el BO ya que retorna el objeto operacion

/*
-- Ejemplo de Ejecucion:
				DECLARE 
					@DOC_TYPE VARCHAR(50) = 'SALES_ORDER'
					,@SERIE VARCHAR(100) = 'C'
					,@DOC_NUM INT = 2
				--
				SELECT D.DOC_TYPE,D.SERIE,D.CURRENT_DOC FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] D WHERE DOC_TYPE = @DOC_TYPE AND SERIE = @SERIE
				--
				EXEC [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCE_BO]
					@DOC_TYPE = @DOC_TYPE
					,@SERIE = @SERIE
					,@DOC_NUM = @DOC_NUM
				--
				SELECT D.DOC_TYPE,D.SERIE,D.CURRENT_DOC FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] D WHERE DOC_TYPE = @DOC_TYPE AND SERIE = @SERIE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCE_BO]
(	
	@DOC_TYPE VARCHAR(50)
	,@DOC_SERIE VARCHAR(100)
	,@DOC_NUM INT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE [SONDA].[SWIFT_DOCUMENT_SEQUENCE]
		SET CURRENT_DOC = @DOC_NUM
		WHERE DOC_TYPE = @DOC_TYPE
			AND SERIE = @DOC_SERIE
		--
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

END
