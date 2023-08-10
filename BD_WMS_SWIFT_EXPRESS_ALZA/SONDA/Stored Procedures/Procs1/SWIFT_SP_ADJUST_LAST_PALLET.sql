/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_UPDATE_PALLET_QTY]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	14-01-2016
-- Description:			Sp que actuliza cantidad de un pallet en especifico de un lote y una tarea
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_ADJUST_LAST_PALLET] @BATCH_ID=157, @PALLET_ID=199, @TASK_ID=5218, @QTY=2
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADJUST_LAST_PALLET]
	@BATCH_ID varchar(250)
   ,@PALLET_ID INT
   ,@TASK_ID INT
   ,@QTY INT

AS
BEGIN
	SET NOCOUNT ON;

	UPDATE [SONDA].[SWIFT_PALLET] 
		SET QTY= QTY - @QTY
		where BATCH_ID=@BATCH_ID
		AND PALLET_ID=@PALLET_ID
		AND TASK_ID= @TASK_ID

	UPDATE [SONDA].[SWIFT_BATCH] 
		SET [QTY_LEFT]=[QTY_LEFT] + @QTY
		WHERE [BATCH_ID]=@BATCH_ID
		AND [TASK_ID] = @TASK_ID

END
