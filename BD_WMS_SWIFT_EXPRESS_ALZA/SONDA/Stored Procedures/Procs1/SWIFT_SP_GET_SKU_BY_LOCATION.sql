/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_GET_SKU_BY_LOCATION]   Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	02-12-2015
-- Description:			Trae todos los SKUs de las ubicaciones por bodega
--                      
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_GET_SKU_BY_LOCATION] @WAREHOUSE='BODEGA_CENTRAL', @LOCATION='A3'
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_BY_LOCATION]
	@WAREHOUSE VARCHAR(50),
	@LOCATION VARCHAR(50)
AS
	SELECT  
		I.INVENTORY
		,I.SKU
		,I.SKU_DESCRIPTION
		,I.ON_HAND
		,CASE  
			WHEN I.SERIAL_NUMBER != '' THEN I.SERIAL_NUMBER
			ELSE '...'
		END AS SERIAL_NUMBER
	FROM [SONDA].[SWIFT_INVENTORY] I
	WHERE I.WAREHOUSE = @WAREHOUSE
		AND I.LOCATION = @LOCATION
		AND I.ON_HAND > 0
	Order by (I.SKU)
