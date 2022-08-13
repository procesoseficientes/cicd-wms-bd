-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint ewms 
-- Description:			Valida que el detalle de la factura de devolucion sea el mismo o mayor al ingresado en la recepción.

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrego el campo de MATERIAL_OWNER a la tabla [#INVOICE]

-- Modificacion 1/30/2018 @ Reborn-Team Sprint Trotzdem
					-- diego.as
					-- Se agrega modificacion para recepcion de wms

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_RECEPTION_FOR_INVOICE_RETURN_TO_SEND_ERP]
					@TASK_ID = 83244
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_RECEPTION_FOR_INVOICE_RETURN_TO_SEND_ERP] (@TASK_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
		--
	DECLARE
		@WITH_DIFFERENCES INT = 0
		,@MESSAGE VARCHAR(1000) = '';
	SELECT TOP 1
		@WITH_DIFFERENCES = 1
		,@MESSAGE = 'Debe confirmar la recepción.'
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
	WHERE
		[TASK_ID] = @TASK_ID
		AND [IS_AUTHORIZED] = 0;

			--
	IF @WITH_DIFFERENCES = 1
	BEGIN
		SELECT
			-1 AS [Resultado]
			,@MESSAGE [Mensaje]
			,-1 [Codigo];
	END;
	ELSE
	BEGIN
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo];
	END;
	
END;