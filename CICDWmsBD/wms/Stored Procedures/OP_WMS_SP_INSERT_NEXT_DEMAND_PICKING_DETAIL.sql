-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint ERGON II
-- Description:	        realiza insersión de todos los campos en OP_WMS_NEXT_PICKING_DEMAND_DETAIL

-- Modificado:	        pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint EPONA
-- Description:	        Se llama a insertar a la linea de picking en caso se utilice linea de picking. 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-19 ErgonTeam@Sheik
-- Description:	 Se cambia el campo de cantidad de int a numerico 

-- Modificacion 7/14/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- rodrigo.gomez
-- Se agregaron los parametros @WAS_IMPLODED y @QTY_IMPLODED y se agregan al insert

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
					-- rodrigo.gomez
					-- Se agregan las columnas intercompany

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se inserta en TRANSFER_REQUEST_DETAIL cuando sea un WT-ERP

-- Modificacion 9/18/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agrean columnas TONE y CALIBER

-- Modificacion 04-Oct-17 @ Nexus Team Sprint 
					-- alberto.ruiz
					-- Se quita llamada a linea de picking

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_INSERT_NEXT_DEMAND_PICKING_DETAIL] @PICKING_DEMAND_HEADER_ID = 4131, 
                                                                    @MATERIAL_ID = 'wms/100019',
                                                                    @QTY = 2.5000,
                                                                    @LINE_NUM = 1,
                                                                    @ERP_OBJECT_TYPE  = 0,
                                                                    @PRICE  = 10.000000,
																	@WAS_IMPLODED = 0,
																	@QTY_IMPLODED = 0,
																	@MASTER_ID_MATERIAL = '100019',
																	@MATERIAL_OWNER = 'wms'
																	,@TONE = '1412'
																	, @CALIBER = '2013'
  SELECT * FROM BEGIN
                    [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
                END [OWNPDD]  where [OWNPDD].[MATERIAL_ID] = 'wms/100018'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_NEXT_DEMAND_PICKING_DETAIL] (
		@PICKING_DEMAND_HEADER_ID INT
		,@MATERIAL_ID VARCHAR(50)
		,@QTY NUMERIC(18, 4)
		,@LINE_NUM INT
		,@ERP_OBJECT_TYPE INT
		,@PRICE NUMERIC(18, 6)
		,@WAS_IMPLODED INT = 0
		,@QTY_IMPLODED INT
		,@MASTER_ID_MATERIAL VARCHAR(50) = NULL
		,@MATERIAL_OWNER VARCHAR(50) = NULL
		,@SOURCE_TYPE VARCHAR(50) = NULL
		,@TONE VARCHAR(20) = NULL
		,@CALIBER VARCHAR(20) = NULL
		,@DISCOUNT DECIMAL(18, 6) = NULL
		,@IS_BONUS INT = NULL
		,@DISCOUNT_TYPE VARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE
			@CURRENT_WAREHOUSE VARCHAR(50)
			,@CLIENT_OWNER VARCHAR(50)
			,@CLIENT_NAME VARCHAR(100)
			,@CLIENT_ROUTE VARCHAR(50)
			,@MATERIAL_NAME VARCHAR(200)
			,@ERP_DOCUMENT VARCHAR(15)
			,@ASSIGNED_BY VARCHAR(50)
			,@WAVE_PICKING_ID INT
			,@TASK_OWNER VARCHAR(25);
    
		SELECT TOP 1
			@CLIENT_OWNER = [H].[CLIENT_CODE]
			,@CLIENT_NAME = [H].[CLIENT_NAME]
			,@CLIENT_ROUTE = [H].[CODE_ROUTE]
			,@MATERIAL_NAME = [T].[MATERIAL_NAME]
			,@CURRENT_WAREHOUSE = [T].[WAREHOUSE_SOURCE]
			,@ASSIGNED_BY = [H].[LAST_UPDATE_BY]
			,@WAVE_PICKING_ID = [H].[WAVE_PICKING_ID]
			,@TASK_OWNER = [T].[TASK_OWNER]
			,@ERP_DOCUMENT = CASE	WHEN [H].[IS_FROM_SONDA] = 1
									THEN 'SO-'
									ELSE 'SA-'
								END
			+ CAST([H].[DOC_NUM] AS VARCHAR)
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [H].[WAVE_PICKING_ID]
											AND [T].[MATERIAL_ID] = @MATERIAL_ID
		WHERE
			[H].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
    
		DECLARE	@DOC_ID INT;
		INSERT	INTO [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
				(
					[PICKING_DEMAND_HEADER_ID]
					,[MATERIAL_ID]
					,[QTY]
					,[LINE_NUM]
					,[ERP_OBJECT_TYPE]
					,[PRICE]
					,[WAS_IMPLODED]
					,[QTY_IMPLODED]
					,[MASTER_ID_MATERIAL]
					,[MATERIAL_OWNER]
					,[TONE]
					,[CALIBER]
					,[DISCOUNT]		
					,[IS_BONUS] 		
					,[DISCOUNT_TYPE]	
    			)
		VALUES
				(
					@PICKING_DEMAND_HEADER_ID
					,@MATERIAL_ID
					,@QTY
					,@LINE_NUM
					,@ERP_OBJECT_TYPE
					,@PRICE
					,@WAS_IMPLODED
					,@QTY_IMPLODED
					,@MASTER_ID_MATERIAL
					,@MATERIAL_OWNER
					,@TONE
					,@CALIBER
					,@DISCOUNT		
					,@IS_BONUS	
					,@DISCOUNT_TYPE
    			);
    
		IF @SOURCE_TYPE = 'WT - ERP'
		BEGIN
			DECLARE	@TRANSFER_REQUEST_ID INT;
    		--
			SELECT
				@TRANSFER_REQUEST_ID = [TRANSFER_REQUEST_ID]
			FROM
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
    		--
			INSERT	INTO [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL]
					(
						[TRANSFER_REQUEST_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[IS_MASTERPACK]
						,[QTY]
						,[STATUS]
    				)
			SELECT TOP 1
				@TRANSFER_REQUEST_ID
				,@MATERIAL_ID
				,[MATERIAL_NAME]
				,[IS_MASTER_PACK]
				,@QTY
				,'OPEN'
			FROM
				[wms].[OP_WMS_MATERIALS]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID;
		END;
    
		SET @DOC_ID = SCOPE_IDENTITY();
    
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@DOC_ID AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;