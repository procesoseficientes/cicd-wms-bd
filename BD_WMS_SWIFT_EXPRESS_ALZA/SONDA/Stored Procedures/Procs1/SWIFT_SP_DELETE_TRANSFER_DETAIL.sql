-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		22-Nov-16 @ A-Team Sprint 5
-- Description:			    SP que elimina el detalle de una transferencia

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_DELETE_TRANSFER_DETAIL]
			@TRANSFER_ID = 55
			,@SKU_CODE = '100003'
			,@SERIE = 'ASDB12315'
		--
		SELECT * FROM [SONDA].[SWIFT_TRANSFER_DETAIL] WHERE [TRANSFER_ID] = 55
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_TRANSFER_DETAIL] (
	@TRANSFER_ID NUMERIC(18 ,0)
	,@SKU_CODE VARCHAR(50)
	,@SERIE VARCHAR(150) = NULL
) AS
BEGIN
	BEGIN TRAN [t1];
	BEGIN TRY
		DELETE [SONDA].[SWIFT_TRANSFER_DETAIL]
		WHERE [TRANSFER_ID] = @TRANSFER_ID
			AND [SKU_CODE] = @SKU_CODE
			AND ISNULL([SERIE],'NA') = ISNULL(@SERIE,'NA')
		--
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
END;
