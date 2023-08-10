CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_OR_INSERT_INVENTORY_WITH_SERIE]

  	   @SERIAL_NUMBER varchar(50)
      ,@WAREHOUSE varchar(50)
      ,@LOCATION varchar(50)
	  ,@WAREHOUSE_TARGET varchar(50)
      ,@LOCATION_TARGET varchar(50)
      ,@CODE_SKU varchar(50)
      ,@SKU_DESCRIPTION varchar(max)/*NO SE ACTUALIZA*/
      ,@ON_HAND floaT    
      ,@LAST_UPDATE_BY  varchar(50)
	  ,@USER varchar(50)
	  ,@QTY INT  

	  
AS

BEGIN TRY
 DECLARE @NEW_ONHAND INT
  SET @NEW_ONHAND = (
  Select ON_HAND  
  from [SONDA].[SWIFT_INVENTORY] I 
  where I.SERIAL_NUMBER=@SERIAL_NUMBER) + @ON_HAND

MERGE [SONDA].[SWIFT_INVENTORY] I
	  USING (SELECT @SERIAL_NUMBER AS SERIAL_NUMBER ) AS S
	  ON I.SERIAL_NUMBER  = S.SERIAL_NUMBER
      WHEN MATCHED THEN 
	   
	  UPDATE SET 
      I.WAREHOUSE=@WAREHOUSE,
      I.LOCATION=@LOCATION,
      I.SKU=@CODE_SKU,
      I.ON_HAND= @NEW_ONHAND,
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
      ,@WAREHOUSE 
      ,@LOCATION 
      ,@CODE_SKU 
      ,@SKU_DESCRIPTION 
      ,@ON_HAND 
      ,NULL  
      , GETDATE() /*@LAST_UPDATE*/
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
				 , @WAREHOUSE_SOURCE = @WAREHOUSE
				 , @LOCATION_SOURCE = @LOCATION
				 , @CODE_SKU = @CODE_SKU
				 , @QTY = @QTY
				 , @SERIAL = @SERIAL_NUMBER

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
