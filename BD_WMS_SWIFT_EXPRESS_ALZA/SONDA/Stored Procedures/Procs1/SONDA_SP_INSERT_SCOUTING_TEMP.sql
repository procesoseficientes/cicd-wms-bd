-- =============================================
-- Autor:				        alberto.ruiz
-- Fecha de Creacion: 	30-08-2016 @ Sprint θ 
-- Description:			    Inserta un cliente proveniente de scouting temporal

--Ejemplo de ejecucion:
/*
  EXEC [SONDA].SONDA_SP_INSERT_SCOUTING_TEMP
			    --Customer
          @CODE_CUSTOMER = 'PR-01'
	        ,@NAME_CUSTOMER = 'NOMBRE PRUEBA01'
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
			,@UPDATED_FROM_BO = 1
			,@SYNC_ID = ''
          --Frequency
          ,@MONDAY = '1'
          ,@TUESDAY = '0'
          ,@WEDNESDAY = '1'
          ,@THURSDAY = '1'
          ,@FRIDAY = '0'
          ,@SATURDAY = '0'
          ,@SUNDAY = '0'          
          ,@FREQUENCY_WEEKS = '1'
          ,@LAST_DATE_VISITED = '09-Nov-15'
		  ,@IS_POSTED = 0

					SELECT * 
          FROM [SONDA].SWIFT_CUSTOMERS_NEW_TEMP
          --WHERE CODE_CUSTOMER = 'SO-125'
          ORDER BY CUSTOMER DESC

          SELECT *
          FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW_TEMP 
          --WHERE CODE_CUSTOMER = 'SO-125'
          ORDER BY CODE_FREQUENCY DESC
*/

-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_SCOUTING_TEMP]
	-- ----------------------------------------------------------------------------------
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
	--,@HHID VARCHAR(50) = NULL
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
	,@UPDATED_FROM_BO INT
	,@SYNC_ID VARCHAR(250)

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

  ,@IS_POSTED INT
  
AS
BEGIN
  	SET NOCOUNT ON;
  	DECLARE @ID INT
          ,@HHID VARCHAR(50) = NULL
          ,@SCOUTING_PREFIX VARCHAR(MAX)
          ,@SCOUTING_SEQUENCE INT
		  ,@CLIENT_EXIST INT
		  ,@IN_ERP INT
		  ,@SYNCID VARCHAR(250)

	  BEGIN TRAN 
	  BEGIN TRY
	  -- ----------------------------------------------------------------------------------
			-- Obtiene la secuencia de scouting
			-- ----------------------------------------------------------------------------------      
      SELECT @SCOUTING_SEQUENCE = NEXT VALUE 
      FOR [SONDA].SCOUTING_CLIENT_TEMP_SEQUENCE
      
      -- ----------------------------------------------------------------------------------
			-- Obtiene la prefijo para el scouting
			-- ----------------------------------------------------------------------------------
      SELECT @SCOUTING_PREFIX = [SONDA].SWIFT_FN_GET_PARAMETER('SCOUTING','CLIENT_PREFIX')      
      
      --
      PRINT('Se concatena el prefijo con la secuencia.')
      
      -- ----------------------------------------------------------------------------------
			-- Se prepara el codigo de scouting
			-- ----------------------------------------------------------------------------------      
      SET @HHID = @SCOUTING_PREFIX + CONVERT(VARCHAR(18), @SCOUTING_SEQUENCE) 
	  SET @SYNCID = @SYNC_ID; 
      
      PRINT('Codigo generado: ' + @HHID)
      
      --
      PRINT('Se inserte el cliente')


      -- ----------------------------------------------------------------------------------
			-- Se inserte el cliente
			-- ----------------------------------------------------------------------------------
      INSERT INTO [SONDA].[SWIFT_CUSTOMERS_NEW_TEMP](
          [CODE_CUSTOMER]
    	    ,[NAME_CUSTOMER]
        	,[CLASSIFICATION_CUSTOMER]
        	,[PHONE_CUSTOMER]
        	,[ADRESS_CUSTOMER]
        	,[CONTACT_CUSTOMER]
        	,[CODE_ROUTE]
        	,[LAST_UPDATE]
        	,[LAST_UPDATE_BY]
        	,[SELLER_DEFAULT_CODE]
        	,[SIGN]
        	,[PHOTO]
        	,[STATUS]
        	,[NEW]
        	,[GPS]
        	,[CODE_CUSTOMER_HH]
        	,[REFERENCE]
        	,[POST_DATETIME]
        	,[POS_SALE_NAME]
        	,[INVOICE_NAME]
        	,[INVOICE_ADDRESS]
        	,[NIT]
        	,[CONTACT_ID]
        	,[LATITUDE]
        	,[LONGITUDE]
			,[UPDATED_FROM_BO]
			,[SYNC_ID]
			,[IS_POSTED]
      )
      VALUES (
          @HHID
          ,@NAME_CUSTOMER
	        ,@CLASSIFICATION_CUSTOMER
          ,@PHONE_CUSTOMER
          ,@ADDRESS_CUSTOMER
          ,@CONTACT_CUSTOMER
          ,@CODE_ROUTE
          ,GETDATE()
          ,@LAST_UPDATE_BY
          ,@SELLER_CODE
        	,@SING
        	,@PHOTO
        	,@STATUS
        	,@NEW
        	,@GPS
          ,@CODE_CUSTOMER
	        ,@REFERENCE
        	,@POST_DATETIME
        	,@POS_SALE_NAME
        	,@INVOICE_NAME
        	,@INVOICE_ADDRESS
        	,@NIT
        	,@CONTACT_ID
        	,RTRIM(LTRIM(SUBSTRING(@GPS,1,CHARINDEX(',',@GPS) - 1)))
        	,RTRIM(LTRIM(SUBSTRING(@GPS,CHARINDEX(',',@GPS) + 1,LEN(@GPS))))
			,@UPDATED_FROM_BO
			,@SYNCID
			,@IS_POSTED
      )
      --
      PRINT('Se obtiene el id generado')

      -- ----------------------------------------------------------------------------------
			-- Se obtiene el id generado
			-- ----------------------------------------------------------------------------------  
      SELECT @ID = SCOPE_IDENTITY()
      PRINT(@ID)            
      
      --
      PRINT('Se inserte la frecuencia del cliente')
      -- ----------------------------------------------------------------------------------
			-- Se inserte la frecuencia del cliente
			-- ----------------------------------------------------------------------------------
      INSERT [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW_TEMP(          
        	CODE_CUSTOMER
        	,SUNDAY
        	,MONDAY
        	,TUESDAY
        	,WEDNESDAY
        	,THURSDAY
        	,FRIDAY
        	,SATURDAY
        	,LAST_UPDATED
        	,LAST_UPDATED_BY
          ,FREQUENCY_WEEKS
        	,LAST_DATE_VISITED          
	    )	
	    VALUES (
        	@HHID
        	,@SUNDAY
        	,@MONDAY
        	,@TUESDAY
        	,@WEDNESDAY
        	,@THURSDAY
        	,@FRIDAY
        	,@SATURDAY
        	,GETDATE()
          ,@LAST_UPDATE_BY
        	,@FREQUENCY_WEEKS
        	,@LAST_DATE_VISITED
	    );
      
      SELECT @HHID AS ID
      
	COMMIT TRAN
  	END TRY	
	  BEGIN CATCH
		  ROLLBACK
		  DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		  RAISERROR (@ERROR,16,1)
	  END CATCH
END
