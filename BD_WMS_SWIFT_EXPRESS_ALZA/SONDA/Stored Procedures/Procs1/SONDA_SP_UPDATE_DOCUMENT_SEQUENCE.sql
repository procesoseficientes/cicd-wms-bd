-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-02-2016
-- Description:			Actualiza el numero actual de un documento

-- Modificacion 27-06-2016
					-- alberto.ruiz
					-- Se valido que solo se actualizara si es mayor el doc_num

-- Modificacion 05-09-2016
					-- alberto.ruiz
					-- Se comento validacion de que si habia o no actualizado registros porque al usuario le salia como error
/*
-- Ejemplo de Ejecucion:
				DECLARE 
					@DOC_TYPE VARCHAR(50) = 'PAYMENT'
					,@SERIE VARCHAR(100) = 'AAA'
					,@DOC_NUM INT = 1
				--
				SELECT D.DOC_TYPE,D.SERIE,D.CURRENT_DOC FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] D WHERE DOC_TYPE = @DOC_TYPE AND SERIE = @SERIE
				--
				EXEC [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCE]
					@DOC_TYPE = @DOC_TYPE
					,@SERIE = @SERIE
					,@DOC_NUM = @DOC_NUM
				--
				SELECT D.DOC_TYPE,D.SERIE,D.CURRENT_DOC FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] D WHERE DOC_TYPE = @DOC_TYPE AND SERIE = @SERIE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCE]
(	
	@DOC_TYPE VARCHAR(50)
	,@SERIE VARCHAR(100)
	,@DOC_NUM INT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_DOCUMENT_SEQUENCE]
		SET CURRENT_DOC = @DOC_NUM
		WHERE DOC_TYPE = @DOC_TYPE
			AND SERIE = @SERIE
			AND [CURRENT_DOC] < @DOC_NUM

		/*-- ------------------------------------------------------------------------------------
		-- Valida que se actualizara la secuencia de documentos
		-- ------------------------------------------------------------------------------------
		IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('No se actualizo la secuencia de documentos porque no aumento la secuencia',16,1)
		END*/

		-- ------------------------------------------------------------------------------------
		-- Finaliza la tran
		-- ------------------------------------------------------------------------------------
		PRINT 'COMMIT'
		--
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END

