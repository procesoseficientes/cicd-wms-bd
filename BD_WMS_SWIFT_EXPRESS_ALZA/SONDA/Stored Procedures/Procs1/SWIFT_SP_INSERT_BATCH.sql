
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	06-01-2016
-- Description:			insert los datos de batch 

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_INSERT_BATCH] 
   @BATCH_SUPPLIER = 'PRUEBA'
  ,@BATCH_SUPPLIER_EXPIRATION_DATE= '12/12/2015'
  ,@STATUS='INACTIVO'
  ,@SKU='8'
  ,@QTY='0'
  ,@QTY_LEFT='0'				
  ,@LAST_UPDATE_BY=''
   SELECT * FROM [SONDA].[SWIFT_BATCH]

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_BATCH]

	 @BATCH_SUPPLIER VARCHAR(250)
	,@BATCH_SUPPLIER_EXPIRATION_DATE AS DATE
	,@STATUS AS VARCHAR(20)
	,@SKU AS VARCHAR(50)
	,@QTY AS INT
	,@QTY_LEFT AS INT
	,@LAST_UPDATE_BY AS VARCHAR(50)
	,@TASK_ID INT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @ID  INT;

	INSERT INTO [SONDA].[SWIFT_BATCH]
           ([BATCH_SUPPLIER]
           ,[BATCH_SUPPLIER_EXPIRATION_DATE]
           ,[STATUS]
           ,[SKU]
           ,[QTY]
           ,[QTY_LEFT]
		   ,[LAST_UPDATE]
		   ,[LAST_UPDATE_BY]
		   ,[TASK_ID])
	VALUES
           (@BATCH_SUPPLIER
           ,@BATCH_SUPPLIER_EXPIRATION_DATE
           ,@STATUS
           ,@SKU
           ,@QTY
           ,@QTY_LEFT
		   ,GETDATE()
		   ,@LAST_UPDATE_BY
		   ,@TASK_ID
		   )

		   	SET @ID = SCOPE_IDENTITY()
	        SELECT @ID as ID

	END
