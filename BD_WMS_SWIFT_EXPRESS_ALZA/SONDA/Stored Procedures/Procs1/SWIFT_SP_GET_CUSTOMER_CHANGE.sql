-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:    Obtiene un registro de la tabla SWIFT_CUSTOMER_CHANGE por medio del Codigo de Cliente, si le mandan NULL obtiene todos los registros 

-- Modificacion 22-Mar-17 @ A-Team Sprint Fenyang
					-- eder.chamale
					-- Se agregaron los parametros NIT y INVOICE_NAME.

-- Modificacion 10-May-17 @ A-Team Sprint Issa
					-- alberto.ruiz
					-- Se agregan las columnas de CUSTOMER_NAME Y NEW_CUSTOMER_NAME
				   
/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_CHANGE]
		 @CUSTOMER = '1'		 
=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMER_CHANGE] (
	@CUSTOMER VARCHAR(50) = NULL
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@FIELD_NAME_FOR_TAX_ID VARCHAR(100);
	--
	SELECT @FIELD_NAME_FOR_TAX_ID = [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING','FIELD_NAME_FOR_TAX_ID');
	--
	BEGIN TRY
		--
		SELECT
			[CC].[CUSTOMER]
			,[CC].[CODE_CUSTOMER]
			,[CC].[PHONE_CUSTOMER]
			,[CC].[ADRESS_CUSTOMER]
			,[CC].[CONTACT_CUSTOMER]
			,[CC].[GPS]
			,[CC].[POSTED_DATETIME]
			,[CC].[POSTED_BY]
			,[CC].[CODE_ROUTE]
			,[CC].[STATUS]
			,[CC].[STATUS_CHANGE_BY]
			,[CC].[STATUS_CHANGE_DATETIME]
			,[CC].[ATTEMPTED_WITH_ERROR]
			,[CC].[IS_POSTED_ERP]
			,[CC].[POSTED_ERP]
			,[CC].[POSTED_RESPONSE]
			,[CC].[TAX_ID]
			,[CC].[INVOICE_NAME]
			,@FIELD_NAME_FOR_TAX_ID [FIELD_NAME_FOR_TAX_ID]
			,ISNULL([CC].[CUSTOMER_NAME],'') [CUSTOMER_NAME]
			,ISNULL([CC].[NEW_CUSTOMER_NAME],'') [NEW_CUSTOMER_NAME]
		FROM [SONDA].[SWIFT_CUSTOMER_CHANGE] AS [CC]
		WHERE [CC].[CUSTOMER] = @CUSTOMER
			OR @CUSTOMER IS NULL;
		--
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@ERROR VARCHAR(MAX) = ERROR_MESSAGE();
		RAISERROR(@ERROR,16,1);
	END CATCH;
END;
