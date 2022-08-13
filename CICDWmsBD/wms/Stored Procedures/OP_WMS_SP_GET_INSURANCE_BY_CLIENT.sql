
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Resta el inventario de la tabla inv_x_licencia
/*
-- Ejemplo de Ejecucion:				
				--
				exec [wms].[OP_WMS_SP_GET_INSURANCE_BY_CLIENT] 
							@QTY ='75'
							,@Code_sku ='110017' 
							,@CUSTOMER ='C00330'
							,@RESULTADO =''
				--				
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INSURANCE_BY_CLIENT]
		@CUSTOMER VARCHAR(50)
		,@INSURANCE VARCHAR (50) OUTPUT

AS
SELECT TOP 1   @INSURANCE=  POLIZA_INSURANCE
  FROM [wms].[OP_WMS_INSURANCE_DOCS]
  where CLIENT_CODE=@CUSTOMER
  SELECT @INSURANCE INSURANCE