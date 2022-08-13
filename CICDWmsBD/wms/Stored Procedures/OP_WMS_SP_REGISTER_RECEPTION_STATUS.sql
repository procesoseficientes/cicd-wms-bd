﻿-- =============================================
-- Autor:                pablo.aguilar
-- Fecha de Creacion:     2016-Oct-07
-- Description:            Se crea SP para registrar el cambio de status de tareas de recepción
-- Modificacion 02-Nov-16 @ A-Team Sprint 4
-- alberto.ruiz
-- Se ajustaron los campos de COMPLETED_DATE y ACCEPTED_DATE

-- Modificación: pablo.aguilar
-- Fecha de Creacion:     2017-02-13 Team ERGON - Sprint ERGON III
-- Description:     se valida cierre de tarea de recepción de ERP 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-12 Nexus@AgeOfEmpires
-- Description:     Se modifica para agregar autorización automática segun parámetro de configuraciones 
-- Modificacion 01-Sep-17 @ Nexus Team Sprint CommandAndConquer
                    -- alberto.ruiz 
                    -- Se agrega actualizacion de estado del detalle de las solicitudes de transferencia
-- Modificacion 10/11/2017 @ NEXUS-Team Sprint ewms
                    -- rodrigo.gomez
                    -- Se remueve la autorizacion automatica de las recepciones por devolucion de factura.

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se ajusta para que no tome los de solicitud de taslado y se agrega try catch

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180725 GForce@FocaMonje 
-- Description:			    Se modifica sp para que actualice como aceptadas solo las tareas asignadas al operador

-- Autor:					rudi.garcia
-- Fecha de Creacion: 		19-Dec-2018 GForce@Perezoso
-- Description:			    Se agrego que cuando una recepcion la completen se eliminen las licencias de despacho cuando estas no tienen ubicacion

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_REGISTER_RECEPTION_STATUS]     @pTRANS_TYPE = 'INGRESO_GENERAL'
                                                        ,@pLOGIN_ID = 'ACAMACHO'
                                                        ,@pCODIGO_POLIZA = '252780'
                                                        ,@pTASK_ID = 295037
                                                        ,@pSTATUS = 'COMPLETED'    
