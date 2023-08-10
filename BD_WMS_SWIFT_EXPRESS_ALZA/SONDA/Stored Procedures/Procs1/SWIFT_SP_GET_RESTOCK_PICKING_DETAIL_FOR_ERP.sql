-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		02-09-2016
-- Description:			    Retorna el picking detalle de una tarea de reabastecimiento con el formato para enviar a SAP para realizar un warehouse transfer request.

/*
-- DROP PROCEDURE [SONDA].[SWIFT_SP_GET_RESTOCK_PICKING_DETAIL_FOR_ERP]

-- Ejemplo de Ejecucion:
        EXEC  [SONDA].[SWIFT_SP_GET_RESTOCK_PICKING_DETAIL_FOR_ERP] @PICKING_HEADER ='1003'
          
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_RESTOCK_PICKING_DETAIL_FOR_ERP] (@PICKING_HEADER INT)

AS
BEGIN
	SELECT
		spd.PICKING_DETAIL DoEntry
	   ,CAST(0 AS INT) DocEntryErp
	   ,spd.CODE_SKU  ItemCode
	   ,spd.DESCRIPTION_SKU ItemDescription
	   ,CAST(spd.Dispatch AS INT) Quantity	   
	   ,CAST(0 AS INT) ObjType
	   ,CAST(0 AS INT) LineNum

	  FROM [SONDA].SWIFT_PICKING_DETAIL spd
	  WHERE spd.PICKING_HEADER = @PICKING_HEADER;  
END
