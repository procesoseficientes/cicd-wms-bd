-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			Trae las listas de ventas por multiplo por SKU de los clientes de las tareas asignadas al dia de trabajo

-- Modificacion 31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agregan columnas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU_FOR_ROUTE]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU_FOR_ROUTE (
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SALES_BY_MULTIPLE_LIST TABLE (
		[SALES_BY_MULTIPLE_LIST_ID] INT
		,UNIQUE([SALES_BY_MULTIPLE_LIST_ID])
	)
	--
	INSERT INTO @SALES_BY_MULTIPLE_LIST
			([SALES_BY_MULTIPLE_LIST_ID])
	SELECT [SM].[SALES_BY_MULTIPLE_LIST_ID]
	FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
	WHERE [SM].[CODE_ROUTE] = @CODE_ROUTE
	--
	SELECT DISTINCT
		[SMS].[SALES_BY_MULTIPLE_LIST_ID]
		,[SMS].[CODE_SKU]
		,[SMS].[CODE_PACK_UNIT]
		,[SMS].[MULTIPLE]
    ,[SMS].[PROMO_ID]
    ,[SMS].[PROMO_NAME]
    ,[SMS].[PROMO_TYPE]
    ,[SMS].[FREQUENCY]
	FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU] AS [SMS]
	INNER JOIN @SALES_BY_MULTIPLE_LIST [SM] ON (
		[SM].[SALES_BY_MULTIPLE_LIST_ID] = [SMS].[SALES_BY_MULTIPLE_LIST_ID]
	)
	WHERE [SMS].[SALES_BY_MULTIPLE_LIST_ID] > 0;
END
