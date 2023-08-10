-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-04-2016
-- Description:			Crea detalle del picking

--Modificacion 01/09/2016 
--pablo.aguilar
--Se agrega parámetro de @LP_LOCATION_SPOT con valor por defecto como nulo, para guardar la ubicación de un reabastecimiento de LP


/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_INSERT_PICKING_DETAIL]
			@PICKING_HEADER = 1
			,@CODE_SKU = '100001'
			,@DESCRIPTION_SKU = 'DESCRIPCION'
			,@DISPATCH = 2
			,@SCANNED = 0
			,@RESULT = NULL
			,@COMMENTS = NULL
			,@LAST_UPDATE_BY = 'PRUEBA'
			,@DIFFERENCE = 2
		--
		SELECT * FROM [SONDA].[SWIFT_PICKING_DETAIL] WHERE PICKING_HEADER = 1 AND DESCRIPTION_SKU = 'DESCRIPCION'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_PICKING_DETAIL
		@PICKING_HEADER INT
		,@CODE_SKU VARCHAR(50)
		,@DESCRIPTION_SKU VARCHAR(250)
		,@DISPATCH INT
		,@SCANNED INT
		,@RESULT INT = NULL
		,@COMMENTS VARCHAR(1000)
		,@LAST_UPDATE_BY VARCHAR(50)
		,@DIFFERENCE INT
		,@LP_LOCATION_SPOT VARCHAR(25) = NULL
AS
BEGIN TRY
	CREATE TABLE #RESULT (RESULT INT)
	--
	DECLARE 
		@CODE_WAREHOUSE VARCHAR(50)
		,@VALIDATION INT = 0

	-- ------------------------------------------------------------------------------------
	-- Obtiene la bodega del encabezado
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @CODE_WAREHOUSE = P.CODE_WAREHOUSE_SOURCE
	FROM [SONDA].[SWIFT_PICKING_HEADER] P
	WHERE P.PICKING_HEADER = @PICKING_HEADER

	-- ------------------------------------------------------------------------------------
	-- Valida inventario
	-- ------------------------------------------------------------------------------------
	
	SELECT  @VALIDATION = [SONDA].[SWIFT_FN_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKU](@CODE_WAREHOUSE,@CODE_SKU,@DISPATCH)
	--
	IF @VALIDATION = 1
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Inserta el detalle
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_PICKING_DETAIL](
			PICKING_HEADER
			,CODE_SKU
			,DESCRIPTION_SKU
			,DISPATCH
			,SCANNED
			,RESULT
			,COMMENTS
			,LAST_UPDATE
			,LAST_UPDATE_BY
			,[DIFFERENCE]
      ,[LP_TARGET_LOCATION]
		) VALUES (
			@PICKING_HEADER
			,@CODE_SKU
			,@DESCRIPTION_SKU
			,@DISPATCH
			,@SCANNED
			,@RESULT
			,@COMMENTS
			,GETDATE()
			,@LAST_UPDATE_BY
			,@DIFFERENCE
      ,@LP_LOCATION_SPOT
		)
	END	
	ELSE
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Muestra error de inventario no disponible
		-- ------------------------------------------------------------------------------------
		DECLARE @ERROR VARCHAR(1000) = 'No hay inventario disponible para el SKU: ' + @CODE_SKU + ' - ' + @DESCRIPTION_SKU
		RAISERROR (@ERROR,16,1)
	END	

  IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CONVERT(VARCHAR(16), '0') DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo , CONVERT(VARCHAR(16), '0') DbData
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo , CONVERT(VARCHAR(16), '0') DbData
END CATCH
