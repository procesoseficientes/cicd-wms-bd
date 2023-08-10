-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-04-2016
-- Description:			Crea detalle de la orden de venta
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_SALES_ORDER_DETAIL]
		@SALES_ORDER_ID INT
		,@SKU VARCHAR(25)
		,@LINE_SEQ INT
		,@QTY INT
		,@PRICE NUMERIC(18,6)
		,@DISCOUNT NUMERIC(18,6)
		,@TOTAL_LINE NUMERIC(18,6)
		,@POSTED_DATETIME DATETIME = NULL
		,@SERIE  INT = 0
		,@SERIE_2 INT = 0
		,@REQUERIES_SERIE INT = 0
		,@COMBO_REFERENCE VARCHAR(50)
		,@PARENT_SEQ INT = 1
		,@IS_ACTIVE_ROUTE INT = 1
		,@CODE_WAREHOUSE VARCHAR(50)
AS
BEGIN TRY
	IF @POSTED_DATETIME IS NULL
	BEGIN
		SET @POSTED_DATETIME = GETDATE()
	END
	
	-- ------------------------------------------------------------------------------------
	-- Inserta el detalle de la orden de venta
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].[SONDA_SALES_ORDER_DETAIL](
		SALES_ORDER_ID
		,SKU
		,LINE_SEQ
		,QTY
		,PRICE
		,DISCOUNT
		,TOTAL_LINE
		,POSTED_DATETIME
		,SERIE
		,SERIE_2
		,REQUERIES_SERIE
		,COMBO_REFERENCE
		,PARENT_SEQ
		,IS_ACTIVE_ROUTE
	) VALUES (
		@SALES_ORDER_ID
		,@SKU
		,@LINE_SEQ
		,@QTY
		,@PRICE
		,@DISCOUNT
		,@TOTAL_LINE
		,@POSTED_DATETIME
		,@SERIE
		,@SERIE_2
		,@REQUERIES_SERIE
		,@COMBO_REFERENCE
		,@PARENT_SEQ
		,@IS_ACTIVE_ROUTE
	)

	-- ------------------------------------------------------------------------------------
	-- Actualiza el inventario reservado
	-- ------------------------------------------------------------------------------------
	UPDATE [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE]
	SET [IS_COMITED] = [IS_COMITED] + @QTY
	WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE
		AND [CODE_SKU] = @SKU
  
  -- ------------------------------------------------------------------------------------
  -- Retorna el resultado
  -- ------------------------------------------------------------------------------------
  IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
