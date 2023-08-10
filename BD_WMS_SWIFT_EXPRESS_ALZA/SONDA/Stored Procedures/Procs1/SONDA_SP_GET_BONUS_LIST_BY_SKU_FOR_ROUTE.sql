-- =====================================================
-- Author:         rudi.garcia
-- Create date:    19-08-2016
-- Description:    Trae las listas de bonificaciones por SKU de los clientes  
--				   de las tareas asignadas al dia de trabajo

-- Modificacion 20-09-2016 @ A-TEAM Sprint 1
	-- alberto.ruiz
	-- Se agrego que obtenga los decuentos por el nombre de la lista de bonificacion

-- Modificacion 31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agregan columnas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
					-- rudi.garcia
					-- Se agrego la columna de "FREQUENCY"

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_SKU_FOR_ROUTE]
			@CODE_ROUTE = '44'

*/
-- =====================================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_BONUS_LIST_BY_SKU_FOR_ROUTE (
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@BONUS_LIST TABLE (
		[BONUS_LIST_ID] INT
		,UNIQUE ([BONUS_LIST_ID])
	);
	--
	INSERT INTO @BONUS_LIST
			([BONUS_LIST_ID])
	SELECT [BL].[BONUS_LIST_ID]
	FROM [SONDA].[SWIFT_BONUS_LIST] [BL]
	WHERE [CODE_ROUTE] = @CODE_ROUTE;
	--
	SELECT DISTINCT
		[BLS].[BONUS_LIST_ID]
		,[BLS].[CODE_SKU]
		,[BLS].[CODE_PACK_UNIT]
		,[BLS].[LOW_LIMIT]
		,[BLS].[HIGH_LIMIT]
		,[BLS].[CODE_SKU_BONUS]
		,[BLS].[BONUS_QTY]
		,[BLS].[CODE_PACK_UNIT_BONUES]
		,[BLS].[PROMO_ID]
		,[BLS].[PROMO_NAME]
		,[BLS].[PROMO_TYPE]
    ,[BLS].[FREQUENCY]
	FROM [SONDA].[SWIFT_BONUS_LIST_BY_SKU] AS [BLS]
	INNER JOIN @BONUS_LIST [BL] ON ([BL].[BONUS_LIST_ID] = [BLS].[BONUS_LIST_ID])
	WHERE [BLS].[BONUS_LIST_ID] > 0;
END;
