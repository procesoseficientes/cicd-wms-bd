-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	16-01-2016
-- Description:			Selecciona los Sku por parametro de buskeda

-- Modificacion 23-Nov-16 @ A-Team Sprint 5
					-- alberto.ruiz
					-- Se agrego columna si maneja serie
/*
-- Ejemplo de Ejecucion:				
				--
				EXEC [SONDA].[SWIFT_SP_GET_SKU_BY_SERCH] @FILTER='bate'
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_BY_SERCH] (
	@FILTER AS VARCHAR (250)	
) AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[VS].[CODE_SKU]
		,[VS].[DESCRIPTION_SKU]
		,[VS].[BARCODE_SKU]
		,[VS].[HANDLE_SERIAL_NUMBER]
	FROM [SONDA].[SWIFT_VIEW_ALL_SKU] [VS]
	WHERE [VS].[CODE_SKU] = @FILTER
		OR [VS].[DESCRIPTION_SKU] LIKE +'%' + @FILTER + '%'
		OR [VS].[BARCODE_SKU] LIKE +'%' + @FILTER + '%';
END
