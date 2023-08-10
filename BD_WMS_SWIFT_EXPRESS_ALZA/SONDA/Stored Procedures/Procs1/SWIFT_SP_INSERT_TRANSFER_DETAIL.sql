-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		22-Nov-16 @ A-Team Sprint 5
-- Description:			    SP que agrega el detalle de una transferencia

-- Mod:					        hector.gonzalez
-- Fecha de Creacion: 		24-Nov-16 @ A-Team Sprint 5
-- Description:			     Se agrego validacion de serie al eliminar un detalle

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_INSERT_TRANSFER_DETAIL]
			@TRANSFER_ID = 55
			,@SKU_CODE = '100003'
			,@QTY = 2
			,@SERIE = 'ASDB12315'
		--
		SELECT * FROM [SONDA].[SWIFT_TRANSFER_DETAIL] WHERE [TRANSFER_ID] = 55
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_TRANSFER_DETAIL (
	@TRANSFER_ID NUMERIC(18,0)
	,@SKU_CODE VARCHAR(50)
	,@QTY FLOAT
	,@SERIE VARCHAR(150) = NULL
) AS
BEGIN
	BEGIN TRY
		BEGIN TRAN [t1];
		--
		DELETE [SONDA].[SWIFT_TRANSFER_DETAIL]
		WHERE [TRANSFER_ID] = @TRANSFER_ID
			AND [SKU_CODE] = @SKU_CODE
      AND ISNULL([SERIE],'NA') = ISNULL(@SERIE,'NA')
		--		
		INSERT	INTO [SONDA].[SWIFT_TRANSFER_DETAIL]
				(
					[TRANSFER_ID]
					,[SKU_CODE]
					,[QTY]
					,[SERIE]
				)
		VALUES (
			@TRANSFER_ID
			,@SKU_CODE
			,@QTY
			,@SERIE
		);

		COMMIT TRAN [t1];
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo];
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN [t1];
		--
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END
