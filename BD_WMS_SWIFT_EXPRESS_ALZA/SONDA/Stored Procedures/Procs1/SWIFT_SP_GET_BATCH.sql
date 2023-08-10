
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	06-01-2016
-- Description:			selecciona los productos del batch 

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_GET_BATCH] 
   @BATCH_ID=2
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_BATCH]
	@BATCH_ID AS INT
AS
BEGIN

	SET NOCOUNT ON;


	SELECT 
		B.BATCH_ID	
		,B.[BATCH_SUPPLIER]
		,CONVERT(varchar,B.BATCH_SUPPLIER_EXPIRATION_DATE,111) AS BATCH_SUPPLIER_EXPIRATION_DATE				
		,B.[SKU]
		,S.[DESCRIPTION_SKU]
		,B.[QTY]
		,B.[QTY_LEFT]
		,B.[STATUS]
  FROM [SONDA].[SWIFT_BATCH] AS B 
  INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] AS S ON (B.[SKU] = S.[CODE_SKU])
  WHERE B.[BATCH_ID] =@BATCH_ID



END
