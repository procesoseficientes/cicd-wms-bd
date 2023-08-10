-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Trae los registros de la Tabla [SONDA].[SWIFT_FAMILY_SKU] 
--					en donde están las FAMILIAS de PRODUCTOS.
/*
Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_GET_FAMILY_SKU]

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_FAMILY_SKU]
AS
BEGIN
	SET NOCOUNT ON;

		SELECT [SFS].[FAMILY_SKU]
				,[SFS].[CODE_FAMILY_SKU]
				,[SFS].[DESCRIPTION_FAMILY_SKU]
				,[SFS].[ORDER]
				,[SFS].[LAST_UPDATE]
				,[SFS].[LAST_UPDATE_BY]
		FROM [SONDA].[SWIFT_FAMILY_SKU] AS SFS

END
