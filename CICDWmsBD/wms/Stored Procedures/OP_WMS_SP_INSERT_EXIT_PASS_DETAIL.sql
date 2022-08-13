-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	22-Nov-2017 @ Reborn-Team Sprint Nach
-- Description:			Sp que inserta el detalle

/*
-- Ejemplo de Ejecucion:
				
				EXEC [wms].[OP_WMS_SP_INSERT_EXIT_PASS_DETAIL]
				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_EXIT_PASS_DETAIL] (
		@PASS_HEADER_ID INT
		,@XML XML
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY

		DELETE
			[wms].[OP_WMS_PASS_DETAIL]
		WHERE
			[PASS_HEADER_ID] = @PASS_HEADER_ID;

		DECLARE	@PASS_DETAIL TABLE (
				[CLIENT_CODE] VARCHAR(50)
				,[CLIENT_NAME] VARCHAR(200)
				,[PICKING_DEMAND_HEADER_ID] INT
				,[DOC_NUM] INT
				,[MATERIAL_ID] VARCHAR(50)
				,[MATERIAL_NAME] VARCHAR(200)
				,[QTY] NUMERIC(18, 4)
				,[DOC_NUM_POLIZA] INT
				,[CODIGO_POLIZA] VARCHAR(25)
				,[NUMERO_ORDEN_POLIZA] VARCHAR(25)
				,[WAVE_PICKING_ID] INT
				,[CREATED_DATE] DATETIME
				,[CODE_WAREHOUSE] VARCHAR(25)
				,[TYPE_DEMAND_CODE] INT
				,[TYPE_DEMAND_NAME] VARCHAR(50)
				,[LINE_NUM] INT
			);

		INSERT	INTO @PASS_DETAIL
				(
					[CLIENT_CODE]
					,[CLIENT_NAME]
					,[PICKING_DEMAND_HEADER_ID]
					,[DOC_NUM]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[DOC_NUM_POLIZA]
					,[CODIGO_POLIZA]
					,[NUMERO_ORDEN_POLIZA]
					,[WAVE_PICKING_ID]
					,[CREATED_DATE]
					,[CODE_WAREHOUSE]
					,[TYPE_DEMAND_CODE]
					,[TYPE_DEMAND_NAME]
					,[LINE_NUM]
				)
		SELECT
			[X].[Rec].[query]('./CLIENT_CODE').[value]('.',
											'varchar(50)') [CLIENT_CODE]
			,[X].[Rec].[query]('./CLIENT_NAME').[value]('.',
											'varchar(200)') [CLIENT_NAME]
			,[X].[Rec].[query]('./PICKING_DEMAND_HEADER_ID').[value]('.',
											'int') [PICKING_DEMAND_HEADER_ID]
			,[X].[Rec].[query]('./DOC_NUM').[value]('.',
											'int') [DOC_NUM]
			,[X].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'varchar(50)') [MATERIAL_ID]
			,[X].[Rec].[query]('./MATERIAL_NAME').[value]('.',
											'varchar(200)') [MATERIAL_NAME]
			,[X].[Rec].[query]('./QTY').[value]('.',
											'numeric(18, 4)') [QTY]
			,[X].[Rec].[query]('./DOC_NUM_POLIZA').[value]('.',
											'int') [DOC_NUM_POLIZA]
			,[X].[Rec].[query]('./CODIGO_POLIZA').[value]('.',
											'varchar(25)') [CODIGO_POLIZA]
			,[X].[Rec].[query]('./NUMERO_ORDEN_POLIZA').[value]('.',
											'varchar(25)') [NUMERO_ORDEN_POLIZA]
			,[X].[Rec].[query]('./WAVE_PICKING_ID').[value]('.',
											'int') [WAVE_PICKING_ID]
			,[X].[Rec].[query]('./CREATED_DATE').[value]('.',
											'DATETIME') [CREATED_DATE]
			,[X].[Rec].[query]('./CODE_WAREHOUSE').[value]('.',
											'varchar(25)') [CODE_WAREHOUSE]
			,[X].[Rec].[query]('./TYPE_DEMAND_CODE').[value]('.',
											'int') [TYPE_DEMAND_CODE]
			,[X].[Rec].[query]('./TYPE_DEMAND_NAME').[value]('.',
											'varchar(50)') [TYPE_DEMAND_NAME]
			,[X].[Rec].[query]('./LINE_NUM').[value]('.',
											'int') [LINE_NUM]
		FROM
			@XML.[nodes]('/ArrayOfPassDetail/Detail') AS [X] ([Rec]);




		INSERT	INTO [wms].[OP_WMS_PASS_DETAIL]
				(
					[PASS_HEADER_ID]
					,[CLIENT_CODE]
					,[CLIENT_NAME]
					,[PICKING_DEMAND_HEADER_ID]
					,[DOC_NUM]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[DOC_NUM_POLIZA]
					,[CODIGO_POLIZA]
					,[NUMERO_ORDEN_POLIZA]
					,[WAVE_PICKING_ID]
					,[CREATED_DATE]
					,[CODE_WAREHOUSE]
					,[TYPE_DEMAND_CODE]
					,[TYPE_DEMAND_NAME]
					,[LINE_NUM]
				)
		SELECT
			@PASS_HEADER_ID
			,[CLIENT_CODE]
			,[CLIENT_NAME]
			,[PICKING_DEMAND_HEADER_ID]
			,[DOC_NUM]
			,[MATERIAL_ID]
			,[MATERIAL_NAME]
			,[QTY]
			,[DOC_NUM_POLIZA]
			,[CODIGO_POLIZA]
			,[NUMERO_ORDEN_POLIZA]
			,[WAVE_PICKING_ID]
			,[CREATED_DATE]
			,[CODE_WAREHOUSE]
			,[TYPE_DEMAND_CODE]
			,[TYPE_DEMAND_NAME]
			,[LINE_NUM]
		FROM
			@PASS_DETAIL;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];


	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;



END;
