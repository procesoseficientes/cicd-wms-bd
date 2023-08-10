
-- =============================================
-- Autor:				rudy.garcia
-- Fecha de Creacion: 	15-10-2015
-- Description:			Actualiza los registros de una ruta para que este finalizada la ruta

-- Modificacion 16-11-2015
				--alberto.ruiz
				--Se agrego la tabla de ordenes de compra

-- Modificacion 03-12-2015
				--alberto.ruiz
				--Se agrego llamado para inactivar la ruta en la tabla de ruta

-- Modificacion 27-Oct-16 @ A-Team Sprint 4
					-- alberto.ruiz
					-- Se agrego que al marcar las consignaciones 
/*
-- Ejemplo de Ejecucion:
				declare @pRESULT varchar(MAX)
				--
				exec [SONDA].[SONDA_UPDATE_ACTIVE_ROUTE]
					@Route = '001',
					@pRESULT= @pRESULT
				--
				select @pRESULT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_UPDATE_ACTIVE_ROUTE]	
	@Route varchar(50), 	
	@pRESULT varchar(MAX) = '' OUTPUT

AS
BEGIN	
	SET NOCOUNT ON;
	--
	DECLARE @tmpResult varchar(MAX) = '';	
	
	UPDATE [SONDA].[SWIFT_CONSIGNMENT_HEADER] 
	SET
		[IS_ACTIVE_ROUTE] = 0
		,[CONSIGNMENT_HH_NUM] = NULL
	WHERE [IS_ACTIVE_ROUTE] = 1
	AND [POS_TERMINAL] = @Route
	--
	UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER] 
	SET [IS_ACTIVE_ROUTE] = 0
	WHERE [IS_ACTIVE_ROUTE] = 1
	AND [POS_TERMINAL] = @Route
	--
	UPDATE [SONDA].[SONDA_PAYMENT_HEADER]
	SET [IS_ACTIVE_ROUTE] = 0
	WHERE [IS_ACTIVE_ROUTE] = 1
	AND [POS_TERMINAL] = @Route
	--
	UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
	SET [IS_ACTIVE_ROUTE] = 0
	WHERE [IS_ACTIVE_ROUTE] = 1
	AND [POS_TERMINAL] = @Route
	--
	EXEC [SONDA].[SWIFT_SP_ROUTE_CHANGE_ACTIVE] @CODE_ROUTE = @Route ,@IS_ACTIVE_ROUTE = 0

	IF (@@ERROR = 0) 
	BEGIN
		SET @tmpResult = 'OK'
	END 
	ELSE BEGIN
		SELECT @tmpResult = 'No se pudo transferir los sku ';
	END
		SELECT @pRESULT = @tmpResult
END
