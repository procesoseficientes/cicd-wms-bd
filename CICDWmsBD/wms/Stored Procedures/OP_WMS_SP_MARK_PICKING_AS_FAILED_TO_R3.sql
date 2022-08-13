-- =============================================
-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20181011 GForce@Langosta
-- Description:	        Sp que marca un picking wms fallido

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3]
				@PICKING_DEMAND_HEADER_ID = 6262
				,@POSTED_RESPONSE = 'Error de sap'
				,@POSTED_STATUS = -1
				,@OWNER = 'motorganica'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_R3] (
		@PICKING_DEMAND_HEADER_ID INT
		,@POSTED_RESPONSE VARCHAR(500)
		,@POSTED_STATUS INT
		,@OWNER VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		
		-- ------------------------------------------------------------------------------------
		-- Actualiza encabezado
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
		SET	
			[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = 'INTERFACE'
			,[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR]
			+ 1
			,[POSTED_STATUS] = ISNULL(@POSTED_STATUS,-1)
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = ISNULL(@POSTED_RESPONSE,-1)
			,[IS_POSTED_ERP] = -1
			,[IS_SENDING] = 0
		WHERE
			[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
		-- ------------------------------------------------------------------------------------
		-- Actualiza Detalle
		-- ------------------------------------------------------------------------------------
		UPDATE
			[DD]
		SET	
			[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR]
			+ 1
			,[POSTED_STATUS] = ISNULL(@POSTED_STATUS,-1)
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[IS_POSTED_ERP] = -1
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
		WHERE
			[DD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
			AND [DD].[MATERIAL_OWNER] = @OWNER;
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