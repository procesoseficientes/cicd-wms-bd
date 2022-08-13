-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que crea las tareas para demanda de despacho de sap

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 Team ERGON - Sprint ERGON EPONA
-- Description:	 Se quita cursor y se reserva unicamente el inventario necesario para suplir la tarea 


-- Modificación: pablo.aguilar
-- Fecha de Modificaci[on: 2017-05-17 ErgonTeam@Sheik
-- Description:	 Se agrega parámetro de @IS_CONSOLIDATED y se asigna el tasksubtype dependiendo de esta variable

-- Modificacion 7/13/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- rodrigo.gomez
-- Se agrega la explocion de masterpack a un nivel si no hay inventario suficiente

-- Modificacion 8/29/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agregan los parametros @SOURCE_TYPE y @TRANSFER_REQUEST_ID

-- Modificacion 04-Oct-17 @ Nexus Team Sprint ewms
-- pablo.aguilar
-- Se agrega parámetro de maneja linea de picking 

-- Modificacion 11-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- pablo.aguilar 
-- Se quita validación de masterpack en linea de picking 

-- Modificacion 22-Dec-17 @ Nexus Team Sprint @IceAge
-- pablo.aguilar
-- Se agregan nueva función de tabla para obtener las licencias a pickear basado en algoritmos de ascedente y descedente

-- Modificacion 12-Jan-2018 @ Reborn-Team Sprint Ramsey
-- rudi.garcia
-- Se agrega el parametro @IS_FOR_DELIVERY_IMMEDIATE para el sp [OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND] cuando es MASTERPACK

-- Modificacion 26-Ene-18 @ Reborn Team Sprint @Trotzdem
-- marvin.solares
-- se agrega el parámetro @PRIORITY como parámetro de entrada y se modifica el procedimiento para que guarde la 
-- prioridad en la tabla OP_WMS_TASK_LIST

-- Modificacion 09-Apr-18 @ Nexus Team Sprint Buho
-- pablo.aguilar
-- Se agrega logica para manejar el tipo de eentrega inmediata con tarea de reubicación

-- Modificacion:			marvin.solares
-- Fecha: 					20180920 GForce@Kiwi 
-- Description:				se modifica query de licencias para que tome como prioridad ubicaciones de fast picking

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:			envío el valor de días mínimo de fecha de expiración a la función que obtiene las licencias de picking

-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			agrego como parámetro una licencia de la cual no quiero que se tome en cuenta su inventario disponible en el algoritmo de picking

-- Autor:				fabrizio.delcompare
-- Fecha de Creacion: 	23-Jul-2029
-- Description:			Cambio completo del query, ahora automaticamente trae disponibilidad recursiva basada en masterpack
-- Autor:				gustavo.garcia
-- Fecha de Creacion: 	22-Mar-2022
-- Description:			Se agrego el uso de la variable has batch ya que se mandaba como null

/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND] 
		@TASK_OWNER = 'ADMIN', -- varchar(25)
		@TASK_ASSIGNEDTO = 'ACAMACHO', -- varchar(25)
		@QUANTITY_ASSIGNED = 10, -- numeric
		@CODIGO_POLIZA_TARGET = NULL, -- varchar(25)
		@MATERIAL_ID = 'alsersa/SKUPRUEBA', -- varchar(25)
		@BARCODE_ID = 'alsersa/SKUPRUEBA', -- varchar(50)
		@ALTERNATE_BARCODE = 'alsersa/SKUPRUEBA', -- varchar(50)
		@MATERIAL_NAME = 'Prueba', -- varchar(200)
		@CLIENT_OWNER = 'alsersa', -- varchar(25)
		@CLIENT_NAME = 'alsersa Guatemala', -- varchar(150)
		@IS_FROM_SONDA = 0, -- int
		@CODE_WAREHOUSE = 'BODEGA_01', -- varchar(50)
		@IS_FROM_ERP = 0, -- int
		@WAVE_PICKING_ID = 0, -- numeric
		@DOC_ID_TARGET = 0, -- int
		@LOCATION_SPOT_TARGET = 'B01-R01-C01-NA', -- varchar(25)
		@IS_CONSOLIDATED = 0, -- int,
		@SOURCE_TYPE  = NULL,
		@TRANSFER_REQUEST_ID = 0

