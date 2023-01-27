-- =============================================
-- Modificacion:					hector.gonzalez
-- Fecha de Creacion: 		03-11-2016 @ A-TEAM Sprint 4
-- Description:			      Se agrego la tabla IS_FROM_SONDA

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-17 Team ERGON - Sprint EPONA
-- Description:	 Se elimina cursor y se reserva unicamente lo necesario para el picking. se agrega validacion si maneja linea de picking e inserta en esa base de datos. 

-- Modificacion 7/7/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- rodrigo.gomez
-- Se agregan las validaciones para el inventario de masterpacks y sus componentes, asi como la explosion del masterpack a un nivel para el picking.

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
-- pablo.aguilar
--  Se hace modiicación para guarde en PickingERPDocument para enviar a SAP.

-- Modificacion 22-Dec-17 @ Nexus Team Sprint @IceAge
-- pablo.aguilar
-- Se agregan nueva función de tabla para obtener las licencias a pickear basado en algoritmos de ascedente y descedente

-- Modificacion 26-Ene-18 @ Reborn Team Sprint @Trotzdem
-- marvin.solares
-- se agrega el parámetro @PRIORITY como parámetro de entrada y se modifica el procedimiento para que guarde la 
-- prioridad en la tabla OP_WMS_TASK_LIST

-- Modificacion			henry.rodriguez
-- Fecha				17-Julio-2019 G-Force@Dublin
-- Descripcion			Se agrego nuevo parametro PROJECT_ID y validacion cuando el egreso es por proyecto.

-- Modificacion			henry.rodriguez
-- Fecha				17-Julio-2019 G-Force@Dublin
-- Descripcion			Se agrega STATUS_CODE en tabla de TASK_LIST

-- Modificacion			henry.rodriguez
-- Fecha				29-Julio-2019 G-Force@Dublin
-- Descripcion			Se agrega ORDER_NUMBER en insert de task list.

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			asigno la ubicacion de salida al egreso general

-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			agrego como parámetro una licencia de la cual no quiero que se tome en cuenta su inventario disponible en el algoritmo de picking

-- Autor:				fabrizio.delcompare
-- Fecha de Creacion: 	08-Mayo-2020
-- Descripcion:			MasterPack ahora es completamente recursivo.

--Modificación:			Elder Lucas
--Fecha modificación:	10 de noviembre 2022
--Descripción:			Manejo de tareas que superan el techo del material para que sean procesadas como picking por canal

