-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-18 @ Team ERGON - Sprint EPONA
-- Description:	 Validar si la ubicación  en la columna [ALLOW_STORAGE]  de OP_WMS_SHELF_SPOTS es 1. de no ser asi retornar error. 

-- Modificacion 01-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se le agregaron los parametros @LOGIN y @TASK_ID para validar que la ubicacion este en una bodega con acceso al usuairo y si es de una transferencia que sea la bodega destinp

-- Modificacion 1/30/2018 @ REBORN-Team Sprint Trotzdem
-- rodrigo.gomez
-- Se agrega la validacion de clases en la ubicacion para la licencia

-- Modificacion 6/13/2018 @ GFORCE-Team Sprint Dinosaurio
-- rodrigo.gomez
-- Se agrega validacion de ubicacion de estado obligatoria

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Mamba
-- Description:		Se modifica para que no permita usar la ubicacion cuando la licencia tiene inventario bloqueado por interfaces en ubicacion de fast picking

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20180625 GForce@Cancun
-- Description:		Se agrega validacion para que no permita ubicar en fast picking, materiales con diferentes propiedades de lote/fecha expiracion, estado, tono y/o calibre

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20180627 GForce@Cancun
-- Description:		Se agrega filtro de material en validaciones de propiedades especiales para fast picking

-- Autor:				henry.rodriguez
-- Fecha de Creacion:	11-Julio-2019
-- Descripcion:			Se agrega validacion para que no permita ubicar en fast picking, proyectos diferentes.

-- Autor:				henry.rodriguez
-- Fecha de Creacion:	26-Julio-2019
-- Descripcion:			Se modifica validacion para que no permita ubicar el mismo material en la ubicacion de fast picking

-- Autor:				henry.rodriguez
-- Fecha de Creacion:	31-Julio-2019
-- Descripcion:			Se agrega validacion por cantidades

-- Autor:				kevin.guerra
-- Fecha de Creacion:	07-04-2020 GForce@Paris Sprint B
-- Descripcion:			Se maneja subfamlias en este SP.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_VALIDATE_LOCATION_FOR_STORAGE] 
				@LOGIN = 'ACAMACHO'
				,@LOCATION_SPOT = 'B01-R01-C01-NC'
				,@TASK_ID = 476534
				,@LICENSE_ID = 548984
