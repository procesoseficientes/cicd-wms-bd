
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-07-06 Nexus@AgeOfEmpires
-- Description:	 Funcion que retorna todos los componentes de un masterpack recorriendo todos los niveles posibles 


/*
-- Ejemplo de Ejecucion:
			SELECT  * FROM [wms].[OP_WMS_FN_GET_MASTER_PACK_ALL_LEVEL_COMPONENTS] ('C00030/RD-001')
  SELECT * FROM [wms].[OP_WMS_MATERIALS] [OWM] WHERE [OWM].[IS_MASTER_PACK] = 1 
  SELECT * FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C] where master_pack_code = 'C00030/M-RD-003'
  
*/
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FN_GET_MASTER_PACK_ALL_LEVEL_COMPONENTS (@MATERIAL_ID VARCHAR(25))
RETURNS @CHILDS TABLE (
  MATERIAL_ID VARCHAR(50)
 ,LEVEL INT
 ,QTY INT
 ,IS_MASTER_PACK INT DEFAULT 0
)
AS
BEGIN

  --Agrega el primer nivel 
  INSERT INTO @CHILDS ([MATERIAL_ID], [LEVEL], [QTY], [IS_MASTER_PACK])
    SELECT
      [C].[COMPONENT_MATERIAL] MATERIAL_ID
     ,1 LEVEL
     ,[C].[QTY] QTY
     ,[M].[IS_MASTER_PACK]
    FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
    INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
      ON [C].[COMPONENT_MATERIAL] = [M].[MATERIAL_ID]
    WHERE [C].[MASTER_PACK_CODE] = @MATERIAL_ID

  --Guardar un contador de hijos actuales
  DECLARE @COUNT_HIJOS INT
  SELECT
    @COUNT_HIJOS = COUNT(*)
  FROM @CHILDS


  ---------------------------------------------------------------------------------
  -- Inicia ciclo hasta no encontrar mas hijos posibles de los materiales 
  ---------------------------------------------------------------------------------  
  WHILE @COUNT_HIJOS <> (SELECT
        @COUNT_HIJOS + COUNT(*)
      FROM @CHILDS [H]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[MASTER_PACK_CODE] = [H].[MATERIAL_ID]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM @CHILDS [H1]
        WHERE [H1].[MATERIAL_ID] = [C].[COMPONENT_MATERIAL]))
  BEGIN

    ---------------------------------------------------------------------------------
    -- Agrega el nuevo nivel encontrado con sus cantidades correctas 
    ---------------------------------------------------------------------------------  
    INSERT INTO @CHILDS
      SELECT
        [C].[COMPONENT_MATERIAL] MATERIAL_ID
       ,[H].[LEVEL] + 1 [LEVEL]
       ,[C].[QTY] * [H].[QTY] QTY
       ,[M].[IS_MASTER_PACK]
      FROM @CHILDS [H]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[MASTER_PACK_CODE] = [H].[MATERIAL_ID]
      INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
        ON [C].[COMPONENT_MATERIAL] = [M].[MATERIAL_ID]
    --WHERE NOT EXISTS (SELECT TOP 1
    --    1
    --  FROM @CHILDS [H1]
    --  WHERE [H1].[MATERIAL_ID] = [C].[COMPONENT_MATERIAL])

    SELECT
      @COUNT_HIJOS = COUNT(*)
    FROM @CHILDS [H]
  END

  RETURN;
END