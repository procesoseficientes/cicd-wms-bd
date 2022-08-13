-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	4/6/2018 @ G-Force Team Sprint  
-- Description:			SP que cancela tareas de recepcion
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_CANCEL_RECEPTION_DETAIL] @XML = '<ArrayOfTareaDetalle >
  <TareaDetalle>
    <SERIAL_NUMBER>537566</SERIAL_NUMBER>
    <MATERIAL_ID>wms/001792</MATERIAL_ID>
    <MATERIAL_NAME>wms/001792</MATERIAL_NAME>
    <QTY>3.0000</QTY>
    <QTY_DOC>0</QTY_DOC>
    <QTY_DIFFERENCE>3.0000</QTY_DIFFERENCE>
    <TASK_COMMENTS>TAREA DE RECEPCION NO. 537566</TASK_COMMENTS>
    <WAVE_PICKING_ID>0</WAVE_PICKING_ID>
    <BARCODE_ID>wms/001792</BARCODE_ID>
    <CODIGO_POLIZA_SOURCE>513883</CODIGO_POLIZA_SOURCE>
    <USE_PICKING_LINE>0</USE_PICKING_LINE>
    <PHYSICAL_COUNT_DETAIL_ID>0</PHYSICAL_COUNT_DETAIL_ID>
    <IS_SELECTED>true</IS_SELECTED>
    <IN_PICKING_LINE>0</IN_PICKING_LINE>
    <CLASS_ID>0</CLASS_ID>
  </TareaDetalle>
  <TareaDetalle>
    <SERIAL_NUMBER>537566</SERIAL_NUMBER>
    <MATERIAL_ID>wms/001799</MATERIAL_ID>
    <MATERIAL_NAME>wms/001799</MATERIAL_NAME>
    <QTY>3.0000</QTY>
    <QTY_DOC>0</QTY_DOC>
    <QTY_DIFFERENCE>3.0000</QTY_DIFFERENCE>
    <TASK_COMMENTS>TAREA DE RECEPCION NO. 537566</TASK_COMMENTS>
    <WAVE_PICKING_ID>0</WAVE_PICKING_ID>
    <BARCODE_ID>wms/001799</BARCODE_ID>
    <CODIGO_POLIZA_SOURCE>513883</CODIGO_POLIZA_SOURCE>
    <USE_PICKING_LINE>0</USE_PICKING_LINE>
    <PHYSICAL_COUNT_DETAIL_ID>0</PHYSICAL_COUNT_DETAIL_ID>
    <IS_SELECTED>true</IS_SELECTED>
    <IN_PICKING_LINE>0</IN_PICKING_LINE>
    <CLASS_ID>0</CLASS_ID>
  </TareaDetalle>
  <TareaDetalle>
    <SERIAL_NUMBER>537566</SERIAL_NUMBER>
    <MATERIAL_ID>wms/01272016</MATERIAL_ID>
    <MATERIAL_NAME>Refrigerador-01272016</MATERIAL_NAME>
    <QTY>3.0000</QTY>
    <QTY_DOC>0</QTY_DOC>
    <QTY_DIFFERENCE>3.0000</QTY_DIFFERENCE>
    <TASK_COMMENTS>TAREA DE RECEPCION NO. 537566</TASK_COMMENTS>
    <WAVE_PICKING_ID>0</WAVE_PICKING_ID>
    <BARCODE_ID>wms/01272016</BARCODE_ID>
    <CODIGO_POLIZA_SOURCE>513883</CODIGO_POLIZA_SOURCE>
    <USE_PICKING_LINE>0</USE_PICKING_LINE>
    <PHYSICAL_COUNT_DETAIL_ID>0</PHYSICAL_COUNT_DETAIL_ID>
    <IS_SELECTED>true</IS_SELECTED>
    <IN_PICKING_LINE>0</IN_PICKING_LINE>
    <CLASS_ID>0</CLASS_ID>
  </TareaDetalle>
