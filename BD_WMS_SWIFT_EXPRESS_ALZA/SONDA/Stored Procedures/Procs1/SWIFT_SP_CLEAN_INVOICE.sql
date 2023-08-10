-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-Apr-17 @ A-TEAM Sprint Garai 
-- Description:			SP que elimina las facturas 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_CLEAN_INVOICE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_INVOICE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DELETE [D]
	FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] [D]
	INNER JOIN [SONDA].[SONDA_POS_INVOICE_HEADER] [H] ON (
		[H].[ID] = [D].[ID]
	)
	WHERE [IS_READY_TO_SEND] = 0
	--
	DELETE FROM [SONDA].[SONDA_POS_INVOICE_HEADER]
	WHERE [IS_READY_TO_SEND] = 0
END
