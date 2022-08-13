CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_CC]
	
	@ACCOUNT_ID		varchar(140),
	@ACCOUNT_NAME	varchar(100),
	@ADUANA_INGRESO varchar(200),
	@AGENTE_ADUANA	varchar(15),
	@AGENTE_ADUANA_NOMBRE varchar(200),
	@NUMEROS_POLIZA varchar(500),
    @UNIDAD_MEDIDA	varchar(15),
	@CANTIDAD		numeric(18,2),
	@DESCRIPCION	varchar(1500),
	@CONTENEDOR		varchar(150),
	@CIF			numeric(18,2),
	@LAST_UPDATE_BY varchar(25),
	@LAST_ACTION	varchar(50),
	@STATUS			varchar(25),
	@pResult		varchar(250) OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRAN
		BEGIN
			INSERT INTO [wms].[OP_WMS_CARTAS_CUPO]
				   ([ACCOUNT_ID]
				   ,[ACCOUNT_NAME]
				   ,[ADUANA_INGRESO]
				   ,[AGENTE_ADUANA]
				   ,[AGENTE_ADUANA_NOMBRE]
				   ,[NUMEROS_POLIZA]
				   ,[UNIDAD_MEDIDA]
				   ,[CANTIDAD]
				   ,[DESCRIPCION]
				   ,[CONTENEDOR]
				   ,[CIF]
				   ,[LAST_UPDATE]
				   ,[LAST_UPDATE_BY]
				   ,[LAST_ACTION]
				   ,[STATUS])
			 VALUES
				   (
				    @ACCOUNT_ID
				   ,@ACCOUNT_NAME
				   ,@ADUANA_INGRESO
				   ,@AGENTE_ADUANA
				   ,@AGENTE_ADUANA_NOMBRE
				   ,@NUMEROS_POLIZA
				   ,@UNIDAD_MEDIDA
				   ,@CANTIDAD
				   ,@DESCRIPCION
				   ,@CONTENEDOR
				   ,@CIF
				   ,CURRENT_TIMESTAMP
				   ,@LAST_UPDATE_BY
				   ,@LAST_ACTION
				   ,@STATUS)
				   
		END
	
	IF @@error = 0 BEGIN
		SELECT @pResult = 'OK'
		COMMIT TRAN
	END
	ELSE
		BEGIN
			ROLLBACK TRAN
			SELECT	@pResult	= ERROR_MESSAGE()
		END
		
END