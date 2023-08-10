-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que obtiene todos los sku con sus unidades de medida para asociarlos a la bonificacion de un acuerdo comercial

-- Modificado:			26-09-2016 @ A-TEAM Sprint 1
-- Autor:				diego.as
-- Descripcion:			Se agrega LEFT JOIN para que traiga los SKUS que no tienen familia de dku

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_SKU_WITH_PACK_UNIT
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_SKU_WITH_PACK_UNIT
AS
BEGIN
	SELECT
		S.CODE_SKU
		,S.DESCRIPTION_SKU
		,(CASE WHEN S.CODE_FAMILY_SKU IS NULL THEN 'SIN FAMILIA' ELSE S.CODE_FAMILY_SKU END) AS  CODE_FAMILY_SKU
		,(CASE WHEN FU.DESCRIPTION_FAMILY_SKU IS NULL THEN	'SIN DESCRIPCION' ELSE FU.DESCRIPTION_FAMILY_SKU END) AS DESCRIPTION_FAMILY_SKU
		,PU.PACK_UNIT
		,PU.CODE_PACK_UNIT
		,PU.DESCRIPTION_PACK_UNIT
	FROM [SONDA].SWIFT_VIEW_ALL_SKU S
	INNER JOIN [SONDA].SONDA_PACK_CONVERSION PC ON (
		S.CODE_SKU = PC.CODE_SKU
	)
	INNER JOIN [SONDA].SONDA_PACK_UNIT PU ON (
		PU.CODE_PACK_UNIT = PC.CODE_PACK_UNIT_FROM
	)
	LEFT JOIN [SONDA].SWIFT_FAMILY_SKU FU ON(
		FU.CODE_FAMILY_SKU = S.CODE_FAMILY_SKU
	)
END
