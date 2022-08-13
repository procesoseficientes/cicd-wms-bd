-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	08-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30123: Catalogo de proyectos
-- Description:			Sp que inserta un proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	12-Jul-2019 G-FORCE@Dublin
-- Description:			Agrego el owner en los parametros del sp

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_PROJECT]						
					@STATUS VARCHAR(20) = 'CREATED'
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_PROJECT] (
		@OPPORTUNITY_CODE VARCHAR(50)
		,@OPPORTUNITY_NAME VARCHAR(150)
		,@SHORT_NAME VARCHAR(25)
		,@OBSERVATIONS VARCHAR(560)
		,@CUSTOMER_CODE VARCHAR(50) = NULL
		,@CUSTOMER_NAME VARCHAR(150) = NULL
		,@CUSTOMER_OWNER VARCHAR(30) = NULL
		,@STATUS VARCHAR(20)
		,@LOGIN_ID VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		DECLARE	@ID UNIQUEIDENTIFIER = NEWID();

		INSERT	INTO [wms].[OP_WMS_PROJECT]
				(
					[ID]
					,[OPPORTUNITY_CODE]
					,[OPPORTUNITY_NAME]
					,[SHORT_NAME]
					,[OBSERVATIONS]
					,[CUSTOMER_CODE]
					,[CUSTOMER_NAME]
					,[CUSTOMER_OWNER]
					,[STATUS]
					,[CREATED_BY]
					,[CREATED_DATE]
				)
		VALUES
				(
					@ID
					,@OPPORTUNITY_CODE
					,@OPPORTUNITY_NAME
					,@SHORT_NAME
					,@OBSERVATIONS
					,@CUSTOMER_CODE
					,@CUSTOMER_NAME
					,@CUSTOMER_OWNER
					,@STATUS
					,@LOGIN_ID
					,GETDATE()
				);
		
		INSERT	INTO [wms].[LOG_PROJECT]
				(
					[PROJECT_ID]
					,[OPPORTUNITY_NAME]
					,[CUSTOMER_CODE]
					,[CUSTOMER_NAME]
					,[CUSTOMER_OWNER]
					,[STATUS]
					,[TYPE_LOG]
					,[CREATED_BY]
					,[CREATED_DATE]
				)
		VALUES
				(
					@ID  -- PROJECT_ID - int
					,@OPPORTUNITY_NAME  -- OPPORTUNITY_NAME - varchar(150)
					,@CUSTOMER_CODE  -- CUSTOMER_CODE - varchar(20)
					,@CUSTOMER_NAME
					,@CUSTOMER_OWNER
					,@STATUS  -- STATUS - varchar(20)
					,'INSERT'  -- TYPE_LOG - varchar(20)
					,@LOGIN_ID  -- CREATED_BY - varchar(64)
					,GETDATE()  -- CREATED_DATE - datetime
					
				);

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@ID AS VARCHAR(156)) AS [DbData];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;