--*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LOCATION_FOR_STORAGE] (
		@LOGIN VARCHAR(50)
		,@LOCATION_SPOT VARCHAR(50)
		,@TASK_ID NUMERIC = NULL
		,@LICENSE_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE	@WAREHOUSE TABLE (
			[WAREHOUSE_BY_USER_ID] INT
			,[LOGIN_ID] VARCHAR(50)
			,[WAREHOUSE_ID] VARCHAR(50)
			,[NAME] VARCHAR(250)
			,[ERP_WAREHOUSE] VARCHAR(50)
		);
  --
	DECLARE	@LICENSE_CLASSES TABLE (
			[CLASS_ID] INT
			,[CLASS_NAME] VARCHAR(50)
			,[CLASS_DESCRIPTION] VARCHAR(250)
			,[CLASS_TYPE] VARCHAR(50)
			,[CREATED_BY] VARCHAR(50)
			,[CREATED_DATETIME] DATETIME
			,[LAST_UPDATED_BY] VARCHAR(50)
			,[LAST_UPDATED] DATETIME
			,[PRIORITY] INT
		);
  --
	DECLARE	@LOCATION_CLASSES TABLE (
			[CLASS_ID] INT
			,[CLASS_NAME] VARCHAR(50)
			,[CLASS_DESCRIPTION] VARCHAR(250)
			,[CLASS_TYPE] VARCHAR(50)
			,[CREATED_BY] VARCHAR(50)
			,[CREATED_DATETIME] DATETIME
			,[LAST_UPDATED_BY] VARCHAR(50)
			,[LAST_UPDATED] DATETIME
			,[PRIORITY] INT
		);
  --
	DECLARE	@COMPATIBLE_CLASSES TABLE ([CLASS_ID] INT);

  --
	DECLARE	@TEMP_LICENSE_WITH_PROJECT TABLE (
			[LICENSE_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(150)
			,[PROJECT_ID] UNIQUEIDENTIFIER
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[BATCH] VARCHAR(50)
			,[DATE_EXPIRATION] DATE
		);
  --
	DECLARE
		@ALLOW_STORAGE INT
		,@HAS_ACCESS INT
		,@MESSAGE VARCHAR(500)
		,@WAREHOUSE_PARENT VARCHAR(25)
		,@WAREHOUSE_TO VARCHAR(25)
		,@IS_LOCATION_IN_WARAHOUSE_TO INT = 1
		,@RESULT INT = -1
		,@CURRENT_CLASS INT = 0
		,@COMPATIBLE INT = 1
		,@ERRORCODE INT = 0
		,@FORCE_LOCATION_FROM_STATUS INT = 0
		,@STATUS VARCHAR(100) = ''
		,@DIFFERENT_LOCATION INT = 0
		,@STATUS_LOCATION VARCHAR(50) = ''
		,@COUNT_INVENTORY_LOCKED_BY_INTERFACES INT = 0
		,@ALLOW_FAST_PICKING INT = 0
		,@COUNT_DOCUMENTS_NOT_SEND_ERP INT = 0
		,@COMPATIBLE_CLASS_BY_SLOTTING_ZONE INT = 1
		,@PARAMETER_USE_SUB_FAMILY VARCHAR(50);

  -- ------------------------------------------------------------------------------------
  -- Obtengo el parámetro de sub familias y se lo asigno a la variable
  -- ------------------------------------------------------------------------------------
	SELECT  @PARAMETER_USE_SUB_FAMILY = value
    FROM    [wms].[OP_WMS_PARAMETER]
    WHERE   [GROUP_ID] = 'MATERIAL_SUB_FAMILY'
    AND [PARAMETER_ID] = 'USE_MATERIAL_SUB_FAMILY';

  -- ------------------------------------------------------------------------------------
  -- Obtiene las bodegas con permiso del usuario
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @WAREHOUSE
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_USER_CD] @LOGIN = @LOGIN;

  -- ------------------------------------------------------------------------------------
  -- Obtiene si existe la ubicacion, si se puede almacenar en ella y si tiene permiso
  -- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@ALLOW_STORAGE = [S].[ALLOW_STORAGE]
		,@HAS_ACCESS = CASE	WHEN [W].[WAREHOUSE_BY_USER_ID] IS NULL
							THEN 0
							ELSE 1
						END
		,@WAREHOUSE_PARENT = [S].[WAREHOUSE_PARENT]
		,@ALLOW_FAST_PICKING = [S].[ALLOW_FAST_PICKING]
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [S]
	LEFT JOIN @WAREHOUSE [W] ON ([S].[WAREHOUSE_PARENT] = [W].[WAREHOUSE_ID])
	WHERE
		[S].[LOCATION_SPOT] = @LOCATION_SPOT;

  -- ------------------------------------------------------------------------------------
  -- Obtiene si es ubicacion de la bodega destino
  -- ------------------------------------------------------------------------------------
	SELECT
		@IS_LOCATION_IN_WARAHOUSE_TO = CASE	WHEN [TH].[WAREHOUSE_TO] = @WAREHOUSE_PARENT
											THEN 1
											ELSE 0
										END
		,@WAREHOUSE_TO = [TH].[WAREHOUSE_TO]
	FROM
		[wms].[OP_WMS_TASK_LIST] [T]
	INNER JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH] ON ([TH].[TRANSFER_REQUEST_ID] = [T].[TRANSFER_REQUEST_ID])
	WHERE
		[T].[SERIAL_NUMBER] = @TASK_ID;


	IF @ALLOW_STORAGE IS NOT NULL
		AND @ALLOW_FAST_PICKING = 1
	BEGIN

    -- ------------------------------------------------------------------------------------
    -- obtengo cuantos materiales de la licencia estan bloqueados por interfaces
    -- ------------------------------------------------------------------------------------

		SELECT
			@COUNT_INVENTORY_LOCKED_BY_INTERFACES = COUNT(1)
		FROM
			[wms].[OP_WMS_INV_X_LICENSE]
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND [LOCKED_BY_INTERFACES] = 1;

    -- ------------------------------------------------------------------------------------
    -- valido que si la recepcion se debe enviar a SAP y hay un documento amarrado a la tarea
    -- que no ha sido confirmado no permitir usar
    -- ------------------------------------------------------------------------------------
		SELECT
			@COUNT_DOCUMENTS_NOT_SEND_ERP = COUNT(1)
		FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
		WHERE
			[H].[TASK_ID] = @TASK_ID
			AND [H].[IS_POSTED_ERP] <= 0;
	END;


	IF ( @PARAMETER_USE_SUB_FAMILY IS NULL OR @PARAMETER_USE_SUB_FAMILY = '0')
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- Obtiene las clases en la licencia actual
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @LICENSE_CLASSES
		SELECT
			[CLASS_ID]
			,[CLASS_NAME]
			,[CLASS_DESCRIPTION]
			,[CLASS_TYPE]
			,[CREATED_BY]
			,[CREATED_DATETIME]
			,[LAST_UPDATED_BY]
			,[LAST_UPDATED]
			,[PRIORITY]
		FROM
			[wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@LICENSE_ID);
		
  -- ------------------------------------------------------------------------------------
  -- Obtiene las clases en la ubicacion destino
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @LOCATION_CLASSES
		SELECT
			[CLASS_ID]
			,[CLASS_NAME]
			,[CLASS_DESCRIPTION]
			,[CLASS_TYPE]
			,[CREATED_BY]
			,[CREATED_DATETIME]
			,[LAST_UPDATED_BY]
			,[LAST_UPDATED]
			,[PRIORITY]
		FROM
			[wms].[OP_WMS_FN_GET_CLASSES_BY_LOCATION](@LOCATION_SPOT);

  -- ------------------------------------------------------------------------------------
  -- Obtiene las clases compatibles con la licencia
  -- ------------------------------------------------------------------------------------

		INSERT	INTO @COMPATIBLE_CLASSES
		SELECT
			[CLASS_ID]
		FROM
			[wms].[OP_WMS_CLASS];
	  --
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@LICENSE_CLASSES )
		BEGIN
			SELECT TOP 1
				@CURRENT_CLASS = [CLASS_ID]
			FROM
				@LICENSE_CLASSES;
		--
			DELETE
				[CC]
			FROM
				@COMPATIBLE_CLASSES [CC]
			LEFT JOIN [wms].[OP_WMS_CLASS_ASSOCIATION] [CA] ON [CC].[CLASS_ID] = [CA].[CLASS_ASSOCIATED_ID]
												AND [CA].[CLASS_ID] = @CURRENT_CLASS
			WHERE
				[CA].[CLASS_ID] IS NULL;
		--
			DELETE FROM
				@LICENSE_CLASSES
			WHERE
				[CLASS_ID] = @CURRENT_CLASS;
		END;
	  --
		INSERT	INTO @COMPATIBLE_CLASSES
		SELECT
			[CLASS_ID]
		FROM
			[wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@LICENSE_ID);

  -- ------------------------------------------------------------------------------------
  -- Valida si las sub clases de la licencia son compatibles con las de la ubicacion
  -- ------------------------------------------------------------------------------------
		DELETE
			[LC]
		FROM
			@LOCATION_CLASSES [LC]
		INNER JOIN @COMPATIBLE_CLASSES [C] ON [LC].[CLASS_ID] = [C].[CLASS_ID];

		SELECT TOP 1
			@COMPATIBLE = 0
		FROM
			@LOCATION_CLASSES;

	END
	ELSE
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- Obtiene las sub clases en la licencia actual
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @LICENSE_CLASSES
		SELECT
			[SUB_CLASS_ID]
			,[SUB_CLASS_NAME]
			,''
			,''
			,[CREATED_BY]
			,[CREATED_DATETIME]
			,[LAST_UPDATED_BY]
			,[LAST_UPDATED]
			,0
		FROM
			[wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LICENSE](@LICENSE_ID);
		
  -- ------------------------------------------------------------------------------------
  -- Obtiene las sub clases en la ubicacion destino
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @LOCATION_CLASSES
		SELECT
			[SUB_CLASS_ID]
			,[SUB_CLASS_NAME]
			,''
			,''
			,[CREATED_BY]
			,[CREATED_DATETIME]
			,[LAST_UPDATED_BY]
			,[LAST_UPDATED]
			,0
		FROM
			[wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LOCATION](@LOCATION_SPOT);
	END
  -- ------------------------------------------------------------------------------------
  -- Valida las ubicaciones obligatorias por estados
  -- ------------------------------------------------------------------------------------

	SELECT
		@FORCE_LOCATION_FROM_STATUS = CASE	WHEN MIN([ML].[STATUS_CODE]) <> MAX([ML].[STATUS_CODE])
											THEN 0
											ELSE 1
										END
		,@STATUS = MAX([ML].[STATUS_CODE])
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
	INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [ML] ON [ML].[STATUS_ID] = [IL].[STATUS_ID]
	WHERE
		[IL].[LICENSE_ID] = @LICENSE_ID;

	IF @FORCE_LOCATION_FROM_STATUS = 1
	BEGIN
		SELECT
			@DIFFERENT_LOCATION = CASE	WHEN [SPARE3] <> ''
											AND [SPARE3] IS NOT NULL
											AND [SPARE3] <> @LOCATION_SPOT
										THEN 1
										ELSE 0
									END
			,@STATUS_LOCATION = [SPARE3]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS]
		WHERE
			[PARAM_TYPE] = 'ESTADO'
			AND [PARAM_GROUP] = 'ESTADOS'
			AND [PARAM_NAME] = @STATUS;

	END;
  -- ------------------------------------------------------------------------------------
  -- validacion en ubicacion de fast picking, esta validacion revisa que no se pueda ubicar una 
  -- licencia en una ubicacion de fast picking cuando para algún material no coinciden las propiedades de lote y fec expiracion,tono, calibre
  -- ------------------------------------------------------------------------------------
	DECLARE
		@PROPERTIES_OF_MATERIALS_DOESNT_MATCH INT = 0
		,@MESSAGE_PROPERTY VARCHAR(300)
		,@ERRORCODE_IN_PROPERTIES INT = 0;
	IF @ALLOW_FAST_PICKING = 1
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- obtengo todos los productos en la licencia que quiero ubicar que tengan las propiedades de tono y calibre y/o lote/fecha expiracion
    -- ------------------------------------------------------------------------------------
		SELECT
			[L].[MATERIAL_ID]
			,[L].[DATE_EXPIRATION]
			,[L].[BATCH]
			,[L].[PROJECT_ID]
			,[SML].[STATUS_CODE]
			,[TCM].[TONE]
			,[TCM].[CALIBER]
			,[M].[HANDLE_TONE]
			,[M].[HANDLE_CALIBER]
			,[M].[BATCH_REQUESTED]
		INTO
			[#MATERIALS_IN_LICENSE]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [L]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [L].[MATERIAL_ID] = [M].[MATERIAL_ID]
		INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [L].[STATUS_ID]
		LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON [L].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID]
		WHERE
			[L].[LICENSE_ID] = @LICENSE_ID;

		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							[#MATERIALS_IN_LICENSE] ))
		BEGIN
			DECLARE
				@MATERIAL_ID VARCHAR(50)
				,@DATE_EXPIRATION DATE
				,@BATCH VARCHAR(50)
				,@STATUS_CODE VARCHAR(50)
				,@TONE VARCHAR(20)
				,@CALIBER VARCHAR(20)
				,@HANDLE_TONE INT
				,@HANDLE_CALIBER INT
				,@BATCH_REQUESTED [NUMERIC](18)
				,@PROJECT_ID UNIQUEIDENTIFIER = NULL;
			SELECT TOP 1
				@MATERIAL_ID = [MATERIAL_ID]
				,@DATE_EXPIRATION = [DATE_EXPIRATION]
				,@BATCH = [BATCH]
				,@STATUS_CODE = [STATUS_CODE]
				,@TONE = [TONE]
				,@CALIBER = [CALIBER]
				,@HANDLE_TONE = [HANDLE_TONE]
				,@HANDLE_CALIBER = [HANDLE_CALIBER]
				,@BATCH_REQUESTED = [BATCH_REQUESTED]
				,@PROJECT_ID = [PROJECT_ID]
			FROM
				[#MATERIALS_IN_LICENSE];

      -- ------------------------------------------------------------------------------------
      -- valido si en la ubicacion ya existe el material ubicado pero con distinto lote y fecha de expiracion
      -- ------------------------------------------------------------------------------------
			IF @BATCH_REQUESTED = 1
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_INV_X_LICENSE] [IL]
								INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
								INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
								WHERE
									[S].[LOCATION_SPOT] = @LOCATION_SPOT
									AND [IL].[MATERIAL_ID] = @MATERIAL_ID
									AND (
											[IL].[BATCH] <> @BATCH
											OR [IL].[DATE_EXPIRATION] <> @DATE_EXPIRATION
										) )
			BEGIN
				SET @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1;
				SET @ERRORCODE_IN_PROPERTIES = 5000;
				SET @MESSAGE_PROPERTY = CONCAT('No se puede ubicar porque existe un NÚMERO DE LOTE y una FECHA DE EXPIRACIÓN diferentes almacenados para el material ',
											@MATERIAL_ID);
				BREAK;

			END;


      -- ------------------------------------------------------------------------------------
      -- valido si en la ubicacion ya existe el material ubicado pero con distinto TONO
      -- ------------------------------------------------------------------------------------
			IF @HANDLE_TONE = 1
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_INV_X_LICENSE] [IL]
								INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
								INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
								INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON [TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
								WHERE
									[S].[LOCATION_SPOT] = @LOCATION_SPOT
									AND [IL].[MATERIAL_ID] = @MATERIAL_ID
									AND [TCM].[TONE] <> @TONE )
			BEGIN
				SET @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1;
				SET @ERRORCODE_IN_PROPERTIES = 5001;
				SET @MESSAGE_PROPERTY = CONCAT('No se puede localizar porque existe un TONO diferente almacenado para el material',
											@MATERIAL_ID);
				BREAK;
			END;

      -- ------------------------------------------------------------------------------------
      -- valido si en la ubicacion ya existe el material ubicado pero con distinto CALIBRE
      -- ------------------------------------------------------------------------------------

			IF @HANDLE_CALIBER = 1
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_INV_X_LICENSE] [IL]
								INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
								INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
								INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON [TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
								WHERE
									[S].[LOCATION_SPOT] = @LOCATION_SPOT
									AND [IL].[MATERIAL_ID] = @MATERIAL_ID
									AND [TCM].[CALIBER] <> @CALIBER )
			BEGIN
				SET @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1;
				SET @ERRORCODE_IN_PROPERTIES = 5002;
				SET @MESSAGE_PROPERTY = CONCAT('No se puede localizar porque existe un CALIBRE diferente almacenado para el material ',
											@MATERIAL_ID);
				BREAK;
			END;

      -- ------------------------------------------------------------------------------------
      -- valido si en la ubicacion ya existe el material ubicado pero con distinto ESTADO
      -- ------------------------------------------------------------------------------------
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_INV_X_LICENSE] [IL]
						INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
						INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
						INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
						WHERE
							[S].[LOCATION_SPOT] = @LOCATION_SPOT
							AND [IL].[MATERIAL_ID] = @MATERIAL_ID
							AND ([SML].[STATUS_CODE] <> @STATUS_CODE) )
			BEGIN
				SET @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1;
				SET @ERRORCODE_IN_PROPERTIES = 5003;
				SET @MESSAGE_PROPERTY = CONCAT('No se puede localizar porque existe un ESTADO diferente almacenado para el material ',
											@MATERIAL_ID);
				BREAK;

			END;


			-- ------------------------------------------------------------------------------------
    -- SI YA EXISTE UNA LICENCIA CON UN PROYECTO ASOCIADO Y ES DIFERENTE AL PROCESANDO NO PERMITE UBICARLO.
    -- ------------------------------------------------------------------------------------
			IF @PROJECT_ID IS NOT NULL
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_INV_X_LICENSE] [IXL]
								INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IXL].[LICENSE_ID] = [L].[LICENSE_ID])
								INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION])
								WHERE
									[SS].[LOCATION_SPOT] = @LOCATION_SPOT
									AND [IXL].[MATERIAL_ID] = @MATERIAL_ID
									AND (
											[IXL].[PROJECT_ID] <> @PROJECT_ID
											OR [IXL].[PROJECT_ID] IS NULL
										)
									AND [IXL].[QTY] > 0 )
			BEGIN
				SET @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1;
				SET @ERRORCODE_IN_PROPERTIES = 5004;
				SET @MESSAGE_PROPERTY = CONCAT('No se puede localizar la licencia porque ya existe almacenado el material: ',
											@MATERIAL_ID,
											' de un proyecto diferente.');
				BREAK;
			END;

			IF @PROJECT_ID IS NULL
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_INV_X_LICENSE] [IXL]
								INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IXL].[LICENSE_ID] = [L].[LICENSE_ID])
								INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION])
								WHERE
									[SS].[LOCATION_SPOT] = @LOCATION_SPOT
									AND [IXL].[MATERIAL_ID] = @MATERIAL_ID
									AND [IXL].[QTY] > 0 )
			BEGIN
				SET @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1;
				SET @ERRORCODE_IN_PROPERTIES = 5005;
				SET @MESSAGE_PROPERTY = CONCAT('No se puede localizar la licencia porque ya existe almacenado el material: ',
											@MATERIAL_ID);
				BREAK;
			END;	

			DELETE FROM
				[#MATERIALS_IN_LICENSE]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID;
		END;

	END;

  -- ------------------------------------------------------------------------------------
  -- Valida si la ubicacion esta configurado para mandatoria, esto quiere decir de que si esta esta configurado coomo si mandatorio solo las clases configuradas puden ubicarse en esta.
  -- ------------------------------------------------------------------------------------

  -- ------------------------------------------------------------------------------------
  -- Obtenemos la zona y la bodega para verficar si esta es mandatoria
  -- ------------------------------------------------------------------------------------
	DECLARE
		@ZONE VARCHAR(25)
		,@WAREHPUSE_CODE VARCHAR(25)
		,@IS_MANDATORY INT = NULL;

	SELECT TOP 1
		@ZONE = [SS].[ZONE]
		,@WAREHPUSE_CODE = @WAREHOUSE_PARENT
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [SS]
	WHERE
		[SS].[LOCATION_SPOT] = @LOCATION_SPOT;

	IF ( @PARAMETER_USE_SUB_FAMILY IS NULL OR @PARAMETER_USE_SUB_FAMILY = '0')
  -- ------------------------------------------------------------------------------------
  -- Obtenemos si es mandatoria
  -- ------------------------------------------------------------------------------------
  		SELECT TOP 1
			@IS_MANDATORY = [SZ].[MANDATORY]
		FROM
			[wms].[OP_WMS_SLOTTING_ZONE] [SZ]
		INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC] ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
		WHERE
			[SZ].[WAREHOUSE_CODE] = @WAREHPUSE_CODE
			AND [SZ].[ZONE] = @ZONE;
	ELSE
  -- ------------------------------------------------------------------------------------
  -- Obtenemos si es mandatoria mediante las sub clases
  -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@IS_MANDATORY = [SZ].[MANDATORY]
		FROM
			[wms].[OP_WMS_SLOTTING_ZONE] [SZ]
		INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SZC] ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
		WHERE
			[SZ].[WAREHOUSE_CODE] = @WAREHPUSE_CODE
			AND [SZ].[ZONE] = @ZONE;


  -- ------------------------------------------------------------------------------------
  -- Lo validamos
  -- ------------------------------------------------------------------------------------
	IF @IS_MANDATORY IS NOT NULL
	BEGIN

    -- ------------------------------------------------------------------------------------
    -- Validamos si es mandatorio
    -- ------------------------------------------------------------------------------------
		IF @IS_MANDATORY = 1
		BEGIN
      -- ------------------------------------------------------------------------------------
      -- Si es mandatorio declaramos las varibales necesarias
      -- ------------------------------------------------------------------------------------
			DECLARE	@LICENSE_CLASSES_FOR_SLOTTING TABLE (
					[CLASS_ID] INT
					,[CLASS_NAME] VARCHAR(50)
					,[CLASS_DESCRIPTION] VARCHAR(250)
					,[CLASS_TYPE] VARCHAR(50)
					,[CREATED_BY] VARCHAR(50)
					,[CREATED_DATETIME] DATETIME
					,[LAST_UPDATED_BY] VARCHAR(50)
					,[LAST_UPDATED] DATETIME
					,[PRIORITY] INT
				);

			DECLARE	@SLOTTING_ZONE_CLASSES TABLE ([CLASS_ID]
											INT);

			IF ( @PARAMETER_USE_SUB_FAMILY IS NULL OR @PARAMETER_USE_SUB_FAMILY = '0')
			BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtenemos las clases de la licencia
      -- ------------------------------------------------------------------------------------

				INSERT	INTO @LICENSE_CLASSES_FOR_SLOTTING
				SELECT
					[CLASS_ID]
					,[CLASS_NAME]
					,[CLASS_DESCRIPTION]
					,[CLASS_TYPE]
					,[CREATED_BY]
					,[CREATED_DATETIME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,[PRIORITY]
				FROM
					[wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@LICENSE_ID);

      -- ------------------------------------------------------------------------------------
      -- Obtenemos las clases de la zona
      -- ------------------------------------------------------------------------------------

				INSERT	INTO @SLOTTING_ZONE_CLASSES
						(
							[CLASS_ID]
						)
				SELECT
					[SZC].[CLASS_ID]
				FROM
					[wms].[OP_WMS_SLOTTING_ZONE] [SZ]
				INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC] ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
				WHERE
					[SZ].[WAREHOUSE_CODE] = @WAREHPUSE_CODE
					AND [SZ].[ZONE] = @ZONE;
			END
			ELSE
			BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtenemos las sub clases de la licencia
      -- ------------------------------------------------------------------------------------

				INSERT	INTO @LICENSE_CLASSES_FOR_SLOTTING
				SELECT
					[SUB_CLASS_ID]
					,[SUB_CLASS_NAME]
					,''
					,''
					,[CREATED_BY]
					,[CREATED_DATETIME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,0
				FROM
					[wms].[OP_WMS_FN_GET_SUB_CLASSES_BY_LICENSE](@LICENSE_ID);

      -- ------------------------------------------------------------------------------------
      -- Obtenemos las sub clases de la zona
      -- ------------------------------------------------------------------------------------

				INSERT	INTO @SLOTTING_ZONE_CLASSES
						(
							[CLASS_ID]
						)
				SELECT
					[SZC].[SUB_CLASS_ID]
				FROM
					[wms].[OP_WMS_SLOTTING_ZONE] [SZ]
				INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SZC] ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
				WHERE
					[SZ].[WAREHOUSE_CODE] = @WAREHPUSE_CODE
					AND [SZ].[ZONE] = @ZONE;
			END

      -- ------------------------------------------------------------------------------------
      -- Validamos si todas las clases de la licencia son compatibles
      -- ------------------------------------------------------------------------------------
			SET @COMPATIBLE_CLASS_BY_SLOTTING_ZONE = (SELECT TOP 1
											0
											FROM
											@LICENSE_CLASSES_FOR_SLOTTING [LC]
											LEFT JOIN @SLOTTING_ZONE_CLASSES [SZC] ON ([LC].[CLASS_ID] = [SZC].[CLASS_ID])
											WHERE
											[SZC].[CLASS_ID] IS NULL);


		END;
	END;


  -- ------------------------------------------------------------------------------------
  -- Obtiene el resultado y el mensaje
  -- ------------------------------------------------------------------------------------
	SELECT
		@MESSAGE = CASE	WHEN @COMPATIBLE = 0
						THEN 'Las clases de la licencia no son compatibles con las clases de la ubicacion actual'
						WHEN @ALLOW_STORAGE IS NULL
						THEN 'Ubicación  "' + @LOCATION_SPOT
								+ '" no existe'
						WHEN @ALLOW_STORAGE = 0
						THEN 'Ubicación "' + @LOCATION_SPOT
								+ '" no esta disponible para almacenaje'
						WHEN @HAS_ACCESS = 0
						THEN 'Usuario no tiene acceso a la ubicación '
								+ @LOCATION_SPOT
						WHEN @IS_LOCATION_IN_WARAHOUSE_TO = 0
						THEN 'La ubicación debe estar en la bodega '
								+ @WAREHOUSE_TO
								+ ' de la solicitud de transferencia'
						WHEN @DIFFERENT_LOCATION = 1
						THEN 'La ubicacion destino no corresponde a la ubicacion configurada en el estado'
						WHEN @COUNT_INVENTORY_LOCKED_BY_INTERFACES > 0
						THEN 'No se puede ubicar en ubicación de fast picking porque hay inventario bloqueado por interfaces'
						WHEN @COUNT_DOCUMENTS_NOT_SEND_ERP > 0
						THEN 'No se puede ubicar en ubicación de fast picking porque la tarea asociada no ha sido enviada a ERP'
						WHEN @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1
						THEN @MESSAGE_PROPERTY
						WHEN @COMPATIBLE_CLASS_BY_SLOTTING_ZONE = 0
						THEN 'La ubicación no puede aceptar todas las clases de la licencia, por que la zona esta configurado como mandatorio '
						ELSE 'OK'
					END
		,@ERRORCODE = CASE	WHEN @COMPATIBLE = 0 THEN 1105
							WHEN @ALLOW_STORAGE IS NULL
							THEN 1104
							WHEN @ALLOW_STORAGE = 0
							THEN 1106
							WHEN @HAS_ACCESS = 0 THEN 1107
							WHEN @IS_LOCATION_IN_WARAHOUSE_TO = 0
							THEN 1108
							WHEN @DIFFERENT_LOCATION = 1
							THEN 1117
							WHEN @COUNT_INVENTORY_LOCKED_BY_INTERFACES > 0
							THEN 3052
							WHEN @COUNT_DOCUMENTS_NOT_SEND_ERP > 0
							THEN 3053
							WHEN @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1
							THEN @ERRORCODE_IN_PROPERTIES
							WHEN @COMPATIBLE_CLASS_BY_SLOTTING_ZONE = 0
							THEN 6000
							ELSE 0
						END
		,@RESULT = CASE	WHEN @ALLOW_STORAGE IS NULL
								OR @ALLOW_STORAGE = 0
								OR @HAS_ACCESS = 0
								OR @IS_LOCATION_IN_WARAHOUSE_TO = 0
								OR @COMPATIBLE = 0
								OR @DIFFERENT_LOCATION = 1
								OR @COUNT_INVENTORY_LOCKED_BY_INTERFACES > 0
								OR @COUNT_DOCUMENTS_NOT_SEND_ERP > 0
								OR @PROPERTIES_OF_MATERIALS_DOESNT_MATCH = 1
								OR @COMPATIBLE_CLASS_BY_SLOTTING_ZONE = 0
						THEN -1
						ELSE 1
					END;

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
	SELECT
		@RESULT AS [Resultado]
		,@MESSAGE [Mensaje]
		,@ERRORCODE [Codigo]
		,@STATUS_LOCATION [DbData];
END;