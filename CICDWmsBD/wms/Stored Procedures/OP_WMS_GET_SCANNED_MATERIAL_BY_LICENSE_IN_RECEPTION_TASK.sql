-- =============================================
-- Autor:                pablo.aguilar
-- Fecha de Creacion:     2017-08-31 @ NEXUS-Team Sprint@Command&Conquer
-- Description:            Sp que valida el barcode escaneado, considerando si es un traslado entre bodegas. 

-- Modificacion: 2017-09-13 @ Reborn-Team Sprint@Collin
-- Autor:        rudi.garcia
-- Description:  Se agregaron los campos de tono y calibre

-- Modificacion 12/12/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se valida, si es una recepcion desde una devolucion que el material exista en ella.

-- Modificacion 2/2/2018 @ Reborn-Team Sprint Trotzdem
					-- rodrigo.gomez
					-- Se agrega validacion para las clases


-- Modificacion 23-Feb-2018 @ Reborn-Team Sprint Ulrich
					-- rudi.garcia
					-- Se agrega la validacion de material

-- Modificacion 5/29/2018 @ GTEAM-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Se agrega propiedad de QUALITY CONTROL

-- Modificacion 5/30/2018 @ GFORCE-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Se agrega unidad de medida

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180726 GForce@FocaMonje 
-- Description:			    se agrega validacion de materiales para recepcion dirigida para recepcion por erp
--							se valida siempre y cuando el parametro diga que se tiene que validar

