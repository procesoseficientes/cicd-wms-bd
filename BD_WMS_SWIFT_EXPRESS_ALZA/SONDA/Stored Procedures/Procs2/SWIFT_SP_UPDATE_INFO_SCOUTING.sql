/*===========================================================
Autor:				    diego.as
Fecha de Creacion: 		20-06-2016 
Description:			Actualiza los datos de un cliente 
						de scouting.

Ejemplo de ejecucion:

  EXEC [SONDA].SWIFT_SP_UPDATE_SCOUTING
  --Customer
          @CODE_CUSTOMER = 'C001'
	        ,@NAME_CUSTOMER = 'NOMBRE PRUEBA'
	        ,@CLASSIFICATION_CUSTOMER = '60'
        	,@PHONE_CUSTOMER = '59888598'
        	,@ADDRESS_CUSTOMER = 'GT'
        	,@CONTACT_CUSTOMER = 'PEDRO'
        	,@CODE_ROUTE = '001'
        	,@SELLER_CODE = 'V001'        	
        	,@LAST_UPDATE_BY = 'OPER1@SONDA'        	
        	,@SING = ''
        	,@PHOTO = ''
        	,@STATUS = 'NEW'
        	,@NEW = '1'
        	,@GPS = '14.594135,-90.4948001'
        	,@REFERENCE = 'MIXCO'
        	,@POST_DATETIME = '10-Nov-15 9:37:50 AM'
        	,@POS_SALE_NAME = 'Anonimo'
        	,@INVOICE_NAME = 'Nombre Facturacion'
        	,@INVOICE_ADDRESS = 'Direccion Facturacion'
        	,@NIT = '45455-45'
        	,@CONTACT_ID = 'LUIS'
  --Frequency
          ,@MONDAY = '1'
          ,@TUESDAY = '0'
          ,@WEDNESDAY = '1'
          ,@THURSDAY = '1'
          ,@FRIDAY = '0'
          ,@SATURDAY = '1'
          ,@SUNDAY = '1'          
          ,@FREQUENCY_WEEKS = '1'
          ,@LAST_DATE_VISITED = '09-Nov-15'
	----
	SELECT * FROM [SONDA].[SWIFT_CUSTOMERS_NEW]
    WHERE CODE_CUSTOMER = 'C001'
    ORDER BY CUSTOMER DESC
	----
    SELECT * FROM [SONDA].[SWIFT_CUSTOMER_FREQUENCY_NEW]
    WHERE CODE_CUSTOMER = 'C001'
    ORDER BY CODE_FREQUENCY DESC
*/

