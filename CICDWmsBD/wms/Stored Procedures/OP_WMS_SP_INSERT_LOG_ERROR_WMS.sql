-- =============================================
-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20181015 GForce@Langosta
-- Description:	        Sp inserta un log en la base de datos

/*
-- Ejemplo de Ejecucion:
		EXEC  [wms].[OP_WMS_SP_INSERT_LOG_ERROR_WMS]
				@SOURCE_APP = '', -- varchar(50)
				@METHOD = '', -- varchar(200)
				@SQL_FUNCTION_OR_SP_NAME = '', -- varchar(300)
				@LOGIN_ID = '', -- varchar(50)
				@JSON_REQUEST = '', -- varchar(1)
				@MESSAGE_ERROR = '', -- varchar(500)
				@STACK_TRACE = '' -- varchar(max)
		--
		select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] WHERE PICKING_DEMAND_HEADER_ID = 5215
		select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_detail] WHERE PICKING_DEMAND_HEADER_ID = 5215
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_LOG_ERROR_WMS] (
		@SOURCE_APP [VARCHAR](50)
		,@METHOD [VARCHAR](200)
		,@SQL_FUNCTION_OR_SP_NAME [VARCHAR](300)
		,@LOGIN_ID [VARCHAR](50)
		,@JSON_REQUEST [VARCHAR](MAX)
		,@MESSAGE_ERROR [VARCHAR](500)
		,@STACK_TRACE [VARCHAR](MAX)
	)
AS
BEGIN
	BEGIN TRY
		DECLARE
			@pResult VARCHAR(200)
			,@ErrorCode INT;
		INSERT	INTO [dbo].[LOG_ERROR_WMS]
				(
					[SOURCE_APP]
					,[METHOD]
					,[SQL_FUNCTION_OR_SP_NAME]
					,[LOGIN_ID]
					,[JSON_REQUEST]
					,[DATE_REQUEST]
					,[MESSAGE_ERROR]
					,[STACK_TRACE]
				)
		VALUES
				(
					@SOURCE_APP  -- SOURCE_APP - varchar(50)
					,@METHOD  -- METHOD - varchar(200)
					,@SQL_FUNCTION_OR_SP_NAME  -- SQL_FUNCTION_OR_SP_NAME - varchar(300)
					,@LOGIN_ID  -- LOGIN_ID - varchar(50)
					,@JSON_REQUEST  -- JSON_REQUEST - varchar(max)
					,GETDATE()  -- DATE_REQUEST - datetime
					,@MESSAGE_ERROR  -- MESSAGE_ERROR - varchar(500)
					,@STACK_TRACE  -- STACK_TRACE - varchar(max)
				);

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' AS [Mensaje]
			,1 AS [Codigo]
			,'' AS [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			@pResult = ERROR_MESSAGE();
			
		SELECT
			@ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@ErrorCode AS [Codigo]
			,'' AS [DbData];
	END CATCH;


END;