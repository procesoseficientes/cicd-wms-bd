-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	12-09-2016 @ A-TEAM Sprint 1
-- Description:			    SP que actualiza el acuerdo comercial

-- Modificacion 12-09-2016 @ A-TEAM Sprint 1
						-- alberto.ruiz
						-- Se agrego parametro de LINKED_TO

-- Modificacion 1/13/2017 @ A-Team Sprint Abeden
					-- rodrigo.gomez
					-- Se resolvio un bug donde aumentaba un dia a la fecha @VALID_END_DATETIME
/*
-- Ejemplo de Ejecucion:

  
				EXEC [SONDA].SWIFT_SP_UPDATE_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 2
					,@CODE_TRADE_AGREEMENT = 'pruebaUPdateTradeAgreement'
					,@NAME_TRADE_AGREEMENT = 'NameUPdateTradeAgreement'
					,@DESCRIPTION_TRADE_AGREEMENT = 'prueba'
          ,@VALID_START_DATETIME = '20160909 00:05:00.000'
          ,@VALID_END_DATETIME = '20160909 00:05:00.000'
					,@STATUS = 0
					,@LAST_UPDATE_BY = 'prueba@SONDA'
					,@LINKED_TO = 'CUSTOMER'
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_TRADE_AGREEMENT](
	@TRADE_AGREEMENT_ID INT
	,@CODE_TRADE_AGREEMENT VARCHAR(50)
	,@NAME_TRADE_AGREEMENT VARCHAR(250)
	,@DESCRIPTION_TRADE_AGREEMENT VARCHAR(250)
	,@VALID_START_DATETIME DATETIME
	,@VALID_END_DATETIME DATETIME
	,@STATUS INT	
	,@LAST_UPDATE_BY VARCHAR(50)
	,@LINKED_TO VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE 
			@ORIGINAL_LINKED_TO VARCHAR(250)
			,@QTY INT = 0
			,@MESSAGE NVARCHAR(250) = ''
			,@QUERY NVARCHAR(1000)
		-- ------------------------------------------------------------------------------------
		-- Obtiene el linked_to original
		-- ------------------------------------------------------------------------------------
		SELECT @ORIGINAL_LINKED_TO = LINKED_TO
		FROM [SONDA].SWIFT_TRADE_AGREEMENT
		WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
		--
		PRINT '@LINKED_TO: ' + @LINKED_TO
		PRINT '@ORIGINAL_LINKED_TO: ' + @ORIGINAL_LINKED_TO

		-- ------------------------------------------------------------------------------------
		-- verfica si puede actualizar el acuerdo comercial
		-- ------------------------------------------------------------------------------------
		IF @ORIGINAL_LINKED_TO != @LINKED_TO
		BEGIN
			SELECT @QUERY = N'' + CASE CAST(@ORIGINAL_LINKED_TO AS NVARCHAR)
				WHEN 'CUSTOMER' THEN 'SELECT @QTY = COUNT(*) FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CUSTOMER WHERE TRADE_AGREEMENT_ID = ' + CAST(@TRADE_AGREEMENT_ID AS varchar)
				ELSE 'SELECT @QTY = COUNT(*) FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL WHERE TRADE_AGREEMENT_ID = ' + CAST(@TRADE_AGREEMENT_ID AS varchar)
			END			
			--
			EXEC SP_EXECUTESQL @QUERY,N'@QTY INT OUTPUT',@QTY = @QTY OUTPUT
			--
			PRINT '@QUERY: ' + @QUERY
			--
			PRINT '@QTY: ' + CAST(@QTY AS VARCHAR)

			IF @QTY > 0
			BEGIN
				SELECT @MESSAGE =  N'' + CASE CAST(@ORIGINAL_LINKED_TO AS NVARCHAR)
					WHEN 'CUSTOMER' THEN 'No puede cambiar el tipo del acuerdo comercial porque todavia tiene clientes asociados'
					ELSE 'No puede cambiar el tipo del acuerdo comercial porque todavia tiene canales asociados'
				END
				--
				PRINT '@MESSAGE: ' + @MESSAGE
				--
				RAISERROR(@MESSAGE,16,1)
			END
		END

		-- ------------------------------------------------------------------------------------
		-- Actualiza el acuerdo comercial
		-- ------------------------------------------------------------------------------------
		UPDATE  [SONDA].SWIFT_TRADE_AGREEMENT
		SET 
			CODE_TRADE_AGREEMENT = @CODE_TRADE_AGREEMENT
			,NAME_TRADE_AGREEMENT = @NAME_TRADE_AGREEMENT
			,DESCRIPTION_TRADE_AGREEMENT = @DESCRIPTION_TRADE_AGREEMENT
			,VALID_START_DATETIME = @VALID_START_DATETIME
			,VALID_END_DATETIME = @VALID_END_DATETIME--DATEADD(SECOND,-1,DATEADD(DAY,0,))
			,STATUS = @STATUS
			,LAST_UPDATE = GETDATE()
			,LAST_UPDATE_BY = @LAST_UPDATE_BY
			,LINKED_TO = @LINKED_TO
		WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe un acuerdo comercial con el mismo codigo de acuerdo comercial'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