/*
-- Ejemplo de Ejecucion:
       
	declare @p11 varchar(4000)
set @p11='OK'
declare @p12 int
set @p12=4466
exec [wms].OP_WMS_SP_INSERT_TASKS_GENERAL @TASK_OWNER='ADMIN',@TASK_ASSIGNEDTO='ACAMACHO',@QUANTITY_ASSIGNED=10,@CODIGO_POLIZA_TARGET='292853',@MATERIAL_ID='C00030/LEC-SMIL-25K',@BARCODE_ID='LEC-SMIL-25K',@ALTERNATE_BARCODE='',@MATERIAL_NAME='LECHE DESCREMADA INST.SKIM MILK POWDER 25 KGS',@CLIENT_OWNER='C00030',@CLIENT_NAME='AUSTRALIA DAIRY GOODS, S.A.',@PRESULT=@p11 output,@WAVE_PICKING_ID=@p12 output,@WAREHOUSE='BODEGA_05',@PRIORITY=0
select @p11, @p12
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL] (
		@TASK_OWNER VARCHAR(25)
		,@TASK_ASSIGNEDTO VARCHAR(25)
		,@QUANTITY_ASSIGNED NUMERIC(18, 4)
		,@CODIGO_POLIZA_TARGET VARCHAR(25)
		,@MATERIAL_ID VARCHAR(25)
		,@BARCODE_ID VARCHAR(50)
		,@ALTERNATE_BARCODE VARCHAR(50) = ''
		,@MATERIAL_NAME VARCHAR(200)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@PRESULT VARCHAR(4000) OUTPUT
		,@WAVE_PICKING_ID NUMERIC(18, 0) OUTPUT
		,@IS_FROM_SONDA INT = 0
		,@WAREHOUSE VARCHAR(50)
		,@FROM_MASTERPACK INT = 0
		,@MASTER_PACK_CODE VARCHAR(50) = NULL
		,@SEND_ERP INT = 0
		,@PRIORITY INT = 1
		,@PROJECT_ID UNIQUEIDENTIFIER = NULL
		,@STATUS_CODE VARCHAR(100) = NULL
		,@LOCATION_SPOT_TARGET VARCHAR(50)
		,@LICENSE_ID_TO_EXCLUDE [NUMERIC](18, 0) = -1
	)
AS
BEGIN

	DECLARE	@OPERACION TABLE (
			[Resultado] INT
			,[Mensaje] VARCHAR(MAX)
			,[Codigo] INT
			,[DbData] VARCHAR(MAX)
		);

	DECLARE
		@WPI NUMERIC(18, 0)
		,@ASSIGNED_DATE DATETIME
		,@CURRENT_LOCATION VARCHAR(25)
		,@CURRENT_WAREHOUSE VARCHAR(25)
		,@LICENSE_ID NUMERIC(18, 0)
		,@TASK_COMMENTS VARCHAR(150)
		,@CODIGO_POLIZA_SOURCE VARCHAR(25)
		,@TASK_TYPE VARCHAR(25)
		,@TASK_SUBTYPE VARCHAR(25)
		,@QUANTITY_PENDING NUMERIC(18, 4)
		,@HAVBATCH NUMERIC(18) = 0
		,@vCURRENT_ASSIGNED NUMERIC(18, 4)
		,@IS_MASTER_PACK INT = 0
		,@ASSEMBLY_QTY INT = 0
		,@AVAILABLE_QTY NUMERIC(18, 4) = 0
		,@PROJECT_NAME AS VARCHAR(150)
		,@PROJECT_CODE AS VARCHAR(50)
		,@PROJECT_SHORT_NAME AS VARCHAR(25)
		,@ORDER_NUMBER VARCHAR(25)
		,@HANDLED_PER_CHANNEL INT = 0
		,@Resultado INT = -1
		,@Mensaje VARCHAR(MAX)
		,@ASSEMBLED_QTY INT = 0
		,@QUERY NVARCHAR(MAX)
		,@ROOF_QTY INT
		,@ES_MEZCLA INT;

	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY

		SELECT
			@ASSIGNED_DATE = GETDATE()
			,@TASK_TYPE = 'TAREA_PICKING'
			,@TASK_SUBTYPE = 'DESPACHO_GENERAL'
			,@QUANTITY_PENDING = @QUANTITY_ASSIGNED;

		IF @WAVE_PICKING_ID = 0
		BEGIN
			SELECT
				@WAVE_PICKING_ID = NEXT VALUE FOR [wms].[OP_WMS_SEQ_WAVE_PICKING_ID];
		END;
		IF @WPI = NULL
		BEGIN
			SET @WPI = 1;
		END;

		IF @WAVE_PICKING_ID = 0
		BEGIN
			SET @WAVE_PICKING_ID = @WPI;
		END;
		ELSE
		BEGIN
			SET @WPI = @WAVE_PICKING_ID;
		END;

        -- ------------------------------------------------------------------------------------
        -- OBTENEMOS EL NUMERO DE ORDEN QUE SE INGRESO
        -- ------------------------------------------------------------------------------------
		SELECT
			@ORDER_NUMBER = [NUMERO_ORDEN]
		FROM
			[wms].[OP_WMS_POLIZA_HEADER]
		WHERE
			[CODIGO_POLIZA] = @CODIGO_POLIZA_TARGET;


		SELECT @ROOF_QTY = (SELECT ISNULL(ROOF_QUANTITY, 0) FROM WMS.OP_WMS_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID)

		IF((SELECT IS_MASTER_PACK FROM wms.OP_WMS_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID) = 1 AND @MATERIAL_NAME LIKE '%M') SET @ES_MEZCLA = 1

		-- ------------------------------------------------------------------------------------
        -- Verificamos si la cantidad solicitada sobrepasa el techo del material, si es así, se procesa como picking por canal
        -- ------------------------------------------------------------------------------------
		IF((@QUANTITY_ASSIGNED > @ROOF_QTY) AND @ES_MEZCLA = 0)
		BEGIN
			SET @HANDLED_PER_CHANNEL = 1
			print 'Inicia procesos por canal'
			INSERT	INTO @OPERACION
						(
							[Resultado]
							,[Mensaje]
							,[Codigo]
							,[DbData]
						)
						EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND_PER_CHANNEL] @TASK_OWNER = @TASK_OWNER, -- varchar(25)
							@TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO, -- varchar(25)
							@QUANTITY_ASSIGNED = @QUANTITY_ASSIGNED, -- numeric
							@CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
							@MATERIAL_ID = @MATERIAL_ID, -- varchar(50)
							@BARCODE_ID = @BARCODE_ID, -- varchar(50)
							@ALTERNATE_BARCODE = @ALTERNATE_BARCODE, -- varchar(50)
							@MATERIAL_NAME = @MATERIAL_NAME, -- varchar(200)
							@CLIENT_OWNER = @CLIENT_OWNER, -- varchar(25)
							@CLIENT_NAME = @CLIENT_NAME, -- varchar(150)
							@IS_FROM_SONDA = @IS_FROM_SONDA, -- int
							@CODE_WAREHOUSE = @WAREHOUSE, -- varchar(50)
							@IS_FROM_ERP = @SEND_ERP, -- int
							@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- numeric
							@DOC_ID_TARGET = 0, -- int
							@LOCATION_SPOT_TARGET = @LOCATION_SPOT_TARGET, -- varchar(25)
							@IS_CONSOLIDATED = 0, -- int
							@SOURCE_TYPE = 'EGRESO_GENERAL', -- varchar(50)
							@TRANSFER_REQUEST_ID = 0, -- int
							@TONE = NULL, -- varchar(20)
							@CALIBER = NULL, -- varchar(20)
							@IN_PICKING_LINE = 0, -- int
							@IS_FOR_DELIVERY_IMMEDIATE = 1,
							@PRIORITY = @PRIORITY,
							@PICKING_HEADER_ID = 0,
							@STATUS_CODE = @STATUS_CODE,
							@ORDER_NUMBER = @ORDER_NUMBER,
							@MIN_DAYS_EXPIRATION_DATE = 0,
							@DOC_NUM = NULL,
							@DOCS_AND_QTYS = NULL;
			SELECT
				@Resultado = [O].[Resultado]
				,@Mensaje = [O].[Mensaje]
				,@WAVE_PICKING_ID = CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData],
											1, '|') AS INT)
				,@ASSEMBLED_QTY = ISNULL(CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData],
											2, '|') AS INT),
											0)
			FROM
				@OPERACION [O];

			IF @Resultado = -1
			BEGIN
				RAISERROR (@Mensaje, 16, 1);
				RETURN;
			END;
		END
        -- ------------------------------------------------------------------------------------
        -- Obtiene el inventario disponible para el material, luego verifica que sea suficiente para el picking.
        -- Si no lo es verifica que sea un masterpack y no venga de una explosion de masterpack, de ser asi obtiene la cantidad disponible a armar y 
        -- establece una nueva cantidad asignada para solo armar los MPs necesarios.
        -- ------------------------------------------------------------------------------------

		SELECT
			@IS_MASTER_PACK = [IS_MASTER_PACK]
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [CLIENT_OWNER] = @CLIENT_OWNER;


		IF @PROJECT_ID IS NULL AND @HANDLED_PER_CHANNEL = 0
		BEGIN

		print @CLIENT_OWNER
		print @MATERIAL_ID
		print @WAREHOUSE
		print @LICENSE_ID_TO_EXCLUDE
		print @AVAILABLE_QTY
			SELECT
				@AVAILABLE_QTY = ISNULL(SUM([QTY]), 0)
			FROM
				[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL]
			WHERE
				[CLIENT_OWNER] = @CLIENT_OWNER
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [CURRENT_WAREHOUSE] = @WAREHOUSE
				AND [STATUS_CODE] = @STATUS_CODE
				AND [LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE;
		END;
		ELSE
		BEGIN


			SELECT
				@AVAILABLE_QTY = SUM([IP].[QTY_LICENSE])
			FROM
				[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROJECT_ID) [IP]
			WHERE
				@WAREHOUSE = [IP].[CURRENT_WAREHOUSE]
				AND @MATERIAL_ID = [IP].[MATERIAL_ID]
				AND @STATUS_CODE = [IP].[STATUS_CODE]
				AND [IP].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE;


		END;

        -- ------------------------------------------------------------------------------------
        -- SI EL EGRESO ES POR PROYECTO OBTIENE LA INFORMACION DEL PROYECTO
        -- ------------------------------------------------------------------------------------
		IF @PROJECT_ID IS NOT NULL
		BEGIN
			SELECT
				@PROJECT_CODE = [OPPORTUNITY_CODE]
				,@PROJECT_NAME = [OPPORTUNITY_NAME]
				,@PROJECT_SHORT_NAME = [SHORT_NAME]
			FROM
				[wms].[OP_WMS_PROJECT]
			WHERE
				[ID] = @PROJECT_ID;
		END;

		IF (@QUANTITY_ASSIGNED > @AVAILABLE_QTY AND @HANDLED_PER_CHANNEL = 0)
		BEGIN
			IF @PROJECT_ID IS NULL
				AND @IS_MASTER_PACK = 1
				--AND @FROM_MASTERPACK = 0
			BEGIN
				SELECT
					@ASSEMBLY_QTY = [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_TO_ASSAMBLE_FOR_MASTERPACK](@MATERIAL_ID,
											@WAREHOUSE);

				IF @ASSEMBLY_QTY > 0
				BEGIN
					SELECT
						@QUANTITY_ASSIGNED = @QUANTITY_ASSIGNED
						- @AVAILABLE_QTY;
					GOTO EXPLOTAR_MASTERPACK;
				END;
			END;

			SELECT
				@PRESULT = 'ERROR, No cuenta con inventario suficiente para continuar con la operación del cliente: '
				+ @CLIENT_NAME + ' SKU: ' + @MATERIAL_ID + ' WAREHOUSE: ' + @WAREHOUSE;
			RAISERROR(@PRESULT, 16, 1);

		END;

		IF @SEND_ERP = 1
			AND NOT EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_PICKING_ERP_DOCUMENT]
								WHERE
									[WAVE_PICKING_ID] = @WAVE_PICKING_ID )
		BEGIN
			INSERT	INTO [wms].[OP_WMS_PICKING_ERP_DOCUMENT]
					(
						[WAVE_PICKING_ID]
						,[CODE_WAREHOUSE]
						,[ATTEMPTED_WITH_ERROR]
						,[IS_POSTED_ERP]
						,[IS_AUTHORIZED]
						,[CREATED_DATE]
						,[LAST_UPDATED]
						,[LAST_UPDATED_BY]
					)
			VALUES
					(
						@WAVE_PICKING_ID
						, -- WAVE_PICKING_ID - int
						@WAREHOUSE
						,       -- CODE_WAREHOUSE - varchar(25)
						0
						,                -- ATTEMPTED_WITH_ERROR - int
						0
						,                -- IS_POSTED_ERP - int
						0
						,                -- IS_AUTHORIZED - int
						GETDATE()
						,        -- CREATED_DATE - datetime
						GETDATE()
						,        -- LAST_UPDATED - datetime
						@TASK_ASSIGNEDTO  -- LAST_UPDATED_BY - varchar(50)
					);
		END;

		PROCESAR_CON_INVENTARIO:



        ---------------------------------------------------------------------------------
        -- Valida si maneja lote
        ---------------------------------------------------------------------------------  
		SELECT TOP 1
			@HAVBATCH = ISNULL([BATCH_REQUESTED], 0)
		FROM
			[wms].[OP_WMS_MATERIALS] [OWM]
		WHERE
			[CLIENT_OWNER] = @CLIENT_OWNER
			AND [MATERIAL_ID] = @MATERIAL_ID;


		SELECT
			@TASK_COMMENTS = 'OLA DE PICKING #'
			+ CAST(@WPI AS VARCHAR);

		CREATE TABLE [#LICENCIAS] (
			[CURRENT_LOCATION] VARCHAR(25)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[LICENSE_ID] NUMERIC
			,[CODIGO_POLIZA] VARCHAR(25)
			,[QTY] NUMERIC(18, 4)
			,[DATE_BASE] DATETIME
			,[ROW] INT
		);

		PRINT '@HAVBATCH ' + CAST(@HAVBATCH AS VARCHAR);
		PRINT '@WAVE_PICKING_ID '
			+ CAST(@WAVE_PICKING_ID AS VARCHAR);
		PRINT '@@CURRENT_WAREHOUSE'
			+ CAST(@WAREHOUSE AS VARCHAR);
		PRINT '@@MATERIAL_ID'
			+ CAST(@MATERIAL_ID AS VARCHAR);
		PRINT '@@QUANTITY_ASSIGNED'
			+ CAST(@QUANTITY_ASSIGNED AS VARCHAR);

		IF(@HANDLED_PER_CHANNEL = 0)
		BEGIN
			IF @PROJECT_ID IS NULL
			BEGIN
				INSERT	INTO [#LICENCIAS]
						(
							[CURRENT_LOCATION]
							,[CURRENT_WAREHOUSE]
							,[LICENSE_ID]
							,[CODIGO_POLIZA]
							,[QTY]
							,[DATE_BASE]
							,[ROW]
						)
				SELECT
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,[ORDER]
				FROM
					[wms].[OP_WMS_FN_GET_LICENSE_TO_PICK](@MATERIAL_ID,
												@WAREHOUSE,
												@QUANTITY_ASSIGNED,
												@HAVBATCH, NULL,
												NULL,
												@STATUS_CODE, 0, /*no valido tolerancia por lote*/
												@LICENSE_ID_TO_EXCLUDE);
			END;
			ELSE
			BEGIN
				INSERT	INTO [#LICENCIAS]
						(
							[CURRENT_LOCATION]
							,[CURRENT_WAREHOUSE]
							,[LICENSE_ID]
							,[CODIGO_POLIZA]
							,[QTY]
							,[DATE_BASE]
							,[ROW]
						)
				SELECT
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,[ORDER]
				FROM
					[wms].[OP_WMS_FN_GET_LICENSE_TO_PICK_FOR_PROYECT](@MATERIAL_ID,
												@WAREHOUSE,
												@QUANTITY_ASSIGNED,
												@HAVBATCH, NULL,
												NULL,
												@STATUS_CODE, 0,
												@PROJECT_ID, 0, /*no valido tolerancia por lote*/
												@LICENSE_ID_TO_EXCLUDE);

			END;
		END;

		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							[#LICENCIAS] ))
		BEGIN
            ---------------------------------------------------------------------------------
            -- Recorrer por licencias el material
            ---------------------------------------------------------------------------------  
			SELECT TOP 1
				@CURRENT_LOCATION = [L].[CURRENT_LOCATION]
				,@CURRENT_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
				,@LICENSE_ID = [L].[LICENSE_ID]
				,@CODIGO_POLIZA_SOURCE = [L].[CODIGO_POLIZA]
				,@vCURRENT_ASSIGNED = CASE	WHEN @QUANTITY_PENDING >= [L].[QTY]
											THEN [L].[QTY]
											ELSE @QUANTITY_PENDING
										END
			FROM
				[#LICENCIAS] [L]
			ORDER BY
				[L].[ROW];

			PRINT CAST(@LICENSE_ID AS VARCHAR);

			IF @PROJECT_ID IS NOT NULL
			BEGIN
				SELECT
					@CLIENT_OWNER = [VC].[CLIENT_CODE]
					,@CLIENT_NAME = [VC].[CLIENT_NAME]
				FROM
					[wms].[OP_WMS_LICENSES] [L]
				INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC] ON ([L].[CLIENT_OWNER] = [VC].[CLIENT_CODE])
				WHERE
					[L].[LICENSE_ID] = @LICENSE_ID;
			END;

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_TASK_LIST]
						WHERE
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [CODIGO_POLIZA_SOURCE] = @CODIGO_POLIZA_SOURCE
							AND [CODIGO_POLIZA_TARGET] = @CODIGO_POLIZA_TARGET
							AND [LICENSE_ID_SOURCE] = @LICENSE_ID
							AND [MATERIAL_ID] = @MATERIAL_ID
							AND [IS_CANCELED] = 0 )
			BEGIN
                ---------------------------------------------------------------------------------
                -- Existe el material en la misma ola y hay disponible de la licencia se actualiza el registro. 
                ---------------------------------------------------------------------------------  
				PRINT CAST('Modifica' AS VARCHAR);
				UPDATE
					[wms].[OP_WMS_TASK_LIST]
				SET	
					[QUANTITY_PENDING] = [QUANTITY_PENDING]
					+ @vCURRENT_ASSIGNED
					,[QUANTITY_ASSIGNED] = [QUANTITY_ASSIGNED]
					+ @vCURRENT_ASSIGNED
					,[IS_COMPLETED] = 0
					,[COMPLETED_DATE] = NULL
					,[IS_PAUSED] = 0
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [CODIGO_POLIZA_SOURCE] = @CODIGO_POLIZA_SOURCE
					AND [CODIGO_POLIZA_TARGET] = @CODIGO_POLIZA_TARGET
					AND [LICENSE_ID_SOURCE] = @LICENSE_ID
					AND [MATERIAL_ID] = @MATERIAL_ID;

			END;
			ELSE
			BEGIN
				PRINT CAST('Inserta' AS VARCHAR);
				PRINT CAST(@vCURRENT_ASSIGNED AS VARCHAR);

				INSERT	INTO [wms].[OP_WMS_TASK_LIST]
						(
							[WAVE_PICKING_ID]
							,[TASK_TYPE]
							,[TASK_SUBTYPE]
							,[TASK_OWNER]
							,[TASK_ASSIGNEDTO]
							,[ASSIGNED_DATE]
							,[QUANTITY_PENDING]
							,[QUANTITY_ASSIGNED]
							,[CODIGO_POLIZA_SOURCE]
							,[CODIGO_POLIZA_TARGET]
							,[LICENSE_ID_SOURCE]
							,[REGIMEN]
							,[IS_DISCRETIONAL]
							,[MATERIAL_ID]
							,[BARCODE_ID]
							,[ALTERNATE_BARCODE]
							,[MATERIAL_NAME]
							,[WAREHOUSE_SOURCE]
							,[LOCATION_SPOT_SOURCE]
							,[CLIENT_OWNER]
							,[CLIENT_NAME]
							,[TASK_COMMENTS]
							,[TRANS_OWNER]
							,[IS_COMPLETED]
							,[MATERIAL_SHORT_NAME]
							,[IS_FROM_SONDA]
							,[FROM_MASTERPACK]
							,[MASTER_PACK_CODE]
							,[IS_FROM_ERP]
							,[PRIORITY]
							,[STATUS_CODE]
							,[PROJECT_ID]
							,[PROJECT_CODE]
							,[PROJECT_NAME]
							,[PROJECT_SHORT_NAME]
							,[ORDER_NUMBER]
							,[LOCATION_SPOT_TARGET]
						)
				VALUES
						(
							@WAVE_PICKING_ID
							,@TASK_TYPE
							,@TASK_SUBTYPE
							,@TASK_OWNER
							,@TASK_ASSIGNEDTO
							,@ASSIGNED_DATE
							,@vCURRENT_ASSIGNED
							,@vCURRENT_ASSIGNED
							,@CODIGO_POLIZA_SOURCE
							,@CODIGO_POLIZA_TARGET
							,@LICENSE_ID
							,'GENERAL'
							,0
							,@MATERIAL_ID
							,@BARCODE_ID
							,@ALTERNATE_BARCODE
							,@MATERIAL_NAME
							,@CURRENT_WAREHOUSE
							,@CURRENT_LOCATION
							,@CLIENT_OWNER
							,@CLIENT_NAME
							,@TASK_COMMENTS
							,0
							,0
							,@MATERIAL_NAME
							,@IS_FROM_SONDA
							,@FROM_MASTERPACK
							,@MASTER_PACK_CODE
							,@SEND_ERP
							,@PRIORITY
							,@STATUS_CODE
							,@PROJECT_ID
							,@PROJECT_CODE
							,@PROJECT_NAME
							,@PROJECT_SHORT_NAME
							,@ORDER_NUMBER
							,@LOCATION_SPOT_TARGET
						);

			END;

			SELECT
				@QUANTITY_PENDING = @QUANTITY_PENDING
				- @vCURRENT_ASSIGNED;

			IF @QUANTITY_PENDING <= 0
			BEGIN
				DELETE
					[#LICENCIAS];
			END;
			ELSE
			BEGIN
				DELETE
					[#LICENCIAS]
				WHERE
					[LICENSE_ID] = @LICENSE_ID;
			END;
		END;

		GOTO FIN;

		EXPLOTAR_MASTERPACK:
        -- ------------------------------------------------------------------------------------
        -- Explota el masterpack mandando a llamarse a si mismo por cada componente.
        -- ------------------------------------------------------------------------------------
		IF @PROJECT_ID IS NULL AND @HANDLED_PER_CHANNEL = 0
			--AND @FROM_MASTERPACK = 0
		BEGIN
			PRINT 'MASTERPACK EXPLOTADO';
			SELECT
				[MASTER_PACK_COMPONENT_ID]
				,[MASTER_PACK_CODE]
				,[COMPONENT_MATERIAL]
				,([QTY] * @QUANTITY_ASSIGNED) [QTY]
			INTO
				[#COMPONENTES]
			FROM
				[wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
			WHERE
				[MASTER_PACK_CODE] = @MATERIAL_ID;

			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								[#COMPONENTES] )
			BEGIN
				DECLARE	@QTY_COMP NUMERIC(18,4) = 0;
				DECLARE	@MATERIAL_ID_COMP VARCHAR(25) = '';
				DECLARE	@BARCODE_ID_COMP VARCHAR(50) = '';
				DECLARE	@ALTERNATE_BARCODE_COMP VARCHAR(50) = '';
				DECLARE	@MATERIAL_NAME_COMP VARCHAR(200) = '';

				SELECT
					@MATERIAL_ID_COMP = [COMPONENT_MATERIAL]
					,@QTY_COMP = [QTY]
					,@BARCODE_ID_COMP = [M].[BARCODE_ID]
					,@ALTERNATE_BARCODE_COMP = [M].[ALTERNATE_BARCODE]
					,@MATERIAL_NAME_COMP = [M].[MATERIAL_NAME]
				FROM
					[#COMPONENTES] [C]
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [C].[COMPONENT_MATERIAL] = [M].[MATERIAL_ID];

				EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL] @TASK_OWNER = @TASK_OWNER,                     -- varchar(25)
					@TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO,           -- varchar(25)
					@QUANTITY_ASSIGNED = @QTY_COMP,                -- numeric
					@CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
					@MATERIAL_ID = @MATERIAL_ID_COMP,              -- varchar(25)
					@BARCODE_ID = @BARCODE_ID_COMP,                -- varchar(50)
					@ALTERNATE_BARCODE = @ALTERNATE_BARCODE_COMP,  -- varchar(50)
					@MATERIAL_NAME = @MATERIAL_NAME_COMP,          -- varchar(200)
					@CLIENT_OWNER = @CLIENT_OWNER,                 -- varchar(25)
					@CLIENT_NAME = @CLIENT_NAME,                   -- varchar(150)
					@PRESULT = @PRESULT,                           -- varchar(4000)
					@WAVE_PICKING_ID = @WAVE_PICKING_ID,           -- numeric
					@IS_FROM_SONDA = @IS_FROM_SONDA,               -- int
					@WAREHOUSE = @WAREHOUSE,                       -- varchar(50)
					@FROM_MASTERPACK = 1,                          -- int
					@MASTER_PACK_CODE = @MATERIAL_ID,
					@SEND_ERP=@SEND_ERP,
					@STATUS_CODE=@STATUS_CODE,
					@PROJECT_ID = @PROJECT_ID,
					@LOCATION_SPOT_TARGET = @LOCATION_SPOT_TARGET,
					@LICENSE_ID_TO_EXCLUDE = @LICENSE_ID_TO_EXCLUDE;

				DELETE FROM
					[#COMPONENTES]
				WHERE
					@MATERIAL_ID_COMP = [COMPONENT_MATERIAL];
			END;

            -- ------------------------------------------------------------------------------------
            -- Si la cantidad disponible en el inventario es mayor a 0 establece el valor de @QUANTITY_ASSIGNED a lo que esta disponible y lo envia a procesar esa cantidad normalmente.
            -- ------------------------------------------------------------------------------------
			IF @AVAILABLE_QTY > 0
			BEGIN
				SELECT
					@QUANTITY_ASSIGNED = @AVAILABLE_QTY;
				GOTO PROCESAR_CON_INVENTARIO;
			END;
		END;
		FIN:
		SELECT
			@WAVE_PICKING_ID = @WPI
			,@PRESULT = 'OK';
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT
			@PRESULT = ERROR_MESSAGE();

		RAISERROR(@PRESULT, 16, 1);
	END CATCH;

END;