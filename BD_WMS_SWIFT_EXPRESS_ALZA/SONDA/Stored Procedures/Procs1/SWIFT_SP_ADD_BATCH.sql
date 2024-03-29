﻿/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_UPDATE_BATCH_QTY]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Inserta un nuevo batch y actualiza la cantidad del mismo a cero (0)  
--						y lo cierra	(status=CLOSED). 
/*
-- Ejemplo de Ejecucion:				
				--
				EXECUTE  [SONDA].[SWIFT_SP_ADD_BATCH] 
					@BATCH_SUPPLIER = 'PRUEBA'
					,@BATCH_SUPPLIER_EXPIRATION_DATE= '12/12/2015'
					,@STATUS='INACTIVO'
					,@SKU='8'
					,@QTY='0'
					,@QTY_LEFT='0'				
					,@LAST_UPDATE_BY=''
					,@TASK_ID =5219
					,@BATCH_ID=NULL
				--
				SELECT * FROM [SONDA].[SWIFT_BATCH]

				--
				DECLARE @ID INT
				--
				EXECUTE  [SONDA].[SWIFT_SP_ADD_BATCH] 
					@BATCH_SUPPLIER = 'PRUEBA'
					,@BATCH_SUPPLIER_EXPIRATION_DATE= '12/12/2015'
					,@STATUS='INACTIVO'
					,@SKU='8'
					,@QTY='0'
					,@QTY_LEFT='0'				
					,@LAST_UPDATE_BY=''
					,@TASK_ID =5219
					,@BATCH_ID=NULL
					,@ID = @ID OUTPUT
				--
				SELECT @ID AS ID
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_BATCH]
	 @BATCH_SUPPLIER VARCHAR(250)
	,@BATCH_SUPPLIER_EXPIRATION_DATE AS DATE
	,@STATUS AS VARCHAR(20)
	,@SKU AS VARCHAR(50)
	,@QTY AS INT
	,@QTY_LEFT AS INT
	,@LAST_UPDATE_BY AS VARCHAR(50)
	,@TASK_ID AS INT
	,@BATCH_ID AS VARCHAR(20)
	,@ID INT = -1 OUTPUT
AS

BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE #T (ID INT)

	BEGIN TRAN
	BEGIN TRY
		INSERT INTO #T
		EXECUTE  [SONDA].[SWIFT_SP_INSERT_BATCH] 
			@BATCH_SUPPLIER =@BATCH_SUPPLIER
			,@BATCH_SUPPLIER_EXPIRATION_DATE= @BATCH_SUPPLIER_EXPIRATION_DATE
			,@STATUS=@STATUS
			,@SKU=@SKU
			,@QTY=@QTY
			,@QTY_LEFT=@QTY_LEFT
			,@LAST_UPDATE_BY=@LAST_UPDATE_BY
			,@TASK_ID= @TASK_ID
		--
		IF (@BATCH_ID IS NOT NULL) 
		BEGIN
			EXEC [SONDA].[SWIFT_SP_BATCH_CLOSED]
				@BATCH_ID = @BATCH_ID
				,@QTY=@QTY
		END
		--
		SELECT TOP 1 @ID = T.ID FROM #T T
		--
		SELECT @ID AS ID

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
	END CATCH
END
