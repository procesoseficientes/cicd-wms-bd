-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-03-24 @ Team ERGON - Sprint Hyper
-- Description:	        Funcion que obtiene el inventario reservado


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 Team ERGON - Sprint ERGON EPONA
-- Description:	 Se modifica para que el inventario reservado realize un SUM a las tareas pendientes

-- Modificación: pablo.aguilar
-- Fecha de Modificaci[on: 2017-05-03 ErgonTeam@Ganondorf
-- Description:	 Se agrega para que tome en cuenta tambien a las tareas de reubicación

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega el tipo de implosion para inventario reservado



/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].OP_WMS_FUNC_GET_INVENTORY_RESERVED()
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_INVENTORY_RESERVED] ()
RETURNS @MATERIALES_RESERVADO TABLE (
  CODE_WAREHOUSE VARCHAR(25)
 ,CODE_MATERIAL VARCHAR(50)
 ,QTY_RESERVED NUMERIC(18, 4)
)
AS
BEGIN


  INSERT INTO @MATERIALES_RESERVADO
    SELECT
      [T].[WAREHOUSE_SOURCE]
     ,[T].[MATERIAL_ID]
     ,SUM([T].[QUANTITY_PENDING]) RESERVADO
    FROM [wms].[OP_WMS_TASK_LIST] [T]
    WHERE [T].[TASK_TYPE] IN ('TAREA_PICKING', 'TAREA_REUBICACION','IMPLOSION_INVENTARIO')
    AND (T.[IS_COMPLETED] <> 1)
    AND (T.[IS_PAUSED] <> 3)
    AND (T.[CANCELED_DATETIME] IS NULL)
    GROUP BY [T].[MATERIAL_ID]
            ,[T].[WAREHOUSE_SOURCE]

  RETURN;
END