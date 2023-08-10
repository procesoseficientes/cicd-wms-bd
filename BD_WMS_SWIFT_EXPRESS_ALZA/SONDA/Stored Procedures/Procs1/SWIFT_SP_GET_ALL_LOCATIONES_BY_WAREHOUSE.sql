/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_GET_ALL_LOCATIONES_BY_WAREHOUSE]   Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	02-12-2015
-- Description:			Trae todas los codigos de las ubicaciones por bodega
--                      
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_GET_ALL_LOCATIONES_BY_WAREHOUSE] @CODE_WAREHOUSE= 'BODEGA_CENTRAL'
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ALL_LOCATIONES_BY_WAREHOUSE]
@CODE_WAREHOUSE VARCHAR(50)
AS
SELECT L.[CODE_LOCATION]
FROM [SONDA].[SWIFT_LOCATIONS] L
INNER JOIN [SONDA].[SWIFT_WAREHOUSES] B 
ON L.[CODE_WAREHOUSE] = B.[CODE_WAREHOUSE]
AND B.[CODE_WAREHOUSE]= @CODE_WAREHOUSE
