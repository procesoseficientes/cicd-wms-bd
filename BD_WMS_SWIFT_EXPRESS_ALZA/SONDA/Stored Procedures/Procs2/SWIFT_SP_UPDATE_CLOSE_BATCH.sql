
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			Valida el cierre de los batchs

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_UPDATE_CLOSE_BATCH] 
   @BATCH_ID = 2
  ,@LAST_UPDATE_BY = 'gerente@SONDA' 

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_CLOSE_BATCH]
	 @BATCH_ID AS INT
	,@LAST_UPDATE_BY AS VARCHAR(50)

AS
BEGIN 

	SET NOCOUNT ON;
      
	UPDATE [SONDA].[SWIFT_BATCH]
	 SET 
		 [LAST_UPDATE] = GETDATE()
		,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
		,[STATUS] = 'CLOSED'
	WHERE [BATCH_ID] = @BATCH_ID

END
