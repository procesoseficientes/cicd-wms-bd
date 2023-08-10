-- =====================================================
-- Author:         alberto.ruiz
-- Create date:    16-04-2016
-- Description:    valida si el documento ya fue enviado a SAP

-- Modificacion 22-06-2016
					-- alberto.ruiz
					-- Se cambio filtro para validar que existe o no la orden de venta

-- Modificacion 27-06-2016
					-- alberto.ruiz
					-- Se cambio para que colocara la orden de venta negativa para que pueda agregar la nueva
					-- ESTE CAMBIO DEBE DE SER TEMPORAL
/*
-- EJEMPLO DE EJECUCION: 
		--Existe
		EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER]
			@DOC_SERIE = 'C'
			,@DOC_NUM = 49
		--No existe
		EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER]
			@DOC_SERIE = 'C'
			,@DOC_NUM = 48
		--Sin detalle
		EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER]
			@DOC_SERIE = 'C'
			,@DOC_NUM = 175
*/
-- =====================================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER (
	@DOC_SERIE VARCHAR(100)
	,@DOC_NUM INT
	,@CODE_ROUTE VARCHAR(50)
	,@CODE_CUSTOMER VARCHAR(50)
	,@POSTED_DATETIME DATETIME
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@EXISTS INT = 0
		,@SALES_ORDER_ID INT
		,@SALES_ORDER_POSTED_DATETIME DATETIME
	--
	SELECT TOP 1 
		@EXISTS = 1
		,@SALES_ORDER_ID = H.SALES_ORDER_ID
		,@SALES_ORDER_POSTED_DATETIME = [H].[POSTED_DATETIME]
	FROM [SONDA].SONDA_SALES_ORDER_HEADER H
	INNER JOIN [SONDA].SONDA_SALES_ORDER_DETAIL D ON (
		H.SALES_ORDER_ID = D.SALES_ORDER_ID
	)
	WHERE /*[H].[IS_ACTIVE_ROUTE] = 1 --> TEMPORAL
		AND */
		H.[POS_TERMINAL] = @CODE_ROUTE
		AND [CLIENT_ID] = @CODE_CUSTOMER
		AND H.DOC_SERIE = @DOC_SERIE
		AND H.DOC_NUM = @DOC_NUM
		AND H.IS_READY_TO_SEND=1
	
	-- ------------------------------------------------------------------------------------
	-- TEMPORAL -------> Valida si existe y le coloca una secuencia negativa
	-- ------------------------------------------------------------------------------------
	IF @EXISTS = 1 AND @SALES_ORDER_POSTED_DATETIME != @POSTED_DATETIME
	BEGIN
		UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
		SET DOC_NUM = NEXT VALUE FOR [SONDA].SALES_ORDER_NEGATIVE_SEQUENCE
		WHERE [POS_TERMINAL] = @CODE_ROUTE
			AND [CLIENT_ID] = @CODE_CUSTOMER
			AND DOC_SERIE = @DOC_SERIE
			AND DOC_NUM = @DOC_NUM
			AND IS_READY_TO_SEND=1
		--
		SET @EXISTS = 0
	END

	-- ------------------------------------------------------------------------------------
	-- Muestra resultado
	-- ------------------------------------------------------------------------------------
	SELECT 
		@EXISTS AS [EXISTS]
		,@SALES_ORDER_ID AS SALES_ORDER_ID
END
