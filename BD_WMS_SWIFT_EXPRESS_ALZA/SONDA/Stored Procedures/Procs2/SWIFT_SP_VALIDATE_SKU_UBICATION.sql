
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	11-01-2016
-- Description:			Valida que el SKU y la localizacion sean correctas

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_VALIDATE_SKU_UBICATION] 
    @LOCATION = 2
   ,@CODE_SKU = '20GE'
   ,@PALLET_ID = 1279
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_SKU_UBICATION]
	 @CODE_LOCATION AS [VARCHAR](50) 
	,@CODE_SKU AS [VARCHAR](50) 
	,@PALLET_ID AS INT
AS
BEGIN 

  SET NOCOUNT ON;

  SELECT COUNT(*) AS VALIDACION_SKU_LOCALIZACION   
  FROM [SONDA].[SWIFT_VIEW_ALL_SKU] AS SU 
  INNER JOIN [SONDA].[SWIFT_BATCH] AS BC ON (SU.[CODE_SKU] = BC.[SKU])
  INNER JOIN [SONDA].[SWIFT_PALLET] AS PA ON (PA.[BATCH_ID] = BC.[BATCH_ID])
  INNER JOIN [SONDA].[SWIFT_LOCATIONS] AS LO ON (LO.[CODE_LOCATION] = PA.[LOCATION])
  WHERE LO.[CODE_LOCATION] = @CODE_LOCATION AND SU.[CODE_SKU] = @CODE_SKU AND PA.PALLET_ID = @PALLET_ID

END
