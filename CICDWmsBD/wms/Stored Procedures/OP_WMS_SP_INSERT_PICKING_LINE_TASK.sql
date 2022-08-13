-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-Oct-17 @ Nexus Team Sprint ewms 
-- Description:			SP que agrega la ola a la linea de picking

-- Modificacion 14-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega IS_NULL para codigo de cliente ,ruta y nombre de cliene

-- Modificacion 22-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se arregla como obtiene la cantidad de cajas

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_PICKING_LINE_TASK]
					@WAVE_PICKING_ID = 74
					,@IS_CONSOLIDATED = 1
					,@PICKING_LINE_ID = 'LINEA_PICKING_1'
					,@LOGIN = 'BETO'
				--
				EXEC [wms].[OP_WMS_SP_INSERT_PICKING_LINE_TASK]
					@WAVE_PICKING_ID = 4581
					,@IS_CONSOLIDATED = 0
					,@PICKING_LINE_ID = 'LINEA_PICKING_1'
					,@LOGIN = 'BETO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_PICKING_LINE_TASK](
	@WAVE_PICKING_ID INT
	,@IS_CONSOLIDATED INT
	,@PICKING_LINE_ID VARCHAR(15)
	,@LOGIN VARCHAR(50)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@QUERY NVARCHAR(4000) = ''
		,@ERP_DOCUMENT VARCHAR(15) = ''
		,@RESULT VARCHAR(250)
		,@MESSAGE VARCHAR(2000)
		,@BOX_QTY INT = 0
		,@GATE VARCHAR(25) = ''
		,@CLIENT_CODE VARCHAR(50) = 'CONSOLIDADO'
		,@CLIENT_NAME VARCHAR(50) = 'CONSOLIDADO'
		,@CODE_ROUTE VARCHAR(50) = 'CONSOLIDADO';
	--
	CREATE TABLE #DEMAND (
		[ERP_DOCUMENT] VARCHAR(15)
		,[CLIENT_ID] VARCHAR(15)
		,[CLIENT_NAME] VARCHAR(150)
		,[CLIENT_ROUTE] VARCHAR(15)
		,[MATERIAL_ID] VARCHAR(25)
		,[MATERIAL_NAME] VARCHAR(150)
		,[QTY] NUMERIC
		,[ASSIGNED_BY] VARCHAR(25)
		,[WAVE_PICKING_ID_3PL] INT
		,[PICKING_LINE_ID] VARCHAR(15)
	)
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- 
		-- ------------------------------------------------------------------------------------
		IF @IS_CONSOLIDATED = 0
		BEGIN
		    SELECT TOP 1
				@CLIENT_CODE = [PH].[CLIENT_CODE]
				,@CLIENT_NAME = [PH].[CLIENT_NAME]
				,@CODE_ROUTE = [PH].[CODE_ROUTE] 
			FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
			WHERE [PH].[PICKING_DEMAND_HEADER_ID] > 0 
				AND [PH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		END

	    -- ------------------------------------------------------------------------------------
	    -- Obtiene el detalle de la ola
	    -- ------------------------------------------------------------------------------------
	    SELECT @QUERY ='INSERT INTO #DEMAND
	    			(
	    				[ERP_DOCUMENT]
	    				,[CLIENT_ID]
	    				,[CLIENT_NAME]
	    				,[CLIENT_ROUTE]
	    				,[MATERIAL_ID]
	    				,[MATERIAL_NAME]
	    				,[QTY]
	    				,[ASSIGNED_BY]
	    				,[WAVE_PICKING_ID_3PL]
						,[PICKING_LINE_ID]
	    			)
	    	SELECT '
	    		+ CASE	
	    			WHEN @IS_CONSOLIDATED = 1 THEN '''PC-' 
	    			ELSE '''P-'
	    		END + CAST(@WAVE_PICKING_ID AS VARCHAR) +'''' + '
	    		,''' + ISNULL(@CLIENT_CODE,'NA') + '''
	    		,''' + ISNULL(@CLIENT_NAME,'NA') + '''
	    		,''' + ISNULL(@CODE_ROUTE,'NA') + '''
	    		,[TL].[MATERIAL_ID]
	    		,MAX([M].[MATERIAL_NAME])
	    		,SUM([TL].[QUANTITY_PENDING])
	    		,''' + @LOGIN + '''
	    		,' + CAST(@WAVE_PICKING_ID AS VARCHAR) + '
				,''' + @PICKING_LINE_ID + '''
	    	FROM [wms].[OP_WMS_TASK_LIST] [TL]
	    	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [TL].[MATERIAL_ID])
	    	WHERE [TL].[SERIAL_NUMBER] > 0
			AND [TL].[WAVE_PICKING_ID] = ' + CAST(@WAVE_PICKING_ID AS VARCHAR) + ' 
			AND [M].[USE_PICKING_LINE] = 1
	    	GROUP BY [TL].[MATERIAL_ID];';
	    --
	    PRINT '@QUERY: ' + @QUERY;
	    --
	    EXEC(@QUERY);

		-- ------------------------------------------------------------------------------------
		-- Obtiene la ubicacion
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@GATE = [TL].[LOCATION_SPOT_TARGET]
		FROM [wms].[OP_WMS_TASK_LIST] [TL]
		WHERE [TL].[SERIAL_NUMBER] > 0
			AND [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	    	
	    -- ------------------------------------------------------------------------------------
	    -- Agrega a la linea
	    -- ------------------------------------------------------------------------------------
	    INSERT INTO [wms].[OP_WMS_DEMAND_TO_PICK]
	    		(
	    			[ERP_DOCUMENT]
	    			,[ERP_DOC_DATE]
	    			,[LOADED_DATE]
	    			,[CLIENT_ID]
	    			,[CLIENT_NAME]
	    			,[CLIENT_ROUTE]
	    			,[MATERIAL_ID]
	    			,[MATERIAL_NAME]
	    			,[QTY]
	    			,[ASSIGNED_BY]
	    			,[CLIENT_REGION]
	    			,[ASSIGNED_DATE]
	    			,[ALLOWED_TO_PICK]
	    			,[ASSIGNED_TO_LINE]
	    			,[POSICION]
	    			,[VOIDED_DATE]
	    --			,[SAP_DELIVERY_ID]
	    --			,[NEEDS_TO_AUDIT]
	    --			,[CLIENT_PHONE]
	    --			,[CLIENT_ADDRESS]
	    --			,[PRIZES_SHIPPED]
	    --			,[PRINTED_SAP]
	    --			,[DUE_TO_PAY]
	    --			,[WAVE_PICKING_ID_3PL]
					--,[GATE]
	    		)
		SELECT
			[D].[ERP_DOCUMENT]
			,GETDATE()
			,GETDATE()
			,[D].[CLIENT_ID]
			,[D].[CLIENT_NAME]
			,[D].[CLIENT_ROUTE]
			,[D].[MATERIAL_ID]
			,[D].[MATERIAL_NAME]
			,[D].[QTY]
			,[D].[ASSIGNED_BY]
			,''
			,GETDATE()
			,NULL
			,@PICKING_LINE_ID
			,0
			,GETDATE()
			--,''
			--,0
			--,''
			--,''
			--,0
			--,GETDATE()
			--,0
			--,[D].[WAVE_PICKING_ID_3PL]
			--,@GATE
		FROM [#DEMAND] [D];

		-- ------------------------------------------------------------------------------------
		-- Se cartoniza
		-- ------------------------------------------------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM [#DEMAND])
		BEGIN
    		SELECT TOP 1 
    			@ERP_DOCUMENT = [D].[ERP_DOCUMENT]
    			,@RESULT = ''
    		FROM [#DEMAND] [D]
    
    		PRINT ' Cartornizar documento: ' + CAST( @ERP_DOCUMENT AS VARCHAR)
    		--
    		EXEC wms.[OP_WMS_SP_CREATE_DISTRIBUTED_TASK]
    			@pERP_DOC = @ERP_DOCUMENT, -- varchar(25)
    			@pLOGIN_ID = @LOGIN, -- varchar(25)
    			@pResult = @RESULT OUTPUT-- varchar(250)
    		--
    		PRINT ' Cartornizar finalizo:  ' + CAST( @RESULT AS VARCHAR)
    		IF(@RESULT != 'OK')
    		BEGIN
    			SELECT @MESSAGE = 
    				CASE @RESULT
    					WHEN '' THEN 'No retorno exito al cartonizar'
    					ELSE @RESULT
    				END
    			--
    			DELETE FROM [#DEMAND] 
    			--
    			RAISERROR(@MESSAGE,16,1);
    		END
		END

		-- ------------------------------------------------------------------------------------
		-- Obtiene la cantidad de cajas el ultimo documento
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @BOX_QTY = ISNULL(MAX([BOX_NUMBER]),0)
		FROM wms.[OP_WMS_DISTRIBUTED_TASK]
		WHERE [ERP_DOC] = @ERP_DOCUMENT

	    -- ------------------------------------------------------------------------------------
	    -- Retorna el resultado
	    -- ------------------------------------------------------------------------------------
		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,(@ERP_DOCUMENT + '|' + CAST(@BOX_QTY AS VARCHAR)) DbData
	END TRY
	BEGIN CATCH
		SELECT
			-1 as Resultado
			,ERROR_MESSAGE()  Mensaje 
			,@@ERROR Codigo
			,'' DbData
	END CATCH
END