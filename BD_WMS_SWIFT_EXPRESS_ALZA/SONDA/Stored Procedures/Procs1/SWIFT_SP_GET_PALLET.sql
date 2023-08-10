﻿
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			verifica si exsite el palletID

/*
-- Ejemplo de Ejecucion:				
				-- EXEC [SONDA].[SWIFT_SP_GET_PALLET] @PALLET_ID = 2


				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PALLET]
    @PALLET_ID AS INT
AS
BEGIN 
	SET NOCOUNT ON;

	SELECT
		P.PALLET_ID
		,P.BATCH_ID
		,P.STATUS
		,P.QTY
		,P.LAST_UPDATE
		,P.LAST_UPDATE_BY
		,P.WAREHOUSE
		,P.LOCATION
		,P.TASK_ID
		,B.SKU
		,B.BATCH_SUPPLIER
		,CONVERT(varchar,B.BATCH_SUPPLIER_EXPIRATION_DATE,111) AS BATCH_SUPPLIER_EXPIRATION_DATE		
		,S.DESCRIPTION_SKU
		,S.BARCODE_SKU
		,B.STATUS AS STATUS_BATCH
	FROM [SONDA].SWIFT_PALLET P
	INNER JOIN [SONDA].SWIFT_BATCH B ON (P.BATCH_ID = B.BATCH_ID)
	INNER JOIN [SONDA].SWIFT_VIEW_ALL_SKU S ON (B.SKU = S.CODE_SKU)
	WHERE P.PALLET_ID = @PALLET_ID
	AND P.QTY > 0


END
