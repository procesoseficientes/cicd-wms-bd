
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	11-01-2016
-- Description:			Valida que el SKU, la cantidad y la ubicacion sean corractos segun la tabla

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_VALIDATE_SKU_QUANTITY_UBICATION] 
    @CODE_SKU='20GE'
   ,@QTY = 2
   ,@LOCATION =  2
   ,@PALLET_ID = 2
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_SKU_QUANTITY_UBICATION]
	  @CODE_SKU AS [VARCHAR](50) 
	 ,@QTY AS INT
	 ,@LOCATION AS INT
	 ,@PALLET_ID AS INT

AS
BEGIN 

  SET NOCOUNT ON;

  SELECT COUNT(*) AS VALIDACION_SKU_CANTIDAD 
	FROM [SONDA].[SWIFT_VIEW_ALL_SKU]  AS SU 
	INNER JOIN [SONDA].[SWIFT_BATCH] AS BC ON (SU.[SKU] = BC.[SKU])
	INNER JOIN [SONDA].[SWIFT_PALLET] AS PA ON (PA.[BATCH_ID] = BC.[BATCH_ID])
	INNER JOIN [SONDA].[SWIFT_LOCATIONS] AS LO ON (LO.[LOCATION] = PA.[LOCATION])
  WHERE SU.[CODE_SKU] = @CODE_SKU AND  PA.[QTY] >= @QTY AND LO.[LOCATION] = @LOCATION 
		AND PA.PALLET_ID = @PALLET_ID

END
