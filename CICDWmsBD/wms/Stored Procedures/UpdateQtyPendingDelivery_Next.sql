-- =============================================
-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	28-Noviembre-2019 G-Force@Kioto
-- Description:			Actualiza el campo de cantidad pendiente en base al xml

/*
-- Ejemplo de Ejecucion:
		EXEC [wms].[UpdateQtyPendingDelivery_Next] @XML = '
			<DELIVERY>
				<UPDATE_ITEM>
					<EXTERNAL_ID>6199</EXTERNAL_ID>
					<EXTERNAL_DETAIL_ID>5512</EXTERNAL_DETAIL_ID>
					<CLIENT_CODE>C00002</CLIENT_CODE>
					<MATERIAL_ID>arium/100010</MATERIAL_ID>
					<QTY>500.0000</QTY>
					<QTY_PENDING>300.0000</QTY_PENDING>
					<CLIENT_ADDRESS>Km. 17.5 acceso a Barcenas, Villa Nueva, Centro de Distribución Guatemala</CLIENT_ADDRESS>
					<GENERATE_NEW_DELIVERY>1</GENERATE_NEW_DELIVERY>
					<LINE_NUM>4</LINE_NUM>
				</UPDATE_ITEM>
				<UPDATE_ITEM>
					<EXTERNAL_ID>6199</EXTERNAL_ID>
					<EXTERNAL_DETAIL_ID>5515</EXTERNAL_DETAIL_ID>
					<CLIENT_CODE>C00002</CLIENT_CODE>
					<MATERIAL_ID>arium/100043</MATERIAL_ID>
					<QTY>5652.0000</QTY>
					<QTY_PENDING>652.0000</QTY_PENDING>
					<CLIENT_ADDRESS>Km. 17.5 acceso a Barcenas, Villa Nueva, Centro de Distribución Guatemala</CLIENT_ADDRESS>
					<GENERATE_NEW_DELIVERY>1</GENERATE_NEW_DELIVERY>
					<LINE_NUM>5</LINE_NUM>
				</UPDATE_ITEM>
			</DELIVERY>
		'		
*/
-- =============================================  
CREATE PROCEDURE [wms].[UpdateQtyPendingDelivery_Next] (@XML XML)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		---------------------------------------------------------------------------------
		-- DECLARAMOS LAS VARIALBLES A UTILIZAR
		---------------------------------------------------------------------------------	
		DECLARE	@TEM_DETAIL TABLE (
				[EXTERNAL_ID] INT
				,[EXTERNAL_DETAIL_ID] INT
				,[CLIENT_CODE] VARCHAR(50)
				,[MATERIAL_ID] VARCHAR(50)
				,[QTY] DECIMAL(18, 4)
				,[QTY_PENDING] DECIMAL(18, 4)
				,[QTY_DELIVERED] DECIMAL(18, 4)
				,[CLIENT_ADDRESS] VARCHAR(500)
				,[GENERATE_NEW_DELIVERY] SMALLINT
				,[LINE_NUM] INT
			);

		--DECLARE	@TEMP_UPD_PICKING_DEMAND_DETAIL TABLE (
		--		[PICKING_DEMAND_DETAIL_ID] INT NULL
		--		,[PICKING_DEMAND_HEADER_ID] INT NULL
		--		,[MATERIAL_ID] VARCHAR(50) NULL
		--		,[LINE_NUM] INT NULL
		--		,[QTY_PENDING_DELIVERY] INT NULL
		--		,[QTY_DELIVERED] INT NULL
		--		,[CLIENT_CODE] VARCHAR(50)
		--		,[CLIENT_ADDRESS] VARCHAR(500)
		--	);

		---------------------------------------------------------------------------------
		-- INSERTAMOS LOS REGISTROS DEL XML
		---------------------------------------------------------------------------------

		INSERT	INTO @TEM_DETAIL
				(
					[EXTERNAL_ID]
					,[EXTERNAL_DETAIL_ID]
					,[CLIENT_CODE]
					,[MATERIAL_ID]
					,[QTY]
					,[QTY_PENDING]
					,[QTY_DELIVERED]
					,[CLIENT_ADDRESS]
					,[GENERATE_NEW_DELIVERY]
					,[LINE_NUM]
				)
		SELECT
			[x].[data].[query]('./EXTERNAL_ID').[value]('.',
											'INT')
			,					-- EXTERNAL_ID - int
			[x].[data].[query]('./EXTERNAL_DETAIL_ID').[value]('.',
											'INT')
			,				-- EXTERNAL_DETAIL_ID - int
			[x].[data].[query]('./CLIENT_CODE').[value]('.',
											'VARCHAR(50)')
			,			-- CLIENT_CODE - varchar(50)
			[x].[data].[query]('./MATERIAL_ID').[value]('.',
											'VARCHAR(50)')
			,			-- MATERIAL_ID - varchar(50)
			[x].[data].[query]('./QTY').[value]('.',
											'DECIMAL(18,4)')
			,					-- QTY - decimal
			[x].[data].[query]('./QTY_PENDING').[value]('.',
											'DECIMAL(18, 4)') -- QTY_PENDING
			,[x].[data].[query]('./QTY_DELIVERED').[value]('.',
											'DECIMAL(18, 4)')
			,		-- QTY_DELIVERED - decimal
			[x].[data].[query]('./CLIENT_ADDRESS').[value]('.',
											'VARCHAR(500)')
			,		-- CLIENT_ADDRESS - varchar(500)
			[x].[data].[query]('./GENERATE_NEW_DELIVERY').[value]('.',
											'SMALLINT')		-- GENERATE_NEW_DELIVERY - smallint
			,[x].[data].[query]('./LINE_NUM').[value]('.',
											'INT')	--LINE_NUM
		FROM
			@XML.[nodes]('/DELIVERY/UPDATE_ITEM') AS [x] ([data]);



		---------------------------------------------------------------------------------
		-- ACTUALIZAMOS LA NEXT_PICKING_DEMAND_DETAIL CON LO PENDIENTE DE ENTREGAR
		---------------------------------------------------------------------------------

		UPDATE
			[D]
		SET	
			[D].[QTY_PENDING_DELIVERY] = [DET_DEV].[QTY_PENDING]
			,[D].[QTY_DELIVERED] = [DET_DEV].[QTY_DELIVERED]
		FROM
			[wms].[OP_WMS_MANIFEST_DETAIL] [D]
		INNER JOIN @TEM_DETAIL [DET_DEV] ON (
											[D].[MANIFEST_HEADER_ID] = [DET_DEV].[EXTERNAL_ID]
											AND D.[MANIFEST_DETAIL_ID] = [DET_DEV].[EXTERNAL_DETAIL_ID]									
											);

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Result]
			,ERROR_MESSAGE() [Message]
			,@@ERROR [Code]
			,'0' [DbData];
	END CATCH;
	
	
END;