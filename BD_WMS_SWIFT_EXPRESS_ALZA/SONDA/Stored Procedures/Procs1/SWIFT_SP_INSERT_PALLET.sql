/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_INSERT_PALLET]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Inserta en la tabla PALLET
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_INSERT_PALLET] 
					@BATCH_ID=1
					,@STATUS='open'
					,@QTY=100	
					,@LAST_UPDATE_BY='oper1@SONDA'
					,@WAREHOUSE='principal'
					,@LOCATION='a1'
					,@TASK_ID='001'
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_PALLET]
	@BATCH_ID INT
	,@STATUS VARCHAR(20)
	,@QTY INT
	,@LAST_UPDATE_BY VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
	,@LOCATION VARCHAR(50)
	,@TASK_ID INT
	,@IS_ADJUSTMENT INT = NULL
	,@ID INT = -1 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE 
		@tmpResult varchar(MAX) = ''

	BEGIN TRAN
	BEGIN TRY
		INSERT INTO [SONDA].[SWIFT_PALLET](
			[BATCH_ID]
			,[STATUS]
			,[QTY]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			,[WAREHOUSE]
			,[LOCATION]
			,[TASK_ID]
		)
		VALUES (
			@BATCH_ID
			,@STATUS
			,@QTY
			,GETDATE()	
			,@LAST_UPDATE_BY
			,@WAREHOUSE
			,@LOCATION
			,@TASK_ID
		)
		--
		SET @ID = SCOPE_IDENTITY()

		IF @IS_ADJUSTMENT IS NULL
		BEGIN
			UPDATE [SONDA].[SWIFT_BATCH]
			SET QTY_LEFT = (QTY_LEFT - @QTY)
			WHERE BATCH_ID = @BATCH_ID
		END

		SELECT @ID AS ID

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
	END CATCH
END
