-- =============================================
-- Autor:               rudi.garcia 
-- Fecha de Creacion:   22-Jan-2019 G-Force@Quetal
-- Description:         SP que inserta un piloto desde el HH

-- Modificacion:        henry.rodriguez
-- Fecha:   			06-Agosto-2019 G-Force@Estambul
-- Description:         Se obtiene el codigo del piloto si ya existe.

/*
	EXECUTE [wms].[OP_WMS_INSERT_PILOT_FROM_DISPATCH_LICENCE] @NAME_PILOT = 'Rudi', @LAST_NAME = 'Garcia'                                                    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_PILOT_FROM_DISPATCH_LICENCE] (
		@NAME_PILOT VARCHAR(25)
		,@LAST_NAME VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@CODE_PILOT INT;

	BEGIN TRY;

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_PILOT] [P]
					WHERE
						[P].[NAME] = @NAME_PILOT
						AND [P].[LAST_NAME] = @LAST_NAME )
		BEGIN
			SELECT TOP 1
				@CODE_PILOT = [P].[PILOT_CODE]
			FROM
				[wms].[OP_WMS_PILOT] [P]
			WHERE
				[P].[NAME] = @NAME_PILOT
				AND [P].[LAST_NAME] = @LAST_NAME;
		END;
		ELSE
		BEGIN
			INSERT	[wms].[OP_WMS_PILOT]
					(
						[NAME]
						,[LAST_NAME]
						,[IDENTIFICATION_DOCUMENT_NUMBER]
						,[LICENSE_NUMBER]
						,[LICESE_TYPE]
						,[LICENSE_EXPIRATION_DATE]
					 )
			VALUES
					(
						@NAME_PILOT
						,@LAST_NAME
						,''
						,''
						,''
						,GETDATE()
					);

			SET @CODE_PILOT = SCOPE_IDENTITY();
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@CODE_PILOT AS VARCHAR(20)) [DbData];
	END TRY
	BEGIN CATCH

		DECLARE	@message VARCHAR(1000) = @@ERROR;
		PRINT @message;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];

		RAISERROR (@message, 16, 1);

	END CATCH;
END;