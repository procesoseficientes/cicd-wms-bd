-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Actualiza el inventario por licencia o inserta la cantidad nueva del 
--						nuevo codigo que se esta creando
/*
-- Ejemplo de Ejecucion:				
				--
				exec [wms].[OP_WMS_SP_UPDATE_OR_INSERT_OP_WMS_INV_X_LICENSE] 
						@CODE_SKU ='C00330/110017' 
						,@SKU_DESCRIPTION ='Concentrado  Tomate (Caja de 6 bolsa de 6.75 LBS)'
						,@UNIT_MEASURE ='CAJAS'
						,@QTY =10
						,@UNIT_PRICE =10
						,@TOTAL =10
						,@CUSTOMER ='C00330'
						,@CUSTOMER_NAME ='ALTURISA DE GUATEMALA S.A.'
						,@USER  ='ADMIN'
						,@WAREHOUSE ='ABC'
						,@LOCATION ='ABC'
						,@HEADER =1717
						,@SIGNO ='+'
						,@ACUERDO_COMERCIAL =12
						,GETDATE()
						,@RESULTADO =''
				--				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_OR_INSERT_OP_WMS_INV_X_LICENSE]

  	    @CODE_SKU varchar(50)
		,@SKU_DESCRIPTION varchar(50)
		,@UNIT_MEASURE varchar(50)
		,@QTY INT
		,@UNIT_PRICE FLOAT
		,@TOTAL FLOAT
		,@CUSTOMER varchar(max)
		,@CUSTOMER_NAME varchar(max)
		,@USER VARCHAR(50) 
		,@WAREHOUSE VARCHAR(50)
		,@LOCATION VARCHAR(50)
		,@HEADER INT
		,@SIGNO VARCHAR(5)
		,@ACUERDO_COMERCIAL VARCHAR(25)
		,@fecha date
		, @RESULTADO AS VARCHAR(250) ='' OUTPUT
	  
AS
 


DECLARE  @MATERIAL VARCHAR(50)= @CUSTOMER+'/'+@CODE_SKU
        ,@NumeroPoliza varchar(20)
		--,@fecha date= getdate() select 
		SET @NumeroPoliza = (select format (@fecha,'ddMMyyyy') as NumeroPoliza);


		
DECLARE @ON_HAND INT;
        set @ON_HAND = (select  QTY  FROM [wms].[OP_WMS_INV_X_LICENSE] WHERE MATERIAL_ID = '31032016')--@CODE_SKU
	    --select @ON_HAND AS QTY


DECLARE @LICENSE_ID INT;
		SET @LICENSE_ID = (SELECT top 1 L.LICENSE_ID FROM [wms].[OP_WMS_LICENSES] L order by L.LICENSE_ID desc)
		--SELECT @LICENSE_ID AS LICENCIA

BEGIN TRY
   -- BEGIN
      MERGE [wms].[OP_WMS_INV_X_LICENSE] I
	  USING (SELECT @MATERIAL AS MATERIAL_ID ) AS M
	  ON I.MATERIAL_ID  = M.MATERIAL_ID
	  and I.[LICENSE_ID]=@LICENSE_ID
      WHEN MATCHED THEN 
	   
	  UPDATE SET 
	   I.QTY = (CASE 
	   WHEN @signo='+' THEN I.QTY + @QTY
	   ELSE I.QTY-@QTY END )
	  ,I.LAST_UPDATED = GETDATE()
	  ,I.LAST_UPDATED_BY = @USER
	  ,I.DATE_EXPIRATION=GETDATE()
	  ,I.ENTERED_QTY=@QTY

	
WHEN NOT MATCHED THEN 

	INSERT ( 
      [LICENSE_ID]
      ,[MATERIAL_ID]
      ,[MATERIAL_NAME]
      ,[QTY]
      ,[VOLUME_FACTOR]
      ,[WEIGTH]
      ,[SERIAL_NUMBER]
      ,[COMMENTS]
      ,[LAST_UPDATED]
      ,[LAST_UPDATED_BY]
      ,[BARCODE_ID]
      ,[TERMS_OF_TRADE]
      ,[STATUS]
      ,[CREATED_DATE]
      ,[DATE_EXPIRATION]
      ,[BATCH]
      ,[ENTERED_QTY]
	  )
VALUES
(	  
	   @LICENSE_ID
	   ,@CUSTOMER+'/'+@CODE_SKU
	   ,@SKU_DESCRIPTION
       ,@QTY
       ,0
       ,0
	   ,'N/A'
	   ,'N/A'
	   ,GETDATE()
	   ,@USER
	   ,@NumeroPoliza+@LICENSE_ID
       ,@ACUERDO_COMERCIAL         
	   ,'PROCESSED'
       ,GETDATE()
       ,GETDATE()
       ,@NumeroPoliza
       ,@QTY);

  --SET @RESULTADO = 'EL CODIGO -> ' +@CUSTOMER+'/'+@CODE_SKU+ ' <- OPERADO CON EXITO' SELECT @RESULTADO AS RESULTADO
	--END 

IF @@error = 0 BEGIN		
		SET @RESULTADO = 'EL CODIGO -> ' + @CUSTOMER+'/'+@CODE_SKU + ' <- OPERADO CON EXITO' SELECT @RESULTADO AS RESULTADO
	END		
	ELSE BEGIN
		
		SET @RESULTADO = 'ERROR EN CODIGO -> ' + @CUSTOMER+'/'+@CODE_SKU + ' <- ' SELECT @RESULTADO AS RESULTADO
	END

END TRY
BEGIN CATCH     
	 SET @RESULTADO = 'ERROR EN CODIGO -> ' + @CUSTOMER+'/'+@CODE_SKU + ' <- ' SELECT @RESULTADO AS RESULTADO
END CATCH