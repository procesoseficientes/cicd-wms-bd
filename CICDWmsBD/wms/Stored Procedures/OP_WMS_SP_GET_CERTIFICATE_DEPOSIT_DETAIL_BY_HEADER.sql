-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Trae TODOS los registros de la Tabla 
--                   [[wms]].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] 
--                   con transacción y control de errores.
--                   Recibe como parámetro:
/*
                    @ID_DEPOSIT_HEADER INT
                
*/
/*
Ejemplo de Ejecucion:
                --
                EXEC [wms].OP_WMS_SP_GET_CERTIFICATE_DEPOSIT_DETAIL_BY_HEADER
                    @ID_DEPOSIT_HEADER = 2
                --    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CERTIFICATE_DEPOSIT_DETAIL_BY_HEADER] (@ID_DEPOSIT_HEADER INT)

AS
BEGIN
  SET NOCOUNT ON;


  SELECT

    [CDD].[CERTIFICATE_DEPOSIT_ID_DETAIL]
   ,[CDD].[CERTIFICATE_DEPOSIT_ID_HEADER]
   ,[CDD].[DOC_ID]
   ,[CDD].[MATERIAL_CODE]
   ,[CDD].[SKU_DESCRIPTION]
   ,[CDD].[LOCATIONS]
   ,[CDD].[BULTOS]
   ,[CDD].[QTY]
   ,ISNULL( CAST(([PD].[CUSTOMS_AMOUNT] / [PD].[QTY]) as NUMERIC(18,2)), 0 )AS [UNIT_VALUE]
   ,ISNULL([PD].[CUSTOMS_AMOUNT], 0) AS [CUSTOMS_AMOUNT]
  FROM [wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] AS [CDD]
  LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
    ON (
    [CDD].[DOC_ID] = [PD].[DOC_ID]
    AND [CDD].[MATERIAL_CODE] = [PD].[MATERIAL_ID]
    )
  WHERE CDD.CERTIFICATE_DEPOSIT_ID_HEADER = @ID_DEPOSIT_HEADER

END