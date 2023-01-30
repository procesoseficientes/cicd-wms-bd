create PROCEDURE [wms].[OP_WMS_SP_COMPLETE_REALLOC]
	@TASK_ID int
AS
	UPDATE [wms].[OP_WMS_TASK] SET 
	COMPLETED_DATE = GETDATE(),
	IS_COMPLETE = 1,
	LAST_UPDATE = GETDATE()
	WHERE TASK_ID = @TASK_ID


	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,'' [DbData];