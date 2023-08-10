
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	12-01-2016
-- Description:			Obtiene el ultimo lote de la tarea

/*
-- Ejemplo de Ejecucion:				
				--EXEC  [SONDA].[SWIFT_SP_GET_LAST_BATCH_BY_TASK] @TASK_Id = 5219
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_LAST_BATCH_BY_TASK]
    @TASK_Id INT
	,@CODE_SKU VARCHAR(50)
AS
BEGIN 
	SET NOCOUNT ON;
	--
	SELECT TOP 1
		B.BATCH_ID BatchId
		,B.BATCH_SUPPLIER BatchSupplier
		,CONVERT(varchar,B.BATCH_SUPPLIER_EXPIRATION_DATE,111) AS BatchSupplierExpirationDate
		,B.STATUS Status
		,B.SKU Sku
		,B.QTY Qty
		,B.QTY_LEFT QtyLeft
		,B.LAST_UPDATE
		,B.LAST_UPDATE_BY LastUpdateBy
		,B.TASK_ID TaskId
		,(SELECT COUNT(P.PALLET_ID) FROM [SONDA].SWIFT_PALLET P WHERE P.TASK_ID = @TASK_Id) AS QtyPallet
	FROM [SONDA].[SWIFT_BATCH] B
	WHERE B.TASK_ID = @TASK_Id 
		AND B.STATUS = 'OPEN'
		AND B.SKU = @CODE_SKU
	ORDER BY B.BATCH_ID DESC
END
