-- =============================================
-- Autor:	            jonatan.palacios
-- Fecha de Creacion: 	13/11/2021 SPRINT 33
-- Description:	        Sp que marca un masterpack wms fallido

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3]
				@MASTERPACK_DEMAND_HEADER_ID = 6262
				,@POSTED_RESPONSE = 'Error de sap'
				,@POSTED_STATUS = -1
				,@OWNER = 'motorganica'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MASTERPACK_AS_FAILED] (
	@MASTERPACK_DEMAND_HEADER_ID INT,
	@POSTED_RESPONSE VARCHAR(500),
	@POSTED_STATUS INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Actualiza encabezado
		-- ------------------------------------------------------------------------------------
		UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER] SET	
			[LAST_UPDATED] = GETDATE(),
			[LAST_UPDATE_BY] = 'INTERFACE',
			[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1,
			[POSTED_STATUS] = ISNULL(@POSTED_STATUS,-1),
			[POSTED_ERP] = GETDATE(),
			[POSTED_RESPONSE] = ISNULL(@POSTED_RESPONSE,-1),
			[IS_POSTED_ERP] = -1,
			[IS_SENDING] = 0,
			[EXPLODED] = -1
				WHERE [MASTER_PACK_HEADER_ID] = @MASTERPACK_DEMAND_HEADER_ID;
		-- ------------------------------------------------------------------------------------
		-- Actualiza Detalle
		-- ------------------------------------------------------------------------------------
		UPDATE [MPDD] SET	
			[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1,
			[POSTED_STATUS] = ISNULL(@POSTED_STATUS,-1),
			[POSTED_ERP] = GETDATE(),
			[POSTED_RESPONSE] = @POSTED_RESPONSE,
			[IS_POSTED_ERP] = -1
				FROM [wms].[OP_WMS_MASTER_PACK_DETAIL] [MPDD]
					WHERE [MPDD].[MASTER_PACK_HEADER_ID] = @MASTERPACK_DEMAND_HEADER_ID
		--
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