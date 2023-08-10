/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_RELOCATE_INVENTORY_MOV]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	20-11-2015
-- Description:			Inserta en la tabla de log los movimientos del inventario
/*
-- Ejemplo de Ejecucion:				
				--
				   EXEC [SONDA].[SWIFT_SP_RELOCATE_INVENTORY_MOVE] 
					 @INVENTORY = 2121
					,@SERIAL_NUMBER = null
					,@WAREHOUSE = '001'
					,@LOCATION = '001'
					,@SKU = '001'
					,@SKU_DESCRIPTION = 'abc'
					,@QTY = 111
					,@LAST_UPDATE_BY = 'user1'
					,@USER = 'user01'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_RELOCATE_INVENTORY_MOVE]
	@SERIAL_NUMBER varchar(50)
    ,@WAREHOUSE_TARGET varchar(50)
    ,@LOCATION_TARGET varchar(50)
	,@WAREHOUSE_SOURCE varchar(50)
    ,@LOCATION_SOURCE varchar(50)
    ,@CODE_SKU varchar(50)
    ,@SKU_DESCRIPTION varchar(max)/*NO SE ACTUALIZA*/
    ,@QTY floaT    
    ,@LAST_UPDATE_BY  varchar(50)
	,@USER varchar(50)
	,@INVENTORY INT
AS
	BEGIN TRY
		MERGE [SONDA].[SWIFT_INVENTORY] I
			  USING (SELECT @INVENTORY AS INVENTORY ) AS S
			  ON I.INVENTORY  = S.INVENTORY
			  WHEN MATCHED THEN    
			  UPDATE SET 
			  I.WAREHOUSE=@WAREHOUSE_SOURCE,
			  I.LOCATION=@LOCATION_SOURCE,
			  I.SKU=@CODE_SKU,
			  I.ON_HAND = I.ON_HAND + @QTY,
			  I.LAST_UPDATE= GETDATE(),
			  I.LAST_UPDATE_BY= @USER,
			  I.IS_SCANNED=0,
			  I.RELOCATED_DATE=GETDATE()
		WHEN NOT MATCHED THEN 
			INSERT (
			   [SERIAL_NUMBER]
			  ,[WAREHOUSE]
			  ,[LOCATION]
			  ,[SKU]
			  ,[SKU_DESCRIPTION]
			  ,[ON_HAND]
			  ,[BATCH_ID]
			  ,[LAST_UPDATE]
			  ,[LAST_UPDATE_BY]
			  ,[TXN_ID]
			  ,[IS_SCANNED]
			  ,[RELOCATED_DATE])
			VALUES
			(	  
				@SERIAL_NUMBER 
				,@WAREHOUSE_SOURCE 
				,@LOCATION_SOURCE
				,@CODE_SKU 
				,@SKU_DESCRIPTION 
				,@QTY 
				,NULL  
				,GETDATE() /*@LAST_UPDATE*/
				,@LAST_UPDATE_BY  
				,NULL  
				,0         /* IS_SCANNER*/
				,GETDATE() /*@RELOCATED_DATE */ 
			);


			 -- insertar en log
  EXEC [SONDA].[SWIFT_SP_INSERT_LOG_RELOCATE]
                   @LAST_UPDATE_BY = @LAST_UPDATE_BY
				 , @WAREHOUSE_TARGET = @WAREHOUSE_TARGET
				 , @LOCATION_TARGET = @LOCATION_TARGET
				 , @WAREHOUSE_SOURCE = @WAREHOUSE_SOURCE
				 , @LOCATION_SOURCE = @LOCATION_SOURCE
				 , @CODE_SKU = @CODE_SKU
				 , @QTY = @QTY
				 , @SERIAL = NULL

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
