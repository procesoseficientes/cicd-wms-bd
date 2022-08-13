-- =============================================
-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20181011 GForce@
-- Description:	        Sp que marca un picking wms como mandada a ERP 

/*
-- Ejemplo de Ejecucion:
		EXEC  [wms].[OP_WMS_SP_MARK_PICKING_AS_SEND_TO_R3]
			@PICKING_DEMAND_HEADER_ID = 5215
			,@POSTED_RESPONSE = 'Exito al guardar en sap 1 '
			,@ERP_REFERENCE = '666'
			,@POSTED_STATUS = 1
			,@OWNER = 'VISCOSA'
		--
		select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] WHERE PICKING_DEMAND_HEADER_ID = 5215
		select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_detail] WHERE PICKING_DEMAND_HEADER_ID = 5215
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_PICKING_AS_SEND_TO_R3] (
		@PICKING_DEMAND_HEADER_ID INT
		,@POSTED_RESPONSE VARCHAR(500)
		,@ERP_REFERENCE VARCHAR(50)
		,@POSTED_STATUS INT
		,@OWNER VARCHAR(50)
		,@IS_INVOICE INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle correspondiente
		-- ------------------------------------------------------------------------------------
		UPDATE
			[DD]
		SET	
			[DD].[POSTED_STATUS] = @POSTED_STATUS
			,[DD].[POSTED_ERP] = GETDATE()
			,[DD].[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[DD].[ERP_REFERENCE] = @ERP_REFERENCE
			,[DD].[IS_POSTED_ERP] = 1
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
		WHERE
			[DD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
			AND [DD].[MATERIAL_OWNER] = @OWNER;
		
		-- ------------------------------------------------------------------------------------
		-- Valida si ya se enviaron todos los detalles
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
						WHERE
							[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
							AND [IS_POSTED_ERP] != 1 )
		BEGIN
			UPDATE
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			SET	
				[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = 'INTERFACE'
				,[POSTED_STATUS] = @POSTED_STATUS
				,[POSTED_ERP] = GETDATE()
				,[POSTED_RESPONSE] = @POSTED_RESPONSE
				,[ERP_REFERENCE] = @ERP_REFERENCE
				,[ERP_REFERENCE_DOC_NUM] = @ERP_REFERENCE
				,[IS_POSTED_ERP] = 1
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
		END;

		-- ------------------------------------------------------------------------------------
		-- Muestra resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;