SELECT * FROM [wms].[OP_WMS_TRANS] [owt] ORDER BY [owt].[SERIAL_NUMBER] DESC 
SELECT * FROM [wms].OP_WMS_TASK_LIST WHERE SERIAL_NUMBER = '234882'
                                                    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_RECEPTION_STATUS] (
		@pTRANS_TYPE VARCHAR(25)
		,@pLOGIN_ID VARCHAR(25)
		,@pCODIGO_POLIZA VARCHAR(25)
		,@pTASK_ID NUMERIC(18, 0)
		,@pSTATUS VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;

    --
	DECLARE	@MATERIAL TABLE (
			[TRANSFER_REQUEST_ID] INT NOT NULL
			,[MATERIAL_ID] VARCHAR(50) NOT NULL
			,[QTY] NUMERIC(18, 6) NOT NULL
			,PRIMARY KEY
				([TRANSFER_REQUEST_ID], [MATERIAL_ID])
		);
    --
	DECLARE
		@WAVE_PICKING_ID INT
		,@DOC_ID VARCHAR(50)
		,@AUTOMATIC_AUTHORIZATION INT = 0
		,@TRANSFER_REQUEST_ID INT
		,@TRANSFER_REQUEST_OPEN_STATUS VARCHAR(25) = 'OPEN'
		,@TRANSFER_REQUEST_CLOSED_STATUS VARCHAR(25) = 'CLOSED'
		,@TASK_SUB_TYPE VARCHAR(25);
	BEGIN TRAN;
	BEGIN TRY
	       -- ------------------------------------------------------------------------------------
            -- Obtiene valores iniciales
            -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@AUTOMATIC_AUTHORIZATION = 1
		FROM
			[wms].[OP_WMS_CONFIGURATIONS] [C]
		WHERE
			[C].[PARAM_TYPE] = 'SISTEMA'
			AND [C].[PARAM_GROUP] = 'RECEPCION'
			AND [C].[PARAM_NAME] = 'AUTORIZACION_AUTOMATICA_RECEPCION'
			AND [C].[NUMERIC_VALUE] = 1;
            --
		SELECT
			@WAVE_PICKING_ID = [T].[WAVE_PICKING_ID]
			,@TRANSFER_REQUEST_ID = [T].[TRANSFER_REQUEST_ID]
			,@TASK_SUB_TYPE = [T].[TASK_SUBTYPE]
		FROM
			[wms].[OP_WMS_TASK_LIST] [T]
		WHERE
			[T].[SERIAL_NUMBER] = @pTASK_ID;
            
            -- ------------------------------------------------------------------------------------
            -- Valida si la tarea no ha sido reasignada
            -- ------------------------------------------------------------------------------------
		IF @pSTATUS = 'COMPLETED'
			AND NOT EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_TASK_LIST] [TL]
								WHERE
									[TL].[SERIAL_NUMBER] = @pTASK_ID
									AND @pLOGIN_ID = [TL].[TASK_ASSIGNEDTO] )
		BEGIN
			RAISERROR ('Tarea ya fue asinada a otro operador.', 16, 1);
		END;
		ELSE
		BEGIN
                -- ------------------------------------------------------------------------------------
                -- Valida si la tarea fue completada
                -- ------------------------------------------------------------------------------------
			IF @pSTATUS = 'COMPLETED'
				OR NOT EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_TASK_LIST]
								WHERE
									[SERIAL_NUMBER] = @pTASK_ID
									AND [IS_ACCEPTED] = 1 )
			BEGIN

				
                    -- ------------------------------------------------------------------------------------
                    -- Genera la transaccion de completado
                    -- ------------------------------------------------------------------------------------
				INSERT	INTO [wms].[OP_WMS_TRANS]
						(
							[TRANS_DATE]
							,[LOGIN_ID]
							,[LOGIN_NAME]
							,[TRANS_TYPE]
							,[TRANS_DESCRIPTION]
							,[TRANS_EXTRA_COMMENTS]
							,[CLIENT_OWNER]
							,[CLIENT_NAME]
							,[CODIGO_POLIZA]
							,[STATUS]
							,[TASK_ID]
							,[MATERIAL_BARCODE]
							,[MATERIAL_CODE]
							,[QUANTITY_UNITS]
							,[SOURCE_LOCATION]
							,[TARGET_LOCATION]
                            
						)
				SELECT
					GETDATE() AS [TRANS_DATE]
					,@pLOGIN_ID AS [LOGIN_ID]
					,(SELECT TOP 1
							[LOGIN_NAME]
						FROM
							[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID)) AS [LOGIN_NAME]
					,CASE	WHEN @WAVE_PICKING_ID IS NULL
							THEN @pTRANS_TYPE
							WHEN @WAVE_PICKING_ID IS NOT NULL
									AND @pTRANS_TYPE = 'INGRESO_FISCAL'
							THEN 'DESPACHO_FISCAL'
							WHEN @WAVE_PICKING_ID IS NOT NULL
									AND @pTRANS_TYPE = 'INGRESO_GENERAL'
							THEN 'DESPACHO_GENERAL'
							ELSE @pTRANS_TYPE
						END AS [TRANS_TYPE]
					,[owtl].[TASK_COMMENTS] [TRANS_DESCRIPTION]
					,'N/A' AS [TRANS_EXTRA_COMMENTS]
					,[owtl].[CLIENT_OWNER]
					,[owtl].[CLIENT_NAME]
					,@pCODIGO_POLIZA AS [CODIGO_POLIZA]
					,@pSTATUS AS [STATUS]
					,[owtl].[SERIAL_NUMBER]
					,'' AS [MATERIAL_BARCODE]
					,'' AS [MATERIAL_CODE]
					,0 AS [QUANTITY_UNITS]
					,'' AS [SOURCE_LOCATION]
					,'' AS [TARGET_LOCATION]
				FROM
					[wms].[OP_WMS_TASK_LIST] [owtl]
				WHERE
					[owtl].[SERIAL_NUMBER] = @pTASK_ID;
				PRINT 'INSERTO TRASACCIÓN';
                    -- ------------------------------------------------------------------------------------
                    -- Si es aceptada la tarea
                    -- ------------------------------------------------------------------------------------
				IF @pSTATUS = 'ACCEPTED'
				BEGIN
					PRINT @WAVE_PICKING_ID;
                        --
					IF NOT (
							@WAVE_PICKING_ID IS NULL
							OR @WAVE_PICKING_ID = 0
							)
					BEGIN
						PRINT 'UPDATE WAVE PICKING';
						-- ------------------------------------------------------------------------------------
						-- Actualizamos las tareas de la ola asignadas al operador en cuestion
						-- ------------------------------------------------------------------------------------
						UPDATE
							[wms].[OP_WMS_TASK_LIST]
						SET	
							[IS_ACCEPTED] = 1
							,[ACCEPTED_DATE] = GETDATE()
						WHERE
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [TASK_ASSIGNEDTO] = @pLOGIN_ID;
                            
                    
                    
						IF EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_PARAMETER] [P]
									WHERE
										[P].[GROUP_ID] = 'PICKING'
										AND [P].[PARAMETER_ID] = 'CREATE_LICENSE_IN_PICKING'
										AND [P].[VALUE] = '1' )
						BEGIN
                    -- ------------------------------------------------------------------------------------
                    -- Se declaran las variables a utilizar
                    -- ------------------------------------------------------------------------------------
                            
							DECLARE
								@LOCATION_SPOT_TARGET VARCHAR(25)
								,@CODIGO_POLIZA_TARGET VARCHAR(25)
								,@CLIENT_OWNER VARCHAR(25)
								,@REGIMEN VARCHAR(50)
								,@WAREHOUSE_TARGET VARCHAR(25);

                    -- ------------------------------------------------------------------------------------
                    -- Obtenemos la data necesaria para crear la licencia
                    -- ------------------------------------------------------------------------------------

							SELECT TOP 1
								@LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET]
								,@CODIGO_POLIZA_TARGET = [TL].[CODIGO_POLIZA_TARGET]
								,@CLIENT_OWNER = [TL].[CLIENT_OWNER]
								,@REGIMEN = [TL].[REGIMEN]
							FROM
								[wms].[OP_WMS_TASK_LIST] [TL]
							WHERE
								[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;



							SELECT TOP 1
								@WAREHOUSE_TARGET = [SS].[WAREHOUSE_PARENT]
							FROM
								[wms].[OP_WMS_SHELF_SPOTS] [SS]
							WHERE
								[SS].[LOCATION_SPOT] = @LOCATION_SPOT_TARGET;
                    
                    -- ------------------------------------------------------------------------------------
                    -- Validamos si la ola de picking tiene una ubicacion destiono y si la licencia no ha sido creada
                    -- ------------------------------------------------------------------------------------

							IF @LOCATION_SPOT_TARGET IS NOT NULL
								AND NOT EXISTS ( SELECT TOP 1
											1
											FROM
											[wms].[OP_WMS_LICENSES] [L]
											WHERE
											[L].[LICENSE_ID] = @WAVE_PICKING_ID )
							BEGIN
                    -- ------------------------------------------------------------------------------------
                    -- Insertamos la licencia de la ola de picking
                    -- ------------------------------------------------------------------------------------

								INSERT	INTO [wms].[OP_WMS_LICENSES]
										(
											[CODIGO_POLIZA]
											,[CLIENT_OWNER]
											,[CURRENT_WAREHOUSE]
											,[CURRENT_LOCATION]
											,[LAST_LOCATION]
											,[LAST_UPDATED]
											,[LAST_UPDATED_BY]
											,[REGIMEN]
											,[WAVE_PICKING_ID]
										)
								VALUES
										(
											@CODIGO_POLIZA_TARGET
											,@CLIENT_OWNER
											,@WAREHOUSE_TARGET
											,@LOCATION_SPOT_TARGET
											,NULL
											,GETDATE()
											,@pLOGIN_ID
											,@REGIMEN
											,@WAVE_PICKING_ID
										);
							END;

						END;
					END;
					ELSE
					BEGIN

						PRINT 'UPDATE SERIAL NUMBER';
						UPDATE
							[wms].[OP_WMS_TASK_LIST]
						SET	
							[IS_ACCEPTED] = 1
							,[ACCEPTED_DATE] = GETDATE()
						WHERE
							[SERIAL_NUMBER] = @pTASK_ID;
					END;
				END;
        
                    -- ------------------------------------------------------------------------------------
                    -- Si es completada la tarea
                    -- ------------------------------------------------------------------------------------
				IF @pSTATUS = 'COMPLETED'
				BEGIN
					UPDATE
						[wms].[OP_WMS_TASK_LIST]
					SET	
						[IS_COMPLETED] = 1
						,[COMPLETED_DATE] = GETDATE()
					WHERE
						[SERIAL_NUMBER] = @pTASK_ID;
                        --
          --

					DELETE
						[IL]
					FROM
						[wms].[OP_WMS_INV_X_LICENSE] [IL]
					INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
					WHERE
						[L].[CURRENT_WAREHOUSE] IS NULL
						AND [L].[CODIGO_POLIZA] = @pCODIGO_POLIZA;
          ---
					DELETE FROM
						[wms].[OP_WMS_LICENSES]
					WHERE
						[CURRENT_WAREHOUSE] IS NULL
						AND [CODIGO_POLIZA] = @pCODIGO_POLIZA;

          --
					UPDATE
						[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
					SET	
						[IS_AUTHORIZED] = CASE
											WHEN @TASK_SUB_TYPE = 'DEVOLUCION_FACTURA'
											THEN 0
											ELSE @AUTOMATIC_AUTHORIZATION
											END
					WHERE
						[TASK_ID] = @pTASK_ID;


					IF NOT EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_TRANS] [T]
									WHERE
										@pTASK_ID = [T].[TASK_ID]
										AND [T].[STATUS] = 'PROCESSED' )
					BEGIN

					
						UPDATE
							[D]
						SET	
							[D].[QTY_CONFIRMED] = 0
							,[D].[IS_CONFIRMED] = 1
							,[D].[IS_POSTED_ERP] = 1
						FROM
							[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
						INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
						WHERE
							[H].[TASK_ID] = @pTASK_ID;
						
						UPDATE
							[H]
						SET	
							[H].[IS_POSTED_ERP] = 1
							,[H].[POSTED_RESPONSE] = 'Completada sin movimientos'
							,[H].[IS_AUTHORIZED] = 1
						FROM
							[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
						INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
						WHERE
							[H].[TASK_ID] = @pTASK_ID;

						UPDATE [$(CICDSaeBD)].[dbo].[FACTF01]
						SET [BLOQ] = 'N', [ENLAZADO]='O'
						WHERE  LTRIM(RTRIM([CVE_DOC])) collate database_default in (select  [DOC_NUM]  collate database_default 
						from [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] 
						where [TASK_ID] = @pTASK_ID)
						UPDATE [$(CICDSaeBD)].[dbo].[COMPO01]
						SET [BLOQ] = 'N', [ENLAZADO]='O'
						WHERE  LTRIM(RTRIM([CVE_DOC])) collate database_default in (select  [DOC_NUM]  collate database_default 
						from [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] 
						where [TASK_ID] = @pTASK_ID)								
							
					END; 
                        -- ------------------------------------------------------------------------------------
                        -- Valida si completo su tarea de recepción de ERP
                        -- ------------------------------------------------------------------------------------
					SELECT TOP 1
						@DOC_ID = [H].[DOC_ID]
					FROM
						[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
					INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
					INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
					LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CODIGO_POLIZA] = [T].[CODIGO_POLIZA_SOURCE]
					LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
					WHERE
						[H].[TASK_ID] = @pTASK_ID
						AND [D].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] > 0
					GROUP BY
						[H].[DOC_ID]
						,[D].[MATERIAL_ID]
					HAVING
						ISNULL(SUM([IL].[ENTERED_QTY]), 0) <> MAX([D].[QTY]);
        
                        -- ------------------------------------------------------------------------------------
                        -- Obtiene el total de cada material recepcionado
                        -- ------------------------------------------------------------------------------------
					INSERT	INTO @MATERIAL
							(
								[TRANSFER_REQUEST_ID]
								,[MATERIAL_ID]
								,[QTY]
                                
							)
					SELECT
						[T].[TRANSFER_REQUEST_ID]
						,[IL].[MATERIAL_ID]
						,SUM([IL].[ENTERED_QTY])
					FROM
						[wms].[OP_WMS_INV_X_LICENSE] [IL]
					INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
					INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA])
					LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] ON [H].[DOC_ID_POLIZA] = [PH].[DOC_ID]
					LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON (
											[H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
											AND [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
					INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
					WHERE
						[H].[TASK_ID] = @pTASK_ID
						AND [T].[TRANSFER_REQUEST_ID] IS NOT NULL
					GROUP BY
						[T].[TRANSFER_REQUEST_ID]
						,[IL].[MATERIAL_ID];
        
                        -- ------------------------------------------------------------------------------------
                        -- Actualiza el detalle de la solicitud de transferencia
                        -- ------------------------------------------------------------------------------------
					UPDATE
						[TD]
					SET	
						[TD].[QTY_PROCESSED] = ([TD].[QTY_PROCESSED]
											+ [M].[QTY])
						,[TD].[STATUS] = CASE
											WHEN ([TD].[QTY_PROCESSED]
											+ [M].[QTY]) >= [TD].[QTY]
											THEN @TRANSFER_REQUEST_CLOSED_STATUS
											ELSE @TRANSFER_REQUEST_OPEN_STATUS
											END
					FROM
						[wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] [TD]
					INNER JOIN @MATERIAL [M] ON (
											[M].[TRANSFER_REQUEST_ID] = [TD].[TRANSFER_REQUEST_ID]
											AND [M].[MATERIAL_ID] = [TD].[MATERIAL_ID]
											)
					WHERE
						[TD].[MATERIAL_ID] = [M].[MATERIAL_ID];
                        --
					IF NOT EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_TRANSFER_REQUEST_DETAIL]
									WHERE
										[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
										AND [STATUS] = @TRANSFER_REQUEST_OPEN_STATUS )
					BEGIN
						UPDATE
							[wms].[OP_WMS_TRANSFER_REQUEST_HEADER]
						SET	
							[STATUS] = @TRANSFER_REQUEST_CLOSED_STATUS
						WHERE
							[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID;
					END;
                        
                        -- ------------------------------------------------------------------------------------
                        -- Abre la recepcion cuando es parcial
                        -- ------------------------------------------------------------------------------------
					IF @DOC_ID IS NOT NULL
						AND @WAVE_PICKING_ID IS NULL
					BEGIN
						UPDATE
							[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
						SET	
							[IS_COMPLETE] = 0
						WHERE
							[ERP_RECEPTION_DOCUMENT_HEADER_ID] > 0
							AND [DOC_ID] = @DOC_ID;
					END;
				END;
			END;
		END;
		COMMIT;
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('' AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@message VARCHAR(1000) = @@ERROR;
		PRINT @message;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 

		RAISERROR (@message, 16, 1);
	
	END CATCH;
END;