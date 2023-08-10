-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	14-03-2016 
-- Description:			    Inserta un cliente proveniente de scouting

-- Modificado 2016-07-04 Sprint ζ
-- rudi.garcia
-- Se modifico la forma de crear el "CODE_CUSTOMER", ahora se utiliza el prefijo y la secuencia.

-- Modificado 2016-07-05 Sprint ζ
-- hector.gonzalez
-- Se agrego parametro UPDATED_FROM_BO y se agrego validacion de que si existe el cliente y si esta enviado a ERP 

-- Modificado 2016-07-19 Sprint η
-- diego.as
-- Se agrego parametro SYNC_ID para evitar duplicidad en los clientes de Scouting.

-- Modificacion 13-Oct-16 @ A-Team Sprint 3
-- alberto.ruiz
-- Se agrego parametro @CODE_CUSTOMER_BO

-- Modificacion 07-11-2016 @ A-Team Sprint 4
-- diego.as
-- Se modifico respuesta del sp para que devuelva el codigo generado para el Scouting

-- Modificacion 4/21/2017 @ A-Team Sprint Hondo
-- rodrigo.gomez
-- Se agrego el campo OWNER_ID a la validacion si existe y al insert

-- Modificacion 6/15/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se valida que el cliente sea nuevo con @NEW

-- Modificacion 8/4/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- Se agrega columna SERVER_POSTED_DATETIME que almacenara la fecha y hora en que se postea el documento en el servidor

-- Modificacion 7/31/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agregan las columnas DEVICE_NETWORK_TYPE e IS_POSTED_OFFLINE

-- Modificacion 1/5/2018 @ A-Team Sprint Ramsey
					-- diego.as
					-- Se eliminan CONVERT en la validacion de existencia del scouting ya que estaba provocando el bug #17014

--Ejemplo de ejecucion:
/*
  EXEC [SONDA].SONDA_SP_INSERT_SCOUTING
          @CODE_CUSTOMER = 'SO-374'
	        ,@NAME_CUSTOMER = 'NOMBRE PRUEBA01'
	        ,@CLASSIFICATION_CUSTOMER = '60'
        	,@PHONE_CUSTOMER = '59888598'
        	,@ADDRESS_CUSTOMER = 'GT'
        	,@CONTACT_CUSTOMER = 'PEDRO'
        	,@CODE_ROUTE = '001'
        	,@SELLER_CODE = 'V001'        	
        	,@LAST_UPDATE_BY = 'RUDI@SONDA'        	
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
		   --Registro Transacciones
		  ,@DEVICE_NETWORK_TYPE = '3G'
		  ,@IS_POSTED_OFFLINE = 0

					SELECT * 
          FROM [SONDA].SWIFT_CUSTOMERS_NEW
          WHERE CODE_CUSTOMER_BO = 'SO-374'

          SELECT *
          FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW 
          --WHERE CODE_CUSTOMER = 'SO-125'
          ORDER BY CODE_FREQUENCY DESC
*/

