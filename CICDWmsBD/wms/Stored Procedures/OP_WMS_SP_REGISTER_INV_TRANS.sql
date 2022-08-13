-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	27-6-2016
-- Description:			Se agrego el vin para el ingreso de la transaccion.

-- Modificacion #001 03-10-2016 @ A-TEAM Sprint 2
-- juancarlos.escalante
-- Se modificó el insert para que se registre el id de la tarea

-- Modificacion 06-Oct-16
-- alberto.ruiz
-- Se modifico el insert para que se registre el Bath(lote) y el Date_expiration

-- Modificacion 07-Nov-16 @ A-Team Sprint 4
-- alberto.ruiz
-- Se agrego parametro de serie

-- Modificacion 26-Ene-17 @Team ERGON - Sprint ERGON II
-- hector.gonzalez
-- Se agrego EXEC de sp OP_WMS_SP_INSERT_MASTER_PACK

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-16 Team ERGON - Sprint ERGON 1
-- Description:	 Se agrega marcar status de tarea.

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 mODIFICAR PARAMETROS DE LLAMADA A SP OP_WMS_SP_INSERT_MASTER_PACK

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-15 Team ERGON - Sprint ERGON V
-- Description:	 Se agrego el codigo y nombre del proveedor a la transaccion

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-10 Nexus@AgeOfEmpires
-- Description:	 Se agrega código para explosión en recepción 

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se inserta en las columnas TRANSFER_REQUEST_ID y SOURCE_TYPE de OP_WMS_TRANS y se bloquea el inventario si viene de una solicitud de traslado

-- Modificacion 9/8/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se corrige longitud de parametro @pMATERIAL_CODE para que coincida con el de la tabla [OP_WMS_MATERIALS]

-- Modificacion 12/09/2017 @ Reborn-Team Sprint Collin
					-- rudi.garcia
					-- Se agrego el tono y calibre en la transaccion.
-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se valida el parametro de explosion por bodegas de los materiales
-- Modificacion 14-Dec-17 @ Nexus Team Sprint HeyYouPikachu! 
					-- pablo.aguilar
					-- Se obtiene cliente de la licencia cuando el subtipo es  @pTRANS_SUBTYPE = 'DEVOLUCION_FACTURA' ya que en esa situación el cliente es la almacenadora como tal.

