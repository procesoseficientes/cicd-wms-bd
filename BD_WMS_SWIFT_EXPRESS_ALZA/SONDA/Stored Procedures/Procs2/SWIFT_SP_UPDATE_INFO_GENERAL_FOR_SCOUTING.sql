--===========================================================
--Autor:				    diego.as
--Fecha de Creacion: 		04-07-2016 Sprint ζ
--Description:			Actualiza los datos Generales de un cliente de scouting. 

-- Modificacion 21-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrego la columna OWNER

/*
--Ejemplo de ejecucion:

  EXEC [SONDA].[SWIFT_SP_UPDATE_INFO_GENERAL_FOR_SCOUTING]
  --Customer
          @CODE_CUSTOMER = 'C001'
			,@NAME_CUSTOMER = '...'
			,@PHONE_CUSTOMER  = '...'
			,@ADRESS_CUSTOMER  = '...'
        	,@POS_SALE_NAME = 'Anonimo'
        	,@INVOICE_NAME = 'Nombre Facturacion'
        	,@INVOICE_ADDRESS = 'Direccion Facturacion'
        	,@NIT = '45455-45'
        	,@CONTACT_ID = 'LUIS'
			,@LOGIN = 'GERENTE@SONDA'
			,@OWNER_ID = 1
	----
	SELECT * FROM [SONDA].[SWIFT_CUSTOMERS_NEW]
    WHERE CODE_CUSTOMER = 'C001'
    ORDER BY CUSTOMER DESC
*/
-- ============================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_INFO_GENERAL_FOR_SCOUTING]
(
  @CODE_CUSTOMER VARCHAR(50)
	,@NAME_CUSTOMER VARCHAR(250) = '...'
	,@PHONE_CUSTOMER VARCHAR(250) = '...'
	,@ADRESS_CUSTOMER VARCHAR(250) = '...'
	,@POS_SALE_NAME VARCHAR(250) = '...'
	,@INVOICE_NAME VARCHAR(250) = '...'
	,@INVOICE_ADDRESS VARCHAR(250) = '...'
	,@NIT VARCHAR(250) = '...'
	,@CONTACT_ID VARCHAR(250) = '...'
	,@COMMENTS VARCHAR(250) = '...'
	,@LOGIN VARCHAR(250)
	,@OWNER_ID INT
)AS
BEGIN
	  --
	  BEGIN TRY
      -- ----------------------------------------------------------------------------------
	  -- Se ACTUALIZA la Informacion General del cliente
	  -- ----------------------------------------------------------------------------------
      UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
	  SET	[NAME_CUSTOMER] = @NAME_CUSTOMER
			,[PHONE_CUSTOMER] = @PHONE_CUSTOMER
			,[ADRESS_CUSTOMER] = @ADRESS_CUSTOMER
			,[POS_SALE_NAME] = @POS_SALE_NAME
        	,[INVOICE_NAME] = @INVOICE_NAME
        	,[INVOICE_ADDRESS] = @INVOICE_ADDRESS
        	,[NIT] = @NIT
        	,[CONTACT_ID] = @CONTACT_ID
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LOGIN
			,[UPDATED_FROM_BO] = 1
			,[OWNER_ID] = @OWNER_ID
	  WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
		--
			IF @@error = 0 BEGIN		
				SELECT  1 AS RESULTADO , 'Proceso Exitoso' MENSAJE ,  0 CODIGO
			END		
			ELSE BEGIN		
				SELECT  -1 AS RESULTADO , ERROR_MESSAGE() MENSAJE ,  @@ERROR CODIGO
			END
		--
  	  END TRY	
	  BEGIN CATCH
			SELECT  -1 AS RESULTADO , ERROR_MESSAGE() MENSAJE ,  @@ERROR CODIGO
	  END CATCH
END
