-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:    Obtiene los 5 primeros datos de la tabla SWIFT_CUSTOMER_CHANGE 

-- Modificacion 22-Mar-17 @ A-Team Sprint Fenyang
					-- eder.chamale
					-- Se agregaron los parametros NIT y INVOICE_NAME.

-- Modificacion 4/4/2017 @ A-Team Sprint Garai
					-- diego.as
					-- Se agrega parametro SHIPPING_ATTEMPTS para que vaya a leer el parametro de intento de envios.

-- Modificacion 5/10/2017 @ A-Team Sprint Issa
					-- diego.as
					-- Se agrega columna NEW_CUSTOMER_NAME

-- Modificacion 5/29/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrego el parametro @OWNER y se filtran los cambios de clientes por tal.
-- Modificacion 6/1/2017 @ A-Team Sprint 
					-- diego.as
					-- Se modifica para que la consulta devuelva las columnas DEPARTMENT, MUNICIPALITY, COLONY
/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_TOP5_CUSTOMER_CHANGE] @OWNER='Arium'

=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP5_CUSTOMER_CHANGE](
	@OWNER VARCHAR(125)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @FIELD_NAME_FOR_TAX_ID VARCHAR(100)
	,@SHIPPING_ATTEMPTS INT
	--
	SELECT @FIELD_NAME_FOR_TAX_ID = [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'FIELD_NAME_FOR_TAX_ID')
	,@SHIPPING_ATTEMPTS = CAST( [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'SHIPPING_ATTEMPTS') AS INT)
	--
	BEGIN TRY
		--
		SELECT TOP 5
				CC.CUSTOMER
				,CC.[OWNER_ID] CODE_CUSTOMER
				,CC.PHONE_CUSTOMER
				,CC.ADRESS_CUSTOMER
				,CC.CONTACT_CUSTOMER
				,CC.GPS
				,CC.POSTED_DATETIME
				,CC.POSTED_BY
				,CC.CODE_ROUTE
				,CC.STATUS
				,CC.STATUS_CHANGE_BY
				,CC.STATUS_CHANGE_DATETIME
				,CC.ATTEMPTED_WITH_ERROR
				,CC.IS_POSTED_ERP
				,CC.POSTED_ERP
				,CC.POSTED_RESPONSE
				,CC.[TAX_ID]
				,CC.[INVOICE_NAME]
				,@FIELD_NAME_FOR_TAX_ID FIELD_NAME_FOR_TAX_ID
				,CC.NEW_CUSTOMER_NAME
				,[CC].[OWNER]
				,ISNULL([CC].[DEPARTMENT], 'NO ESPECIFICADO') AS DEPARTMENT
				,ISNULL([CC].[MUNICIPALITY],'NO ESPECIFICADO') AS MUNICIPALITY
				,ISNULL([CC].[COLONY], 'NO ESPECIFICADO') AS COLONY
		FROM [SONDA].[SWIFT_CUSTOMER_CHANGE] AS CC
			INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VAC] ON [CC].[CODE_CUSTOMER] = [VAC].[CODE_CUSTOMER]
      WHERE ISNULL(IS_POSTED_ERP, 0) = 0
      AND ISNULL(ATTEMPTED_WITH_ERROR, 0) <= @SHIPPING_ATTEMPTS
      AND CC.STATUS = 'ACCEPTED'
	  AND [CC].[OWNER] = @OWNER
      ORDER BY ATTEMPTED_WITH_ERROR,CC.POSTED_DATETIME 
    --
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@ERROR,16,1)
	END CATCH
	--
END
