-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-13 11:25:41
-- Description:		Obtiene el detalle de una orden de compra

-- Modificado 2016-04-13
-- joel.delcompare
-- Se agregro el descuento 
-- Modificado 2016-04-14
-- joel.delcompare
-- Se agrego el factor de conversion 

-- Modificado 2016-05-12
		-- joel.delcompare
		-- Se agregó la unidad de medida para el evio a SBO


-- Modificado 23-08-2016
    -- hector.gonzales
    -- Se agrego campo IS_BONUS 

-- Modificado 08-11-2016 @ A-Team Sprint 4
      --  diego.as
      --  Se agrego campo LONG

	  -- Modificacion 4/5/2017 @ A-Team Sprint Garai
	  					-- rodrigo.gomez
	  					-- Se cambio de DISCOUNT a DISCOUNT_BY_GENERAL_AMOUNT

-- Modificacion 5/29/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrego parametro @OWNER

-- Modificacion 6/14/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrego la relacion de intercompany para los SKUs

/*
-- Ejemplo de Ejecucion:

USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @SALES_ORDER_ID int

SET @SALES_ORDER_ID = 33696

EXECUTE @RC = [SONDA].SWIFT_SP_GET_SALE_ORDER_DETAIL @SALES_ORDER_ID
GO

*/
-- =============================================  
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_SALE_ORDER_DETAIL (
	@SALES_ORDER_ID INT
	, @INTERFACE_OWNER VARCHAR(125) = 'Arium'
	, @CUSTOMER_OWNER VARCHAR(125) = 'Arium'
) AS
BEGIN
	DECLARE @PARAMETER_OWNER VARCHAR(125)
			,@SHIPPING_ATTEMPTS VARCHAR(100)
	--
	SELECT @PARAMETER_OWNER = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER_INTERCOMPANY','SEND_ALL_DETAIL')
			,@SHIPPING_ATTEMPTS = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER', 'SHIPPING_ATTEMPTS')
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene todo el detalle debido a que el OWNER es el mismo al que esta en parametros
	-- ------------------------------------------------------------------------------------
	IF(@CUSTOMER_OWNER = @PARAMETER_OWNER AND @INTERFACE_OWNER = @PARAMETER_OWNER)
	BEGIN	
		SELECT
		D.SALES_ORDER_ID
		,[SKUI].[ITEM_CODE] [SKU]
		,D.LINE_SEQ
		,D.QTY
		,D.PRICE
		,D.DISCOUNT
		,D.TOTAL_LINE
		,D.POSTED_DATETIME
		,D.SERIE
		,D.SERIE_2
		,D.REQUERIES_SERIE
		,D.COMBO_REFERENCE
		,D.PARENT_SEQ
		,D.IS_ACTIVE_ROUTE
		,ISNULL(ssoh.[DISCOUNT_BY_GENERAL_AMOUNT], 0) DISC_PRCNT   
		,ISNULL((SELECT
			spu.UM_ENTRY
			FROM [SONDA].SONDA_PACK_UNIT spu
			WHERE spu.CODE_PACK_UNIT = D.CODE_PACK_UNIT)
		,-1) UM_ENTRY
		,D.CODE_PACK_UNIT
		,D.IS_BONUS
		,(CASE svas.HANDLE_DIMENSION
			WHEN 1 THEN D.LONG
			WHEN 0 THEN NULL
			ELSE NULL
		END) AS [LONG]
		,[svas].[OWNER]
		FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] AS D
			INNER JOIN [SONDA].SONDA_SALES_ORDER_HEADER ssoh ON (D.SALES_ORDER_ID = ssoh.SALES_ORDER_ID)
			INNER JOIN [SONDA].SWIFT_VIEW_ALL_SKU svas ON(svas.CODE_SKU = D.SKU) 
			INNER JOIN [SONDA].[SWIFT_SKU_INTERCOMPANY] [SKUI] ON [svas].[CODE_SKU] = [SKUI].[MASTER_ID] AND SKUI.[SOURCE]=@INTERFACE_OWNER
		WHERE D.SALES_ORDER_ID = @SALES_ORDER_ID
		AND SSOH.IS_READY_TO_SEND=1
		AND ISNULL([D].[IS_POSTED_ERP], 0) = 0
		AND (ISNULL([D].ATTEMPTED_WITH_ERROR,0) < CAST(@SHIPPING_ATTEMPTS AS INT))
	END
	ELSE
	BEGIN
	-- ------------------------------------------------------------------------------------
	-- Obtiene solo las lineas de detalle donde @OWNER es igual al owner de los SKU.
	-- ------------------------------------------------------------------------------------
		SELECT
			D.SALES_ORDER_ID
			,[SKUI].[ITEM_CODE] [SKU]
			,D.LINE_SEQ
			,D.QTY
			,D.PRICE
			,D.DISCOUNT
			,D.TOTAL_LINE
			,D.POSTED_DATETIME
			,D.SERIE
			,D.SERIE_2
			,D.REQUERIES_SERIE
			,D.COMBO_REFERENCE
			,D.PARENT_SEQ
			,D.IS_ACTIVE_ROUTE
			,ISNULL(ssoh.[DISCOUNT_BY_GENERAL_AMOUNT], 0) DISC_PRCNT   
			,ISNULL((SELECT
				spu.UM_ENTRY
				FROM [SONDA].SONDA_PACK_UNIT spu
				WHERE spu.CODE_PACK_UNIT = D.CODE_PACK_UNIT)
			,-1) UM_ENTRY
			,D.CODE_PACK_UNIT
			,D.IS_BONUS
			,(CASE svas.HANDLE_DIMENSION
				WHEN 1 THEN D.LONG
				WHEN 0 THEN NULL
				ELSE NULL
			END) AS [LONG]
			,[svas].[OWNER]
		FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] AS D
			INNER JOIN [SONDA].SONDA_SALES_ORDER_HEADER ssoh ON (D.SALES_ORDER_ID = ssoh.SALES_ORDER_ID)
			INNER JOIN [SONDA].SWIFT_VIEW_ALL_SKU svas ON(svas.CODE_SKU = D.SKU) 
			INNER JOIN [SONDA].[SWIFT_SKU_INTERCOMPANY] [SKUI] ON [svas].[CODE_SKU] = [SKUI].[MASTER_ID]
		WHERE D.SALES_ORDER_ID = @SALES_ORDER_ID
			AND SSOH.IS_READY_TO_SEND=1
			AND ISNULL([D].[IS_POSTED_ERP], 0) = 0
			AND (ISNULL([D].ATTEMPTED_WITH_ERROR,0) < CAST(@SHIPPING_ATTEMPTS AS INT))
			AND svas.[OWNER] = @INTERFACE_OWNER
			AND @PARAMETER_OWNER <> @CUSTOMER_OWNER
			AND [SKUI].[SOURCE] = @INTERFACE_OWNER
	END
END
