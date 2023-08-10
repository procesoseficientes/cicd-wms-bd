-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	30-Jan-17 @ A-TEAM Sprint Bankole 
-- Description:			SP que obtiene el detalle de una transferencia 

-- Modificacion 		12/17/2018 @ G-Force Team Sprint OsoPolar
-- Autor: 				diego.as
-- Historia/Bug:		Bug 26336: SKU's sin unidades de medida al aceptar una transferencia en linea
-- Descripcion: 		12/17/2018 - Se agrega campo VAT_CODE 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_TRANSFER_DETAIL_BY_TRANSFER_ID]
					@TRANSFER_ID = 153
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TRANSFER_DETAIL_BY_TRANSFER_ID] (@TRANSFER_ID INT)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		SELECT
			[TD].[TRANSFER_ID]
			,[TD].[SKU_CODE]
			,[S].[DESCRIPTION_SKU]
			,[TD].[QTY]
			,[TD].[STATUS]
			,[TD].[SERIE]
			,[S].[CODE_PACK_UNIT] AS [SALES_PACK_UNIT]
			,'MANUAL' AS [CODE_PACK_UNIT_STOCK]
			,[S].[VAT_CODE]
		FROM
			[SONDA].[SWIFT_TRANSFER_DETAIL] [TD]
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S]
		ON	([S].[CODE_SKU] = [TD].[SKU_CODE])
		WHERE
			[TD].[TRANSFER_ID] = @TRANSFER_ID;
	END;
