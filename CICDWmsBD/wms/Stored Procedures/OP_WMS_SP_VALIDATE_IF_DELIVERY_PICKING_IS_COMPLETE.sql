-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-05 @ Team REBORN - Sprint Ramsey
-- Description:	        SP que devuelve el porcentaje de la demanda de despacho despachada

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_VALIDATE_IF_DELIVERY_PICKING_IS_COMPLETE 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_IF_DELIVERY_PICKING_IS_COMPLETE] (@WAVE_PICKING_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
  --

	BEGIN TRY
		DECLARE
			@QTY_TOTAL NUMERIC(18, 4)
			,@QTY_DELIVERED NUMERIC(18, 4)
			,@PORCENTAJE NUMERIC(18, 2) = 0;

		SELECT
			@QTY_TOTAL = COUNT([PL].[LABEL_ID])
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
		INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL] ON [PL].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
		WHERE
			[DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;


		SELECT
			@QTY_DELIVERED = COUNT([DD].[LABEL_ID])
		FROM
			[wms].[OP_WMS_DELIVERED_DISPATCH_HEADER] [DH]
		INNER JOIN [wms].[OP_WMS_DELIVERED_DISPATCH_DETAIL] [DD] ON [DD].[DELIVERED_DISPATCH_HEADER_ID] = [DH].[DELIVERED_DISPATCH_HEADER_ID]
		WHERE
			[DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

		IF @QTY_DELIVERED IS NOT NULL
		BEGIN
			SET @PORCENTAJE = (@QTY_DELIVERED / @QTY_TOTAL
								* 100);
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@PORCENTAJE AS VARCHAR) [DbData];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

END;