/*
-- Ejemplo de Ejecucion:
EXEC [wms].OP_WMS_SP_REGISTER_INV_TRANS @pTRADE_AGREEMENT = ''
                                         ,@pLOGIN_ID = ''
                                         ,@pTRANS_TYPE = ''
                                         ,@pTRANS_EXTRA_COMMENTS = ''
                                         ,@pMATERIAL_BARCODE = ''
                                         ,@pMATERIAL_CODE = ''
                                         ,@pSOURCE_LICENSE = 0
                                         ,@pTARGET_LICENSE = 0
                                         ,@pSOURCE_LOCATION = ''
                                         ,@pTARGET_LOCATION = ''
                                         ,@pCLIENT_OWNER = ''
                                         ,@pQUANTITY_UNITS = 0
                                         ,@pSOURCE_WAREHOUSE = ''
                                         ,@pTARGET_WAREHOUSE = ''
                                         ,@pTRANS_SUBTYPE = ''
                                         ,@pCODIGO_POLIZA = ''
                                         ,@pLICENSE_ID = 0
                                         ,@pSTATUS = ''
                                         ,@pTRANS_MT2 NUMERIC(18, 2)
                                         ,@VIN VARCHAR(40)
                                         ,@pRESULT VARCHAR(300) OUTPUT
                                         ,@pTASK_ID NUMERIC(18, 0) = NULL
										                     ,@SERIAL = ''
                                         ,@BATCH = ''
                                         ,@DATE_EXPIRATION = ''
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_INV_TRANS] (
		@pTRADE_AGREEMENT VARCHAR(25)
		,@pLOGIN_ID VARCHAR(25)
		,@pTRANS_TYPE VARCHAR(25)
		,@pTRANS_EXTRA_COMMENTS VARCHAR(50)
		,@pMATERIAL_BARCODE VARCHAR(25)
		,@pMATERIAL_CODE VARCHAR(50)
		,@pSOURCE_LICENSE NUMERIC(18, 0)
		,@pTARGET_LICENSE NUMERIC(18, 0)
		,@pSOURCE_LOCATION VARCHAR(25)
		,@pTARGET_LOCATION VARCHAR(25)
		,@pCLIENT_OWNER VARCHAR(25)
		,@pQUANTITY_UNITS NUMERIC(18, 4)
		,@pSOURCE_WAREHOUSE VARCHAR(25)
		,@pTARGET_WAREHOUSE VARCHAR(25)
		,@pTRANS_SUBTYPE VARCHAR(25)
		,@pCODIGO_POLIZA VARCHAR(25)
		,@pLICENSE_ID NUMERIC(18, 0)
		,@pSTATUS VARCHAR(25)
		,@pTRANS_MT2 NUMERIC(18, 2)
		,@VIN VARCHAR(40)
		,@pRESULT VARCHAR(300) OUTPUT
		,@pTASK_ID NUMERIC(18, 0) = NULL
		,@SERIAL VARCHAR(50)
		,@BATCH VARCHAR(50) = NULL
		,@DATE_EXPIRATION DATE = NULL
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE	@ErrorMessage NVARCHAR(4000);
	DECLARE	@ErrorSeverity INT;
	DECLARE	@ErrorState INT;
	DECLARE
		@pMATERIAL_ID VARCHAR(50)
		,@CODE_SUPPLIER VARCHAR(25)
		,@NAME_SUPPLIER VARCHAR(100)
		,@EXPLOSION_TYPE VARCHAR(50)
		,@EXPLODE_IN_RECEPTION INT = 0
		,@IS_FROM_ERP INT = 0
		,@SOURCE_TYPE VARCHAR(50)
		,@TRANSFER_REQUEST_ID INT
		,@DOC_ID INT
		,@TONE VARCHAR(20) = NULL
		,@CALIBER VARCHAR(20) = NULL
		,@WAREHOUSE VARCHAR(25);


	   

	BEGIN TRY
    ---------------------------------------------------------------------------------
    -- Obtener valores 
    ---------------------------------------------------------------------------------  
		SELECT TOP 1
			@EXPLOSION_TYPE = [C].[TEXT_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS] [C]
		WHERE
			[C].[PARAM_TYPE] = 'SISTEMA'
			AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
			AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION';

		SELECT TOP 1
			@TRANSFER_REQUEST_ID = [TL].[TRANSFER_REQUEST_ID]
			,@SOURCE_TYPE = [TL].[SOURCE_TYPE]
			,@DOC_ID = [TL].[DOC_ID_SOURCE]
			,@pTRANS_SUBTYPE = [TL].[TASK_SUBTYPE]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[SERIAL_NUMBER] = @pTASK_ID;
	

		IF @TRANSFER_REQUEST_ID IS NOT NULL
			OR @pTRANS_SUBTYPE = 'DEVOLUCION_FACTURA'
		BEGIN
			SELECT
				@pCLIENT_OWNER = [L].[CLIENT_OWNER]
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			WHERE
				[L].[LICENSE_ID] = @pLICENSE_ID;
		END;
	--
		SELECT
			@WAREHOUSE = [WAREHOUSE_PARENT]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS]
		WHERE
			[LOCATION_SPOT] = @pTARGET_LOCATION;
--
		SELECT TOP 1
			@EXPLODE_IN_RECEPTION = ISNULL([MW].[VALUE], 0)
			,@pMATERIAL_ID = [M].[MATERIAL_ID]
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [MW] ON [MW].[MATERIAL_ID] = [M].[MATERIAL_ID]
											AND @WAREHOUSE = [MW].[WAREHOUSE_ID]
		LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP] ON [MP].[MATERIAL_PROPERTY_ID] = [MW].[MATERIAL_PROPERTY_ID]
											AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
		WHERE
			(
				[M].[BARCODE_ID] = @pMATERIAL_BARCODE
				OR [M].[ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
			)
			AND [M].[CLIENT_OWNER] = @pCLIENT_OWNER;

		SELECT TOP 1
			@CODE_SUPPLIER = [RDH].[CODE_SUPPLIER]
			,@NAME_SUPPLIER = [RDH].[NAME_SUPPLIER]
			,@IS_FROM_ERP = 1
		FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
		WHERE
			[RDH].[TASK_ID] = @pTASK_ID;

		IF @pTRADE_AGREEMENT IS NULL
			OR @pTRADE_AGREEMENT = ''
		BEGIN
			SELECT
				@pTRADE_AGREEMENT = CASE	WHEN [PH].[ACUERDO_COMERCIAL] IS NOT NULL
											AND [PH].[ACUERDO_COMERCIAL] <> ''
											THEN [PH].[ACUERDO_COMERCIAL]
											ELSE [AC].[ACUERDO_COMERCIAL]
									END
			FROM
				[wms].[OP_WMS_POLIZA_HEADER] [PH]
			INNER JOIN [wms].[OP_WMS_ACUERDOS_X_CLIENTE] [AC] ON [PH].[CLIENT_CODE] = [AC].[CLIENT_ID]
			WHERE
				[PH].[DOC_ID] = @DOC_ID;

		END;

    ---------------------------------------------------------------------------------
    -- Obtenemos Tono y Calibre del material ingresado
    ---------------------------------------------------------------------------------  

		SELECT
			@TONE = [TCM].[TONE]
			,@CALIBER = [TCM].[CALIBER]
		FROM
			[wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID])
		WHERE
			[IL].[LICENSE_ID] = @pLICENSE_ID
			AND [IL].[MATERIAL_ID] = @pMATERIAL_ID;


		DELETE
			[wms].[OP_WMS_TRANS]
		WHERE
			[MATERIAL_CODE] = @pMATERIAL_ID
			AND [TARGET_LICENSE] = @pTARGET_LICENSE
			AND [LICENSE_ID] = @pLICENSE_ID
			AND [QUANTITY_UNITS] = @pQUANTITY_UNITS
			AND ISNULL([SERIAL], '') = ISNULL(@SERIAL, '')
			AND [TRANS_SUBTYPE] = @pTRANS_SUBTYPE
			AND [LOGIN_ID] = @pLOGIN_ID
			AND [STATUS] = @pSTATUS
			AND [TRANS_TYPE] = @pTRANS_TYPE
			AND ISNULL([SOURCE_TYPE], '') = ISNULL(@SOURCE_TYPE,
											'')
			AND [TASK_ID] = @pTASK_ID;

			
	

		BEGIN TRANSACTION;
    ---------------------------------------------------------------------------------
    -- insertar transacción 
    ---------------------------------------------------------------------------------  
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
					,[TRANS_MT2]
					,[VIN]
					,[TASK_ID]
					,[SERIAL]
					,[BATCH]
					,[DATE_EXPIRATION]
					,[CODE_SUPPLIER]
					,[NAME_SUPPLIER]
					,[SOURCE_TYPE]
					,[TRANSFER_REQUEST_ID]
					,[TONE]
					,[CALIBER]
				)
		VALUES
				(
					@pTRADE_AGREEMENT
					,CURRENT_TIMESTAMP
					,@pLOGIN_ID
					,(SELECT
							*
						FROM
							[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID))
					,@pTRANS_TYPE
					,ISNULL((SELECT
									*
								FROM
									[wms].[OP_WMS_FUNC_GETTRANS_DESC](@pTRANS_TYPE)),
							@pTRANS_TYPE)
					,@pTRANS_EXTRA_COMMENTS
					,@pMATERIAL_BARCODE
					,@pMATERIAL_ID
					,(SELECT
							*
						FROM
							[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE,
											@pCLIENT_OWNER))
					,NULL
					,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID,
											@pCLIENT_OWNER)
					,@pSOURCE_LICENSE
					,@pTARGET_LICENSE
					,@pSOURCE_LOCATION
					,@pTARGET_LOCATION
					,@pCLIENT_OWNER
					,(SELECT
							*
						FROM
							[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_OWNER))
					,@pQUANTITY_UNITS
					,ISNULL((SELECT
									ISNULL([WAREHOUSE_PARENT],
											'BODEGA_DEF')
								FROM
									[wms].[OP_WMS_SHELF_SPOTS]
								WHERE
									[LOCATION_SPOT] = @pSOURCE_LOCATION),
							'BODEGA_DEF')
					,ISNULL((SELECT
									ISNULL([WAREHOUSE_PARENT],
											'BODEGA_DEF')
								FROM
									[wms].[OP_WMS_SHELF_SPOTS]
								WHERE
									[LOCATION_SPOT] = @pTARGET_LOCATION),
							'BODEGA_DEF')
					,@pTRANS_SUBTYPE
					,@pCODIGO_POLIZA
					,@pLICENSE_ID
					,@pSTATUS
					,@pTRANS_MT2
					,@VIN
					,@pTASK_ID
					,@SERIAL
					,@BATCH
					,@DATE_EXPIRATION
					,@CODE_SUPPLIER
					,@NAME_SUPPLIER
					,@SOURCE_TYPE
					,@TRANSFER_REQUEST_ID
					,@TONE
					,@CALIBER
				);



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
					@pLICENSE_ID
					,(SELECT
							[CURRENT_LOCATION]
						FROM
							[OP_WMS_LICENSES]
						WHERE
							[LICENSE_ID] = @pLICENSE_ID)
					,@pTARGET_LOCATION
					,@pTRANS_TYPE
					,CURRENT_TIMESTAMP
					,@pLOGIN_ID
				);

    ---------------------------------------------------------------------------------
    -- Actualiza acuerdo comercial 
    ---------------------------------------------------------------------------------  
		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[TERMS_OF_TRADE] = @pTRADE_AGREEMENT
		WHERE
			[LICENSE_ID] = @pLICENSE_ID
			AND [TERMS_OF_TRADE] = '';
    ---------------------------------------------------------------------------------
    -- actualizar datos en tablas 
    ---------------------------------------------------------------------------------  
		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[LAST_LOCATION] = [CURRENT_LOCATION]
			,[CURRENT_LOCATION] = @pTARGET_LOCATION
			,[LAST_UPDATED_BY] = @pLOGIN_ID
			,[CURRENT_WAREHOUSE] = ISNULL((SELECT
											ISNULL([WAREHOUSE_PARENT],
											'BODEGA_DEF')
											FROM
											[wms].[OP_WMS_SHELF_SPOTS]
											WHERE
											[LOCATION_SPOT] = @pTARGET_LOCATION),
											'BODEGA_DEF')
			,[STATUS] = 'ALLOCATED'
			,[USED_MT2] = @pTRANS_MT2
		WHERE
			[LICENSE_ID] = @pLICENSE_ID;
    --
		UPDATE
			[wms].[OP_WMS_POLIZA_HEADER]
		SET	
			[STATUS] = 'COMPLETED'
			,[LAST_UPDATED] = CURRENT_TIMESTAMP
			,[LAST_UPDATED_BY] = @pLOGIN_ID
		WHERE
			[CODIGO_POLIZA] = @pCODIGO_POLIZA;

		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[TERMS_OF_TRADE] = @pTRADE_AGREEMENT
		WHERE
			[LICENSE_ID] = @pLICENSE_ID;


		IF @TRANSFER_REQUEST_ID IS NOT NULL
		BEGIN
      -- ------------------------------------------------------------------------------------
      -- Bloquea el inventario si viene de una solicitud de traslado
      -- ------------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_INV_X_LICENSE]
			SET	
				[IS_BLOCKED] = 1
			WHERE
				[LICENSE_ID] = @pLICENSE_ID;
		END;

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MATERIALS] [M]
					WHERE
						[M].[MATERIAL_ID] = @pMATERIAL_CODE
						AND [M].[IS_MASTER_PACK] = 1 )
		BEGIN
      ---------------------------------------------------------------------------------
      -- registrar datos de masterpack ingresado 
      ---------------------------------------------------------------------------------  
			EXEC [wms].[OP_WMS_SP_INSERT_MASTER_PACK] @MATERIAL_ID_MASTER_PACK = @pMATERIAL_CODE,
				@LICENSE_ID = @pLICENSE_ID,
				@LAST_UPDATE_BY = @pLOGIN_ID,
				@QTY = @pQUANTITY_UNITS;


      ---------------------------------------------------------------------------------
      -- Si esta activada la bandera de explota en recepción realizar explosión.
      ---------------------------------------------------------------------------------  
			IF @EXPLODE_IN_RECEPTION = 1
				AND @IS_FROM_ERP = 0
			BEGIN

        ---------------------------------------------------------------------------------
        -- validar si explotara en cascada o directo al ultimo nivel 
        ---------------------------------------------------------------------------------  
				IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
				BEGIN
					EXEC [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @pLICENSE_ID,
						@LOGIN_ID = @pLOGIN_ID,
						@MATERIAL_ID = @pMATERIAL_CODE;
				END;
				ELSE
				BEGIN
					EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @pLICENSE_ID,
						@MATERIAL_ID = @pMATERIAL_CODE,
						@LAST_UPDATE_BY = @pLOGIN_ID,
						@MANUAL_EXPLOTION = 0;
				END;
			END;

		END;


		EXEC [wms].[OP_WMS_SP_REGISTER_RECEPTION_STATUS] @pTRANS_TYPE = @pTRANS_TYPE,
			@pLOGIN_ID = @pLOGIN_ID,
			@pCODIGO_POLIZA = @pCODIGO_POLIZA,
			@pTASK_ID = @pTASK_ID, @pSTATUS = 'ACCEPTED';
		SELECT
			@pRESULT = 'OK';

		
		COMMIT TRANSACTION;
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('' AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			@pRESULT = ERROR_MESSAGE();
		PRINT @pRESULT;

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@@ERROR AS [Codigo]
			,'' AS [DbData];

		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
	END CATCH;


END;