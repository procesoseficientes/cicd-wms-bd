CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_MATERIAL]
        @CODE_SKU varchar(50)
		,@SKU_DESCRIPTION varchar(50)
		,@CUSTOMER varchar(max)
		,@USER VARCHAR(50) 
AS
       DECLARE  @MATERIAL VARCHAR(50)= @CUSTOMER+'/'+@CODE_SKU

BEGIN TRY
      MERGE [wms].[OP_WMS_MATERIALS] MT
	  USING (SELECT @MATERIAL AS MATERIAL_ID ) AS MP
	  ON MT.MATERIAL_ID  = MP.MATERIAL_ID
      WHEN MATCHED THEN 
	   
	  UPDATE SET 
	   MT.LAST_UPDATED = GETDATE()
	  ,MT.LAST_UPDATED_BY = @USER
	


WHEN NOT MATCHED THEN 

INSERT 
           ([CLIENT_OWNER]
			,[MATERIAL_ID]
			,[BARCODE_ID]
			,[MATERIAL_NAME]
			,[SHORT_NAME]
			,[VOLUME_FACTOR]
			,[MATERIAL_CLASS]
			,[HIGH]
			,[LENGTH]
			,[WIDTH]
			,[MAX_X_BIN]
			,[SCAN_BY_ONE]
			,[REQUIRES_LOGISTICS_INFO]
			,[WEIGTH]
			,[LAST_UPDATED]
			,[LAST_UPDATED_BY]
			,[IS_CAR]
			,[BATCH_REQUESTED])
     VALUES
           (@CUSTOMER
           ,@CUSTOMER+'/'+@CODE_SKU
           ,@CODE_SKU
           ,@SKU_DESCRIPTION
           ,@SKU_DESCRIPTION
           ,0
           ,''
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,GETDATE()
           ,@USER
           ,0
           ,0);

IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje --,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH