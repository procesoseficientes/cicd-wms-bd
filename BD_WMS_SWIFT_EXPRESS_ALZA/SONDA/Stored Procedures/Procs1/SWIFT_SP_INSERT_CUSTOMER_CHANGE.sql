-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	06-07-2016 Sprint ζ
-- Description:			    Inserta en la tabla SWIFT_CUSTOMER_CHANGE un nuevo registro

-- Modificacion 3/22/2017 @ A-Team Sprint Fenyang
					-- rodrigo.gomez
					-- Se agregaron los campos TAX_ID e INVOICE_NAME 

-- Modificacion 5/10/2017 @ A-Team Sprint Issa
					-- rodrigo.gomez
					-- Se agregaron los campos CUSTOMER_NAME y NEW_CUSTOMER_NAME 

-- Modificacion 29-May-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Se agregaron campos de nit y nombre de facturacion

-- Modificacion 8/3/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- Se agrega columna SERVER_POSTED_DATETIME que albergara la fecha y hora en la que se postea el documento en el servidor

-- Modificacion 7/31/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agregaron los campos DEVICE_NETWORK_TYPE e IS_POSTED_OFFLINE

--Ejemplo de ejecucion:
/*
  EXEC [SONDA].[SWIFT_SP_INSERT_CUSTOMER_CHANGE]
  	 @CODE_CUSTOMER = 'RD001'
    ,@PHONE_CUSTOMER = '458598'
    ,@ADRESS_CUSTOMER = '0 Calle'
    ,@CONTACT_CUSTOMER = '123'
	,@GPS = '14,-90'
    ,@POSTED_DATETIME = '20160202'
    ,@POSTED_BY = 'prueba@SONDA'
    ,@CODE_ROUTE = '002'
	,@TAX_ID = 'C.F.'
	,@INVOICE_NAME = 'Tienda la Bendicion'
	,@CUSTOMER_NAME = 'Tienda la Bendicion'
	,@NEW_CUSTOMER_NAME = 'Tienda la Bendicion'
	,@DEVICE_NETWORK_TYPE = '3G'
	,@IS_POSTED_OFFLINE = 0

    SELECT * FROM [SONDA].SWIFT_CUSTOMER_CHANGE WHERE CODE_CUSTOMER = 'RD001'
*/


-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_CUSTOMER_CHANGE 
  @CODE_CUSTOMER VARCHAR(50)
  ,@PHONE_CUSTOMER VARCHAR(50)
  ,@ADRESS_CUSTOMER VARCHAR(250)
  ,@CONTACT_CUSTOMER VARCHAR(50)
  ,@GPS VARCHAR(50)
  ,@POSTED_DATETIME DATETIME
  ,@POSTED_BY VARCHAR(50) 
  ,@CODE_ROUTE VARCHAR(50)
  ,@TAX_ID VARCHAR(50)
  ,@INVOICE_NAME VARCHAR(100)
  ,@CUSTOMER_NAME VARCHAR(250)
  ,@NEW_CUSTOMER_NAME VARCHAR(250)
  ,@DEVICE_NETWORK_TYPE VARCHAR(15) = NULL
  ,@IS_POSTED_OFFLINE INT = 0
AS
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @ID NUMERIC(18,0), @OWNER VARCHAR(50), @OWNER_ID VARCHAR(50);
	DECLARE @SERVER_POSTED_DATETIME DATETIME = GETDATE();
	--   
	DELETE
		[T]
	FROM
		[SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE] [T]
	INNER JOIN [SONDA].[SWIFT_CUSTOMER_CHANGE] [CC]
	ON	[CC].[CUSTOMER] = [T].[CUSTOMER]
	WHERE
		[CC].[CODE_CUSTOMER] = @CODE_CUSTOMER
		AND [CC].[POSTED_DATETIME] = @POSTED_DATETIME;
	--
	DELETE FROM
		[SONDA].[SWIFT_CUSTOMER_CHANGE]
	WHERE
		[CODE_CUSTOMER] = @CODE_CUSTOMER
		AND [POSTED_DATETIME] = @POSTED_DATETIME;
	--
	SELECT @OWNER = [OWNER] , @OWNER_ID = [OWNER_ID] 
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
	--
	INSERT	INTO [SONDA].[SWIFT_CUSTOMER_CHANGE]
			(
				[CODE_CUSTOMER]
				,[PHONE_CUSTOMER]
				,[ADRESS_CUSTOMER]
				,[CONTACT_CUSTOMER]
				,[GPS]
				,[POSTED_DATETIME]
				,[POSTED_BY]
				,[CODE_ROUTE]
				,[STATUS]
				,[TAX_ID]
				,[INVOICE_NAME]
				,[CUSTOMER_NAME]
				,[NEW_CUSTOMER_NAME]
				,[OWNER]
				,[OWNER_ID]
				,[SERVER_POSTED_DATETIME]
				,[DEVICE_NETWORK_TYPE]
				,[IS_POSTED_OFFLINE]
			)
	VALUES
			(
				@CODE_CUSTOMER
				,@PHONE_CUSTOMER
				,@ADRESS_CUSTOMER
				,@CONTACT_CUSTOMER
				,@GPS
				,@POSTED_DATETIME
				,@POSTED_BY
				,@CODE_ROUTE
				,'NEW'
				,@TAX_ID
				,@INVOICE_NAME
				,@CUSTOMER_NAME
				,@NEW_CUSTOMER_NAME
				,@OWNER
				,@OWNER_ID
				,@SERVER_POSTED_DATETIME
				,@DEVICE_NETWORK_TYPE
				,@IS_POSTED_OFFLINE
			);

	--
	SET @ID = SCOPE_IDENTITY();
	--
	SELECT
		@ID AS [ID], @SERVER_POSTED_DATETIME AS SERVER_POSTED_DATETIME;

END TRY
BEGIN CATCH
  DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    RAISERROR (@ERROR, 16, 1)
END CATCH
