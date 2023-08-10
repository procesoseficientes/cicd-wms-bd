
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			Actualiza la cantidad del pallet 

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_UPDATE_QTY_PALLET] 
   @PALLET_ID = 2
  ,@QTY = 2

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_QTY_PALLET]
     @PALLET_ID AS INT
	,@QTY AS INT
		
AS
BEGIN 

	SET NOCOUNT ON;

	UPDATE [SONDA].[SWIFT_PALLET]
	   SET [QTY] = @QTY
	 WHERE [PALLET_ID] = @PALLET_ID



END
