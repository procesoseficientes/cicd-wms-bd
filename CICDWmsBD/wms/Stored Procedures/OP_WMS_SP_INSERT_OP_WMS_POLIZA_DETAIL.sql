/****** 
exec [wms].[OP_WMS_SP_INSERT_OP_WMS_POLIZA_DETAIL]
	     @SKU_DESCRIPTION ='Uno'
		,@CUSTOMER ='1'
		,@CUSTOMER_NAME ='Uno'
		,@USER ='Uno'
		,@QTY= '1'
		,@UNIT_MEASURE= 'Uno'
		,@TOTAL = '1'
		,@HEADER = '1' 
 ******/
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_OP_WMS_POLIZA_DETAIL]
		@SKU_DESCRIPTION varchar(50)
		,@CUSTOMER varchar(max)
		,@CUSTOMER_NAME varchar(max)
		,@USER VARCHAR(50) 
		,@QTY INT
		,@UNIT_MEASURE VARCHAR(50)=''
		,@TOTAL FLOAT=0
		,@UNIT_PRICE FLOAT=0
		,@HEADER int
		,@LINE int
		,@fecha date
	
	  
AS
declare  @NumeroPoliza varchar(20)
		--,@fecha date= getdate() 
		
		SET @NumeroPoliza = (select format (@fecha,'ddMMyyyy') as NumeroPoliza);

DECLARE @Valor_Actual AS numeric(18, 2)=0
		,@Valor_Nuevo AS numeric(18, 2) = 0
		,@Valor_PROMEDIO AS numeric(18, 2)=0
  SELECT top 1 @Valor_Actual = CUSTOMS_AMOUNT
  FROM [wms].[OP_WMS_POLIZA_DETAIL]
  WHERE SKU_DESCRIPTION =@SKU_DESCRIPTION

  IF(@TOTAL< @UNIT_PRICE)
  BEGIN
  SET @Valor_Nuevo = @TOTAL
  END
  ELSE
  SET @Valor_Nuevo = @UNIT_PRICE


  IF (@Valor_Actual>0) 
  begin
  SET @Valor_PROMEDIO = (@Valor_Actual + @Valor_Nuevo)/2
  end
  else 
  Set @Valor_PROMEDIO=@Valor_Nuevo
   

BEGIN TRY

INSERT INTO [wms].[OP_WMS_POLIZA_DETAIL] 
      ( [DOC_ID]
	  , [LINE_NUMBER]
      ,[SKU_DESCRIPTION]
      ,[SAC_CODE]
      ,[BULTOS]
      ,[CLASE]
      ,[NET_WEIGTH]
      ,[WEIGTH_UNIT]
      ,[QTY]
      ,[CUSTOMS_AMOUNT]
      ,[QTY_UNIT]
      ,[VOLUME]
      ,[VOLUME_UNIT]
      ,[LAST_UPDATED_BY]
      ,[LAST_UPDATED]
      ,[ORIGIN_DOC_ID]
      ,[CODIGO_POLIZA_ORIGEN]
      ,[CLIENT_CODE]
      ,[ORIGIN_LINE_NUMBER]
      ,[PICKING_STATUS]
	  ,[DAI]
	  ,[IVA]
	  ,[MISC_TAXES]
	  )
  VALUES 
  (
  @HEADER
   ,@LINE
  ,@SKU_DESCRIPTION
  ,'0'
  ,@QTY
  ,'10'
  ,'0'
  ,null
  ,@QTY
  ,@Valor_PROMEDIO
  ,@UNIT_MEASURE
  ,'0'
  ,'0'
  ,@USER
  ,GETDATE()
  ,@NumeroPoliza
  ,@NumeroPoliza
  ,@CUSTOMER
  ,'1'
  ,'COMPLETED'
  ,'0'
  ,'0'
  ,'0'
  );

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