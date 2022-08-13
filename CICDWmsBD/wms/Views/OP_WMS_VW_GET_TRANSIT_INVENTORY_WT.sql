


-- =============================================
-- Autor:					Michael Mazariegos
-- Fecha de Creacion: 		13 Julio 2021
-- Description:			    vista que muestra la cantidad de material en transito por manifiesto de carga

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_VW_GET_TRANSIT_INVENTORY_WT]
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VW_GET_TRANSIT_INVENTORY_WT]
AS
(

		SELECT  [DT].[WAREHOUSE_TO]
		,[DT].[MATERIAL_ID]
		,SUM([DT].[RESERVADO]) [RESERVADO] 
		, [DT].[Tipo] FROM  (

			SELECT
			 [TRH].[WAREHOUSE_TO]
			,[T].[MATERIAL_ID]
			,SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) [RESERVADO]
			,'Transferencia' [Tipo]
		FROM
				[wms].[OP_WMS_TASK_LIST] [T]
				INNER JOIN [wms].[OP_WMS_MATERIALS] M ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
				INNER JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON [TRH].TRANSFER_REQUEST_ID = [T].TRANSFER_REQUEST_ID
				INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[TRANSFER_REQUEST_ID] = [T].[TRANSFER_REQUEST_ID]
			WHERE
				[T].[TASK_TYPE] = 'TAREA_PICKING'
				AND [T].[TASK_SUBTYPE] = 'DESPACHO_WT'
				--AND [T].[IS_COMPLETED] = 1
				AND [MH].[STATUS] = 'CREATED' -- VALIDACIÓN PARA QUE APAREZCA EL REGISTRO HASTA SER RECEPCIONADO
				AND ([T].[IS_PAUSED] <> 3)
				AND ([T].[CANCELED_DATETIME] IS NULL)
				AND [T].[WAVE_PICKING_ID] IN (
				SELECT
					[H].[WAVE_PICKING_ID]
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]	
					--INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [M] ON [M].[TRANSFER_REQUEST_ID] = [H].[TRANSFER_REQUEST_ID]
					--INNER JOIN [SAPSERVER].SBOwms.[dbo].[OWTQ] R ON R.[DocEntry] = [H].[DOC_ENTRY] AND R.[DocStatus]= 'O'
					--INNER JOIN [SAPSERVER].SBOwms.[dbo].[WTQ1] d ON [R].[DocEntry] = d.[DocEntry] AND  [d].[LineStatus] ='O'
					--AND [M].[ITEM_CODE_ERP] =  D.[ItemCode] COLLATE SQL_Latin1_General_CP850_CI_AS
				WHERE
					[H].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
					
					----AND [H].[IS_POSTED_ERP] <> 1 --AND [H].[WAVE_PICKING_ID] NOT IN ( 896, 3328) 
					)
			GROUP BY
			 [TRH].[WAREHOUSE_TO]
				,[T].[MATERIAL_ID]
				,[T].[WAREHOUSE_SOURCE]
			HAVING
				SUM([T].[QUANTITY_ASSIGNED] - [T].[QUANTITY_PENDING]) > 0
			) AS DT 
		GROUP BY [DT].[WAREHOUSE_TO]
				,[DT].[MATERIAL_ID]
				,tipo
	)	