</ArrayOfTareaDetalle>', -- xml
	
	@CODIGO_POLIZA = '513883', -- varchar(25)
	@REASON = 'Cantidad incorrecta', -- varchar(250)
	@TASK_ID = 537566 -- int
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_CANCEL_RECEPTION_DETAIL] (
		@XML XML
		,@CODIGO_POLIZA VARCHAR(25)
		,@REASON VARCHAR(250)
		,@TASK_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
    -- -------------------------------------------
    -- Creamos variables 
    -- -------------------------------------------
		DECLARE	@MATERIALS_TEMP TABLE (
				[MATERIAL_ID] VARCHAR(50)
				,[LICENSE_ID] INT
				,[HAS_TASK] INT
			);


		DECLARE	@MATERIALS TABLE (
				[MATERIAL_ID] VARCHAR(50)
			);

		DECLARE	@MESSAGE VARCHAR(MAX) = '';

    --

		DECLARE	@MATERIALS_IN_TASKS TABLE (
				[MATERIAL_ID] VARCHAR(50)
			);
    --

		DECLARE	@REGIMEN VARCHAR(50);
    -- -------------------------------------------
    -- Obtenemos el regimen de la tarea
    -- -------------------------------------------
		SELECT TOP 1
			@REGIMEN = [T].[REGIMEN]
		FROM
			[wms].[OP_WMS_TASK_LIST] [T]
		WHERE
			[T].[SERIAL_NUMBER] = @TASK_ID;


    -- -------------------------------------------
    -- Obtenemos los materiales a buscar
    -- -------------------------------------------
		INSERT	INTO @MATERIALS
				(
					[MATERIAL_ID]
				)
		SELECT
			[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'VARCHAR(50)')
		FROM
			@XML.[nodes]('/ArrayOfTareaDetalle/TareaDetalle')
			AS [x] ([Rec]);



    -- -------------------------------------------
    -- Solo operamos si la recepcion no esta autorizada para enviar a ERP
    -- -------------------------------------------   

		IF @REGIMEN = 'GENERAL'
		BEGIN
			IF (ISNULL((SELECT
							1
						FROM
							[wms].[OP_WMS_TASK_LIST]
						WHERE
							[SERIAL_NUMBER] = @TASK_ID
							AND [IS_COMPLETED] = 0), 0) = 1)
			BEGIN
				RAISERROR ('No se puede cancelar una tarea cuando no esta en estado ''COMPLETADA''', 16, 1);
			END;

			IF (ISNULL((SELECT
							1
						FROM
							[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
						WHERE
							[TASK_ID] = @TASK_ID
							AND [IS_AUTHORIZED] = 1), 0) = 1)
			BEGIN
				RAISERROR ('No se puede cancelar una tarea cuando el documento este autorizado para enviar a ERP', 16, 1);
			END;
		END;



    -- -------------------------------------------
    -- Obtenemos las licencias de los materriales
    -- -------------------------------------------

		INSERT	INTO @MATERIALS_TEMP
				(
					[MATERIAL_ID]
					,[LICENSE_ID]
				)
		SELECT
			[INVL].[MATERIAL_ID]
			,[INVL].[LICENSE_ID]
		FROM
			[wms].[OP_WMS_LICENSES] AS [L]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] AS [INVL] ON [INVL].[LICENSE_ID] = [L].[LICENSE_ID]
		INNER JOIN @MATERIALS AS [M] ON [M].[MATERIAL_ID] = [INVL].[MATERIAL_ID]
		WHERE
			[L].[CODIGO_POLIZA] = @CODIGO_POLIZA;


    -- -------------------------------------------
    -- Obtenemos los materiales de de la tarea
    -- -------------------------------------------
		INSERT	INTO @MATERIALS_IN_TASKS
				(
					[MATERIAL_ID]
				)
		SELECT
			[TL].[MATERIAL_ID]
		FROM
			[wms].[OP_WMS_TASK_LIST] AS [TL]
		INNER JOIN @MATERIALS_TEMP AS [M] ON [M].[MATERIAL_ID] = [TL].[MATERIAL_ID]
											AND [M].[LICENSE_ID] = [TL].[LICENSE_ID_SOURCE];


		IF @REGIMEN = 'GENERAL'
		BEGIN
      -- -------------------------------------------
      -- Obtemos si algun material esta en una tarea
      -- -------------------------------------------
			UPDATE
				[M]
			SET	
				[M].[HAS_TASK] = 1
			FROM
				@MATERIALS_TEMP AS [M]
			INNER JOIN @MATERIALS_IN_TASKS AS [MIT] ON [MIT].[MATERIAL_ID] = [M].[MATERIAL_ID];

		END;
		ELSE
		BEGIN
      -- -------------------------------------------
      -- Obtemos si algun material esta en la aprobación fiscal
      -- -------------------------------------------
			UPDATE
				[M]
			SET	
				[M].[HAS_TASK] = 1
			FROM
				@MATERIALS_TEMP AS [M]
			INNER JOIN [wms].[OP_WMS3PL_POLIZA_TRANS_MATCH]
				AS [PTM] ON ([PTM].[MATERIAL_CODE] = [M].[MATERIAL_ID])
			WHERE
				[PTM].[CODIGO_POLIZA] = @CODIGO_POLIZA;
		END;

    -- -------------------------------------------
    -- Validamos si algun material esta en una tarea o en una aprobación fiscal
    -- -------------------------------------------    

		IF (SELECT
				COUNT(1)
			FROM
				@MATERIALS_TEMP
			WHERE
				[HAS_TASK] = 1) > 0
		BEGIN
			SELECT
				@MESSAGE = CONCAT(@MESSAGE, [MATERIAL_ID])
			FROM
				@MATERIALS_TEMP
			WHERE
				[HAS_TASK] = 1;

			IF @REGIMEN = 'GENERAL'
			BEGIN
				SELECT
					@MESSAGE = 'Los siguientes materiales ya están asociados a una tarea de despacho: '
					+ @MESSAGE;
			END;
			ELSE
			BEGIN
				SELECT
					@MESSAGE = 'Los siguientes materiales ya están aprobados fiscalmente: '
					+ @MESSAGE;
			END;


			SELECT
				0 AS [Resultado]
				,@MESSAGE [Mensaje]
				,-2 [Codigo]
				,'0' [DbData];
		END;
		ELSE
		BEGIN

      -- -------------------------------------------
      -- Se cambia el estado en la tabla de transacciones
      -- -------------------------------------------
			UPDATE
				[T]
			SET	
				[STATUS] = 'CANCEL'
				,[T].[TRANS_EXTRA_COMMENTS] = @REASON
			FROM
				[wms].[OP_WMS_TRANS] [T]
			INNER JOIN @MATERIALS_TEMP [MT] ON ([MT].[MATERIAL_ID] = [T].[MATERIAL_CODE])
			WHERE
				[T].[CODIGO_POLIZA] = @CODIGO_POLIZA;


	        -- -------------------------------------------
      -- Se eliminan los numeros de series de la licencia
      -- -------------------------------------------
			DELETE
				[MSN]
			FROM
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MSN]
			INNER JOIN @MATERIALS_TEMP [MT] ON (
											[MSN].[MATERIAL_ID] = [MT].[MATERIAL_ID]
											AND [MSN].[LICENSE_ID] = [MT].[LICENSE_ID]
											);


      -- -------------------------------------------
      -- Se eliminan los detalles de la licencia
      -- -------------------------------------------

			DELETE
				[IL]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			INNER JOIN @MATERIALS_TEMP [MT] ON (
											[IL].[LICENSE_ID] = [MT].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [MT].[MATERIAL_ID]
											);



      -- -------------------------------------------
      -- Se eliminan las licencias que ya no tengan detalles
      -- -------------------------------------------
			DELETE
				[L]
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
			WHERE
				[IL].[MATERIAL_ID] IS NULL
				AND [L].[CODIGO_POLIZA] = @CODIGO_POLIZA;

      -- -------------------------------------------
      -- Actualizo la tarea a 'NO COMPLETADA' para que se pueda recepcionar con los materiales correctos
      -- -------------------------------------------

			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[IS_COMPLETED] = 0
			WHERE
				[SERIAL_NUMBER] = @TASK_ID;

			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,'0' [DbData];

		END;

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;