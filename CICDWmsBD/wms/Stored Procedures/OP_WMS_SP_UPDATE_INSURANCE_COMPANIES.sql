
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Resta el inventario de la tabla inv_x_licencia
/*
-- Ejemplo de Ejecucion:				
				--
				exec [wms].[OP_WMS_SP_UPDATE_INV_X_LICENSE] 
							@QTY ='75'
							,@Code_sku ='110017' 
							,@CUSTOMER ='C00330'
							,@RESULTADO =''
				--				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_INSURANCE_COMPANIES]
		@POLIZA_SEGURO VARCHAR(50)
		,@user varchar(50)
		,@Rpoliza varchar(250) output

as

DECLARE @INVENTARIO AS NUMERIC(18,2)
		,@DISPONIBLE AS  NUMERIC(18,2)
		,@TOTAL AS  NUMERIC(18,2)

select @INVENTARIO= SUM (PD.CUSTOMS_AMOUNT* pd.QTY)  --06042016
from [wms].[OP_WMS_POLIZA_HEADER] PH
INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] PD ON (PH.DOC_ID = PD.DOC_ID)
INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] IL ON (PD.SKU_DESCRIPTION = IL.MATERIAL_NAME)
INNER JOIN [wms].[OP_WMS_VIEW_INSURANCE_DOC] ID ON (ID.POLIZA_INSURANCE = PH.POLIZA_ASEGURADA)
WHERE PH.POLIZA_ASEGURADA =@POLIZA_SEGURO


SELECT @TOTAL = ID.AMOUNT  
FROM [wms].[OP_WMS_VIEW_INSURANCE_DOC] ID
WHERE ID.POLIZA_INSURANCE =@POLIZA_SEGURO

SET @DISPONIBLE= @TOTAL - @INVENTARIO
SET @Rpoliza = @DISPONIBLE 
select convert (varchar(25),@Rpoliza) + '#'+ CONVERT(varchar(25), @TOTAL ) RPoliza


UPDATE [wms].[OP_WMS_INSURANCE_DOCS]
SET AVAILABLE= @DISPONIBLE
	,LAST_UPDATED= GETDATE()
	,LAST_TXN_DATE= GETDATE()
	,LAST_UPDATED_BY = @user