
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
  ,@LAST_UPDATE_BY = 'gerente@SONDA' 

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PALLET_BATCH]
	 @PALLET_ID AS INT
	,@BATCH_ID AS INT
	,@LAST_UPDATE_BY AS VARCHAR(50)

AS
BEGIN 

	SET NOCOUNT ON;
      
	UPDATE [SONDA].[SWIFT_PALLET]
	 SET [BATCH_ID] = @BATCH_ID
		,[LAST_UPDATE] = GETDATE()
		,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
	WHERE [PALLET_ID] = @PALLET_ID

END
