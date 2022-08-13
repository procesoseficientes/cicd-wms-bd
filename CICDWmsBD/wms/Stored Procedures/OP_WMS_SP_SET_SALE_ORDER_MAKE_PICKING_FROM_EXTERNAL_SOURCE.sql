-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que marca la orden de venta de fuente externa que ya generro un picking

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SWIFT_EXPRESS].[wms].[SONDA_SALES_ORDER_HEADER] WHERE SALES_ORDER_ID = 33687
				--
				EXEC [wms].[OP_WMS_SP_SET_SALE_ORDER_MAKE_PICKING_FROM_EXTERNAL_SOURCE]
					@EXTERNAL_SOURCE_ID = 1
					,@SALES_ORDER_ID = 33687
				--
				SELECT * FROM [SWIFT_EXPRESS].[wms].[SONDA_SALES_ORDER_HEADER] WHERE SALES_ORDER_ID = 33687

				--
				SELECT * FROM [SWIFT_EXPRESS].[confitesa].[SONDA_SALES_ORDER_HEADER] WHERE SALES_ORDER_ID = 22
				--
				EXEC [wms].[OP_WMS_SP_SET_SALE_ORDER_MAKE_PICKING_FROM_EXTERNAL_SOURCE]
					@EXTERNAL_SOURCE_ID = 2
					,@SALES_ORDER_ID = 22
				--
				SELECT * FROM [SWIFT_EXPRESS].[confitesa].[SONDA_SALES_ORDER_HEADER] WHERE SALES_ORDER_ID = 22
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SET_SALE_ORDER_MAKE_PICKING_FROM_EXTERNAL_SOURCE] (
		@EXTERNAL_SOURCE_ID INT
		,@SALES_ORDER_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX);
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente externa
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
		FROM
			[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
		--
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

		-- ------------------------------------------------------------------------------------
		-- Marca la orden de venta de la fuente externa que genero un picking
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'UPDATE ' + @DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME + '.[SONDA_SALES_ORDER_HEADER]
		SET [HAVE_PICKING] = 1
		WHERE [SALES_ORDER_ID] = '
			+ CAST(@SALES_ORDER_ID AS VARCHAR);
		--
		PRINT '--> @QUERY: ' + @QUERY;
		--
		EXEC (@QUERY);
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;