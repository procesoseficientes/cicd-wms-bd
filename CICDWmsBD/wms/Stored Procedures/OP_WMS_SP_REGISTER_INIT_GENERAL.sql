-- =============================================
-- Autor:					---------
-- Fecha de Creacion: 		---------
-- Description:			    ---------

-- Modificacion #001 03-10-2016 @ A-TEAM Sprint 2
-- juancarlos.escalante
-- Se modificó el insert para que se registre el id de la tarea


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	  Lllamar al método OP_WMS_SP_INSERT_MASTER_PACK

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-06-12 Team ERGON - Sprint ERGON Sheik
-- Description:	  Se cambio la forma de crear la poliza

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-16 ErgonTeam@BreathOfTheWild
-- Description:	 Se agregan campos de fecha de expiración, lote y serie 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-10 Nexus@AgeOfEmpires
-- Description:	 Se agrega código para explosión en recepción 

-- Modificacion 12/09/2017 @ Reborn-Team Sprint Collin
					-- rudi.garcia
					-- Se agrego el tono y calibre en la transaccion.

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:
		--
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_INIT_GENERAL]
	@pTRADE_AGREEMENT VARCHAR(25)
	,@pLOGIN_ID VARCHAR(25)
	,@pTRANS_TYPE VARCHAR(25)
	,@pTRANS_EXTRA_COMMENTS VARCHAR(50)
	,@pMATERIAL_BARCODE VARCHAR(25)
	,@pMATERIAL_CODE VARCHAR(25)
	,@pSOURCE_LICENSE NUMERIC(18, 0)
	,@pTARGET_LICENSE NUMERIC(18, 0)
	,@pSOURCE_LOCATION VARCHAR(25)
	,@pTARGET_LOCATION VARCHAR(25)
	,@pCLIENT_OWNER VARCHAR(25)
	,@pQUANTITY_UNITS NUMERIC(18, 2)
	,@pSOURCE_WAREHOUSE VARCHAR(25)
	,@pTARGET_WAREHOUSE VARCHAR(25)
	,@pTRANS_SUBTYPE VARCHAR(25)
	,@pCODIGO_POLIZA VARCHAR(25) OUTPUT
	,@pLICENSE_ID NUMERIC(18, 0)
	,@pSTATUS VARCHAR(25)
	,@pTransMT2 NUMERIC(18, 2)
	,@pRESULT VARCHAR(300) OUTPUT
	,@pTASK_ID NUMERIC(18, 0) = NULL
	,@SERIAL VARCHAR(50) = NULL
	,@BATCH VARCHAR(50) = NULL
	,@DATE_EXPIRATION DATE = NULL
	,@VIN VARCHAR(40) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@pMATERIAL_ID VARCHAR(50)
		,@pTransId NUMERIC(18, 0)
		,@DOC_ID NUMERIC
		,@LOGIN_NAME VARCHAR(50)
		,@MATERIAL_DESC VARCHAR(200)
		,@CLIENT_NAME VARCHAR(100)
		,@EXPLOSION_TYPE VARCHAR(50)
		,@EXPLODE_IN_RECEPTION INT = 0
		,@TONE VARCHAR(20) = NULL
		,@CALIBER VARCHAR(20) = NULL;


	BEGIN TRY

    --- ------------------------------------------
    --- Validamos si la poliza ya fue creada
    --- ------------------------------------------

		IF @pCODIGO_POLIZA IS NULL
			OR @pCODIGO_POLIZA = ''
		BEGIN
      --- ------------------------------------------
      --- Insertamos la poliza encabezado
      --- ------------------------------------------
			INSERT	INTO [wms].[OP_WMS_POLIZA_HEADER]
					(
						[CODIGO_POLIZA]
						,[FECHA_ACEPTACION_DMY]
						,[REGIMEN]
						,[FECHA_LLEGADA]
						,[LAST_UPDATED_BY]
						,[LAST_UPDATED]
						,[STATUS]
						,[CLIENT_CODE]
						,[ACUERDO_COMERCIAL]
						,[RAZON_SOCIAL_REPRESENTANTE]
						,[WAREHOUSE_REGIMEN]
						,[FECHA_DOCUMENTO]
						,[TIPO]
						,[NUMERO_DUA]
						,[REFERENCIA_EXTRA]
					)
			VALUES
					(
						''
						,CURRENT_TIMESTAMP
						,'GENERAL'
						,CURRENT_TIMESTAMP
						,@pLOGIN_ID
						,CURRENT_TIMESTAMP
						,'COMPLETED'
						,@pCLIENT_OWNER
						,@pTRADE_AGREEMENT
						,(SELECT
								*
							FROM
								[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_OWNER))
						,'GENERAL'
						,CURRENT_TIMESTAMP
						,'INGRESO'
						,@pTRANS_EXTRA_COMMENTS
						,@pTRANS_EXTRA_COMMENTS
					);

			SELECT
				@DOC_ID = SCOPE_IDENTITY();

			UPDATE
				[wms].[OP_WMS_POLIZA_HEADER]
			SET	
				[NUMERO_ORDEN] = CONVERT(VARCHAR(25), @DOC_ID)
				,[CODIGO_POLIZA] = CONVERT(VARCHAR(15), @DOC_ID)
			WHERE
				[DOC_ID] = @DOC_ID;

			SELECT
				@pCODIGO_POLIZA = CONVERT(VARCHAR(15), @DOC_ID);

		END;

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
			@LOGIN_NAME = [L].[LOGIN_NAME]
		FROM
			[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID) [L];

		SELECT TOP 1
			@CLIENT_NAME = [CLIENT_NAME]
		FROM
			[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_OWNER);

		SELECT TOP 1
			@pMATERIAL_ID = ISNULL([MATERIAL_ID],
									@pMATERIAL_BARCODE)
			,@MATERIAL_DESC = [M].[MATERIAL_NAME]
			,@EXPLODE_IN_RECEPTION = [M].[EXPLODE_IN_RECEPTION]
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		WHERE
			(
				[M].[BARCODE_ID] = @pMATERIAL_BARCODE
				OR [M].[ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
			)
			AND [M].[CLIENT_OWNER] = @pCLIENT_OWNER;

		SELECT
			@pSOURCE_WAREHOUSE = 'BODEGA_DEF'
			,@pTARGET_WAREHOUSE = 'BODEGA_DEF';

		SELECT TOP 1
			@pSOURCE_WAREHOUSE = ISNULL([WAREHOUSE_PARENT],
										'BODEGA_DEF')
		FROM
			[wms].[OP_WMS_SHELF_SPOTS]
		WHERE
			[LOCATION_SPOT] = @pSOURCE_LOCATION;
		SELECT TOP 1
			@pTARGET_WAREHOUSE = ISNULL([WAREHOUSE_PARENT],
										'BODEGA_DEF')
		FROM
			[wms].[OP_WMS_SHELF_SPOTS]
		WHERE
			[LOCATION_SPOT] = @pTARGET_LOCATION;

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
					,[TASK_ID]
					,[BATCH]
					,[DATE_EXPIRATION]
					,[SERIAL]
					,[VIN]
					,[TONE]
					,[CALIBER]
				)
		VALUES
				(
					@pTRADE_AGREEMENT
					,CURRENT_TIMESTAMP
					,@pLOGIN_ID
					,@LOGIN_NAME
					,@pTRANS_TYPE
					,ISNULL((SELECT
									*
								FROM
									[wms].[OP_WMS_FUNC_GETTRANS_DESC](@pTRANS_TYPE)),
							@pTRANS_TYPE)
					,@pTRANS_EXTRA_COMMENTS
					,@pMATERIAL_BARCODE
					,@pMATERIAL_ID
					,@MATERIAL_DESC
					,NULL
					,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID,
											@pCLIENT_OWNER)
					,@pSOURCE_LICENSE
					,@pTARGET_LICENSE
					,@pSOURCE_LOCATION
					,@pTARGET_LOCATION
					,@pCLIENT_OWNER
					,@CLIENT_NAME
					,@pQUANTITY_UNITS
					,@pSOURCE_WAREHOUSE
					,@pTARGET_WAREHOUSE
					,@pTRANS_SUBTYPE
					,@pCODIGO_POLIZA
					,@pLICENSE_ID
					,@pSTATUS
					,@pTransMT2
					,@pTASK_ID
					,@BATCH
					,@DATE_EXPIRATION
					,@SERIAL
					,@VIN
					,@TONE
					,@CALIBER
				);

		SELECT
			@pTransId = (SELECT TOP 1
								MAX([SERIAL_NUMBER])
							FROM
								[wms].[OP_WMS_TRANS]);

		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[LAST_LOCATION] = [CURRENT_LOCATION]
			,[CURRENT_LOCATION] = @pTARGET_LOCATION
			,[LAST_UPDATED_BY] = @pLOGIN_ID
			,[CURRENT_WAREHOUSE] = @pTARGET_WAREHOUSE
			,[STATUS] = 'ALLOCATED'
			,[USED_MT2] = @pTransMT2
		WHERE
			[LICENSE_ID] = @pLICENSE_ID;


		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[CODIGO_POLIZA] = @pCODIGO_POLIZA
		WHERE
			[LICENSE_ID] = @pLICENSE_ID;


		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MATERIALS] [M]
					WHERE
						[M].[MATERIAL_ID] = @pMATERIAL_CODE
						AND [M].[IS_MASTER_PACK] = 1 )
		BEGIN
			EXEC [wms].[OP_WMS_SP_INSERT_MASTER_PACK] @MATERIAL_ID_MASTER_PACK = @pMATERIAL_CODE,
				@LICENSE_ID = @pLICENSE_ID,
				@LAST_UPDATE_BY = @pLOGIN_ID,
				@QTY = @pQUANTITY_UNITS;
		END;


    -- Si esta activada la bandera de explota en recepción realizar explosión.
    ---------------------------------------------------------------------------------  
		IF @EXPLODE_IN_RECEPTION = 1
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



		SELECT
			@pRESULT = 'OK';

	END TRY
	BEGIN CATCH
		SELECT
			@pRESULT = ERROR_MESSAGE();
	END CATCH;

END;