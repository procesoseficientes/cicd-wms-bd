-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-Nov-17 @ Nexus Team Sprint F-Zero
-- Description:			SP que que genera el manifiesto de carga apartir de una demanda
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CREATE_MANIFEST_FROM_PICKING_DEMAND]
					@VEHICLE_CODE = 32
					,@LOGIN = 'BETO'
					,@XML = N'<?xml version="1.0"?>
					<ArrayOfManifiestoDetalle xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
						<ManifiestoDetalle>
							<QTY>0</QTY>
							<DOCUMENT_DATE>0001-01-01T00:00:00</DOCUMENT_DATE>
							<WAVE_PICKING_ID>4599</WAVE_PICKING_ID>
							<MANIFEST_HEADER_ID>0</MANIFEST_HEADER_ID>
							<WEIGHT>0</WEIGHT>
							<PICKING_DEMAND_HEADER_ID>7441</PICKING_DEMAND_HEADER_ID>
							<IS_SELECTED>false</IS_SELECTED>
							<LAST_UPDATE>0001-01-01T00:00:00</LAST_UPDATE>
							<LINE_NUM>0</LINE_NUM>
							<MANIFEST_DETAIL_ID>0</MANIFEST_DETAIL_ID>
						</ManifiestoDetalle>
					</ArrayOfManifiestoDetalle>'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_MANIFEST_FROM_PICKING_DEMAND](
	@VEHICLE_CODE INT
	,@LOGIN VARCHAR(50)
	,@XML XML
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @MANIFEST_DETAIL TABLE(
		[WAVE_PICKING_ID] INT NOT NULL
		,[PICKING_DEMAND_HEADER_ID] INT NOT NULL UNIQUE
		,PRIMARY KEY ([WAVE_PICKING_ID],[PICKING_DEMAND_HEADER_ID])
	)
	--
	DECLARE 
		@ID INT = 0
		,@DISTRIBUTION_CENTER_ID VARCHAR(50) = ''
		,@PILOT_CODE INT = 0
		,@PLATE_NUMBER VARCHAR(10) = ''

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene el centro de distribucion del usuario
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @DISTRIBUTION_CENTER_ID = [W].[DISTRIBUTION_CENTER_ID] 
		FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
		INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON ([W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID])
		WHERE [WU].[WAREHOUSE_BY_USER_ID] > 0
			AND [WU].[LOGIN_ID] = @LOGIN

		-- ------------------------------------------------------------------------------------
		-- Obtiene datos del vehiculo
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@PILOT_CODE = [V].[PILOT_CODE]
			,@PLATE_NUMBER = [V].[PLATE_NUMBER]
		FROM [wms].[OP_WMS_VEHICLE] [V]
		WHERE [V].[VEHICLE_CODE] = @VEHICLE_CODE
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene el detalle del manifiesto
		-- ------------------------------------------------------------------------------------
		INSERT INTO @MANIFEST_DETAIL
				(
					[WAVE_PICKING_ID]
					,[PICKING_DEMAND_HEADER_ID]
				)
		SELECT
			x.Rec.query('./WAVE_PICKING_ID').value('.', 'int')
			,x.Rec.query('./PICKING_DEMAND_HEADER_ID').value('.', 'int')
		FROM @XML.nodes('/ArrayOfManifiestoDetalle/ManifiestoDetalle') AS x (Rec)

		-- ------------------------------------------------------------------------------------
		-- Valida si existe el un manifiesto para el vehiculo
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @ID = [MH].[MANIFEST_HEADER_ID]
		FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
		WHERE [MH].[MANIFEST_HEADER_ID] > 0
			AND [MH].[VEHICLE] = @VEHICLE_CODE
			AND [MH].[STATUS] IN ('IN_PICKING','CREATED')
			AND [MH].[MANIFEST_TYPE] = 'SALES_ORDER'
		ORDER BY [MH].[MANIFEST_HEADER_ID] DESC

		IF @ID = 0
		BEGIN
		    -- ------------------------------------------------------------------------------------
		    -- Inserta el manifiesto encabezado
		    -- ------------------------------------------------------------------------------------
		    INSERT INTO [wms].[OP_WMS_MANIFEST_HEADER]
		    		(
		    			[DRIVER]
		    			,[VEHICLE]
		    			,[DISTRIBUTION_CENTER]
		    			,[CREATED_DATE]
		    			,[STATUS]
		    			,[LAST_UPDATE]
		    			,[LAST_UPDATE_BY]
		    			,[MANIFEST_TYPE]
		    			,[TRANSFER_REQUEST_ID]
		    			,[PLATE_NUMBER]
		    			,[SOURCE]
		    		)
		    SELECT
		    	@PILOT_CODE
		    	,@VEHICLE_CODE
		    	,@DISTRIBUTION_CENTER_ID
		    	,GETDATE()
		    	,'IN_PICKING'
		    	,GETDATE()
		    	,@LOGIN
		    	,'SALES_ORDER'
		    	,NULL
		    	,@PLATE_NUMBER
		    	,'DEMANDA_DE_DESPACHO';
		    --
		    SET @ID = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
		    UPDATE [wms].[OP_WMS_MANIFEST_HEADER]
			SET
				[STATUS] = 'IN_PICKING'
				,[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = @LOGIN
			WHERE [MANIFEST_HEADER_ID] = @ID
		END

		-- ------------------------------------------------------------------------------------
		-- Inserta el manifiesto detalle
		-- ------------------------------------------------------------------------------------
		INSERT INTO [wms].[OP_WMS_MANIFEST_DETAIL]
				(
					[MANIFEST_HEADER_ID]
					,[CODE_ROUTE]
					,[CLIENT_CODE]
					,[WAVE_PICKING_ID]
					,[MATERIAL_ID]
					,[QTY]
					,[STATUS]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[ADDRESS_CUSTOMER]
					,[CLIENT_NAME]
					,[LINE_NUM]
					,[PICKING_DEMAND_HEADER_ID]
					,[STATE_CODE]
					,[CERTIFICATION_TYPE]
				)
		SELECT
			@ID
			,[DH].[CODE_ROUTE]
			,[DH].[CLIENT_CODE]
			,[DH].[WAVE_PICKING_ID]
			,[DD].[MATERIAL_ID]
			,[DD].[QTY]
			,'ON_WAREHOUSE'
			,GETDATE()
			,@LOGIN
			,[DH].[ADDRESS_CUSTOMER]
			,[DH].[CLIENT_NAME]
			,[DD].[LINE_NUM]
			,[DD].[PICKING_DEMAND_HEADER_ID]
			,[DH].[STATE_CODE]
			,NULL
		FROM @MANIFEST_DETAIL [MD]
		INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON ([DH].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID])
		INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON ([DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID])

		-- ------------------------------------------------------------------------------------
		-- Retorna el resultado
		-- ------------------------------------------------------------------------------------
		SELECT  
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo 
	END CATCH
END