-- =============================================
-- Autor:				    hector.gonzalez
-- Fecha de Creacion: 	    06-06-2016
-- Description:			    Inserta un detalle si el sku existe

--Ejemplo de ejecucion:
/*
  EXEC [SONDA].[SONDA_SP_INSERT_TAKE_INVENTORY_DETAIL_IF_SKU_EXIST]
	@TAKE_INVENTORY_ID = 44
	,@CODE_SKU = '2465'
	,@QTY = 2
	,@POSTED_DATETIME = '2016-06-06 21:32:18.000'
	,@CODE_PACK_UNIT = 'Paquete'
	,@LAST_QTY = 1
	
*/

-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_TAKE_INVENTORY_DETAIL_IF_SKU_EXIST]
	-- ----------------------------------------------------------------------------------
  -- Parametros para customer
	-- ----------------------------------------------------------------------------------
  @TAKE_INVENTORY_ID INT
	,@CODE_SKU VARCHAR(50)
	,@QTY NUMERIC(18,6)
	,@POSTED_DATETIME VARCHAR(50) 
	,@CODE_PACK_UNIT VARCHAR(100) 
	,@LAST_QTY NUMERIC(18,6)
AS
BEGIN
  	SET NOCOUNT ON;

	DECLARE @RESULT INT=0
      -- ----------------------------------------------------------------------------------
			-- Se verifica la existencia del SKU
	  -- ----------------------------------------------------------------------------------
			
			SELECT @RESULT=1 
			FROM [SONDA].SWIFT_VIEW_ALL_SKU VAS 
			INNER JOIN [SONDA].SONDA_PACK_CONVERSION SPC ON (VAS.CODE_SKU = SPC.CODE_SKU)
			WHERE VAS.CODE_SKU = @CODE_SKU 
			AND SPC.CODE_PACK_UNIT_FROM = @CODE_PACK_UNIT

	  -- ----------------------------------------------------------------------------------
			-- Se inserta el detalle del sku si existE en la base de datos
	  -- ----------------------------------------------------------------------------------
		
		IF @RESULT = 1
	BEGIN 
		INSERT INTO [SONDA].[SONDA_TAKE_INVENTORY_DETAIL](
             [TAKE_INVENTORY_ID]
    	    ,[CODE_SKU]
        	,[QTY]
        	,[POSTED_DATETIME]
        	,[CODE_PACK_UNIT]
        	,[LAST_QTY]
      )
	  VALUES( @TAKE_INVENTORY_ID
    	    ,@CODE_SKU
        	,@QTY
        	,@POSTED_DATETIME
        	,@CODE_PACK_UNIT
        	,@LAST_QTY)
	END

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------            
	  
	  SELECT @RESULT AS RESULT
			 ,@CODE_SKU AS CODE_SKU
			 

			 

 END
