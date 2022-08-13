CREATE PROC [wms].[OP_WMS_SP_CREATE_ACUSE_RECIBO]			
	@POLIZA VARCHAR(20)
	,@FOB VARCHAR(50)
	,@DATE DATETIME
	,@CODIGO_TRASPORTISTA varchar(50)
    ,@PLACA_TRASPORTISTA varchar(20)    
    ,@NUMERO_CONTENEDOR varchar(20)
	,@NUMERO_MARCHAMO varchar(20)
    ,@USER_ID varchar(25)
    ,@STATUS varchar(20)
    ,@FOTO1 IMAGE
    ,@FOTO2 IMAGE
	,@FOTO3 IMAGE
	,@pResult varchar(200) OUTPUT
		   --,@pDocID varchar(200) OUTPUT
AS
	IF EXISTS(SELECT 1 FROM [wms].OP_WMS_ACUSE_RECIBO					
					where CODIGO_POLIZA = @POLIZA
					AND  [STATUS] = 'SATISFACTORIO')
	BEGIN
			SELECT	@pResult	= 'Poliza ya fue ingresado'
			RETURN -1
	END

BEGIN TRY
	INSERT INTO [wms].[OP_WMS_ACUSE_RECIBO]
			   ( 
			   CODIGO_POLIZA
			   ,FOB
			   ,[DATE]
			   ,CODIGO_TRANSPORTISTA
			   ,PLACA_TRANSPORTE
			   ,NUMERO_CONTENEDOR
			   ,NUMERO_MARCHAMO
			   ,LAST_UPDATED_BY
			   ,LAST_UPDATED
			   ,[STATUS]
			   ,FOTO_1
			   ,FOTO_2
			   ,FOTO_3
			   )
		 VALUES
			   (			   
			   @POLIZA
			   ,@FOB
			   ,@DATE
			   ,@CODIGO_TRASPORTISTA
			   ,@PLACA_TRASPORTISTA
			   ,@NUMERO_CONTENEDOR
			   ,@NUMERO_MARCHAMO			   
			   ,@USER_ID
			   , GETDATE()
			   ,@STATUS
			   ,@FOTO1
				,@FOTO2
				,@FOTO3
			   )
	           
		--SELECT @pDocID = SCOPE_IDENTITY()
		SELECT @pResult = 'OK'
END TRY	
BEGIN CATCH	
	SELECT @pResult = ERROR_MESSAGE()
END CATCH