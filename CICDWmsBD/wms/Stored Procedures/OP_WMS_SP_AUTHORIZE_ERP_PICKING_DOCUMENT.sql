-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que autoriza el envio de un picking wms a erp

-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON SHEIK
-- Description:	        Se cambio para que de parametro pidiera el wave picking en lugar de el demand picking id Y que solo tome encuenta los que no se han mandado con exito

-- Modificacion 8/29/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- No deja autorizar los pickings de solicitudes de traslado.

-- Modificacion 1/10/2018 @ Reborn-Team Sprint Ramsey
-- diego.as
-- Se agregan validaciones para el tipo de entrega del picking asi como el estado de la entrega del mismo.

-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20190424 GForce@Xoloexcuincle
-- Description:	        Se cambia para que si acepte autorizar pickings de transferencia para envio a erp

/*
-- Ejemplo de Ejecucion:
			exec [wms].OP_WMS_SP_AUTHORIZE_ERP_PICKING_DOCUMENT @WAVE_PICKING_ID=2,@LAST_UPDATE_BY=N'ADMIN'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AUTHORIZE_ERP_PICKING_DOCUMENT] (
		@WAVE_PICKING_ID INT
		,@LAST_UPDATE_BY VARCHAR(50)
	)
AS
BEGIN
  
  --
	DECLARE	@IS_TRANSFER_REQUEST INT = 0;
  --
	BEGIN TRY

		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_TASK_LIST] [T]
						WHERE
							[T].[IS_COMPLETED] = 0
							AND [T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID )
		BEGIN
      --
			DECLARE
				@PICKING_DELIVERY_STATUS VARCHAR(50) = NULL
				,@IS_FOR_DELIVERY_IMMEDIATE INT = 1;
      -- ----------------------------------------------------------------------------------
      -- Se obtiene el tipo de demanda o picking (ENTREGA INMEDIATA || ENTREGA NO INMEDIATA)
      -- ----------------------------------------------------------------------------------
			SELECT
				@IS_FOR_DELIVERY_IMMEDIATE = [DH].[IS_FOR_DELIVERY_IMMEDIATE]
			FROM
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] AS [DH]
			WHERE
				[DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

      -- ----------------------------------------------------------------------------------
      -- Si es de entrega inmediata se sigue el funcionamiento normal)
      -- ----------------------------------------------------------------------------------
			IF (@IS_FOR_DELIVERY_IMMEDIATE = 1)
			BEGIN
				PRINT ('inmediato');
				PRINT (CAST(@WAVE_PICKING_ID AS VARCHAR));
				UPDATE
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
				SET	
					[IS_AUTHORIZED] = 1
					,[ATTEMPTED_WITH_ERROR] = 0
					,[IS_POSTED_ERP] = 0
					,[LAST_UPDATE] = GETDATE()
					,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
					,[POSTED_STATUS] = 0
					,[IS_SENDING] = 0
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [IS_POSTED_ERP] <> 1;
        --
				UPDATE
					[DD]
				SET	
					[DD].[IS_POSTED_ERP] = 0
					,[DD].[POSTED_ERP] = NULL
					,[DD].[POSTED_STATUS] = 0
					,[DD].[ATTEMPTED_WITH_ERROR] = 0
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
				INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
				WHERE
					[DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [DD].[IS_POSTED_ERP] <> 1;
				UPDATE
					[wms].[OP_WMS_PICKING_ERP_DOCUMENT]
				SET	
					[IS_AUTHORIZED] = 1
					,[ATTEMPTED_WITH_ERROR] = 0
					,[IS_POSTED_ERP] = 0
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [IS_POSTED_ERP] <> 1
					AND [PICKING_ERP_DOCUMENT_ID] > 0;
			END;
      -- ----------------------------------------------------------------------------------
      -- Si no es de entrega inmediata se valida el estado de entrega del picking
      -- ----------------------------------------------------------------------------------
			ELSE
			BEGIN

        -- ----------------------------------------------------------------------------------
        -- Se obtiene el estado de entrega del picking
        -- ----------------------------------------------------------------------------------
				SELECT
					@PICKING_DELIVERY_STATUS = [DDH].[STATUS]
				FROM
					[wms].[OP_WMS_DELIVERED_DISPATCH_HEADER]
					AS [DDH]
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

        -- ----------------------------------------------------------------------------------
        -- Si no existe el estado o el este es 'CREATED' no se puede autorizar
        -- ----------------------------------------------------------------------------------
				IF (
					@PICKING_DELIVERY_STATUS IS NULL
					OR @PICKING_DELIVERY_STATUS = 'CREATED'
					)
				BEGIN
					SELECT
						-1 AS [Resultado]
						,'No puede autorizar el picking '
						+ CAST(@WAVE_PICKING_ID AS VARCHAR)
						+ ' debido a que este aún no ha sido entregado.' [Mensaje]
						,-1 [Codigo];
					GOTO FIN;
				END;
        -- ----------------------------------------------------------------------------------
        -- Si el estado o el este es 'COMPLETED' o  'PARTIAL' entonces se puede autorizar
        -- ----------------------------------------------------------------------------------
				ELSE
				BEGIN
					IF (
						@PICKING_DELIVERY_STATUS = 'COMPLETED'
						OR @PICKING_DELIVERY_STATUS = 'PARTIAL'
						)
					BEGIN
						UPDATE
							[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
						SET	
							[IS_AUTHORIZED] = 1
							,[ATTEMPTED_WITH_ERROR] = 0
							,[IS_POSTED_ERP] = 0
							,[LAST_UPDATE] = GETDATE()
							,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
							,[POSTED_STATUS] = 0
							,IS_SENDING = 0
						WHERE
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [IS_POSTED_ERP] <> 1;
            --
						UPDATE
							[DD]
						SET	
							[DD].[IS_POSTED_ERP] = 0
							,[DD].[POSTED_ERP] = NULL
							,[DD].[POSTED_STATUS] = 0
							,[DD].[ATTEMPTED_WITH_ERROR] = 0
						FROM
							[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
						INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
						WHERE
							[DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
            --
						UPDATE
							[wms].[OP_WMS_PICKING_ERP_DOCUMENT]
						SET	
							[IS_AUTHORIZED] = 1
							,[ATTEMPTED_WITH_ERROR] = 0
							,[IS_POSTED_ERP] = 0
						WHERE
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [IS_POSTED_ERP] <> 1
							AND [PICKING_ERP_DOCUMENT_ID] > 0;
					END;
				END;
			END;
		END;
    --
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
		FIN:
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

END;
