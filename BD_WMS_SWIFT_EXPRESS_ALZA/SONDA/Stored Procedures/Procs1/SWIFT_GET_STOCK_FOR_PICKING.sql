-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	1-25-2016
-- Description:			Obtiene el inventario para picking 

-- Modificacion 02-03-2016
          -- rudi.garcia
          -- Se agrego el parametro a SWIFT_FN_GET_INVENTORY_RESERVED para que solo filtro por la bodega

/*	Ejemplo de execucion
		EXEC [SONDA].SWIFT_GET_STOCK_FOR_PICKING @CODE_WAREHOUSE = 'C001'
*/
-- =============================================

CREATE PROC [SONDA].[SWIFT_GET_STOCK_FOR_PICKING]
@CODE_WAREHOUSE VARCHAR(50)
AS
	SELECT *
	INTO #RESERVED
	FROM [SONDA].[SWIFT_FN_GET_INVENTORY_RESERVED](@CODE_WAREHOUSE)
	--
	SELECT *
	INTO #TEMP
	FROM [SONDA].[SWIFT_FN_GET_INVENTORY_RESERVED_TEMP]()
	--
	SELECT
		INVENTORY = IDENTITY(int,1,1)
    	,A.SKU AS CODE_SKU
    	,MAX(A.SKU_DESCRIPTION) AS SKU_DESCRIPTION
    	,0 AS ON_HAND
    	,0 AS RESERVED
    	,(
      	  SUM(ON_HAND)-
      	  (
        	COALESCE(MAX(IR.QYT_RESERVED), 0)
        	)-
        	COALESCE(MAX(IRT.QYT_RESERVED),0)
    	) AS TO_SALE
	INTO #RESULT
	FROM [SONDA].SWIFT_INVENTORY A
	LEFT JOIN #RESERVED IR ON (A.SKU = IR.CODE_SKU)
	LEFT JOIN #TEMP IRT ON (A.SKU = IRT.CODE_SKU)
	WHERE A.ON_HAND > 0
		AND A.LAST_UPDATE_BY != 'BULK_DATA'
		AND A.WAREHOUSE = @CODE_WAREHOUSE
	GROUP BY A.SKU
	--ORDER BY A.SKU
	--
	SELECT * FROM #RESULT WHERE TO_SALE > 0
