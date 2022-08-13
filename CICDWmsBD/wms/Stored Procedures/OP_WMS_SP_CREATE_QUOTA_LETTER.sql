CREATE PROC [wms].[OP_WMS_SP_CREATE_QUOTA_LETTER]
			@POLIZAS varchar(max)
           ,@CLAVE_ADUANA varchar(20)
           ,@NOMBRE_ADUANA varchar(100)
           ,@NO_FACTURA varchar(20)
           ,@MERCHANDISE_DESCRIPTION varchar(200)
           ,@MERCHANDISE_QTY numeric(18,0)
           ,@MERCHANDISE_VALUE numeric(18,2)
           ,@BL_NUMBER varchar(20)
           ,@CONTAINER_NUMBER varchar(20)
           ,@CLAVE_AGENTE_ADUANERO varchar(20)
           ,@NOMBRE_AGENTE_ADUANERO varchar(100)
           ,@NOMBRE_CONSIGNATARIO varchar(100)
           ,@NIT_CONSIGNATARIO varchar(100)
           ,@DOMICILIO_FISCAL_CONSIGNATARIO varchar(100)
           ,@RELATED_CLIENT_CODE varchar(20)
		   ,@pResult varchar(200) OUTPUT
		   ,@pDocID varchar(200) OUTPUT
AS
BEGIN TRY
INSERT INTO [wms].[OP_WMS_QUOTA_LETTER]
           ([POLIZAS]
           ,[CLAVE_ADUANA]
           ,[NOMBRE_ADUANA]
           ,[NO_FACTURA]
           ,[MERCHANDISE_DESCRIPTION]
           ,[MERCHANDISE_QTY]
           ,[MERCHANDISE_VALUE]
           ,[BL_NUMBER]
           ,[CONTAINER_NUMBER]
           ,[CLAVE_AGENTE_ADUANERO]
           ,[NOMBRE_AGENTE_ADUANERO]
           ,[NOMBRE_CONSIGNATARIO]
           ,[NIT_CONSIGNATARIO]
           ,[DOMICILIO_FISCAL_CONSIGNATARIO]
           ,[STATUS]
           ,[RELATED_CLIENT_CODE]
           ,[LAST_UPDATED]
           ,[LAST_UPDATED_BY])
     VALUES
           (@POLIZAS
           ,@CLAVE_ADUANA
           ,@NOMBRE_ADUANA
           ,@NO_FACTURA
           ,@MERCHANDISE_DESCRIPTION
           ,@MERCHANDISE_QTY
           ,@MERCHANDISE_VALUE
           ,@BL_NUMBER
           ,@CONTAINER_NUMBER
           ,@CLAVE_AGENTE_ADUANERO
           ,@NOMBRE_AGENTE_ADUANERO
           ,@NOMBRE_CONSIGNATARIO
           ,@NIT_CONSIGNATARIO
           ,@DOMICILIO_FISCAL_CONSIGNATARIO
           ,'SOLICITADA'
           ,@RELATED_CLIENT_CODE
           ,CURRENT_TIMESTAMP
           ,@RELATED_CLIENT_CODE)
	SELECT @pDocID = SCOPE_IDENTITY()
	SELECT @pResult = 'OK'
END TRY
	
BEGIN CATCH
	ROLLBACK TRAN;
	SELECT @pResult = ERROR_MESSAGE()
END CATCH