/*
-- Ejemplo de Ejecucion:
               EXEC [wms].[OP_WMS_GET_SCANNED_BARCODE_FOR_LICENSE_IN_RECEPTION_TASK] @BARCODE_ID = 'autovanguard/VAA1001'
                                                                         ,@CLIENT_OWNER = 'wms_ALMACENADORA'
                                                                         ,@LICENSE_ID = 367930
                                                                         ,@TASK_ID = 476464
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SCANNED_MATERIAL_BY_LICENSE_IN_RECEPTION_TASK] (
		@BARCODE_ID VARCHAR(25)
		,@CLIENT_OWNER VARCHAR(25)
		,@LICENSE_ID NUMERIC
		,@TASK_ID NUMERIC
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MATERIAL TABLE (
			[CLIENT_OWNER] [VARCHAR](25) NOT NULL
			,[MATERIAL_ID] [VARCHAR](50) NOT NULL
			,[BARCODE_ID] [VARCHAR](25) NOT NULL
			,[ALTERNATE_BARCODE] [VARCHAR](25) NULL
			,[MATERIAL_NAME] [VARCHAR](200) NOT NULL
			,[SHORT_NAME] [VARCHAR](200) NOT NULL
			,[VOLUME_FACTOR] [DECIMAL](18, 4) NULL
			,[MATERIAL_CLASS] [VARCHAR](25) NULL
			,[HIGH] [NUMERIC](18, 3) NULL
										DEFAULT ((0))
			,[LENGTH] [NUMERIC](18, 3) NULL
										DEFAULT ((0))
			,[WIDTH] [NUMERIC](18, 3) NULL
										DEFAULT ((0))
			,[MAX_X_BIN] [NUMERIC](18, 0) NULL
			,[SCAN_BY_ONE] [NUMERIC](18, 0) NULL
			,[REQUIRES_LOGISTICS_INFO] [NUMERIC](18, 0) NULL
			,[WEIGTH] [DECIMAL](18, 6) NULL
			,[IMAGE_1] [IMAGE] NULL
			,[IMAGE_2] [IMAGE] NULL
			,[IMAGE_3] [IMAGE] NULL
			,[LAST_UPDATED] [DATETIME] NULL
			,[LAST_UPDATED_BY] [VARCHAR](25) NULL
			,[IS_CAR] [NUMERIC](18, 0) NULL
										DEFAULT ((0))
			,[MT3] [NUMERIC](18, 2) NULL
			,[BATCH_REQUESTED] [NUMERIC](18, 0) NULL
			,[SERIAL_NUMBER_REQUESTS] [NUMERIC](18, 0) NULL
			,[IS_MASTER_PACK] [INT] NOT NULL
									DEFAULT ((0))
			,[ERP_AVERAGE_PRICE] [NUMERIC](18, 6) NOT NULL
											DEFAULT ((0.0))
			,[WEIGHT_MEASUREMENT] [VARCHAR](50) NULL
			,[EXPLODE_IN_RECEPTION] [INT] NOT NULL
											DEFAULT ((0))
			,[HANDLE_TONE] [INT] NOT NULL
									DEFAULT ((0))
			,[HANDLE_CALIBER] [INT] NOT NULL
									DEFAULT ((0))
			,[QUALITY_CONTROL] [INT] DEFAULT (0)
										NOT NULL
			,[MEASUREMENT_UNIT] VARCHAR(50)
			,[MEASUREMENT_QTY] INT DEFAULT (1)
									NOT NULL
			,[EXPIRATION_TOLERANCE] INT DEFAULT(0) 
		); 
	--
	DECLARE
		@IS_GLOBAL_CLIENT AS INT = 0
		,@RECEPTION_HEADER_ID INT = 0
		,@MATERIAL_CLASS INT = 0
		,@CURRENT_CLASS INT = 0
		,@COMPANY_CODE VARCHAR(25) = NULL;
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
	DECLARE	@COMPATIBLE_CLASSES TABLE ([CLASS_ID] INT);

	SELECT TOP 1
		@COMPANY_CODE = [COMPANY_CODE]
	FROM
		[wms].[OP_SETUP_COMPANY]; 
	
	IF (@COMPANY_CODE = @CLIENT_OWNER)
	BEGIN
		SELECT TOP 1
			@CLIENT_OWNER = [M].[CLIENT_OWNER]
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
		WHERE
			(
				[M].[BARCODE_ID] = @BARCODE_ID
				OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
				OR [UMM].[BARCODE] = @BARCODE_ID
				OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
			);
	END;
	-- ------------------------------------------------------------------------------------
	-- Valida que si existe la material.
	-- ------------------------------------------------------------------------------------
	DECLARE	@MATERIAL_ID VARCHAR(50) = NULL;

	SELECT TOP 1
		@MATERIAL_ID = [M].[MATERIAL_ID]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
	WHERE
		(
			[M].[BARCODE_ID] = @BARCODE_ID
			OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
			OR [UMM].[BARCODE] = @BARCODE_ID
			OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
		);

	IF @MATERIAL_ID IS NULL
	BEGIN
		DECLARE	@MESSAGE_ERROR VARCHAR(100);

		SELECT
			@MESSAGE_ERROR = CONCAT('El material escaneado ',
									@BARCODE_ID,
									' no existe.');
		RAISERROR (@MESSAGE_ERROR, 16, 1);
		RETURN;
	END;
	-- ------------------------------------------------------------------------------------
	-- validacion de recepcion dirigida por ordenes de compra
	-- ------------------------------------------------------------------------------------
	DECLARE	@VALIDA_DOCUMENTO_RECEPCION INT = 0;
	DECLARE	@SOURCE_RECEPTION VARCHAR(20) = 'PURCHASE_ORDER';
	DECLARE	@SOURCE_TRANSFER VARCHAR(20) = 'ERP_TRANSFER';
	DECLARE	@SOURCE_INVOICE VARCHAR(20) = 'INVOICE';

	SELECT TOP 1
		@VALIDA_DOCUMENTO_RECEPCION = [NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_GROUP] = 'RECEPCION'
		AND [PARAM_NAME] = 'VALIDA_RECEPCION_DIRIGIDA';

	IF @VALIDA_DOCUMENTO_RECEPCION = 0
	BEGIN
		SET @SOURCE_RECEPTION = 'INVOICE';--cuando el parámetro es 0 debe hacer el flujo normal
	END;

	IF EXISTS 
	( 
		SELECT TOP 1
			1
		FROM
			[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
		WHERE
			[RH].[TASK_ID] = @TASK_ID
			AND (
					[RH].[SOURCE] = @SOURCE_RECEPTION
					OR [RH].[SOURCE] = @SOURCE_INVOICE
					OR [RH].[SOURCE] = @SOURCE_TRANSFER
				) 
	)
	BEGIN
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD]
						INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RD].[MATERIAL_ID]
						LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
						WHERE
							(
								[M].[BARCODE_ID] = @BARCODE_ID
								OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
								OR [UMM].[BARCODE] = @BARCODE_ID
								OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
							)
							AND EXISTS ( SELECT
											1
											FROM
											[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
											WHERE
											[RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
											AND [RH].[TASK_ID] = @TASK_ID ) )
		BEGIN
			RAISERROR(N'El material escaneado no pertenece al documento.', 16,1);
		END;
	END;

    
	-- ------------------------------------------------------------------------------------
	-- Valida las clases
	-- ------------------------------------------------------------------------------------

	SELECT TOP 1
		@MATERIAL_CLASS = [MATERIAL_CLASS]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
	WHERE
		(
			[BARCODE_ID] = @BARCODE_ID
			OR [ALTERNATE_BARCODE] = @BARCODE_ID
			OR [UMM].[BARCODE] = @BARCODE_ID
			OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
		)
		AND [CLIENT_OWNER] = @CLIENT_OWNER;

	-- ------------------------------------------------------------------------------------
	-- Valida la compatibilidad de clases
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
	--
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
	--
	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						@COMPATIBLE_CLASSES
					WHERE
						[CLASS_ID] = @MATERIAL_CLASS )
	BEGIN
		RAISERROR(N'La clase del material no es compatible con las clases actualmente en la licencia.',16,1);
		RETURN;
	END;

	-- ------------------------------------------------------------------------------------
	-- Valida si es de una solicitud de traslado
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@IS_GLOBAL_CLIENT = 1
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
	WHERE
		[TASK_ID] = @TASK_ID
		AND (
				[IS_FROM_WAREHOUSE_TRANSFER] = 1
				OR (
					[TYPE] = 'DEVOLUCION_FACTURA'
					AND [IS_FROM_ERP] = 0
					)
			); 

		
	--
	IF @IS_GLOBAL_CLIENT = 1
	BEGIN
		SET @CLIENT_OWNER = NULL;
		--
		SELECT TOP 1
			@CLIENT_OWNER = [M].[CLIENT_OWNER]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [IL].[MATERIAL_ID] = [M].[MATERIAL_ID]
		WHERE
			[IL].[LICENSE_ID] = @LICENSE_ID;
	END;

	-- ------------------------------------------------------------------------------------
	-- Inserta el material a utilizar
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @MATERIAL
			(
				[CLIENT_OWNER]
				,[MATERIAL_ID]
				,[BARCODE_ID]
				,[ALTERNATE_BARCODE]
				,[MATERIAL_NAME]
				,[SHORT_NAME]
				,[VOLUME_FACTOR]
				,[MATERIAL_CLASS]
				,[HIGH]
				,[LENGTH]
				,[WIDTH]
				,[MAX_X_BIN]
				,[SCAN_BY_ONE]
				,[REQUIRES_LOGISTICS_INFO]
				,[WEIGTH]
				,[IMAGE_1]
				,[IMAGE_2]
				,[IMAGE_3]
				,[LAST_UPDATED]
				,[LAST_UPDATED_BY]
				,[IS_CAR]
				,[MT3]
				,[BATCH_REQUESTED]
				,[SERIAL_NUMBER_REQUESTS]
				,[IS_MASTER_PACK]
				,[ERP_AVERAGE_PRICE]
				,[WEIGHT_MEASUREMENT]
				,[EXPLODE_IN_RECEPTION]
				,[HANDLE_TONE]
				,[HANDLE_CALIBER]
				,[QUALITY_CONTROL]
				,[MEASUREMENT_UNIT]
				,[MEASUREMENT_QTY]
				,[EXPIRATION_TOLERANCE]
  			)
	SELECT TOP 1
		[M].[CLIENT_OWNER]
		,[M].[MATERIAL_ID]
		,[M].[BARCODE_ID]
		,[M].[ALTERNATE_BARCODE]
		,[M].[MATERIAL_NAME]
		,[M].[SHORT_NAME]
		,[M].[VOLUME_FACTOR]
		,[M].[MATERIAL_CLASS]
		,[M].[HIGH]
		,[M].[LENGTH]
		,[M].[WIDTH]
		,[M].[MAX_X_BIN]
		,[M].[SCAN_BY_ONE]
		,[M].[REQUIRES_LOGISTICS_INFO]
		,[M].[WEIGTH]
		,[M].[IMAGE_1]
		,[M].[IMAGE_2]
		,[M].[IMAGE_3]
		,[M].[LAST_UPDATED]
		,[M].[LAST_UPDATED_BY]
		,[M].[IS_CAR]
		,[M].[MT3]
		,[M].[BATCH_REQUESTED]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[M].[IS_MASTER_PACK]
		,[M].[ERP_AVERAGE_PRICE]
		,[M].[WEIGHT_MEASUREMENT]
		,[M].[EXPLODE_IN_RECEPTION]
		,[M].[HANDLE_TONE]
		,[M].[HANDLE_CALIBER]
		,[M].[QUALITY_CONTROL]
		,ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base')
		+ ' 1x' + CAST(ISNULL([UMM].[QTY], 1) AS VARCHAR)
		,ISNULL([UMM].[QTY], 1)
		,[M].[EXPIRATION_TOLERANCE]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
											AND (
											[UMM].[BARCODE] = @BARCODE_ID
											OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
											)
	WHERE
		(
			[M].[BARCODE_ID] = @BARCODE_ID
			OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
			OR [UMM].[BARCODE] = @BARCODE_ID
			OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
		)
		AND (
				@CLIENT_OWNER IS NULL
				OR [M].[CLIENT_OWNER] = @CLIENT_OWNER
			);

	-- ------------------------------------------------------------------------------------
	-- Actualiza la licencia si no tiene cliente
	-- ------------------------------------------------------------------------------------
	IF @CLIENT_OWNER IS NULL
	BEGIN
		SELECT
			@CLIENT_OWNER = [M].[CLIENT_OWNER]
		FROM
			@MATERIAL [M];
		--
		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[CLIENT_OWNER] = @CLIENT_OWNER
		WHERE
			[LICENSE_ID] = @LICENSE_ID;
	END;


	-- ------------------------------------------------------------------------------------
	-- Muestra resultado final
	-- ------------------------------------------------------------------------------------
	SELECT
		[M].[CLIENT_OWNER]
		,[M].[MATERIAL_ID]
		,[M].[BARCODE_ID]
		,[M].[ALTERNATE_BARCODE]
		,[M].[MATERIAL_NAME]
		,[M].[SHORT_NAME]
		,[M].[VOLUME_FACTOR]
		,[M].[MATERIAL_CLASS]
		,[M].[HIGH]
		,[M].[LENGTH]
		,[M].[WIDTH]
		,[M].[MAX_X_BIN]
		,[M].[SCAN_BY_ONE]
		,[M].[REQUIRES_LOGISTICS_INFO]
		,[M].[WEIGTH]
		,[M].[IMAGE_1]
		,[M].[IMAGE_2]
		,[M].[IMAGE_3]
		,[M].[LAST_UPDATED]
		,[M].[LAST_UPDATED_BY]
		,[M].[IS_CAR]
		,[M].[MT3]
		,[M].[BATCH_REQUESTED]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[M].[IS_MASTER_PACK]
		,[M].[ERP_AVERAGE_PRICE]
		,[M].[WEIGHT_MEASUREMENT]
		,[M].[EXPLODE_IN_RECEPTION]
		,[M].[HANDLE_TONE]
		,[M].[HANDLE_CALIBER]
		,[M].[QUALITY_CONTROL]
		,[M].[MEASUREMENT_UNIT]
		,[M].[MEASUREMENT_QTY]
		,[M].[EXPIRATION_TOLERANCE]
	FROM
		@MATERIAL [M];
END;