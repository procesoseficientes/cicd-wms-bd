-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:    Modifica un registro de la tabla [SWIFT_CUSTOMER_CHANGE] si es nuevo aceptado o rechazado y quien lo modifico y la fecha

-- Modificacion 10-May-17 @ A-Team Sprint Issa
					-- alberto.ruiz
					-- Se agrega validacion de envio de etiquetas

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_UPDATE_STATUS_CUSTOMER_CHANGE]
		 @CUSTOMER = '3874'
		,@STATUS = 'ACCEPTED'  --REJECTED, ACCEPTED, NEW
		,@LOGIN = 'gerente@SONDA'
*/
-- =========================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_STATUS_CUSTOMER_CHANGE] (
	@CUSTOMER VARCHAR(50)
	,@STATUS VARCHAR(50)
	,@LOGIN VARCHAR(50)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SEND_TAGS_TO_ERP VARCHAR(10) = '0'
	--
	BEGIN TRY
		SELECT @SEND_TAGS_TO_ERP = [SONDA].[SWIFT_FN_GET_PARAMETER]('CUSTOMER_CHANGE','SEND_TAGS_TO_ERP')
		
		-- ------------------------------------------------------------------------------------
		-- Valida si tiene que enviar las etiquetas
		-- ------------------------------------------------------------------------------------
		IF @STATUS = 'ACCEPTED' AND @SEND_TAGS_TO_ERP = '1'
		BEGIN
			DECLARE @MESSAGE VARCHAR(MAX) = ''
			--
			SELECT @MESSAGE = @MESSAGE + ('La etiqueta ' + [T].[TAG_VALUE_TEXT] + ' no tiene asignado el campo correspondiente del ERP. ')
			FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE] [TCC]
			INNER JOIN [SONDA].[SWIFT_TAGS] [T] ON ([T].[TAG_COLOR] = [TCC].[TAG_COLOR])
			WHERE [TCC].[CUSTOMER] = @CUSTOMER
				AND [T].[QRY_GROUP] IS NULL
			--
			PRINT '--> @MESSAGE: ' + @MESSAGE
			--
			IF @MESSAGE != ''
			BEGIN
				RAISERROR(@MESSAGE,16,1)
			END
		END

		-- ------------------------------------------------------------------------------------
		-- Actualiza el cliente
		-- ------------------------------------------------------------------------------------
		UPDATE [SONDA].[SWIFT_CUSTOMER_CHANGE]
		SET STATUS = @STATUS
			,STATUS_CHANGE_BY = @LOGIN
			,STATUS_CHANGE_DATETIME = GETDATE()			
		WHERE CUSTOMER = @CUSTOMER 
		--
		SELECT
			1 AS Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,'0' DbData
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS Resultado
			,ERROR_MESSAGE() Mensaje
			,@@ERROR Codigo 
	END CATCH
END