-- ============================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_INFO_SCOUTING]
( -- ----------------------------------------------------------------------------------
  -- Parametros para customer
  -- ----------------------------------------------------------------------------------
  @CODE_CUSTOMER VARCHAR(50)
	,@NAME_CUSTOMER VARCHAR(50)
	,@CLASSIFICATION_CUSTOMER VARCHAR(50) = NULL
	,@PHONE_CUSTOMER VARCHAR(50) = NULL
	,@ADDRESS_CUSTOMER VARCHAR(MAX) = NULL
	,@CONTACT_CUSTOMER VARCHAR(50) = NULL
	,@CODE_ROUTE VARCHAR(50)
	,@SELLER_CODE VARCHAR(50) = NULL	
	,@LAST_UPDATE_BY VARCHAR(50)
	,@SING VARCHAR(MAX) = NULL
	,@PHOTO VARCHAR(MAX) = NULL
	,@STATUS VARCHAR(20) = NULL
	,@NEW VARCHAR(10) = 1
	,@GPS VARCHAR(MAX) = '0,0'
	,@REFERENCE VARCHAR(150) = NULL	
	,@POST_DATETIME datetime = NULL
	,@POS_SALE_NAME VARCHAR(150) = '...'
	,@INVOICE_NAME VARCHAR(150) = '...'
	,@INVOICE_ADDRESS VARCHAR(150) = '...'
	,@NIT VARCHAR(150) = '...'
	,@CONTACT_ID VARCHAR(150) = '...'

  -- ----------------------------------------------------------------------------------
  -- Parametros para frequency
  -- ----------------------------------------------------------------------------------
  ,@MONDAY VARCHAR(2) 
  ,@TUESDAY VARCHAR(2)
  ,@WEDNESDAY VARCHAR(2)
  ,@THURSDAY VARCHAR(2)
  ,@FRIDAY VARCHAR(2)
  ,@SATURDAY VARCHAR(2)
  ,@SUNDAY VARCHAR(2)  
  ,@FREQUENCY_WEEKS VARCHAR(2) = NULL
  ,@LAST_DATE_VISITED DATETIME = NULL
)AS
BEGIN
	--
  	SET NOCOUNT ON;
	  --
	  BEGIN TRAN UpdateTrans
	  --
	  BEGIN TRY
	  --
      PRINT('Se ACTUALIZA el cliente')
      -- ----------------------------------------------------------------------------------
	  -- Se ACTUALIZA el cliente
	  -- ----------------------------------------------------------------------------------
      UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
	  SET [NAME_CUSTOMER] = @NAME_CUSTOMER
        	,[CLASSIFICATION_CUSTOMER] = @CLASSIFICATION_CUSTOMER
        	,[PHONE_CUSTOMER] = @PHONE_CUSTOMER
        	,[ADRESS_CUSTOMER] = @ADDRESS_CUSTOMER
        	,[CONTACT_CUSTOMER] = @CONTACT_CUSTOMER
        	,[CODE_ROUTE] = @CODE_ROUTE
        	,[LAST_UPDATE] = GETDATE()
        	,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
        	,[SELLER_DEFAULT_CODE] = @SELLER_CODE
        	,[SIGN] = @SING
        	,[PHOTO] = @PHOTO
        	,[STATUS] = @STATUS
        	,[NEW] = @NEW
        	,[GPS] = @GPS
        	,[CODE_CUSTOMER_HH] = @CODE_CUSTOMER
        	,[REFERENCE] = @REFERENCE
        	,[POST_DATETIME] = @POST_DATETIME
        	,[POS_SALE_NAME] = @POS_SALE_NAME
        	,[INVOICE_NAME] = @INVOICE_NAME
        	,[INVOICE_ADDRESS] = @INVOICE_ADDRESS
        	,[NIT] = @NIT
        	,[CONTACT_ID] = @CONTACT_ID
        	,[LATITUDE] = RTRIM(LTRIM(SUBSTRING(@GPS,1,CHARINDEX(',',@GPS) - 1)))
        	,[LONGITUDE] = RTRIM(LTRIM(SUBSTRING(@GPS,CHARINDEX(',',@GPS) + 1,LEN(@GPS))))
	  WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
      --
      PRINT('Se ACTUALIZA la frecuencia del cliente')
      -- ----------------------------------------------------------------------------------
	  -- Se ACTUALIZA la frecuencia del cliente
	  -- ----------------------------------------------------------------------------------
      UPDATE [SONDA].[SWIFT_CUSTOMER_FREQUENCY_NEW]
	  SET [SUNDAY] = @SUNDAY
        	,[MONDAY] = @MONDAY
        	,[TUESDAY] = @TUESDAY
        	,[WEDNESDAY] = @WEDNESDAY
        	,[THURSDAY] = @THURSDAY
        	,[FRIDAY] = @FRIDAY
        	,[SATURDAY] = @SATURDAY
        	,[LAST_UPDATED] = GETDATE()
        	,[LAST_UPDATED_BY] = @LAST_UPDATE_BY
            ,FREQUENCY_WEEKS = @FREQUENCY_WEEKS
        	,LAST_DATE_VISITED = @LAST_DATE_VISITED
	  WHERE CODE_CUSTOMER = @CODE_CUSTOMER
	  --
  	  COMMIT TRAN UpdateTrans
	  --
  	END TRY	
	  BEGIN CATCH
		  ROLLBACK
		  DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		  RAISERROR (@ERROR,16,1)
	  END CATCH
END
