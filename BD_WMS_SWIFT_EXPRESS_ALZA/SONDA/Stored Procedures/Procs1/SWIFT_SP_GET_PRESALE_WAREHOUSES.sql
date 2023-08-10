-- Autor:				pedro.loukota
-- Fecha de Creacion: 	12-11-2015
-- Description:			Obtiene Bodegas de preventa
/*
-- Ejemplo de Ejecucion:				
				select [SONDA].SWIFT_SP_GET_PRESALE_WAREHOUSES
*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PRESALE_WAREHOUSES]


AS
BEGIN



		    SELECT  * FROM [SONDA].[SWIFT_WAREHOUSES] 
	
			
			
END
