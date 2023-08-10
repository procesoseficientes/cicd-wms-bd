-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-15-2016
-- Description:			se obtienen las series de los producto de un picking para ser enviada a ERP

-- Modificado Fecha
		-- anonymous
		-- sin motivo alguno

/*
-- Ejemplo de Ejecucion:
      USE SWIFT_EXPRESS
      GO
      
      DECLARE @RC int
      DECLARE @PICKING_HEADER varchar(50)
      
      SET @PICKING_HEADER = '178' 
      
      EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_ITRS @PICKING_HEADER
      GO
*/
-- =============================================
CREATE PROC [SONDA].SWIFT_SP_GET_ERP_ITRS
   @PICKING_HEADER VARCHAR(50)
AS  
SELECT   
 CAST(@PICKING_HEADER AS INT) AS DocEntry ,
  st.TXN_CODE_SKU ItemCode,
  st.TXN_SERIE TxnSerie,
  'AVAILABLE'  STATUS 
  FROM [SONDA].SWIFT_TXNS st INNER JOIN [SONDA].SWIFT_TASKS st1
  ON st1.TASK_ID = st.TASK_SOURCE_ID
WHERE  st1.PICKING_NUMBER IS NOT NULL
AND  LEN(st.TXN_SERIE) > 0 
  AND st1.PICKING_NUMBER = @PICKING_HEADER;
