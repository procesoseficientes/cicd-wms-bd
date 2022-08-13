﻿-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-24 @ Team REBORN - Sprint 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_CERTIFICATION_DETAIL_CONSOLIDATED @CERTIFICATION_HEADER_ID = 1150
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_CERTIFICATION_DETAIL_CONSOLIDATED (@CERTIFICATION_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [CD].[MATERIAL_ID]
   ,SUM([CD].[QTY]) [QTY]
   ,[CD].[CERTIFICATION_TYPE]   
  FROM [wms].[OP_WMS_CERTIFICATION_HEADER] [CH]
  INNER JOIN [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
    ON [CH].[CERTIFICATION_HEADER_ID] = [CD].[CERTIFICATION_HEADER_ID]  
  WHERE [CD].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
  GROUP BY [CD].[CERTIFICATION_TYPE]
          ,[CD].[MATERIAL_ID]   

END