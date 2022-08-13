-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-03-13 @ Team ERGON - Sprint ERGON V
-- Description:	  Se adjunta cambios para agregar transacción a reubicaciones completas de invnetario. 


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-19 Team ERGON - Sprint EPONA
-- Description:	 Se modifica para validar bandera de no reubicación en ubicación origen

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-11 @ Team REBORN - Sprint Collin
-- Description:	   Se agrega actualizacion a estado y parametros necesarios

-- Modificacion 1/30/2018 @ REBORN-Team Sprint Trotzdem
					-- rodrigo.gomez
					-- Se agrega validacion de clases en la licencia y la locacion destino

-- Modificacion:			marvin.solares
-- Fecha: 					20180920 GForce@Kiwi 
-- Description:			    se adapta sp para que proceda a colocar el inventario recepcionado a una licencia ya existente de la ubicacion seleccionada

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20182910 GForce@Mamba
-- Description:         Se modifica para que no modifique el estado de la licencia que sera reubicada

-- Modificacion 		1/27/2020 @ G-Force Team Sprint 
-- Autor: 				CARLOS.LARA
-- Historia/Bug:		Product Backlog Item 34990: Registro de espacios físicos por posición
-- Descripcion: 		1/27/2020 - Se agregó la actualización del dato TOTAL_POSTION de la tabal OP_WMS_INV_X_LICENSE

