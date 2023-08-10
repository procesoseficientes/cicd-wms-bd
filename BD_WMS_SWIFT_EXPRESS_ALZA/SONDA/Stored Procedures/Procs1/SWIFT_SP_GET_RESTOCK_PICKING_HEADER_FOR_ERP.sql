-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		02-09-2016
-- Description:			    Retorna el picking header de una tarea de reabastecimiento con el formato para enviar a SAP para realizar un warehouse transfer request.

/*
-- DROP PROCEDURE [SONDA].[SWIFT_SP_GET_RESTOCK_PICKING_HEADER_FOR_ERP]

-- Ejemplo de Ejecucion:
        EXEC  [SONDA].[SWIFT_SP_GET_RESTOCK_PICKING_HEADER_FOR_ERP] @PICKING_HEADER ='1003'
          
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_RESTOCK_PICKING_HEADER_FOR_ERP] (@PICKING_HEADER INT)

AS
BEGIN
  SELECT 
	PICKING_HEADER 
	,CAST(NULL AS VARCHAR(50)) CardCode
	,CODE_WAREHOUSE_SOURCE FromWarehouse 
	,PICKING_HEADER DocEntry
	,CLASSIFICATION_PICKING Classification
	,CAST(0 AS INT) DocRate
	,GETDATE() DocDate
	,CAST(0 AS INT) DocEntry
	,CAST(0 AS INT) DocNum
  FROM [SONDA].[SWIFT_PICKING_HEADER] H
  WHERE PICKING_HEADER = @PICKING_HEADER
  
END
