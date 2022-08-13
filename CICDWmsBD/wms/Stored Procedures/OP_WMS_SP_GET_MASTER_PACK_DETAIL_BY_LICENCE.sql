
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que devuelve un detalle de master pack 

-- Modificacion:        hector.gonzalez
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	        Se quito toda referencia hacia measure_unit


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-09-20 Nexus@DuckHunt
-- Description:	 Se agrega al select que filte por is_implosion = 0 and exploded = 0 ya que solo se muestrar masterpacks por explotar.


/*
 -- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MASTER_PACK_DETAIL_BY_LICENCE] @LICENCE_ID  =167628
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_MASTER_PACK_DETAIL_BY_LICENCE (@LICENCE_ID INT, @MATERIAL_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @CLIENT_CODE VARCHAR(50)

  ---Obtiene el cliente
  SELECT TOP 1
    @CLIENT_CODE = [L].[CLIENT_OWNER]
  FROM [wms].[OP_WMS_LICENSES] [L]
  WHERE [L].[LICENSE_ID] = @LICENCE_ID

  ---Obtiene el id del material
  SELECT TOP 1
    @MATERIAL_ID = [M].[MATERIAL_ID]
  FROM [wms].[OP_WMS_MATERIALS] [M]
  WHERE ([M].[MATERIAL_ID] = @MATERIAL_ID
  OR [M].[BARCODE_ID] = @MATERIAL_ID
  OR [M].[ALTERNATE_BARCODE] = @MATERIAL_ID)
  AND [M].[CLIENT_OWNER] = @CLIENT_CODE

  --
  SELECT
    [MPD].[MASTER_PACK_DETAIL_ID]
   ,[MPD].[MASTER_PACK_HEADER_ID]
   ,[MPD].[MATERIAL_ID]
   ,[M].[MATERIAL_NAME]
   ,[M].[CLIENT_OWNER] [CLIENT_CODE]
   ,[C].[CLIENT_NAME]
   ,[M].[BARCODE_ID]
   ,[MPD].[QTY]
   ,[MPD].[BATCH]
   ,[MPD].[DATE_EXPIRATION]
  FROM [wms].[OP_WMS_MASTER_PACK_DETAIL] [MPD]
  INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
    ON [MPD].[MASTER_PACK_HEADER_ID] = [H].[MASTER_PACK_HEADER_ID]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON [MPD].[MATERIAL_ID] = [M].[MATERIAL_ID]
  INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C]
    ON [M].[CLIENT_OWNER] = [C].[CLIENT_CODE]
  WHERE [H].[LICENSE_ID] = @LICENCE_ID
  AND H.[MATERIAL_ID] = @MATERIAL_ID
  AND [H].[IS_IMPLOSION] = 0
  AND [H].[EXPLODED] = 0


END