/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_UPDATE_BATCH_QTY]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			ACTUALIZA LA TABLA BATCH LOS VALORES DE LA CANTIDAD RESTANTE 
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_UPDATE_BATCH_QTY]
				@BATCH_ID =1
			    ,@QTY =10
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_BATCH_CLOSED]
	@BATCH_ID INT
   ,@QTY INT

AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE [SONDA].[SWIFT_BATCH]
	SET
		[QTY] = (QTY - @QTY) 
		,[QTY_LEFT] =0
		,[STATUS]='CLOSED'
	WHERE [BATCH_ID] = @BATCH_ID
END