*/

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND] (
		@TASK_OWNER VARCHAR(25)
		,@TASK_ASSIGNEDTO VARCHAR(25)
		,@QUANTITY_ASSIGNED NUMERIC(18, 4)
		,@CODIGO_POLIZA_TARGET VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@BARCODE_ID VARCHAR(50)
		,@ALTERNATE_BARCODE VARCHAR(50) = ''
		,@MATERIAL_NAME VARCHAR(200)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@IS_FROM_SONDA INT = 0
		,@CODE_WAREHOUSE VARCHAR(50)
		,@IS_FROM_ERP INT
		,@WAVE_PICKING_ID NUMERIC(18, 0)
		,@DOC_ID_TARGET INT
		,@LOCATION_SPOT_TARGET VARCHAR(25)
		,@IS_CONSOLIDATED INT = 0
		,@FROM_MASTERPACK INT = 0
		,@SOURCE_TYPE VARCHAR(50) = NULL
		,@TRANSFER_REQUEST_ID INT = 0
		,@TONE VARCHAR(20) = NULL
		,@CALIBER VARCHAR(20) = NULL
		,@IN_PICKING_LINE INT = 0
		,@IS_FOR_DELIVERY_IMMEDIATE INT
		,@PRIORITY INT = 1
		,@PICKING_HEADER_ID INT = NULL
		,@STATUS_CODE VARCHAR(50) = NULL
		,@PROJECT_ID UNIQUEIDENTIFIER = NULL
		,@ORDER_NUMBER VARCHAR(25)
		,@MIN_DAYS_EXPIRATION_DATE INT = 0
		,@DOC_NUM VARCHAR(50) = NULL
		,@LICENSE_ID_TO_EXCLUDE INT = -1
	)
