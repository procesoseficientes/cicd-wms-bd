-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que obtene el detalle de una solicitud de transferencia
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_DETAIL]
					@SERIAL_NUMBER = 808033
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_DETAIL](
	@TRANSFER_REQUEST_ID INT = 0,
	@SERIAL_NUMBER INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	print @TRANSFER_REQUEST_ID
	print @SERIAL_NUMBER

	IF (@SERIAL_NUMBER != 0)
	BEGIN
		PRINT ''
		SET @TRANSFER_REQUEST_ID = (SELECT TOP 1 TRANSFER_REQUEST_ID FROM wms.OP_WMS_TASK_LIST WHERE SERIAL_NUMBER = @SERIAL_NUMBER)
	END

	SELECT
		[D].[TRANSFER_REQUEST_ID]
		,[D].[MATERIAL_ID]
		,[D].[MATERIAL_NAME]
		,[D].[IS_MASTERPACK]
		,CASE
			WHEN [D].[IS_MASTERPACK] = 0 THEN 'NO'
			ELSE 'SI'
		END [IS_MASTERPACK_DESCRIPTION]
		,[D].[QTY]
		,[D].[STATUS]
		,CASE [D].[STATUS]
			WHEN 'OPEN' THEN 'ABIERTA'
			WHEN 'CLOSE' THEN 'CERRADA'
			ELSE [D].[STATUS]
		END [STATUS_DESCRIPTION]
		,[D].[STATUS_CODE]
	FROM [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] [D]
	WHERE [D].[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
END