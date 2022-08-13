-- =============================================
-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20181015 GForce@Langosta
-- Description:	        Sp inserta un log en la base de datos

/*
-- Ejemplo de Ejecucion:
		EXEC  [dbo].[OP_WMS_SP_INSERT_LOG_ERROR_WMS]
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
CREATE PROCEDURE [dbo].[OP_WMS_SP_INSERT_LOG_ERROR_WMS] (
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
	EXEC [wms].[OP_WMS_SP_INSERT_LOG_ERROR_WMS] @SOURCE_APP,
		@METHOD, @SQL_FUNCTION_OR_SP_NAME, @LOGIN_ID,
		@JSON_REQUEST, @MESSAGE_ERROR, @STACK_TRACE;
	
END;