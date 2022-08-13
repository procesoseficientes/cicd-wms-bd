

-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Consulta de Zonas por Bodega


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-31 ErgonTeam@sHEIK
-- Description:	 Se modifica para consultar la zona a la nueva tabla de zonas. 





/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_ZONES_BY_WAREHOUSE]  @WAREHOUSE = 'BODEGA_01|BODEGA_02'
   SELECT * FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_ZONES_BY_WAREHOUSE (@WAREHOUSE VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [W].[VALUE] [CODE_WAREHOUSE] INTO #WAREHOUSE
  FROM [wms].[OP_WMS_FN_SPLIT](@WAREHOUSE, '|') [W]

  SELECT
    [S].[ZONE]
    ,[Z].[DESCRIPTION]
    
  FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
  INNER JOIN [#WAREHOUSE] [W]
    ON [S].[WAREHOUSE_PARENT] = W.[CODE_WAREHOUSE]

  INNER JOIN [wms].[OP_WMS_ZONE] [Z]
    ON  Z.ZONE =  S.ZONE  
  GROUP BY [S].[ZONE]
    ,Z.DESCRIPTION

END