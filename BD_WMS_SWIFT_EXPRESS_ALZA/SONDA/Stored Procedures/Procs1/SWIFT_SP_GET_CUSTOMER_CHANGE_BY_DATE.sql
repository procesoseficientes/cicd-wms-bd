-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:     Obtiene los datos de la tabla SWIFT_CUSTOMER_CHANGE que esten entre un rango de fechas

-- Modificacion 22-Mar-17 @ A-Team Sprint Fenyang
					-- eder.chamale
					-- Se agregaron los parametros NIT y INVOICE_NAME.
				   
-- Modificacion 10-May-17 @ A-Team Sprint Issa
					-- alberto.ruiz
					-- Se agregan las columnas de CUSTOMER_NAME Y NEW_CUSTOMER_NAME

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_CHANGE_BY_DATE]
		 @START_DATE = '2017-01-01'
		 ,@END_DATE = '2018-07-12'
*/
-- =========================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMER_CHANGE_BY_DATE] (
	@START_DATE DATETIME
	,@END_DATE DATETIME
) AS
BEGIN
	SET NOCOUNT ON;
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
			,[CC].[LAST_UPDATE]
			,[CC].[LAST_UPDATE_BY]
			,[CC].[TAX_ID]
			,[CC].[INVOICE_NAME]
			,ISNULL([CC].[CUSTOMER_NAME],'') [CUSTOMER_NAME]
			,ISNULL([CC].[NEW_CUSTOMER_NAME],'') [NEW_CUSTOMER_NAME]
		FROM [SONDA].[SWIFT_CUSTOMER_CHANGE] AS [CC]
		WHERE [CC].[POSTED_DATETIME] BETWEEN @START_DATE AND (@END_DATE + '23:59:59.000');
		--
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@ERROR VARCHAR(MAX) = ERROR_MESSAGE();
		RAISERROR(@ERROR,16,1);
	END CATCH;
END;
