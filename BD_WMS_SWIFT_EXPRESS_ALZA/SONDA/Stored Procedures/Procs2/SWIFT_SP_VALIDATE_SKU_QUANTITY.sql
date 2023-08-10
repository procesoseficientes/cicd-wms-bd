
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	11-01-2016
-- Description:			Valida que el SKU y la cantidad sea menor o igual a la de la tabla

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_VALIDATE_SKU_QUANTITY] 
    @CODE_SKU='20GE'
   ,@QTY = 2
   ,@PALLET_ID = 1279
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_SKU_QUANTITY]
	  @CODE_SKU AS [VARCHAR](50) 
	 ,@QTY AS INT
	 ,@PALLET_ID AS INT

AS
BEGIN 

  SET NOCOUNT ON;

  SELECT COUNT(*) AS VALIDACION_SKU_CANTIDAD 
	FROM [SONDA].[SWIFT_VIEW_ALL_SKU]  AS SU 
	INNER JOIN [SONDA].[SWIFT_BATCH] AS BC ON (SU.[CODE_SKU] = BC.[SKU])
	INNER JOIN [SONDA].[SWIFT_PALLET] AS PA ON (PA.[BATCH_ID] = BC.[BATCH_ID])
	INNER JOIN [SONDA].[SWIFT_LOCATIONS] AS LO ON (LO.[LOCATION] = PA.[LOCATION])
  WHERE SU.[CODE_SKU] = @CODE_SKU AND  PA.[QTY] >= @QTY AND PA.PALLET_ID = @PALLET_ID

END
