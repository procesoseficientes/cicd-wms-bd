-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		21-Nov-16 @ A-Team Sprint 5
-- Description:			    SP que obtiene las bonificaciones por multiplo de la ruta

-- Modificacion 31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agregan columnas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_SKU_MULTIPLE_FOR_ROUTE]
			@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_BONUS_LIST_BY_SKU_MULTIPLE_FOR_ROUTE (
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
	WHERE [BL].[CODE_ROUTE] = @CODE_ROUTE;
	--
	SELECT DISTINCT
		[BLS].[BONUS_LIST_ID]
		,[BLS].[CODE_SKU]
		,[BLS].[CODE_PACK_UNIT]
		,[BLS].[MULTIPLE]
		,[BLS].[CODE_SKU_BONUS]
		,[BLS].[BONUS_QTY]
		,[BLS].[CODE_PACK_UNIT_BONUES]
    ,[BLS].[PROMO_ID]
    ,[BLS].[PROMO_NAME]
    ,[BLS].[PROMO_TYPE]
    ,[BLS].[FREQUENCY]
	FROM [SONDA].[SWIFT_BONUS_LIST_BY_SKU_MULTIPLE] AS [BLS]
	INNER JOIN @BONUS_LIST [BL] ON ([BL].[BONUS_LIST_ID] = [BLS].[BONUS_LIST_ID])
	WHERE [BLS].[BONUS_LIST_ID] > 0;
END;
