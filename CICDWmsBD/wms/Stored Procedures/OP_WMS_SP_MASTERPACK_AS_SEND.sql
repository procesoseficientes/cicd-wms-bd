-- =============================================
-- Autor:	            jonatan.palacios
-- Fecha de Creacion: 	2021/11/12 SPRINT 33
-- Description:	        Sp que marca un masterpack wms como mandada a ERP 

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
CREATE PROCEDURE [wms].[OP_WMS_SP_MASTERPACK_AS_SEND] (
	@MASTERPACK_DEMAND_HEADER_ID INT,
	@POSTED_RESPONSE VARCHAR(500),
	@ERP_REFERENCE VARCHAR(50),
	@POSTED_STATUS INT,
	@IS_INVOICE INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle correspondiente
		-- ------------------------------------------------------------------------------------
		UPDATE [MDD] SET	
			[MDD].[POSTED_STATUS] = @POSTED_STATUS,
			[MDD].[POSTED_ERP] = GETDATE(),
			[MDD].[POSTED_RESPONSE] = @POSTED_RESPONSE,
			[MDD].[ERP_REFERENCE] = @ERP_REFERENCE,
			[MDD].[IS_POSTED_ERP] = 1
			FROM [wms].[OP_WMS_MASTER_PACK_DETAIL] [MDD]
				WHERE
					[MDD].[MASTER_PACK_HEADER_ID] = @MASTERPACK_DEMAND_HEADER_ID
		-- ------------------------------------------------------------------------------------
		-- Valida si ya se enviaron todos los detalles
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS ( SELECT TOP 1 1 FROM [wms].[OP_WMS_MASTER_PACK_DETAIL]
			WHERE [MASTER_PACK_HEADER_ID] = @MASTERPACK_DEMAND_HEADER_ID AND [IS_POSTED_ERP] != 1 )
		BEGIN
			UPDATE
				[wms].[OP_WMS_MASTER_PACK_HEADER]
			SET	
				[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATE_BY] = 'INTERFACE'
				,[POSTED_STATUS] = @POSTED_STATUS
				,[POSTED_ERP] = GETDATE()
				,[POSTED_RESPONSE] = @POSTED_RESPONSE
				,[ERP_REFERENCE] = @ERP_REFERENCE
				,[ERP_REFERENCE_DOC_NUM] = @ERP_REFERENCE
				,[IS_POSTED_ERP] = 1
				,[EXPLODED] = 1
			WHERE
				[MASTER_PACK_HEADER_ID] = @MASTERPACK_DEMAND_HEADER_ID;
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
