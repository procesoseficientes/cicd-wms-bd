
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 22-08-2016
-- Description:			Se elimina un picking

-- Modificacion
-- Autor:				rudi.garcia
-- Fecha de Creacion: 17-04-2017 @Team Ergon Sprint Epona
-- Description:			Se arreglo el sp para que ponga estado de pendientes a la linea cancelada del documento de poliza

-- Modificacion
-- Autor:				rudi.garcia
-- Fecha de Creacion: 18-04-2017 @Team Ergon Sprint Epona
-- Description:			Se agrego el roolback para la demanda de despacho

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-25 ErgonTeam@Sheik
-- Description:	 Se agrega que devuelva objeto operación por cambio de arquitectura

-- Modificacion 02-Mar-18 @ Nexus Team Sprint@Vernichtung
					-- pablo.aguilar
					-- Se modifica para que si cancelo sin haber estado aceptada o trabajada elimine todo el detalle del documento. 


/*
  -- Ejemplo de Ejecucion:
				-- 
				BEGIN TRAN 
				EXEC [wms].OP_WMS_DELETE_PICKING 
					@WAVE_PICKING_ID = 899              
					,@USER_ID = 'JMAZARIAGOS'
					

					SELECT * FROM wms.OP_WMS_TASK_LIST WHERE WAVE_PICKING_ID = 899
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_DELETE_PICKING]
	@WAVE_PICKING_ID NUMERIC
	,@USER_ID VARCHAR(25)
AS
BEGIN TRAN;
BEGIN TRY

	DECLARE	@REGIMEN VARCHAR(25);

		-- ------------------------------------------------------------------------------------
		-- Se obtiene el regimen de la ola de picking
		-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@REGIMEN = [TL].[REGIMEN]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	WHERE
		[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
				PRINT ('FACTP '+ cast(@WAVE_PICKING_ID as varchar));

			UPDATE 
				FACT 
			SET	
				FACT.BLOQ='N',
				FACT.[ENLAZADO] = 'O'
			FROM [SAE70EMPRESA01].[dbo].[FACTP01] FACT
			INNER JOIN wms.OP_WMS_NEXT_PICKING_DEMAND_HEADER  h ON FACT.[CVE_DOC] LIKE '%'+h.DOC_NUM+'%' COLLATE DATABASE_DEFAULT
			where h.WAVE_PICKING_ID=@WAVE_PICKING_ID
	PRINT ('FACTP end');
		-- ------------------------------------------------------------------------------------
		-- Se valida si ya se ha trabajado alguna ola de picking
		-- ------------------------------------------------------------------------------------
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_TASK_LIST] [TL]
				WHERE
					(
						[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [TL].[QUANTITY_PENDING] != [TL].[QUANTITY_ASSIGNED]
					) )
		AND @REGIMEN <> 'FISCAL'
	BEGIN

		PRINT ('REALIZAR PARCIAL');
			-- ------------------------------------------------------------------------------------
			-- Se completan las lineas del la ola de picking cuando ya an trabajado una linea de detalle
			-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[IS_COMPLETED] = 1
			,[COMPLETED_DATE] = GETDATE()
			,[CANCELED_BY] = @USER_ID
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
	END;
	ELSE
	BEGIN
			-- ------------------------------------------------------------------------------------
			-- Se cancela la ola de picking para que no aparezca en el administrador de tareas
			-- ------------------------------------------------------------------------------------

		PRINT ('NO HA TOCADO EL DETALLE');
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[IS_PAUSED] = 3
			,[IS_COMPLETED] = 1
			,[IS_CANCELED] = 1
			,[CANCELED_DATETIME] = CURRENT_TIMESTAMP
			,[CANCELED_BY] = @USER_ID
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;


		DELETE
			[D]
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
		INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
		WHERE
			[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;


		DELETE
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

		GOTO FINALIZAR; 

	END;

		-- ------------------------------------------------------------------------------------
		-- Se valida si el picking pertenece a una demanda de despacho
		-- ------------------------------------------------------------------------------------
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
				WHERE
					[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID )
	BEGIN
		DECLARE	@MATERIAL_ID VARCHAR(25);
		DECLARE	@MATERIALS TABLE (
				[MATERIAL_ID] VARCHAR(25)
			);

			-- ------------------------------------------------------------------------------------
			-- Se Obtiene los productos de la ola de picking
			-- ------------------------------------------------------------------------------------
		INSERT	INTO @MATERIALS
				(
					[MATERIAL_ID]
				)
		SELECT
			[TL].[MATERIAL_ID]
		FROM
			[wms].[OP_WMS_TASK_LIST] AS [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		GROUP BY
			[TL].[MATERIAL_ID];

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@MATERIALS )
		BEGIN

			SELECT TOP 1
				@MATERIAL_ID = [MATERIAL_ID]
			FROM
				@MATERIALS;

				-- ------------------------------------------------------------------------------------
				-- Se rebaja el detalle de la demanda de despacho
				-- ------------------------------------------------------------------------------------
			EXEC [wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE] @LOGIN_ID = @USER_ID,
				@WAVE_PICKING_ID = @WAVE_PICKING_ID,
				@MATERIAL_ID = @MATERIAL_ID;
			DELETE FROM
				@MATERIALS
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID;
		END;
	END;

	IF @REGIMEN = 'FISCAL'
	BEGIN
			-- ------------------------------------------------------------------------------------
			-- Se actualiza en status del detalle de la poliza a pendiente nuevamente para que aparesca en la orden de preparado
			-- ------------------------------------------------------------------------------------
		UPDATE
			[PD]
		SET	
			[PD].[PICKING_STATUS] = 'PENDING'
			,[PD].[LAST_UPDATED_BY] = @USER_ID
			,[PD].[LAST_UPDATED] = GETDATE()
		FROM
			[wms].[OP_WMS_POLIZA_DETAIL] [PD]
		INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([PD].[DOC_ID] = [PH].[DOC_ID])
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON (
											[TL].[CODIGO_POLIZA_TARGET] = [PH].[CODIGO_POLIZA]
											AND [TL].[LINE_NUMBER_POLIZA_TARGET] = [PD].[LINE_NUMBER]
											)
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
	END;

		--
	FINALIZAR: 
	
	EXEC [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED] @WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
		@LOGIN = @USER_ID; -- varchar(50)

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CONVERT(VARCHAR(16), 1) [DbData];
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK;
	SELECT
		-1 AS [Resultado]
		,ERROR_MESSAGE() [Mensaje]
		,@@ERROR [Codigo];
END CATCH;