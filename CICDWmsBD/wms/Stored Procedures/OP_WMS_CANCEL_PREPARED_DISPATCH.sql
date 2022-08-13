-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/18/2018 @ GForce-Team Sprint Búho 
-- Description:			Cancela un despacho general de orden de preparado

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_CANCEL_PREPARED_DISPATCH]
					@PICKING_DEMAND_HEADER_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_CANCEL_PREPARED_DISPATCH](
	@PICKING_DEMAND_HEADER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DOC_NUM INT = 0
		,@WAVE_PICKING_ID INT = 0
		,@LICENSE_ID INT = 0
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Valida que sea una orden de preparado
		-- ------------------------------------------------------------------------------------    
		IF EXISTS (SELECT TOP 1 1 FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID AND [IS_FOR_DELIVERY_IMMEDIATE] = 1)
		BEGIN
			RAISERROR ('La demanda no es de entrega no inmediata.', 16, 1);
			RETURN;
		END

		-- ------------------------------------------------------------------------------------
		-- Valida que no se haya creado ya el picking final para la orden de preparado
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 
			@DOC_NUM = [DOC_NUM]
			,@WAVE_PICKING_ID = [WAVE_PICKING_ID]
		FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] 
		WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID

		IF EXISTS (SELECT TOP 1 1 FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] WHERE [DOC_NUM] = @DOC_NUM AND [IS_FOR_DELIVERY_IMMEDIATE] = 1)
		BEGIN
			RAISERROR ('La demanda no se puede cancelar debido a que ya se esta realizando el picking final.', 16, 1);
			RETURN;
		END
		
		-- ------------------------------------------------------------------------------------
		-- Cancela todas las tareas asignadas a la ola de picking
		-- ------------------------------------------------------------------------------------
		UPDATE [wms].[OP_WMS_TASK_LIST] 
		SET [QUANTITY_PENDING] = 0, [IS_CANCELED] = 1
		WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID

		-- ------------------------------------------------------------------------------------
		-- Le quita el DEMAND_HEADER_ID a la licencia y desbloquea el inventario de la licencia
		-- ------------------------------------------------------------------------------------
		 UPDATE IL
		SET [IL].[LOCKED_BY_INTERFACES] = 0
		FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L]
		  ON (
		  [IL].[LICENSE_ID] = [L].[LICENSE_ID]
		  )
		WHERE [L].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID


		 UPDATE [L] SET
		  [L].[PICKING_DEMAND_HEADER_ID] = NULL
		FROM [wms].[OP_WMS_LICENSES] [L] 
		WHERE [L].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
		
		-- ------------------------------------------------------------------------------------
		-- Elimina la demanda despacho
		-- ------------------------------------------------------------------------------------
		DELETE FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] 
		WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID

		DELETE FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
		WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID

		-- ------------------------------------------------------------------------------------
		-- Resultado final
		-- ------------------------------------------------------------------------------------
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH

		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
		,'' DbData
	END CATCH

END