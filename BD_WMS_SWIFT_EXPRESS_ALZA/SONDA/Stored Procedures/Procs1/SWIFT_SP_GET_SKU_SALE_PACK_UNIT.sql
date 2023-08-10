-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	04-05-2016
-- Description:			Obtiene las unidades de medida

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_SKU_SALE_PACK_UNIT]
		
*/		
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_SALE_PACK_UNIT]
		
AS
BEGIN
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos de las unidades de medida 
	-- ------------------------------------------------------------------------------------
	SELECT 
    PU.PACK_UNIT,
    PU.CODE_PACK_UNIT,
    PU.DESCRIPTION_PACK_UNIT,
    PU.LAST_UPDATE,
    PU.LAST_UPDATE_BY,
    PU.UM_ENTRY		
	FROM [SONDA].SONDA_PACK_UNIT PU 
	
END
