-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	08-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30123: Catalogo de proyectos
-- Description:			Sp que inserta un proyecto

-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		09-JuLio-19 @ GForce-Team Sprint Dublin
-- Description:			    Se agrego nuevo parametro e insert en log.

-- Autor:					marvin.solares
-- Fecha de Creacion: 		18-JuLio-19 @ GForce-Team Sprint Dublin
-- Description:			    se agrega validacion para que no permita eliminar proyecto cuando tiene asignado inventario
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_DELETE_PROJECT]						
					@ID = '000XCVZXC1V2Z4D5F4AS5DF', @LOGIN = ''
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_PROJECT] (
		@ID UNIQUEIDENTIFIER
		,@LOGIN AS VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

---------------------------------------------------------------------------------
-- OBTENEMOS LOS DATOS DEL PROYECTO
---------------------------------------------------------------------------------

		DECLARE	@OPPORTUNITY_NAME AS VARCHAR(150);
		DECLARE	@CUSTOMER_CODE AS VARCHAR(20);
		DECLARE	@STATUS AS VARCHAR(20);

		-- ------------------------------------------------------------------------------------
		-- si el projecto tiene asociado inventario no permitimos la eliminacion
		-- ------------------------------------------------------------------------------------
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
					WHERE
						[PROJECT_ID] = @ID )
		BEGIN
			RAISERROR (N'No puede eliminar el proyecto porque tiene asignado inventario.', 16, 1);
			RETURN;
		END;
		SELECT
			@OPPORTUNITY_NAME = [OPPORTUNITY_NAME]
			,@CUSTOMER_CODE = [CUSTOMER_CODE]
			,@STATUS = [STATUS]
		FROM
			[wms].[OP_WMS_PROJECT]
		WHERE
			[ID] = @ID;

---------------------------------------------------------------------------------
-- ELIMINAMOS EL PROYECTO
---------------------------------------------------------------------------------

		DELETE FROM
			[wms].[OP_WMS_PROJECT]
		WHERE
			@ID = [ID];

---------------------------------------------------------------------------------
-- INSERTAMOS LOG DE ELIMINACION
---------------------------------------------------------------------------------

		INSERT	[wms].[LOG_PROJECT]
				(
					[PROJECT_ID]
					,[OPPORTUNITY_NAME]
					,[CUSTOMER_CODE]
					,[STATUS]
					,[TYPE_LOG]
					,[CREATED_BY]
					,[CREATED_DATE]
				)
		VALUES
				(
					@ID
					, -- PROJECT_ID - uniqueidentifier
					@OPPORTUNITY_NAME
					, -- OPPORTUNITY_NAME - varchar(150)
					@CUSTOMER_CODE
					, -- CUSTOMER_CODE - varchar(20)
					@STATUS
					, -- STATUS - varchar(20)
					'DELETE'
					, -- TYPE_LOG - varchar(20)
					@LOGIN
					, -- CREATED_BY - varchar(64)
					GETDATE()  -- CREATED_DATE - datetime
				);

---------------------------------------------------------------------------------
-- DEVUELVE CODIGO DE OPERACION SATISFACTORIO
---------------------------------------------------------------------------------

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