/*
-- Ejemplo de Ejecucion: 
			SELECT * FROM [wms].[OP_WMS_LICENSES] WHERE [LICENSE_ID] =  23434
  EXEC [wms].[OP_WMS_SP_REALLOC_LICENSE] @pLICENCIA_ID = 23434
                                           ,@pNEW_LOCATION_SPOT = 'B04-TA-C13-NU'
                                           ,@pLOGIN_ID = 'BCORADO'
                                           ,@pMt2 = 42
                                           ,@pResult = ''
										   ,@pTOTAL_POSITION = 3
  SELECT * FROM [wms].[OP_WMS_LICENSES] WHERE [LICENSE_ID] =  23434
  SELECT * FROM [wms].[OP_WMS_TRANS] [OWT] WHERE [OWT]. = 23434
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REALLOC_LICENSE]
-- Add the parameters for the stored procedure here
	@pLICENCIA_ID NUMERIC(18, 0) OUTPUT
	,@pNEW_LOCATION_SPOT VARCHAR(25)
	,@pLOGIN_ID VARCHAR(25)
	,@pMt2 NUMERIC(18, 2)
	,@pResult VARCHAR(250) OUTPUT
	,@PARAM_NAME VARCHAR(50) = 'ESTADO_DEFAULT'
	,@pTOTAL_POSITION INT = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE	@ErrorMessage NVARCHAR(4000);
	DECLARE	@ErrorSeverity INT;
	DECLARE	@ErrorState INT;
	DECLARE	@ErrorCode INT;
	DECLARE	@pCURRENT_LOCATION VARCHAR(50);
	DECLARE	@WAVEPICKING_ID INT = 0;
	DECLARE	@OPERADOR_TASK VARCHAR(50);

	DECLARE
		@CURRENT_CLASS INT = 0
		,@ALLOW_REALLOC INT = 0
		,@COMPATIBLE INT = 1
		,@ALLOW_FAST_PICKING INT = 0;

	DECLARE	@STATUS_TB TABLE (
			[RESULTADO] INT
			,[MENSAJE] VARCHAR(15)
			,[CODIGO] INT
			,[STATUS_ID] INT
		);

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
	BEGIN TRY

		BEGIN
			--VALIDAR QUE EXISTA LA LICENCIA
			IF NOT EXISTS ( SELECT
								1
							FROM
								[wms].[OP_WMS_LICENSES]
							WHERE
								[LICENSE_ID] = @pLICENCIA_ID )
			BEGIN
				SELECT
					@pResult = 'LICENCIA ['
					+ CONVERT(VARCHAR(10), @pLICENCIA_ID)
					+ '] NO EXISTE'
					,@ErrorCode = 1101;
				
				RAISERROR(@pResult, 16, 1); 
				RETURN -1;
			END;

			 --SE OBTIENE LA UBICACION DE LA LICENCIA
			SELECT TOP 1
				@pCURRENT_LOCATION = [CURRENT_LOCATION]
			FROM
				[wms].[OP_WMS_LICENSES]
			WHERE
				[LICENSE_ID] = @pLICENCIA_ID;


			SELECT TOP 1
				@ALLOW_REALLOC = [S].[ALLOW_REALLOC]
			FROM
				[wms].[OP_WMS_SHELF_SPOTS] [S]
			WHERE
				[S].[LOCATION_SPOT] = @pCURRENT_LOCATION;

			IF (@ALLOW_REALLOC = 0)
			BEGIN
				SELECT
					@pResult = 'UBICACION ORIGEN '
					+ @pCURRENT_LOCATION
					+ ' NO ESTA DISPONIBLE PARA REUBICACION '
					,@ErrorCode = 1102;
		  
				RAISERROR(@pResult, 16, 1);
				RETURN -1;
			END;


			--VALIDAR QUE LA UBICACION DESTINO NO SEA LA MISMA QUE LA UBICACION ACTUAL
			IF @pNEW_LOCATION_SPOT = @pCURRENT_LOCATION
			BEGIN
				SELECT
					@pResult = 'LICENCIA YA SE ENCUENTRA EN LA UBICACION DESTINO'
					,@ErrorCode = 1103;
				RAISERROR(@pResult, 16, 1);
				RETURN -1;
			END;

			--VALIDAR QUE LA UBICACION DESTINO EXISTA
			IF NOT EXISTS ( SELECT
								1
							FROM
								[wms].[OP_WMS_SHELF_SPOTS]
							WHERE
								[LOCATION_SPOT] = @pNEW_LOCATION_SPOT )
			BEGIN
				SELECT
					@pResult = 'UBICACION '
					+ @pNEW_LOCATION_SPOT + ' NO EXISTE'
					,@ErrorCode = 1104;
				RAISERROR(@pResult, 16, 1);
				RETURN -1;
			END;

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
				[wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@pLICENCIA_ID);
	
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
				[wms].[OP_WMS_FN_GET_CLASSES_BY_LOCATION](@pNEW_LOCATION_SPOT);
	
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
				[wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@pLICENCIA_ID);
	
			-- ------------------------------------------------------------------------------------
			-- Valida si las clases de la licencia son compatibles con las de la ubicacion
			-- ------------------------------------------------------------------------------------
			DELETE
				[LC]
			FROM
				@LOCATION_CLASSES [LC]
			INNER JOIN @COMPATIBLE_CLASSES [C] ON [LC].[CLASS_ID] = [C].[CLASS_ID];

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							@LOCATION_CLASSES )
			BEGIN
				SELECT
					@pResult = 'Las clases de la licencia no son compatibles con las clases de la ubicacion actual'
					,@ErrorCode = 1105;
				RAISERROR(@pResult, 16, 1);
				RETURN -1;
			END;

			DECLARE
				@NEW_WAREHOUSE VARCHAR(50)
				,@PAST_WAREHOUSE VARCHAR(50);
			SELECT TOP 1
				@NEW_WAREHOUSE = [WAREHOUSE_PARENT]
				,@ALLOW_FAST_PICKING = [ALLOW_FAST_PICKING]
			FROM
				[wms].[OP_WMS_SHELF_SPOTS]
			WHERE
				[LOCATION_SPOT] = @pNEW_LOCATION_SPOT;

			SELECT TOP 1
				@PAST_WAREHOUSE = [WAREHOUSE_PARENT]
			FROM
				[wms].[OP_WMS_SHELF_SPOTS]
			WHERE
				[LOCATION_SPOT] = @pCURRENT_LOCATION;


			--PROCEDER CON LA ACTUALIZACION			
			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[LAST_LOCATION] = [CURRENT_LOCATION]
				,[CURRENT_LOCATION] = @pNEW_LOCATION_SPOT
				,[CURRENT_WAREHOUSE] = @NEW_WAREHOUSE
				,[LAST_UPDATED] = CURRENT_TIMESTAMP
				,[LAST_UPDATED_BY] = @pLOGIN_ID
				,[USED_MT2] = @pMt2
			WHERE
				[LICENSE_ID] = @pLICENCIA_ID;

			UPDATE
				[wms].[OP_WMS_INV_X_LICENSE]
			SET
				[TOTAL_POSITION] = @pTOTAL_POSITION
			WHERE
				[LICENSE_ID] = @pLICENCIA_ID;

		END;


			--RECORD THE REALLOC
		INSERT	INTO [wms].[OP_WMS_REALLOCS_X_LICENSE]
				(
					[LICENSE_ID]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[TRANS_TYPE]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
				)
		VALUES
				(
					@pLICENCIA_ID
					,@pCURRENT_LOCATION
					,@pNEW_LOCATION_SPOT
					,'REALLOC'
					,CURRENT_TIMESTAMP
					,@pLOGIN_ID
				);

		INSERT	INTO [wms].[OP_WMS_TRANS]
				(
					[TERMS_OF_TRADE]
					,[TRANS_DATE]
					,[LOGIN_ID]
					,[LOGIN_NAME]
					,[TRANS_TYPE]
					,[TRANS_DESCRIPTION]
					,[TRANS_EXTRA_COMMENTS]
					,[MATERIAL_BARCODE]
					,[MATERIAL_CODE]
					,[MATERIAL_DESCRIPTION]
					,[MATERIAL_TYPE]
					,[MATERIAL_COST]
					,[SOURCE_LICENSE]
					,[TARGET_LICENSE]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[CLIENT_OWNER]
					,[CLIENT_NAME]
					,[QUANTITY_UNITS]
					,[SOURCE_WAREHOUSE]
					,[TARGET_WAREHOUSE]
					,[TRANS_SUBTYPE]
					,[CODIGO_POLIZA]
					,[LICENSE_ID]
					,[STATUS]
				)
		SELECT TOP 1
			MAX([IL].[TERMS_OF_TRADE]) [TERMS_OF_TRADE]
			,GETDATE() [TRANS_DATE]
			,@pLOGIN_ID [LOGIN_ID]
			,(SELECT TOP 1
					[LOGIN_NAME]
				FROM
					[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID)) [LOGIN_NAME]
			,'REUBICACION_COMPLETA' [TRANS_TYPE]
			,'REUBICACION COMPLETA' [TRANS_DESCRIPTION]
			,NULL [TRANS_EXTRA_COMMENTS]
			,'' [MATERIAL_BARCODE]
			,'' [MATERIAL_CODE]
			,NULL [MATERIAL_TYPE]
			,NULL [MATERIAL_DESCRIPTION]
			,0 [MATERIAL_COST]
			,@pLICENCIA_ID [SOURCE_LICENSE]
			,@pLICENCIA_ID [TARGET_LICENSE]
			,@pCURRENT_LOCATION [SOURCE_LOCATION]
			,@pNEW_LOCATION_SPOT [TARGET_LOCATION]
			,MAX([L].[CLIENT_OWNER]) [CLIENT_OWNER]
			,MAX([C].[CLIENT_NAME]) [CLIENT_NAME]
			,SUM([IL].[QTY]) [QUANTITY_UNITS]
			,@PAST_WAREHOUSE [SOURCE_WAREHOUSE]
			,@NEW_WAREHOUSE [TARGET_WAREHOUSE]
			,'' [TRANS_SUBTYPE]
			,MAX([L].[CODIGO_POLIZA]) [CODIGO_POLIZA]
			,@pLICENCIA_ID [LICENSE_ID]
			,'PROCESSED' [STATUS]
		FROM
			[wms].[OP_WMS_LICENSES] [L]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [L].[CLIENT_OWNER] = [C].[CLIENT_CODE]
		WHERE
			[L].[LICENSE_ID] = @pLICENCIA_ID
			AND [IL].[QTY] > 0
		GROUP BY
			[L].[LICENSE_ID];

			-- ------------------------------------------------------------------------------------
		-- si estamos ubicando en una ubicacion con la propiedad ALLOW_FAST_PICKING = TRUE
		-- debemos trasladar el inventario de la licencia creada en la recepcion hacia 
		-- una licencia previamente creada en dicha ubicacion
		-- ------------------------------------------------------------------------------------
		IF @ALLOW_FAST_PICKING = 1
		BEGIN
			EXEC [wms].[OP_WMS_SP_UPDATE_LICENSE_TOTAL_REALLOC_FAST_PICKING] @LOGIN_ID = @pLOGIN_ID, -- varchar(50)
				@LICENSE_ID = @pLICENCIA_ID, -- int
				@LOCATION_ID = @pNEW_LOCATION_SPOT, -- varchar(25)
				@TRANS_TYPE = 'REUBICACION_COMPLETA'; -- varchar(25)
		END;

		SELECT
			@pResult = 'OK';
	
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' AS [Mensaje]
			,1 AS [Codigo]
			,'' AS [DbData];

	END TRY
	BEGIN CATCH
		SELECT
			@pResult = ERROR_MESSAGE();
			
		SELECT
			@ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@ErrorCode AS [Codigo]
			,'' AS [DbData];
	END CATCH;

END;