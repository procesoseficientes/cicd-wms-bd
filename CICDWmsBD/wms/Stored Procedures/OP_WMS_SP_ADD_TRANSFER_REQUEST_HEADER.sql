-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			SP para agregar una solicitud de transferencia

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_ADD_TRANSFER_REQUEST_HEADER]
					@REQUEST_TYPE = 'prueba'
					,@WAREHOUSE_FROM = 'prueba'
					,@WAREHOUSE_TO = 'prueba'
					,@DELIVERY_DATE = '20170817'
					,@COMMENT = 'prueba'
					,@STATUS = 'prueba'
					,@CREATED_BY = 'prueba'
					,@OWNER = 'prueba'
				-- 
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_TRANSFER_REQUEST_HEADER](
	@REQUEST_TYPE VARCHAR(50)
	,@WAREHOUSE_FROM VARCHAR(25)
	,@WAREHOUSE_TO VARCHAR(25)
	,@DELIVERY_DATE DATETIME
	,@COMMENT VARCHAR(250)
	,@STATUS VARCHAR(25)
	,@CREATED_BY VARCHAR(25)
	,@OWNER VARCHAR(50) = NULL
	,@IS_FROM_ERP INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [wms].[OP_WMS_TRANSFER_REQUEST_HEADER]
				(
					[REQUEST_TYPE]
					,[WAREHOUSE_FROM]
					,[WAREHOUSE_TO]
					,[REQUEST_DATE]
					,[DELIVERY_DATE]
					,[COMMENT]
					,[STATUS]
					,[CREATED_BY]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[OWNER]
					,[IS_FROM_ERP]
				)
		VALUES
				(
					@REQUEST_TYPE  -- REQUEST_TYPE - varchar(50)
					,@WAREHOUSE_FROM  -- WAREHOUSE_FROM - varchar(25)
					,@WAREHOUSE_TO  -- WAREHOUSE_TO - varchar(25)
					,GETDATE()  -- REQUEST_DATE - datetime
					,@DELIVERY_DATE  -- DELIVERY_DATE - datetime
					,@COMMENT  -- COMMENT - varchar(250)
					,@STATUS  -- STATUS - varchar(25)
					,@CREATED_BY  -- CREATED_BY - varchar(25)
					,GETDATE()  -- LAST_UPDATE - datetime
					,@CREATED_BY  -- LAST_UPDATE_BY - varchar(25)
					,@OWNER  -- OWNER - varchar(50)
					,@IS_FROM_ERP -- IS_FROM_ERP - Int
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END