-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-02-2016
-- Description:			Actualiza el estado anulado de la orden de venta

-- Modificacion 07-Mar-17 @ A-Team Sprint Ebonne
					-- alberto.ruiz
					-- Se agrega validacion si se puede anular la orden de venta

/*
-- Ejemplo de Ejecucion:
				DECLARE 
					@SERIE VARCHAR(100) = 'C'
					,@DOC_NUM INT = 2
					,@VOID INT = 1
				--
				SELECT S.DOC_SERIE,S.DOC_NUM,IS_VOID FROM [SONDA].[SONDA_SALES_ORDER_HEADER] S WHERE DOC_SERIE = @SERIE AND DOC_NUM = @DOC_NUM
				--
				EXEC [SONDA].[SONDA_SP_UPDATE_SALE_ORDER_VOID]
					@SERIE = @SERIE
					,@DOC_NUM = @DOC_NUM
					,@VOID = @VOID
				--
				SELECT S.DOC_SERIE,S.DOC_NUM,IS_VOID FROM [SONDA].[SONDA_SALES_ORDER_HEADER] S WHERE DOC_SERIE = @SERIE AND DOC_NUM = @DOC_NUM
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_UPDATE_SALE_ORDER_VOID
(	
	@SERIE VARCHAR(100)
	,@DOC_NUM INT
	,@VOID INT = 1
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @CAN_VOID INT = 0
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Valida si se puede anular la orden de venta
		-- ------------------------------------------------------------------------------------
		IF @VOID = 1
		BEGIN
			SELECT @CAN_VOID = [SONDA].[SONDA_FN_CAN_VOID_SALE_ORDER](@SERIE,@DOC_NUM)
			--
			IF @CAN_VOID = 0
			BEGIN
				RAISERROR('El pedido ya se encuentra procesado, no es posible Anularlo',16,1)
			END
		END
		
		-- ------------------------------------------------------------------------------------
		-- Actualiza la orden de venta
		-- ------------------------------------------------------------------------------------
		UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
		SET IS_VOID = @VOID
			,VOID_DATETIME = GETDATE()
		WHERE DOC_SERIE = @SERIE
			AND DOC_NUM = @DOC_NUM
			AND IS_READY_TO_SEND=1
	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
	END CATCH
END
