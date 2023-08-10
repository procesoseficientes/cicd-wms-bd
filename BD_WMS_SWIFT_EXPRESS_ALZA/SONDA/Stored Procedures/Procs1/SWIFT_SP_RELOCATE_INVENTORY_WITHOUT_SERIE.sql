/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_UPDATE_OR_INSERT_INVENTORY_WITH_SERIE]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	20-11-2015
-- Description:			Inserta en la tabla de log los movimientos del inventario
/*
-- Ejemplo de Ejecucion:				
				--
	   exec [SONDA].SWIFT_SP_UPDATE_OR_INSERT_INVENTORY_WITH_SERIE
	   @SERIAL_NUMBER = 'abcdefghi'
      ,@WAREHOUSE ='a1b2c3'
      ,@LOCATION ='a1b2c3'
      ,@SKU ='a1b2c3'
      ,@SKU_DESCRIPTION='a1b2c3' 
      ,@ON_HAND =40
      ,@LAST_UPDATE_BY='a1b2c3'          
	  ,@user='a1b2c3'
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_RELOCATE_INVENTORY_WITHOUT_SERIE]
	@INVENTORY INT
	,@SERIAL_NUMBER varchar(50)
	,@WAREHOUSE_SOURCE varchar(50)
	,@LOCATION_SOURCE varchar(50)
	,@WAREHOUSE_TARGET varchar(50)
	,@LOCATION_TARGET varchar(50)
	,@CODE_SKU varchar(50)
	,@SKU_DESCRIPTION varchar(max)/*NO SE ACTUALIZA*/
	,@QTY floaT    
	,@LAST_UPDATE_BY  varchar(50)
	,@USER varchar(50)
	,@LAST_UPDATE DATETIME


AS
BEGIN TRY
	DECLARE @QTY_OLD FLOAT
	--
	Select TOP 1 @QTY_OLD = ON_HAND  
	from [SWIFT_INVENTORY] 
	where INVENTORY = @INVENTORY

	IF @QTY_OLD = @QTY
	begin
		DELETE FROM SWIFT_INVENTORY WHERE INVENTORY = @INVENTORY
	end
	else if @QTY_OLD > @QTY
	begin	
		UPDATE SWIFT_INVENTORY
		SET ON_HAND = (@QTY_OLD - @QTY)
		WHERE INVENTORY = @INVENTORY
	end
	--
	EXEC [SONDA].[SWIFT_SP_RELOCATE_INVENTORY_MOVE] 
		 @INVENTORY = @INVENTORY
		,@SERIAL_NUMBER = @SERIAL_NUMBER
		,@WAREHOUSE_TARGET = @WAREHOUSE_TARGET
		,@LOCATION_TARGET = @LOCATION_TARGET
		,@WAREHOUSE_SOURCE = @WAREHOUSE_SOURCE
		,@LOCATION_SOURCE = @LOCATION_SOURCE
		,@CODE_SKU = @CODE_SKU
		,@SKU_DESCRIPTION = @SKU_DESCRIPTION
		,@QTY = @QTY
		,@LAST_UPDATE_BY = @LAST_UPDATE_BY
		,@USER = @USER
  
  -- insertar en log
  EXEC [SONDA].[SWIFT_SP_INSERT_LOG_RELOCATE]  
                  @LAST_UPDATE_BY = @LAST_UPDATE_BY
				 , @WAREHOUSE_TARGET = @WAREHOUSE_TARGET
				 , @LOCATION_TARGET = @LOCATION_TARGET
				 , @WAREHOUSE_SOURCE = @WAREHOUSE_SOURCE
				 , @LOCATION_SOURCE = @LOCATION_SOURCE
				 , @CODE_SKU = @CODE_SKU
				 , @QTY = @QTY

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
