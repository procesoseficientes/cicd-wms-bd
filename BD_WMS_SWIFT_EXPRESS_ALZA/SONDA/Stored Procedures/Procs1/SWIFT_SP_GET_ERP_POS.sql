-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-18-2016
-- Description:			se obtienen las series de los producto de un recepcion para ser enviada a ERP

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
      
      EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_SOS @PICKING_HEADER
      GO
*/
-- =============================================
CREATE PROC [SONDA].SWIFT_SP_GET_ERP_POS
@RECEPTION_HEADER VARCHAR(50)
AS
SELECT 	
	 @RECEPTION_HEADER AS DocEntry
	, t.TXN_CODE_SKU AS ItemCode	
	, TS.Txn_Serie  as TxnSerie
  , 'AVAILABLE' STATUS 
FROM [SONDA].SWIFT_TXNS T
	INNER JOIN [SONDA].SWIFT_TXNS_SERIES TS ON (T.TXN_ID = TS.TXN_ID AND T.TXN_CODE_SKU = TS.TXN_CODE_SKU)
WHERE T.HEADER_REFERENCE = @RECEPTION_HEADER
AND T.TXN_TYPE='PUTAWAY';
