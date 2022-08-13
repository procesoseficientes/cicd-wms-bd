-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 @ Team ERGON - Sprint ERGON EPONA
-- Description:	 Función para obtener el inventario comprometido en una tarea de picking por licencia. 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-03 ErgonTeam@Ganondorf
-- Description:	 Se agrega para que tome en cuenta las tareas de reubicación. 

-- Modificacion 9/12/2017 @ Reborn - Team Sprint Collin
					-- diego.as
					-- Se agrega PRIMARY KEY a la tabla temporal que se devuelve debido a que esta haciendo TABLE SCAN

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega el tipo 'IMPLOSION_INVENTARIO'
/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE] ()
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE] ()
RETURNS @COMMITED_INVENTORY TABLE (
  MATERIAL_ID VARCHAR(50)
 ,LICENCE_ID INT
 ,COMMITED_QTY NUMERIC(18, 4)
 ,CODE_WAREHOUSE VARCHAR(25)
 ,CLIENT_OWNER VARCHAR(25)
 ,PRIMARY KEY([MATERIAL_ID], [LICENCE_ID], [CODE_WAREHOUSE], [CLIENT_OWNER])
)
AS
BEGIN
  INSERT INTO @COMMITED_INVENTORY ([MATERIAL_ID], [LICENCE_ID], [COMMITED_QTY], [CODE_WAREHOUSE], [CLIENT_OWNER])
    SELECT DISTINCT
      [T].[MATERIAL_ID]
     ,[T].[LICENSE_ID_SOURCE] [LICENCE_ID]
     ,SUM([T].[QUANTITY_PENDING]) [COMMITED_QTY]
     ,[T].[WAREHOUSE_SOURCE] [CODE_WAREHOUSE]
     ,[T].[CLIENT_OWNER] [CLIENT_OWNER]
    FROM [wms].[OP_WMS_TASK_LIST] [T]
    WHERE [T].[TASK_TYPE] IN ('TAREA_PICKING', 'TAREA_REUBICACION','IMPLOSION_INVENTARIO')
    AND (T.IS_COMPLETED <> 1)
    AND (T.IS_PAUSED <> 3)
    AND (T.CANCELED_DATETIME IS NULL)
    GROUP BY [T].[LICENSE_ID_SOURCE]
            ,[T].[MATERIAL_ID]
            ,[T].[WAREHOUSE_SOURCE]
            ,[T].[CLIENT_OWNER]

  RETURN;
END