-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		22-Nov-16 @ A-Team Sprint 5
-- Description:			    Vista para obtner el detalle de las transferencias

-- Modificacion 		12/17/2018 @ G-Force Team Sprint OsoPolar
-- Autor: 				diego.as
-- Historia/Bug:		Bug 26336: SKU's sin unidades de medida al aceptar una transferencia en linea
-- Descripcion: 		12/17/2018 - Se agrega campo VAT_CODE, [SALES_PACK_UNIT], [CODE_PACK_UNIT_STOCK]

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[SWIFT_VIEW_TRANSFER_DETAIL]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_TRANSFER_DETAIL]
AS
	(
		SELECT
			[TRANSFER_ID]
			,[SKU_CODE]
			,[DESCRIPTION_SKU]
			,[QTY]
			,[STATUS]
			,[TD].[SERIE]
			,[S].[CODE_PACK_UNIT] AS [SALES_PACK_UNIT]
			,'MANUAL' AS [CODE_PACK_UNIT_STOCK]
			,[S].[VAT_CODE]
		FROM
			[SONDA].[SWIFT_TRANSFER_DETAIL] [TD]
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S]
		ON	([TD].[SKU_CODE] = [S].[CODE_SKU])
	);
