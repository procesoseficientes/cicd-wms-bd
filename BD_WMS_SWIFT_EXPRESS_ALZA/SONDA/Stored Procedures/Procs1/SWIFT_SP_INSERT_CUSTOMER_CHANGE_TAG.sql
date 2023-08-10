-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	06-07-2016 Sprint ζ
-- Description:			    Inserta las etiquetas en la tabla SWIFT_TAG_X_CUSTOMER_CHANGE para el cliente modificado

-- Modificacion:			hector.gonzalez
-- Fecha de Creacion: 		11-07-2016 Sprint ζ
-- Description:			    Se modifico el sp para que regresara si la transaccion fue exitosa o no

-- Modificacion 8/9/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- Se agrega insert a las columnas [DEVICE_NETWORK_TYPE], [IS_POSTED_OFFLINE]

--Ejemplo de ejecucion:
/*
  EXEC [SONDA].[SWIFT_SP_INSERT_CUSTOMER_CHANGE_TAG]
  	 @TAG_COLOR ='#123'
    ,@CUSTOMER = 1
	,@DEVICE_NETWORK_TYPE = '3G'
	,@IS_POSTED_OFFLINE = 0
	
    SELECT * FROM [SONDA].SWIFT_TAG_X_CUSTOMER_CHANGE WHERE TAG_COLOR = '#123' AND CUSTOMER = 1
*/


-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_CUSTOMER_CHANGE_TAG] 
    @TAG_COLOR VARCHAR (8)
    ,@CUSTOMER INT
	,@DEVICE_NETWORK_TYPE VARCHAR(15)
	,@IS_POSTED_OFFLINE INT
AS
BEGIN TRY

  INSERT INTO [SONDA].SWIFT_TAG_X_CUSTOMER_CHANGE(
     TAG_COLOR
    ,CUSTOMER
	,[DEVICE_NETWORK_TYPE]
	,[IS_POSTED_OFFLINE]
  )
  VALUES(
     @TAG_COLOR
    ,@CUSTOMER
	,@DEVICE_NETWORK_TYPE
	,@IS_POSTED_OFFLINE
  )

  IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH
  ROLLBACK
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
