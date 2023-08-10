-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		28-Nov-16 @ A-Team Sprint 5
-- Description:			      se agrego validacion on_hand > 0 

-- Modificacion 6/16/2017 @ A-Team Sprint Jibade
					-- diego.as
					-- Se agrega columna en el WHERE para filtrar solo las etiquetas que realmente tienen informacion.
/*
  EJEMPLO:
  SELECT * FROM [SONDA].S_INVENTORY_SERIAL('C001')
*/
-- =============================================
CREATE  FUNCTION [SONDA].[S_INVENTORY_SERIAL]
(        
-- Add the parameters for the function here
@Warehouse nvarchar(8) = 'PG.GUM01'
)
RETURNS TABLE 
AS
RETURN 
(
-- Add the SELECT statement with parameter references here
SELECT 
	i.SKU SKU
	,i.SERIAL_NUMBER		AS SKU_SERIE
	,''	AS SKU_PHONE
	,''		AS SKU_ICC
	,i.WAREHOUSE		AS WAREHOUSE
FROM 
 [SONDA].[SWIFT_INVENTORY] i 
WHERE 	
i.WAREHOUSE = @Warehouse 
 AND  i.ON_HAND > 0
 AND ISNULL(i.[SERIAL_NUMBER], 'N/A') <> 'N/A'
)