AS
BEGIN
	SET NOCOUNT OFF;
    -- -------------------------------------------------------------
    -- Declaramos las variables necesarias
    -- -------------------------------------------------------------
	DECLARE
		@PROJECT_CODE VARCHAR(50) = NULL
		,@PROJECT_NAME VARCHAR(150) = NULL
		,@PROJECT_SHORT_NAME VARCHAR(25) = NULL
		,@COUNT_LIC INT;

	DECLARE
		@WPI NUMERIC(18, 0)
		,@ASSIGNED_DATE DATETIME
		,@CURRENT_LOCATION VARCHAR(25)
		,@CURRENT_WAREHOUSE VARCHAR(25)
		,@LICENSE_ID NUMERIC(18, 0)
		,@TASK_COMMENTS VARCHAR(150)
		,@PRESULT VARCHAR(max)
		,@CODIGO_POLIZA_SOURCE VARCHAR(25)
		,@QUANTITY_PENDING NUMERIC(18, 4)
		,@HAVBATCH NUMERIC(18) = 0
		,@vCURRENT_ASSIGNED NUMERIC(18, 4)
		,@IS_MASTER_PACK INT = 0
		,@ASSEMBLY_QTY INT = 0
		,@AVAILABLE_QTY NUMERIC(18, 4) = 0
		,@ASSEMBLED_QTY INT = 0
		,@QUERY NVARCHAR(MAX)
		,@IN_PICKING_LINE_ORIGINAL INT = @IN_PICKING_LINE
		,@TASK_ASSIGNEDTO_ORIGINAL VARCHAR(25) = @TASK_ASSIGNEDTO
		,@TASK_TYPE VARCHAR(25) = 'TAREA_PICKING'
		,@TASK_SUBTYPE VARCHAR(25) = ''
		,@DISPATCH_BY_STATUS INT = 0
		,@QTY_AVAILABLE_FROM_LICENSE_PROYECT NUMERIC(18, 4);

	DECLARE	@INVENTORY_PROYECT_TABLE TABLE (
			[ID] INT
			,[PROJECT_ID] UNIQUEIDENTIFIER
			,[PK_LINE] INT
			,[LICENSE_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[QTY_LICENSE] NUMERIC(18, 4)
			,[QTY_RESERVED] NUMERIC(18, 4)
			,[QTY_DISPATCHED] NUMERIC(18, 4)
			,[RESERVED_PICKING] NUMERIC(18, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
			,[STATUS_CODE] VARCHAR(50)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[CURRENT_LOCATION] VARCHAR(25)
		);

	BEGIN TRY

        -- ------------------------------------------------------------------------------------
        -- Obtenemos la informacion del proyecto si lo mandaran
        -- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@PROJECT_CODE = [P].[OPPORTUNITY_CODE]
			,@PROJECT_NAME = [P].[OPPORTUNITY_NAME]
			,@PROJECT_SHORT_NAME = [P].[SHORT_NAME]
		FROM
			[wms].[OP_WMS_PROJECT] [P]
		WHERE
			@PROJECT_ID = [P].[ID];

        -- ------------------------------------
        -- Obtenemos el inventario del proyecto
        -- ------------------------------------

		IF @PROJECT_ID IS NOT NULL
		BEGIN
			INSERT	INTO @INVENTORY_PROYECT_TABLE
					(
						[ID]
						,[PROJECT_ID]
						,[PK_LINE]
						,[LICENSE_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY_LICENSE]
						,[QTY_RESERVED]
						,[QTY_DISPATCHED]
						,[RESERVED_PICKING]
						,[TONE]
						,[CALIBER]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[STATUS_CODE]
						,[CURRENT_WAREHOUSE]
						,[CURRENT_LOCATION]
					)
			SELECT
				[IP].[ID]
				,[IP].[PROJECT_ID]
				,[IP].[PK_LINE]
				,[IP].[LICENSE_ID]
				,[IP].[MATERIAL_ID]
				,[IP].[MATERIAL_NAME]
				,[IP].[QTY_LICENSE]
				,[IP].[QTY_RESERVED]
				,[IP].[QTY_DISPATCHED]
				,[IP].[RESERVED_PICKING]
				,[IP].[TONE]
				,[IP].[CALIBER]
				,[IP].[BATCH]
				,[IP].[DATE_EXPIRATION]
				,[IP].[STATUS_CODE]
				,[IP].[CURRENT_WAREHOUSE]
				,[IP].[CURRENT_LOCATION]
			FROM
				[wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROJECT_ID) [IP]
			WHERE
				@CODE_WAREHOUSE = [IP].[CURRENT_WAREHOUSE]
				AND [MATERIAL_ID] = @MATERIAL_ID;
		END;

		SELECT
			@DISPATCH_BY_STATUS = CONVERT(INT, [P].[VALUE])
		FROM
			[wms].[OP_WMS_PARAMETER] [P]
		WHERE
			[P].[GROUP_ID] = 'PICKING_DEMAND'
			AND [P].[PARAMETER_ID] = 'DISPATCH_BY_STATUS';



		SELECT
			@ASSIGNED_DATE = GETDATE()
			,@TASK_TYPE = CASE	WHEN @IS_FOR_DELIVERY_IMMEDIATE = 0
								THEN 'TAREA_REUBICACION'
								ELSE 'TAREA_PICKING'
							END
			,@TASK_SUBTYPE = CASE	WHEN @IS_CONSOLIDATED = 1
											AND @IS_FOR_DELIVERY_IMMEDIATE = 1
									THEN 'DESPACHO_CONSOLIDADO'
									WHEN @IS_CONSOLIDATED = 0
											AND @IS_FOR_DELIVERY_IMMEDIATE = 1
									THEN 'DESPACHO_GENERAL'
									WHEN @IS_FOR_DELIVERY_IMMEDIATE = 0
									THEN 'ENTREGA_NO_INMEDIATA'
									ELSE @TASK_SUBTYPE
								END
			,@QUANTITY_PENDING = @QUANTITY_ASSIGNED;
        --
		SELECT
			@TASK_SUBTYPE = CASE	WHEN @IS_FOR_DELIVERY_IMMEDIATE = 0
									THEN 'ENTREGA_NO_INMEDIATA'
									WHEN @IS_FOR_DELIVERY_IMMEDIATE = 1
											AND ISNULL(@PICKING_HEADER_ID,
											0) > 0
									THEN 'INVENTARIO_PREPARADO'
									WHEN (
											@SOURCE_TYPE = 'WT - SWIFT'
											OR @SOURCE_TYPE = 'WT - ERP'
											)
											AND @IS_FOR_DELIVERY_IMMEDIATE = 1
									THEN 'DESPACHO_WT'
									ELSE @TASK_SUBTYPE
							END;
		SELECT TOP 1
			@TASK_ASSIGNEDTO = CASE	WHEN [USE_PICKING_LINE] = 0
									THEN ''
									ELSE @TASK_ASSIGNEDTO
								END
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID;

        ---------------------------------------------------------------------------------
        -- Valida Ola de picking
        ---------------------------------------------------------------------------------  
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

		PRINT 'wave picking id: ' + CAST(@WAVE_PICKING_ID AS VARCHAR);

        -- ------------------------------------------------------------------------------------
        -- Obtiene el inventario disponible para el material, luego verifica que sea suficiente para el picking.
        -- Si no lo es verifica que sea un masterpack y no venga de una explosion de masterpack, de ser asi obtiene la cantidad disponible a armar y 
        -- establece una nueva cantidad asignada para solo armar los MPs necesarios.
        -- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@IS_MASTER_PACK = [IS_MASTER_PACK]
			,
               --Validar que si está en linea de picking el material tambien este en linea de picking 
			@IN_PICKING_LINE = CASE	WHEN @IN_PICKING_LINE = 1
											AND [USE_PICKING_LINE] = 1
									THEN 1
									ELSE 0
								END
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [CLIENT_OWNER] = @CLIENT_OWNER;

        ---------------------------------------------------------------------------------
        -- Valida inventario
        ---------------------------------------------------------------------------------  
		SELECT
			@AVAILABLE_QTY = ISNULL(SUM([AVAILABLE_QTY]), 0)
		FROM
			[wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [CURRENT_WAREHOUSE] = @CODE_WAREHOUSE;

		print '@AVAILABLE_QTY GW: ' + CAST(@AVAILABLE_QTY AS VARCHAR)
		print ''
		print '@QUANTITY_ASSIGNED GW: ' + CAST(@QUANTITY_ASSIGNED AS VARCHAR)
		print ''

        ---------------------------------------------------------------------------------
        -- Validamos si es por proyecto
        ---------------------------------------------------------------------------------  
		IF @PROJECT_ID IS NOT NULL
		BEGIN
            ---------------------------------------------------------------------------------
            -- Obtenemos la cantidad disponible
            ---------------------------------------------------------------------------------  
			SELECT
				@QTY_AVAILABLE_FROM_LICENSE_PROYECT = ISNULL(SUM([IPT].[QTY_LICENSE]),
											0)
			FROM
				@INVENTORY_PROYECT_TABLE [IPT]
			WHERE
				@MATERIAL_ID = [IPT].[MATERIAL_ID]
				AND @CODE_WAREHOUSE = [IPT].[CURRENT_WAREHOUSE];

			SET @AVAILABLE_QTY = CASE	WHEN @QTY_AVAILABLE_FROM_LICENSE_PROYECT >= @QUANTITY_ASSIGNED
										THEN @QTY_AVAILABLE_FROM_LICENSE_PROYECT
										ELSE (@QTY_AVAILABLE_FROM_LICENSE_PROYECT
											+ @AVAILABLE_QTY)
									END;

		END;

		IF (
			@QUANTITY_ASSIGNED > @AVAILABLE_QTY
			AND ISNULL(@PICKING_HEADER_ID, 0) = 0
			)
		BEGIN
			IF @IS_MASTER_PACK = 1
				AND @FROM_MASTERPACK = 0
			BEGIN
				SELECT
					@ASSEMBLY_QTY = [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK_ON_DISPATCH_DEMAND](@MATERIAL_ID,
											@CODE_WAREHOUSE,
											@STATUS_CODE);

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
				+ @CLIENT_NAME + ' SKU: ' + @MATERIAL_ID
				+ ' , Pedido No.: ' + @DOC_NUM
				+ ' , Tolerancia fecha Expiración: '
				+ CAST(@MIN_DAYS_EXPIRATION_DATE AS VARCHAR)
				+ ' días';
			RAISERROR(@PRESULT, 16, 1);

		END;


		PROCESAR_CON_INVENTARIO:
        ---------------------------------------------------------------------------------
        -- Valida si maneja lote
        --------------------------------------------------------------------------------- 
		
		PRINT 'PROCESANDO CON INVENTARIO'
		SELECT TOP 1
			@HAVBATCH = ISNULL([BATCH_REQUESTED], 0)
		FROM
			[wms].[OP_WMS_MATERIALS]
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
			,[QTY] NUMERIC(19, 4)
			,[DATE_BASE] DATETIME
			,[ROW] INT
			,[ALLOW_FAST_PICKING] INT
			,[PRIORITY] INT
		);

		CREATE TABLE [#LICENCIAS_TEMP] (
			[CURRENT_LOCATION] VARCHAR(25)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[LICENSE_ID] NUMERIC
			,[CODIGO_POLIZA] VARCHAR(25)
			,[QTY] NUMERIC(19, 4)
			,[DATE_BASE] DATETIME
			,[ROW] INT
			,[ALLOW_FAST_PICKING] INT
			,[PRIORITY] INT
		);

		PRINT '@HAVBATCH' + CAST(@HAVBATCH AS VARCHAR);
		PRINT '@WAVE_PICKING_ID'
			+ CAST(@WAVE_PICKING_ID AS VARCHAR);

		IF @PROJECT_ID IS NOT NULL
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
						,[ALLOW_FAST_PICKING]
						,[PRIORITY]
					)
			SELECT
				[CURRENT_LOCATION]
				,[CURRENT_WAREHOUSE]
				,[LICENSE_ID]
				,[CODIGO_POLIZA]
				,[QTY]
				,[FECHA_DOCUMENTO]
				,[ORDER]
				,[ALLOW_FAST_PICKING]
				,1
			FROM
				[wms].[OP_WMS_FN_GET_LICENSE_TO_PICK_FOR_PROYECT](@MATERIAL_ID,
											@CODE_WAREHOUSE,
											@QUANTITY_ASSIGNED,
											@HAVBATCH, NULL,
											@PICKING_HEADER_ID,
											@STATUS_CODE, 0,
											@PROJECT_ID,
											@MIN_DAYS_EXPIRATION_DATE,
											@LICENSE_ID_TO_EXCLUDE);

			INSERT	INTO [#LICENCIAS]
					(
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[DATE_BASE]
						,[ROW]
						,[ALLOW_FAST_PICKING]
						,[PRIORITY]
					)
			SELECT
				[CURRENT_LOCATION]
				,[CURRENT_WAREHOUSE]
				,[LICENSE_ID]
				,[CODIGO_POLIZA]
				,[QTY]
				,[FECHA_DOCUMENTO]
				,[ORDER]
				,[ALLOW_FAST_PICKING]
				,2
			FROM
				[wms].[OP_WMS_FN_GET_LICENSE_TO_PICK](@MATERIAL_ID,
											@CODE_WAREHOUSE,
											@QUANTITY_ASSIGNED,
											@HAVBATCH, NULL,
											@PICKING_HEADER_ID,
											@STATUS_CODE,
											@MIN_DAYS_EXPIRATION_DATE,
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
						,[ALLOW_FAST_PICKING]
					)
			SELECT
				[CURRENT_LOCATION]
				,[CURRENT_WAREHOUSE]
				,[LICENSE_ID]
				,[CODIGO_POLIZA]
				,[QTY]
				,[FECHA_DOCUMENTO]
				,[ORDER]
				,[ALLOW_FAST_PICKING]
			FROM
				[wms].[OP_WMS_FN_GET_LICENSE_TO_PICK](@MATERIAL_ID,
											@CODE_WAREHOUSE,
											@QUANTITY_ASSIGNED,
											@HAVBATCH, 
											NULL,
											@PICKING_HEADER_ID,
											@STATUS_CODE,
											@MIN_DAYS_EXPIRATION_DATE,
											@LICENSE_ID_TO_EXCLUDE);
		END;


		SELECT
			@COUNT_LIC = COUNT(*)
		FROM
			[#LICENCIAS];
		PRINT CAST(ISNULL(@LICENSE_ID_TO_EXCLUDE, 0) AS VARCHAR);
		PRINT @CODE_WAREHOUSE;
        -- ------------------------------------------------------------------------------------
        -- si no devuelve licencias para pickear, retornamos un error y no guardamos tareas de picking
        -- ------------------------------------------------------------------------------------

		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[#LICENCIAS] )
		BEGIN
			SELECT
				@PRESULT = 'ERROR, No cuenta con licencias disponibles para continuar con la operación del cliente: '
				+ @CLIENT_NAME + ' SKU: ' + @MATERIAL_ID
				+ ' , Pedido No.: ' + @DOC_NUM
				+ ' , Tolerancia fecha Expiración: '
				+ CAST(@MIN_DAYS_EXPIRATION_DATE AS VARCHAR)
				+ ' días '
				+'Material ID: ' + @MATERIAL_ID
				+'Code warehouse ' + @CODE_WAREHOUSE
				+'--> @QUANTITY_ASIGNED: '+ CAST(@QUANTITY_ASSIGNED AS VARCHAR)
				+ '--> @PICKING HEADER ID: '+ CAST(@PICKING_HEADER_ID AS VARCHAR)
				+'--> @STATUS_CODE: '+ CAST(@STATUS_CODE AS VARCHAR)
				+'--> @MIN_DAYS_BY_SALE_ORDER: '+ CAST(@MIN_DAYS_EXPIRATION_DATE AS VARCHAR)
				+'--> @LICENSE_ID_TO_EXCLUDE: '+ CAST(@LICENSE_ID_TO_EXCLUDE AS VARCHAR)
			RAISERROR(@PRESULT, 18, 1);
		END;

		DECLARE
			@LICENCIA_ELEGIDA NUMERIC = NULL
			,@LICENCIA_ACTUAL NUMERIC
			,@FILA_LICENCIA INT
			,@CANTIDAD_LICENCIAS INT
			,@QTY_LICENCIA INT
			,@FILA INT = 1;


		IF @TONE IS NOT NULL
			OR @CALIBER IS NOT NULL
		BEGIN
			INSERT	INTO [#LICENCIAS_TEMP]
					(
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[DATE_BASE]
						,[ROW]
						,[ALLOW_FAST_PICKING]
						,[PRIORITY]
					)
			SELECT
				[L].[CURRENT_LOCATION]
				,[L].[CURRENT_WAREHOUSE]
				,[L].[LICENSE_ID]
				,[L].[CODIGO_POLIZA]
				,[L].[QTY]
				,[L].[DATE_BASE]
				,ROW_NUMBER() OVER (ORDER BY [L].[ALLOW_FAST_PICKING] DESC, [L].[QTY], [L].[DATE_BASE])
				,[L].[ALLOW_FAST_PICKING] [ALLOW_FAST_PICKING]
				,[L].[PRIORITY]
			FROM
				[#LICENCIAS] [L]
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = @MATERIAL_ID
											)
			INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID])
			WHERE
				(
					@TONE IS NULL
					OR [TCM].[TONE] = @TONE
				)
				AND (
						@CALIBER IS NULL
						OR [TCM].[CALIBER] = @CALIBER
					);

			DELETE
				[#LICENCIAS];
			INSERT	INTO [#LICENCIAS]
			SELECT
				*
			FROM
				[#LICENCIAS_TEMP];
			DELETE
				[#LICENCIAS_TEMP];
		END;

		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							[#LICENCIAS] ))
		BEGIN
			PRINT 'TOP 1 LICENSE'
            ---------------------------------------------------------------------------------
            -- Se obtiene la cantidad total de licencias
            ---------------------------------------------------------------------------------  
			DECLARE	@QTY_LICENSE_TONO NUMERIC(19, 4);
			SET @FILA = 1;
			SELECT
				@CANTIDAD_LICENCIAS = COUNT([LICENSE_ID])
				,@QTY_LICENSE_TONO = SUM([QTY])
			FROM
				[#LICENCIAS];

            ---------------------------------------------------------------------------------
            -- Se verifica si es un picking de tono o calibre para sacar el inventario por lote
            ---------------------------------------------------------------------------------  
			IF @TONE IS NOT NULL
				OR @CALIBER IS NOT NULL
			BEGIN

                ---------------------------------------------------------------------------------
                -- Se obtiene la cantidad total de licencias
                ---------------------------------------------------------------------------------  

				SET @FILA = 1;

				IF @QUANTITY_PENDING <= @QTY_LICENSE_TONO
				BEGIN

					WHILE (@FILA <= @CANTIDAD_LICENCIAS)
					BEGIN
						SELECT
							@LICENCIA_ACTUAL = [L].[LICENSE_ID]
							,@FILA_LICENCIA = [L].[ROW]
							,@QTY_LICENCIA = [L].[QTY]
						FROM
							[#LICENCIAS] [L]
						INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = @MATERIAL_ID
											)
						INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID])
						WHERE
							(
								@TONE IS NULL
								OR [TCM].[TONE] = @TONE
							)
							AND (
									@CALIBER IS NULL
									OR [TCM].[CALIBER] = @CALIBER
								)
							AND [L].[ROW] = @FILA
						ORDER BY
							[L].[ALLOW_FAST_PICKING] DESC
							,[L].[QTY] ASC
							,[L].[DATE_BASE] ASC;
                        ---------------------------------------------------------------------------------
                        -- Si la cantidad pendiente 
                        ---------------------------------------------------------------------------------  
						IF @QUANTITY_PENDING <= @QTY_LICENCIA
							OR @FILA_LICENCIA = @CANTIDAD_LICENCIAS
						BEGIN
							SELECT
								@LICENCIA_ELEGIDA = @LICENCIA_ACTUAL;
							BREAK;
						END;
						ELSE
						BEGIN
							SET @FILA = @FILA + 1;
						END;
					END;
				END;
				ELSE
				BEGIN
					SELECT
						@PRESULT = 'ERROR, No cuenta con inventario suficiente para continuar con la operación del cliente: '
						+ @CLIENT_NAME + ' SKU: '
						+ @MATERIAL_ID;
					RAISERROR(@PRESULT, 16, 1);
				END;

				SELECT
					@CANTIDAD_LICENCIAS = COUNT([LICENSE_ID])
				FROM
					[#LICENCIAS];

			END;

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
			WHERE
				(
					@LICENCIA_ELEGIDA IS NULL
					OR [L].[LICENSE_ID] = @LICENCIA_ELEGIDA
				)
			ORDER BY
				[L].[PRIORITY]
				,[L].[ROW];


			PRINT 'license id: ' + CAST(@LICENSE_ID AS VARCHAR);

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_TASK_LIST]
						WHERE
							[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [LICENSE_ID_SOURCE] = @LICENSE_ID
							AND [MATERIAL_ID] = @MATERIAL_ID )
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
					AND [LICENSE_ID_SOURCE] = @LICENSE_ID
					AND [MATERIAL_ID] = @MATERIAL_ID;
			END;
			ELSE
			BEGIN
				PRINT 'Insert';
				PRINT @MATERIAL_ID
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
							,[IS_FROM_ERP]
							,[DOC_ID_TARGET]
							,[LOCATION_SPOT_TARGET]
							,[SOURCE_TYPE]
							,[TRANSFER_REQUEST_ID]
							,[TONE]
							,[CALIBER]
							,[IN_PICKING_LINE]
							,[IS_FOR_DELIVERY_IMMEDIATE]
							,[PRIORITY]
							,[FROM_MASTERPACK]
							,[STATUS_CODE]
							,[PROJECT_ID]
							,[PROJECT_CODE]
							,[PROJECT_NAME]
							,[PROJECT_SHORT_NAME]
							,[ORDER_NUMBER]
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
							,1
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
							,@IS_FROM_ERP
							,@DOC_ID_TARGET
							,@LOCATION_SPOT_TARGET
							,@SOURCE_TYPE
							,@TRANSFER_REQUEST_ID
							,@TONE
							,@CALIBER
							,@IN_PICKING_LINE
							,@IS_FOR_DELIVERY_IMMEDIATE
							,@PRIORITY
							,@FROM_MASTERPACK
							,@STATUS_CODE
							,@PROJECT_ID
							,@PROJECT_CODE
							,@PROJECT_NAME
							,@PROJECT_SHORT_NAME
							,@ORDER_NUMBER
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
		IF @FROM_MASTERPACK = 0
		BEGIN
			PRINT 'GOING FIN'
			GOTO FIN;
		END;
		ELSE
		BEGIN
			PRINT 'FIN_COMPONENTE'
			GOTO FIN_COMPONENTE;
		END;

		EXPLOTAR_MASTERPACK:

		IF @FROM_MASTERPACK = 0
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
				DECLARE	@QTY_COMP INT = 0;
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

				PRINT 'COMPONENTE: ' + CAST (@MATERIAL_ID_COMP AS VARCHAR)
				PRINT 'CANTIDAD COMP:' + CAST (@QTY_COMP AS VARCHAR)

				EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND] 
					@TASK_OWNER = @TASK_OWNER,                     -- varchar(25)
					@TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO_ORIGINAL,  -- varchar(25)
					@QUANTITY_ASSIGNED = @QTY_COMP,                -- numeric
					@CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
					@MATERIAL_ID = @MATERIAL_ID_COMP,              -- varchar(25)
					@BARCODE_ID = @BARCODE_ID_COMP,                -- varchar(50)
					@ALTERNATE_BARCODE = @ALTERNATE_BARCODE_COMP,  -- varchar(50)
					@MATERIAL_NAME = @MATERIAL_NAME_COMP,          -- varchar(200)
					@CLIENT_OWNER = @CLIENT_OWNER,                 -- varchar(25)
					@CLIENT_NAME = @CLIENT_NAME,                   -- varchar(150)
					@IS_FROM_SONDA = @IS_FROM_SONDA,               -- int
					@CODE_WAREHOUSE = @CODE_WAREHOUSE,             -- varchar(50)
					@IS_FROM_ERP = @IS_FROM_ERP,                   -- int
					@WAVE_PICKING_ID = @WAVE_PICKING_ID,           -- numeric
					@DOC_ID_TARGET = @DOC_ID_TARGET,               -- int
					@LOCATION_SPOT_TARGET = @LOCATION_SPOT_TARGET, -- varchar(25)
					@IS_CONSOLIDATED = @IS_CONSOLIDATED,           -- int
					@FROM_MASTERPACK = 1,
					@SOURCE_TYPE = @SOURCE_TYPE,
					@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID,
					@IN_PICKING_LINE = @IN_PICKING_LINE_ORIGINAL,
					@IS_FOR_DELIVERY_IMMEDIATE = @IS_FOR_DELIVERY_IMMEDIATE,
					@PRIORITY = @PRIORITY,
					@STATUS_CODE = @STATUS_CODE,
					@PROJECT_ID = @PROJECT_ID,
					@ORDER_NUMBER = @ORDER_NUMBER,
					@LICENSE_ID_TO_EXCLUDE = @LICENSE_ID_TO_EXCLUDE;

				DELETE FROM
					[#COMPONENTES]
				WHERE
					@MATERIAL_ID_COMP = [COMPONENT_MATERIAL];
			END;

			SELECT
				@ASSEMBLED_QTY = @QUANTITY_ASSIGNED;
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
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@WAVE_PICKING_ID AS VARCHAR) + '|'
			+ CAST(@ASSEMBLED_QTY AS VARCHAR) [DbData];
		FIN_COMPONENTE:
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,'' [DbData];
	END CATCH;
END;
