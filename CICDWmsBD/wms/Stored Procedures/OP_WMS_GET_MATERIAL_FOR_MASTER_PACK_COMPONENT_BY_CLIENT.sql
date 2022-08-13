-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 @ Team ERGON - Sprint ERGON V
-- Description:	 Se crea SP para obtener materiales para asignar como componente de un masterpack. 

-- Modificacion:	      hector.gonzalez
-- Fecha de Creacion: 	2017-04-21 @ Team ERGON - Sprint EPONA
-- Description:	        se agrego validacion para que no tome en cuenta los masterpack padres


/*
-- Ejemplo de Ejecucion:
			exec [wms].[OP_WMS_GET_MATERIAL_FOR_MASTER_PACK_COMPONENT_BY_CLIENT] @MASTER_PACK_MATERIAL_ID  = 'wms/PT0001'
, @CLIENT_ID = 'wms'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_GET_MATERIAL_FOR_MASTER_PACK_COMPONENT_BY_CLIENT (@MASTER_PACK_MATERIAL_ID VARCHAR(50)
, @CLIENT_ID VARCHAR(50) = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --

  ---------------------------------------------------------------------------------
  -- VALIDAR PADRES
  ---------------------------------------------------------------------------------  
  SELECT
    [C].[MASTER_PACK_CODE] PARENT INTO #PADRES
  FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
  WHERE [C].[COMPONENT_MATERIAL] = @MASTER_PACK_MATERIAL_ID
  DECLARE @COUNT_PADRES INT
  SELECT
    @COUNT_PADRES = COUNT(*)
  FROM #PADRES

  WHILE @COUNT_PADRES <> (SELECT
        @COUNT_PADRES + COUNT(*)
      FROM [#PADRES] [P]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[COMPONENT_MATERIAL] = P.[parent]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM [#PADRES] [P1]
        WHERE [P1].[parent] = [C].[MASTER_PACK_CODE]))
  BEGIN
    INSERT INTO [#PADRES]
      SELECT
        [MASTER_PACK_CODE]
      FROM [#PADRES] [P]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[COMPONENT_MATERIAL] = P.[parent]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM [#PADRES] [P1]
        WHERE [P1].[parent] = [C].[MASTER_PACK_CODE])

    SELECT
      @COUNT_PADRES = COUNT(*)
    FROM #PADRES
  END


  ---------------------------------------------------------------------------------
  -- SE MUESTRA EL RESULTADO
  ---------------------------------------------------------------------------------  

  SELECT DISTINCT
    [OWM].[CLIENT_OWNER] [CLIENT_ID]
   ,[OWM].[MATERIAL_ID]
   ,[OWM].[MATERIAL_NAME]
   ,[OWM].[BARCODE_ID]
   ,0 [IS_SELECT]
   ,CASE [OWM].[IS_MASTER_PACK]
      WHEN 1 THEN 'Si'
      WHEN 0 THEN 'No'
    END AS [IS_MASTER_PACK]
  FROM [wms].[OP_WMS_MATERIALS] [OWM]
  LEFT JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CM]
    ON ([CM].[MASTER_PACK_CODE] = @MASTER_PACK_MATERIAL_ID
    AND [CM].[COMPONENT_MATERIAL] = [OWM].[MATERIAL_ID]
    )
  WHERE [CM].[MASTER_PACK_COMPONENT_ID] IS NULL
  AND (@CLIENT_ID IS NULL
  OR [OWM].[CLIENT_OWNER] = @CLIENT_ID)
  AND [OWM].[MATERIAL_ID] <> @MASTER_PACK_MATERIAL_ID
  AND [OWM].[MATERIAL_ID] NOT IN (SELECT
      *
    FROM [#PADRES] [p1])

END