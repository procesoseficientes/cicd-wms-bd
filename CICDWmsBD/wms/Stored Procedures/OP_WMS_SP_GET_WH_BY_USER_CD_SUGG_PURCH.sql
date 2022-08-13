
-- =============================================
-- Autor:			henry.rodriguez
-- Modificacion:	06-Marzo-2020 @ALZA-HN
-- Descripcion:		SP para obtener las bodegas por usuario solamente para el sugerido de compras.

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_WH_BY_USER_CD_SUGG_PURCH] @LOGIN = 'rrivera'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WH_BY_USER_CD_SUGG_PURCH] (@LOGIN VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [WU].[WAREHOUSE_BY_USER_ID]
   ,[WU].[LOGIN_ID]
   ,[WU].[WAREHOUSE_ID]
   ,[W].[NAME]
   ,[W].[ERP_WAREHOUSE]
  FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
  INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
    ON (
    [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
    )
  WHERE [WU].[LOGIN_ID] = @LOGIN

END

