-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-04 @ Team REBORN - Sprint Collin
-- Description:	        Obtiene el 

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_SUPPLIER_BY_DOCUMENT] @TASK_ID = 476558
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SUPPLIER_BY_DOCUMENT] (@TASK_ID NUMERIC)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT TOP 1
    [RDH].[CODE_SUPPLIER]
    ,[RDH].[NAME_SUPPLIER]      
  FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
  WHERE [RDH].[TASK_ID] = @TASK_ID

END