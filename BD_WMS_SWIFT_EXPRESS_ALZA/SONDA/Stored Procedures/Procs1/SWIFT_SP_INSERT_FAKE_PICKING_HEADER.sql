
-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	17-Oct-16 @ A-TEAM Sprint 
-- Description:			SP que obtiene el detalle de las consignaciones filtrado por fecha.

/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SWIFT_SP_INSERT_FAKE_PICKING_HEADER] 	@CLASSIFICATION_PICKING = '4'
													,@CODE_CLIENT = '123123'
													,@REFERENCE = '1231231'
													,@STATUS = 'CLOSED'
													,@ERP_REFERENCE = 0
													,@COMMENTS = 'dasdasd'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_FAKE_PICKING_HEADER](
	@CLASSIFICATION_PICKING VARCHAR(50) = '4'
	,@CODE_CLIENT VARCHAR(50)
	,@REFERENCE VARCHAR(50)
	,@STATUS VARCHAR(50)
	,@ERP_REFERENCE VARCHAR(256)
	,@COMMENTS VARCHAR(MAX)
)AS
BEGIN
	BEGIN TRY
		DECLARE	@ID INT;


		INSERT	INTO [SONDA].[SWIFT_PICKING_HEADER]
				(
					[CLASSIFICATION_PICKING]
					,[CODE_CLIENT]
					,[REFERENCE]
					,[STATUS]
					,[ERP_REFERENCE]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[COMMENTS]
				)
		VALUES
				(
					@CLASSIFICATION_PICKING
					,@CODE_CLIENT
					,@REFERENCE
					,@STATUS
					,@ERP_REFERENCE
					,GETDATE()
					,'FAKE_PICKING'
					,@COMMENTS
				); 

		SELECT @ID = SCOPE_IDENTITY();
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CONVERT(VARCHAR(16) ,@ID) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,CONVERT(VARCHAR(16) ,'0') [DbData];
	END CATCH;
END
