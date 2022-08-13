
-- =============================================
-- Autor:				JOSE.GARCIA
-- Fecha de Creacion: 	17-ENERO-17 
-- Description:			RECIBE LOS MATERIALES A INSERTAR 
--						EN EL INVENTARIO EXTERNO

/*
-- Ejemplo de Ejecucion:
				--
				

		EXEC [wms].[OP_WMS_ADD_REVIEW_FROM_EXTERNAL]
						@CLIENTE ='C00330',
						@CODIGO = '1768',
						@DESCRIPCION = 'TOMATES',
						@UNIDAD_MEDIDA='LIBRA',
						@QTY = 10,
						@PRECIO_UNITARIO=10,
						@TOTAL=100
						
				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_ADD_REVIEW_FROM_EXTERNAL]
(   
	@CLIENTE VARCHAR(50),
	@CODIGO VARCHAR(50),
	@DESCRIPCION VARCHAR(150),
	@UNIDAD_MEDIDA VARCHAR(50),
	@QTY NUMERIC(18,2),
	@PRECIO_UNITARIO NUMERIC(18,2),
	@TOTAL NUMERIC(18,2)
)

AS
DECLARE @ERROR VARCHAR (250)='Error: '
DECLARE @TRANS VARCHAR (250)=''
DECLARE @RESUMEN VARCHAR (250)=':'
BEGIN 
BEGIN TRY


INSERT INTO [wms].[OP_WMS_CHARGE_EXTERNAL_INVENTORY]
           ([CLIENTE]
		   ,[CODIGO]
           ,[DESCRIPCION]
           ,[UNIDAD_MEDIDA]
           ,[QTY]
           ,[PPRECIO_UNITARIO]
           ,[COSTO_TOTAL])
     VALUES
           (@CLIENTE
		   ,@CODIGO
           ,@DESCRIPCION
           ,@UNIDAD_MEDIDA
           ,@QTY
           ,@PRECIO_UNITARIO
           ,@TOTAL)


IF @@error = 0 BEGIN		
		SELECT  1 as Resultado ,  'OK'
		--SELECT @TRANS + @RESUMEN RESULTADO
	END		
	ELSE BEGIN
		
		SELECT -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
END