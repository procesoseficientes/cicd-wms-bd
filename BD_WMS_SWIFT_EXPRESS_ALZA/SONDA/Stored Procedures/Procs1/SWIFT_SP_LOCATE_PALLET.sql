

-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			Actualiza el estado del pallet 

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_LOCATE_PALLET] 
   @LAST_UPDATE_BY = 'gerente@SONDA'
  ,@CODE_LOCATION = 2
  ,@PALLET_ID = 2
  ,@CODE_WAREHOUSE = 2

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_LOCATE_PALLET]
     @LAST_UPDATE_BY AS VARCHAR(50)
    ,@CODE_LOCATION AS VARCHAR(50)
    ,@PALLET_ID AS INT
	,@CODE_WAREHOUSE AS VARCHAR(50)
		
AS
BEGIN 

	SET NOCOUNT ON;

	UPDATE [SONDA].[SWIFT_PALLET]
	   SET [STATUS] = 'LOCATED'
		  ,[LAST_UPDATE] = GETDATE()
		  ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
		  ,[WAREHOUSE] = @CODE_WAREHOUSE
		  ,[LOCATION] = @CODE_LOCATION
	 WHERE [PALLET_ID] = @PALLET_ID



END
