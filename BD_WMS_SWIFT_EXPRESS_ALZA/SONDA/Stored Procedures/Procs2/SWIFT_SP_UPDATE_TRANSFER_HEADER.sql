-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		11-Oct-16 @ A-Team Sprint 2
-- Description:			    SP que actualiza la transferencia

-- Modificacion 24-Jan-17 @ A-Team Sprint Bankole
					-- alberto.ruiz
					-- Se agrego el campo de is_online y estatus

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_UPDATE_TRANSFER_HEADER]
			@TRANSFER_ID  = 52
			,@SELLER_CODE = '-1'
			,@SELLER_ROUTE = 'RUDI@SONDA'
			,@CODE_WAREHOUSE_SOURCE = 'C003'
			,@LAST_UPDATE_BY = 'gerente@SONDA'
			,@COMMENT = 'comentario'
			,@STATUS = 'COMPLETADO'
			,@IS_ONLINE = 0
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_TRANSFER_HEADER] (
	@TRANSFER_ID NUMERIC(18 ,0)
	,@SELLER_CODE VARCHAR(50)
	,@SELLER_ROUTE VARCHAR(50)
	,@CODE_WAREHOUSE_SOURCE VARCHAR(50)
	,@LAST_UPDATE_BY VARCHAR(50)
	,@COMMENT VARCHAR(250)
	,@STATUS VARCHAR(20)
	,@IS_ONLINE INT
) AS
BEGIN
	BEGIN TRAN [t1];
	BEGIN TRY
		DECLARE @DEFAULT_WAREHOUSE VARCHAR(50)
		--
		SELECT 
			@DEFAULT_WAREHOUSE = [DEFAULT_WAREHOUSE]
		FROM [SONDA].[SWIFT_VIEW_SELLER_LOGIN] 
		WHERE[SELLER_CODE] = @SELLER_CODE
			AND [SELLER_ROUTE] = @SELLER_ROUTE
		--
		UPDATE [SONDA].[SWIFT_TRANSFER_HEADER]
		SET	
			[SELLER_CODE] = @SELLER_CODE
			,[SELLER_ROUTE] = @SELLER_ROUTE
			,[CODE_WAREHOUSE_SOURCE] = @CODE_WAREHOUSE_SOURCE
			,[CODE_WAREHOUSE_TARGET] = @DEFAULT_WAREHOUSE
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
			,[COMMENT] = @COMMENT
			,[STATUS] = @STATUS
			,[IS_ONLINE] = @IS_ONLINE
		WHERE [TRANSFER_ID] = @TRANSFER_ID;
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
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END
