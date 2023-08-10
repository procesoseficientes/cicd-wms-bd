-- =====================================================
-- Author:         rudi.garcia
-- Create date:    22-08-2016
-- Description:    Trae las listas descuentos por SKU de los clientes  
--				   de las tareas asignadas al dia de trabajo

-- Modificacion 19-09-2016 @ A-TEAM Sprint 1
				-- alberto.ruiz
				-- Se modifico para que por la ruta obtenga los SKU

-- Modificacion 2/13/2017 @ A-Team Sprint Chatuluka
	-- rodrigo.gomez
	-- Se agregaron las columnas PACK_UNIT, HIGH_LIMIT y LOW_LIMIT al select de SWIFT_DISCOUNT_LIST_BY_SKU

-- Modificacion 31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agregan columnas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

-- Modificacion			11/16/2018 @ G-Force Team Sprint Mamut
-- Autor:				diego.as
-- Historia/Bug:		Product Backlog Item 25638: Aplicación de Descuento Único en el Móvil
-- Descripcion:			11/16/2018 - Se agrega columna IS_UNIQUE que indica si el descuento es UNICO (Valor 1) o NO (Valor 0)

/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SONDA_SP_GET_DISCOUNT_LIST_BY_SKU_FOR_ROUTE]
		@CODE_ROUTE = '136'

*/
-- =====================================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_DISCOUNT_LIST_BY_SKU_FOR_ROUTE]
	(
		@CODE_ROUTE VARCHAR(50)
	)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		DECLARE	@DISCOUNT_LIST TABLE
			(
				[DISCOUNT_LIST_ID] INT
				,UNIQUE ([DISCOUNT_LIST_ID])
			);
	--
		INSERT	INTO @DISCOUNT_LIST
				(
					[DISCOUNT_LIST_ID]
				)
		SELECT
			[DL].[DISCOUNT_LIST_ID]
		FROM
			[SONDA].[SWIFT_DISCOUNT_LIST] [DL]
		WHERE
			[DL].[CODE_ROUTE] = @CODE_ROUTE;
	--
		SELECT DISTINCT
			[DLS].[DISCOUNT_LIST_ID]
			,[DLS].[CODE_SKU]
			,[DLS].[PACK_UNIT]
			,[DLS].[LOW_LIMIT]
			,[DLS].[HIGH_LIMIT]
			,[DLS].[DISCOUNT]
			,[DLS].[PROMO_ID]
			,[DLS].[PROMO_NAME]
			,[DLS].[PROMO_TYPE]
			,[DLS].[DISCOUNT_TYPE]
			,[DLS].[FREQUENCY]
			,[DLS].[IS_UNIQUE]
		FROM
			[SONDA].[SWIFT_DISCOUNT_LIST_BY_SKU] AS [DLS]
		INNER JOIN @DISCOUNT_LIST [DL]
		ON	([DL].[DISCOUNT_LIST_ID] = [DLS].[DISCOUNT_LIST_ID])
		WHERE
			[DLS].[DISCOUNT_LIST_ID] > 0;
	END;
