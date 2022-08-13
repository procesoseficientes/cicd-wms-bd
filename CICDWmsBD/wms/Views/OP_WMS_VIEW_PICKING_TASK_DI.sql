-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2016-11-07
-- Description:	 Se modifica campo de PICKING_FINISHED_DATE por COMPLETED_DATE 

-- Autor:	marvin.solares
-- Fecha: 	GForce@Madagascar 20191213
-- Description:	 se valida que pueda hacer transacciones para cualquier poliza


/*
-- Ejemplo de Ejecucion:
			select * from [wms].OP_WMS_VIEW_PICKING_TASK_DI
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_PICKING_TASK_DI]
AS
SELECT A.WAVE_PICKING_ID,
       A.TASK_TYPE,
       A.TASK_SUBTYPE,
       A.TASK_ASSIGNEDTO,
       A.TASK_COMMENTS,
       MAX(A.IS_PAUSED) AS IS_PAUSED,
       MAX(A.SERIAL_NUMBER) AS SERIAL_NUMBER,
       MAX(A.ASSIGNED_DATE) AS ASSIGNED_DATE,
       MAX(A.[COMPLETED_DATE]) AS PICKING_FINISHED_DATE,
       MAX(A.IS_CANCELED) AS IS_CANCELED,
       MAX(A.QUANTITY_PENDING) AS QUANTITY_PENDING,
       MAX(A.QUANTITY_ASSIGNED) AS QUANTITY_ASSIGNED,
       (
           SELECT TOP 1
                  B.NUMERO_ORDEN
           FROM [wms].OP_WMS_POLIZA_HEADER B
           WHERE B.CODIGO_POLIZA = A.CODIGO_POLIZA_SOURCE
                 AND REGIMEN LIKE '%DI%'
       ) AS NUMERO_ORDEN_SOURCE,
       (
           SELECT TOP 1
                  B.NUMERO_ORDEN
           FROM [wms].OP_WMS_POLIZA_HEADER B
           WHERE B.CODIGO_POLIZA = A.CODIGO_POLIZA_TARGET
                 AND REGIMEN LIKE '%DI%'
       ) AS NUMERO_ORDEN_TARGET,
       A.CODIGO_POLIZA_SOURCE,
       A.CODIGO_POLIZA_TARGET,
       A.MATERIAL_ID,
       A.BARCODE_ID,
       MATERIAL_NAME,
       (CASE MAX(A.IS_COMPLETED)
            WHEN 0 THEN
                'INCOMPLETA'
            ELSE
                'COMPLETA'
        END
       ) AS IS_COMPLETED
FROM [wms].OP_WMS_TASK_LIST A,
     [wms].OP_WMS_POLIZA_HEADER B
WHERE A.CODIGO_POLIZA_TARGET = B.CODIGO_POLIZA
GROUP BY A.WAVE_PICKING_ID,
         A.TASK_TYPE,
         A.TASK_SUBTYPE,
         A.TASK_ASSIGNEDTO,
         A.TASK_COMMENTS,
         A.CODIGO_POLIZA_SOURCE,
         A.CODIGO_POLIZA_TARGET,
         A.MATERIAL_ID,
         A.BARCODE_ID,
         A.MATERIAL_NAME;