-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_INSERT_SCOUTING (
-- ----------------------------------------------------------------------------------
-- Parametros para customer
-- ----------------------------------------------------------------------------------
@CODE_CUSTOMER VARCHAR(50)
, @NAME_CUSTOMER VARCHAR(50)
, @CLASSIFICATION_CUSTOMER VARCHAR(50) = NULL
, @PHONE_CUSTOMER VARCHAR(50) = NULL
, @ADDRESS_CUSTOMER VARCHAR(MAX) = NULL
, @CONTACT_CUSTOMER VARCHAR(50) = NULL
, @CODE_ROUTE VARCHAR(50)
, @SELLER_CODE VARCHAR(50) = NULL
, @LAST_UPDATE_BY VARCHAR(50)
--,@HHID VARCHAR(50) = NULL
, @SING VARCHAR(MAX) = NULL
, @PHOTO VARCHAR(MAX) = NULL
, @STATUS VARCHAR(20) = NULL
, @NEW VARCHAR(10) = 1
, @GPS VARCHAR(MAX) = '0,0'
, @REFERENCE VARCHAR(150) = NULL
, @POST_DATETIME DATETIME = NULL
, @POS_SALE_NAME VARCHAR(150) = '...'
, @INVOICE_NAME VARCHAR(150) = '...'
, @INVOICE_ADDRESS VARCHAR(150) = '...'
, @NIT VARCHAR(150) = '...'
, @CONTACT_ID VARCHAR(150) = '...'
, @UPDATED_FROM_BO INT
, @SYNC_ID VARCHAR(250)

, @OWNER_ID INT = NULL
-- ----------------------------------------------------------------------------------
-- Parametros para frequency
-- ----------------------------------------------------------------------------------
, @MONDAY VARCHAR(2)
, @TUESDAY VARCHAR(2)
, @WEDNESDAY VARCHAR(2)
, @THURSDAY VARCHAR(2)
, @FRIDAY VARCHAR(2)
, @SATURDAY VARCHAR(2)
, @SUNDAY VARCHAR(2)
, @FREQUENCY_WEEKS VARCHAR(2) = NULL
, @LAST_DATE_VISITED DATETIME = NULL
-- ------------------------------------------------------------------------------------
-- Parametros para registro de transacciones
-- ------------------------------------------------------------------------------------
, @DEVICE_NETWORK_TYPE VARCHAR(15) = NULL
, @IS_POSTED_OFFLINE INT = 0
)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @ID INT
         ,@HHID VARCHAR(50) = NULL
         ,@SCOUTING_PREFIX VARCHAR(MAX)
         ,@SCOUTING_SEQUENCE INT
         ,@CLIENT_EXIST VARCHAR(50) = NULL
         ,@IN_ERP INT
         ,@SYNCID VARCHAR(250)
		 ,@OWNER_CODE VARCHAR(50) = NULL
		 ,@SERVER_POSTED_DATETIME DATETIME = GETDATE();
  BEGIN TRAN
  BEGIN TRY

    -- ----------------------------------------------------------------------------------
    -- Se verifica la existencia del cliente y si ya esta en ERP
    -- ----------------------------------------------------------------------------------      
    IF ISNUMERIC(@CODE_CUSTOMER) <> 0 
	BEGIN 
		SELECT
			@CLIENT_EXIST = SCN.CODE_CUSTOMER
		FROM [SONDA].SWIFT_CUSTOMERS_NEW SCN
		WHERE SCN.[CODE_CUSTOMER_HH] = @CODE_CUSTOMER
			AND [SCN].[CODE_ROUTE] = @CODE_ROUTE
			AND [SCN].[POST_DATETIME] = @POST_DATETIME
	END
	ELSE
	BEGIN
		SELECT
			@CLIENT_EXIST = SCN.CODE_CUSTOMER
		FROM [SONDA].SWIFT_CUSTOMERS_NEW SCN
		WHERE SCN.CODE_CUSTOMER = @CODE_CUSTOMER

		SELECT
			@IN_ERP = COUNT([SCN].[IS_POSTED_ERP])
		FROM [SONDA].SWIFT_CUSTOMERS_NEW SCN
		WHERE SCN.CODE_CUSTOMER = @CODE_CUSTOMER
			AND IS_POSTED_ERP = 1
	END	
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el prefijo para la creacion de scouting
	-- ------------------------------------------------------------------------------------

	SELECT
        @SCOUTING_PREFIX = [SONDA].SWIFT_FN_GET_PARAMETER('SCOUTING', 'CLIENT_PREFIX')

    -- ----------------------------------------------------------------------------------
    -- Se elimina si existe, de lo contrario se agraga otra secuencia 
    -- ----------------------------------------------------------------------------------      
    IF (@CLIENT_EXIST IS NOT NULL AND ISNUMERIC(@CLIENT_EXIST) <> 1 )
    BEGIN
		--
		SELECT 
			@SCOUTING_SEQUENCE = REPLACE(@CLIENT_EXIST, @SCOUTING_PREFIX,'')

    END
    ELSE
    BEGIN
      --
      PRINT ('Se obtiene la secuencia y el prefijo del scouting')
      -- ----------------------------------------------------------------------------------
      -- Obtiene la secuencia de scouting
      -- ----------------------------------------------------------------------------------      
      SELECT
        @SCOUTING_SEQUENCE = NEXT VALUE
        FOR [SONDA].SCOUTING_CLIENT_SEQUENCE
      --
      PRINT ('Se concatena el prefijo con la secuencia.')
    END;

	-- ----------------------------------------------------------------------------------
    -- Se prepara el codigo de scouting
    -- ----------------------------------------------------------------------------------      
    SET @HHID = @SCOUTING_PREFIX + CONVERT(VARCHAR(18), @SCOUTING_SEQUENCE)
    SET @SYNCID = @SYNC_ID;

    PRINT ('Codigo generado: ' + @HHID)

    --
    PRINT ('Se inserte el cliente')

    DECLARE @CODE_CUSTOMER_BO VARCHAR(50) = NULL
           ,@EXISTS INT = 0

    SELECT TOP 1
      @EXISTS = 1
     ,@CODE_CUSTOMER_BO = [C].[CODE_CUSTOMER]
	 ,@OWNER_ID = [SC].[COMPANY_ID]
	 ,@OWNER_CODE = [C].[OWNER_ID]
    FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
		INNER JOIN [SONDA].[SWIFT_COMPANY] [SC] ON [C].[OWNER] = [SC].[COMPANY_NAME]
    WHERE [C].[CODE_CUSTOMER] = @CODE_CUSTOMER
	--
    IF @EXISTS = 0
    BEGIN
      SELECT TOP 1
        @EXISTS = 1
       ,@CODE_CUSTOMER_BO = [CN].[CODE_CUSTOMER]
      FROM [SONDA].[SWIFT_CUSTOMERS_NEW] [CN]
      WHERE [CN].[CODE_CUSTOMER] = @HHID
    END


    -- ----------------------------------------------------------------------------------
    -- Se inserta el cliente
    -- ----------------------------------------------------------------------------------
	INSERT	INTO [SONDA].[SWIFT_CUSTOMERS_NEW]
			(
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
				,[CODE_CUSTOMER_BO]
				,[OWNER_ID]
				,[SERVER_POSTED_DATETIME]
				,[DEVICE_NETWORK_TYPE]
				,[IS_POSTED_OFFLINE]
			)
	VALUES
			(
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
				,RTRIM(LTRIM(SUBSTRING(@GPS, 1,
										CHARINDEX(',', @GPS)
										- 1)))
				,RTRIM(LTRIM(SUBSTRING(@GPS,
										CHARINDEX(',', @GPS)
										+ 1, LEN(@GPS))))
				,@UPDATED_FROM_BO
				,@SYNCID
				,CASE @NEW 
					WHEN '0' THEN @OWNER_CODE
					ELSE NULL
				 END
				,@OWNER_ID
				,@SERVER_POSTED_DATETIME
				,@DEVICE_NETWORK_TYPE
				,@IS_POSTED_OFFLINE
			);
    --
    PRINT ('Se obtiene el id generado')

    -- ----------------------------------------------------------------------------------
    -- Se obtiene el id generado
    -- ----------------------------------------------------------------------------------  
    SELECT
      @ID = SCOPE_IDENTITY()
    PRINT (@ID)

    --
    PRINT ('Se inserte la frecuencia del cliente')
    -- ----------------------------------------------------------------------------------
    -- Se inserte la frecuencia del cliente
    -- ----------------------------------------------------------------------------------
    INSERT [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW (CODE_CUSTOMER
    , SUNDAY
    , MONDAY
    , TUESDAY
    , WEDNESDAY
    , THURSDAY
    , FRIDAY
    , SATURDAY
    , LAST_UPDATED
    , LAST_UPDATED_BY
    , FREQUENCY_WEEKS
    , LAST_DATE_VISITED)
      VALUES (@HHID, @SUNDAY, @MONDAY, @TUESDAY, @WEDNESDAY, @THURSDAY, @FRIDAY, @SATURDAY, GETDATE(), @LAST_UPDATE_BY, @FREQUENCY_WEEKS, @LAST_DATE_VISITED);

    SELECT
      CASE CAST(@EXISTS AS VARCHAR)
        WHEN '0' THEN @HHID
        ELSE @HHID
      END AS ID
	  , @SERVER_POSTED_DATETIME AS SERVER_POSTED_DATETIME
    COMMIT TRAN
  END TRY
  BEGIN CATCH
    ROLLBACK
    DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    RAISERROR (@ERROR, 16, 1)
  END CATCH
END
