
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			Valida los pallets por lote

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_UPDATE_BATCH] 
   @PALLET_ID = 2
  ,@BATCH_ID = 2

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_BATCH]
	 @BATCH_ID AS INT
	,@BATCH_SUPPLIER AS VARCHAR(250)
	,@BATCH_SUPPLIER_EXPIRATION_DATE AS DATE
	,@STATUS AS VARCHAR(20)
	,@SKU AS VARCHAR(50)
	,@QTY AS INT
	,@QTY_LEFT AS INT
	,@LAST_UPDATE AS DATETIME
	,@LAST_UPDATE_BY AS VARCHAR(50)

AS
BEGIN 

  SET NOCOUNT ON;

  UPDATE [SONDA].[SWIFT_BATCH]
   SET [BATCH_SUPPLIER] = @BATCH_SUPPLIER
      ,[BATCH_SUPPLIER_EXPIRATION_DATE] = @BATCH_SUPPLIER_EXPIRATION_DATE
      ,[STATUS] = @STATUS
      ,[SKU] = @SKU
      ,[QTY] = @QTY
      ,[QTY_LEFT] = @QTY_LEFT
      ,[LAST_UPDATE] = @LAST_UPDATE
      ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
 WHERE [BATCH_ID] = @BATCH_ID
      


END
