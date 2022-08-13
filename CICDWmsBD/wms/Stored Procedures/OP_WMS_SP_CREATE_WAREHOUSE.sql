-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/19/2017 @ NEXUS-Team Sprint IceAge
-- Description:			Inserta una bodega

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CREATE_WAREHOUSE] 
					@WAREHOUSE_ID = 'BODEGA_01', -- varchar(25)
					@NAME = 'BODEGA_01', -- varchar(50)
					@COMMENTS = 'ALMACENAJE SECO', -- varchar(150)
					@ERP_WAREHOUSE = '05', -- varchar(50)
					@SHUNT_NAME = 'BODEGA_01', -- varchar(25)
					@WAREHOUSE_WEATHER = 'SECO', -- varchar(50)
					@WAREHOUSE_STATUS = 1, -- int
					@IS_3PL_WAREHOUSE = 1, -- int
					@WAREHOUSE_ADDRESS = '', -- varchar(250)
					@GPS_URL = '', -- varchar(100)
					@DISTRIBUTION_CENTER_ID = 'CTR_SUR', -- varchar(50)
					@PICKING_TYPE = 'ASCENDENTE' -- varchar(50)
				-- 
				SELECT * FROM [wms].[OP_WMS_WAREHOUSES] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_WAREHOUSE](
	@WAREHOUSE_ID VARCHAR(25)
	,@NAME VARCHAR(50)
	,@COMMENTS VARCHAR(150)
	,@ERP_WAREHOUSE VARCHAR(50)
	,@SHUNT_NAME VARCHAR(25)
	,@WAREHOUSE_WEATHER VARCHAR(50)
	,@WAREHOUSE_STATUS INT
	,@IS_3PL_WAREHOUSE INT
	,@WAREHOUSE_ADDRESS VARCHAR(250)
	,@GPS_URL VARCHAR(100)
	,@DISTRIBUTION_CENTER_ID VARCHAR(50)
	,@PICKING_TYPE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [wms].[OP_WMS_WAREHOUSES]
		        (
		         [WAREHOUSE_ID]
		        ,[NAME]
		        ,[COMMENTS]
		        ,[ERP_WAREHOUSE]
		        ,[SHUNT_NAME]
		        ,[WAREHOUSE_WEATHER]
		        ,[WAREHOUSE_STATUS]
		        ,[IS_3PL_WAREHUESE]
		        ,[WAHREHOUSE_ADDRESS]
		        ,[GPS_URL]
		        ,[DISTRIBUTION_CENTER_ID]
		        ,[PICKING_TYPE]
		        )
		VALUES
		        (
		         @WAREHOUSE_ID  -- WAREHOUSE_ID - varchar(25)
		        ,@NAME  -- NAME - varchar(50)
		        ,@COMMENTS  -- COMMENTS - varchar(150)
		        ,@ERP_WAREHOUSE  -- ERP_WAREHOUSE - varchar(50)
		        ,@SHUNT_NAME  -- SHUNT_NAME - varchar(25)
		        ,@WAREHOUSE_WEATHER  -- WAREHOUSE_WEATHER - varchar(50)
		        ,@WAREHOUSE_STATUS  -- WAREHOUSE_STATUS - int
		        ,@IS_3PL_WAREHOUSE  -- IS_3PL_WAREHUESE - int
		        ,@WAREHOUSE_ADDRESS  -- WAHREHOUSE_ADDRESS - varchar(250)
		        ,@GPS_URL  -- GPS_URL - varchar(100)
		        ,@DISTRIBUTION_CENTER_ID  -- DISTRIBUTION_CENTER_ID - varchar(50)
		        ,@PICKING_TYPE  -- PICKING_TYPE - varchar(50)
		        )
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe una bodega con el mismo código.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END