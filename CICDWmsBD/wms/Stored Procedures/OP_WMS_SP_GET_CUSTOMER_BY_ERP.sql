-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Julio-2019 G-Force@Dublin
-- Description:			Sp que obtiene los clientes de ERP

-- Autor:				marvin.solares
-- Fecha de Creacion: 	12-Julio-2019 G-Force@Dublin
-- Description:			se modifica para que al fallar algun ambiente de erp devuelva el error hacia el bo y no devuelva clientes

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_CUSTOMER_BY_ERP]
				
*/
-- =============================================  
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CUSTOMER_BY_ERP]
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE	@TEMP_CUSTOMER AS TABLE (
			[CUSTOMER_CODE] VARCHAR(15)
			,[CUSTOMER_NAME] VARCHAR(100)
			,[OWNER] VARCHAR(30)
		);

		-- ------------------------------------------------------------------------------------
		-- OBTENEMOS EL OWNER(CLIENT_CODE)
		-- ------------------------------------------------------------------------------------

	SELECT
		[C].[COMPANY_ID]
		,[ES].[INTERFACE_DATA_BASE_NAME]
		,[C].[ERP_DATABASE]
		,[ES].[SCHEMA_NAME]
		,[C].[CLIENT_CODE]
	INTO
		[#owners]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
	WHERE
		[ES].[READ_ERP] = 1;

		-- ------------------------------------------------------------------------------------
		-- RECORREMOS LOS 
		-- ------------------------------------------------------------------------------------
	WHILE (EXISTS ( SELECT TOP 1
						1
					FROM
						[#owners] ))
	BEGIN
		DECLARE	@ID INT;
		DECLARE
			@INTERFACE_DATA_BASE_NAME VARCHAR(200)
			,@ERP_DATABASE VARCHAR(200)
			,@SCHEMA_NAME VARCHAR(200)
			,@QUERY NVARCHAR(2000)
			,@CLIENT_CODE VARCHAR(30);

		SELECT TOP 1
			@ID = [COMPANY_ID]
			,@INTERFACE_DATA_BASE_NAME = [INTERFACE_DATA_BASE_NAME]
			,@ERP_DATABASE = [ERP_DATABASE]
			,@SCHEMA_NAME = [SCHEMA_NAME]
			,@CLIENT_CODE = [CLIENT_CODE]
		FROM
			[#owners];

		IF @ERP_DATABASE IS NOT NULL
			AND @ERP_DATABASE <> ''
		BEGIN
			SELECT
				@QUERY = N'EXEC '
				+ @INTERFACE_DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.SWIFT_SP_GET_CUSTOMERS @DATABASE ='''
				+ @ERP_DATABASE + ''',@OWNER ='''
				+ @CLIENT_CODE + '''';
	--
			INSERT	INTO @TEMP_CUSTOMER
					(
						[CUSTOMER_CODE]
						,[CUSTOMER_NAME]
						,[OWNER]
						
					)
					EXEC [sp_executesql] @QUERY;
		END;
		DELETE FROM
			[#owners]
		WHERE
			[COMPANY_ID] = @ID;
		
	END;

	SELECT
		[CUSTOMER_CODE]
		,[CUSTOMER_NAME]
		,[OWNER]
	FROM
		@TEMP_CUSTOMER;
END;