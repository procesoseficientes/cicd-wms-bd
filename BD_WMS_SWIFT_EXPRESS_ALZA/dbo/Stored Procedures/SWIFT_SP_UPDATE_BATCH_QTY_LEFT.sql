/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_UPDATE_BATCH_QTY_LEFT]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			ACTUALIZA EN LA TABLA EL VALOR DE QTY_LEFT
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_UPDATE_BATCH_QTY_LEFT] @BATCHID=1, @QTY_NEW=10
				--				
*/
-- =============================================
Create PROCEDURE [SWIFT_SP_UPDATE_BATCH_QTY_LEFT]
	@BATCH_ID INT
   ,@QTY INT

AS
BEGIN
	SET NOCOUNT ON;

	UPDATE [SONDA].[SWIFT_BATCH]
	SET	   
		[QTY_LEFT] = (QTY_LEFT- @QTY)  
		,[STATUS]='CLOSED' 
	WHERE  [BATCH_ID]=@BATCH_ID
END
