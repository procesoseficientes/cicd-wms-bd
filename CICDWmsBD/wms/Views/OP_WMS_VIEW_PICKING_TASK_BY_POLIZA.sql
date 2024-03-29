﻿-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		07-nov-16 @ A-Team Sprint 4
-- Description:			      Se modifico columna PICKING_FINISHED_DATE por COMPLETED_DATE ya que daba error de otra historia

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].OP_WMS_VIEW_PICKING_TASK_BY_POLIZA
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VIEW_PICKING_TASK_BY_POLIZA
AS
SELECT A.WAVE_PICKING_ID	
	, TASK_SUBTYPE
	, TASK_ASSIGNEDTO
	, TASK_COMMENTS
	, (REGIMEN) AS REGIMEN	
	, (A.SERIAL_NUMBER) AS SERIAL_NUMBER
	, (ASSIGNED_DATE) AS ASSIGNED_DATE 
	, (A.COMPLETED_DATE) AS PICKING_FINISHED_DATE	
	, (QUANTITY_PENDING) AS QUANTITY_PENDING
	, (QUANTITY_ASSIGNED) AS QUANTITY_ASSIGNED
	, MATERIAL_ID, BARCODE_ID
	, MATERIAL_NAME
	, A.CODIGO_POLIZA_TARGET    
	, A.CODIGO_POLIZA_SOURCE    
	, (SELECT TOP (1) NUMERO_ORDEN
		FROM [wms].OP_WMS_POLIZA_HEADER AS B
		WHERE (CODIGO_POLIZA = (A.CODIGO_POLIZA_SOURCE)) AND (WAREHOUSE_REGIMEN = (A.REGIMEN))) AS NUMERO_ORDEN_SOURCE
	, (SELECT TOP (1) NUMERO_ORDEN
		FROM [wms].OP_WMS_POLIZA_HEADER AS B
		WHERE (CODIGO_POLIZA = (A.CODIGO_POLIZA_TARGET)) AND (WAREHOUSE_REGIMEN = (A.REGIMEN))) AS NUMERO_ORDEN_TARGET	
	, (CASE
		WHEN [CANCELED_BY] IS NULL THEN 0
		ELSE 1
		END	) AS CANCELED_BY
	, ISNULL((SUM(T.QUANTITY_UNITS * -1)),0) AS QUANTITY_UNITS											
FROM [wms].OP_WMS_TASK_LIST AS A
		INNER JOIN [wms].[OP_WMS_TRANS] T ON (A.CODIGO_POLIZA_TARGET = T.CODIGO_POLIZA				
													AND	A.[LICENSE_ID_SOURCE] = T.[LICENSE_ID]
													AND T.[TRANS_SUBTYPE] = 'PICKING')
GROUP BY  A.WAVE_PICKING_ID	
	, TASK_SUBTYPE
	, TASK_ASSIGNEDTO
	, TASK_COMMENTS
	, (REGIMEN) 
	, (A.SERIAL_NUMBER) 
	, (ASSIGNED_DATE) 
	, (A.COMPLETED_DATE)
	, (QUANTITY_PENDING) 
	, (QUANTITY_ASSIGNED)
	, MATERIAL_ID, BARCODE_ID
	, MATERIAL_NAME
	, A.CODIGO_POLIZA_TARGET    
	, A.CODIGO_POLIZA_SOURCE
	, CANCELED_BY


--GROUP BY WAVE_PICKING_ID, TASK_TYPE, TASK_SUBTYPE, TASK_ASSIGNEDTO, TASK_COMMENTS, MATERIAL_ID, BARCODE_ID, MATERIAL_NAME, A.CODIGO_POLIZA_TARGET, A.CODIGO_POLIZA_SOURCE