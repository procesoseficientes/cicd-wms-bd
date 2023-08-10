
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			Actualiza el estado del pallet 

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_UPDATE_STATUS_PALLET] 
   @PALLET_ID = ''

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_STATUS_PALLET]

@PALLET_ID AS INT

AS
BEGIN 

	SET NOCOUNT ON;

	DECLARE @ID  INT;

	UPDATE [SONDA].[SWIFT_PALLET]
		SET [STATUS] = 'LOCATED'
	WHERE [PALLET_ID] = @PALLET_ID

	SET @ID = SCOPE_IDENTITY()
	SELECT @ID as ID

END
