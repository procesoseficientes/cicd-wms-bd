-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		2017-04-28 @ TeamErgon Sprint Ganondorf
-- Description:			    Sp que registra el re-abastecimiento

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					--  Se modifica para que diferencia por ubicación destino al actualizar task_list

					-- Modificacion 26-Feb-18 @ Nexus Team Sprint vERNICHTUNG
										-- pablo.aguilar
										-- Se agrega valicación de tipo de tarea para colocar en 0 la nueva licencia y asi asignarselo a la primera licencia. 

/*
-- Ejemplo de Ejecucion:
        DECLARE @pRESULT VARCHAR(300)
		--
		EXEC [wms].[OP_WMS_SP_REGISTER_DISPATCH_GENERAL] 
			@pLOGIN_ID = '' , -- varchar(25)
			@pCLIENT_OWNER = '' , -- varchar(25)
			@pMATERIAL_ID = '' , -- varchar(50)
			@pMATERIAL_BARCODE = '' , -- varchar(25)
			@pSOURCE_LICENSE = NULL , -- numeric
			@pSOURCE_LOCATION = '' , -- varchar(25)
			@pQUANTITY_UNITS = NULL , -- numeric
			@pCODIGO_POLIZA = '' , -- varchar(25)
			@pWAVE_PICKING_ID = NULL , -- numeric
			@pSERIAL_NUMBER = NULL , -- numeric
			@pTipoUbicacion = '' , -- varchar(25)
			@pMt2 = NULL , -- numeric
			@pRESULT = @pRESULT OUTPUT , -- varchar(300)
			@pTASK_ID = NULL -- numeric
		--
		SELECT @pRESULT
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_REALLOC_FOR_REPLENISHMENT] (
     @LOGIN_ID VARCHAR(25)
    ,@MATERIAL_ID VARCHAR(50)
    ,@MATERIAL_BARCODE VARCHAR(25)
    ,@SOURCE_LICENSE NUMERIC(18, 0)
    ,@SOURCE_LOCATION VARCHAR(25)
    ,@QUANTITY_UNITS NUMERIC(18, 4)
    ,@WAVE_PICKING_ID NUMERIC(18, 0)
    ,@MT2 NUMERIC(18, 2)
    ,@TYPE_LOCATION VARCHAR(25)
    ,@TARGET_LOCATION VARCHAR(25)
    ,@NEW_LICENSE_ID NUMERIC(18, 0) = 0 OUTPUT
    ,@RESULT VARCHAR(500) = '' OUTPUT
	)
AS
BEGIN

    SET NOCOUNT ON;

  --DECLARE @ErrorMessage NVARCHAR(4000);
  --DECLARE @ErrorSeverity INT;
  --DECLARE @ErrorState INT;
    DECLARE @pTASK_IS_PAUSED INT;
    DECLARE @pTASK_IS_CANCELED INT;
  --DECLARE @pSKUQtyPending NUMERIC(18, 0);
    DECLARE @pMATERIAL_ID_LOCAL VARCHAR(50);
    DECLARE @pCLIENT_ID_LOCAL VARCHAR(50);
    DECLARE @pINV_AVAILABLE NUMERIC(18, 4);
    DECLARE @pCODIGO_POLIZA VARCHAR(50);
    DECLARE @pREGIMEN VARCHAR(20);
    DECLARE @pTaskId NUMERIC;
    DECLARE @TERMS_OF_TRADE VARCHAR(50);
  --DECLARE @IS_FROM_SONDA INT;
    DECLARE
        @BATCH VARCHAR(50)
       ,@DATE_EXPIRATION DATE
       ,@VIN VARCHAR(40)
       ,@CURRENT_WAREHOUSE VARCHAR(25)
		,@TARGET_WAREHOUSE VARCHAR(25)
		,@TASK_SUBTYPE VARCHAR(25)
		,@STATUS_NAME VARCHAR(100);

	DECLARE @OPERACION TABLE
            (
              [RESULTADO] INT ,
              [MENSAJE] VARCHAR(250) ,
              [CODIGO] INT ,
              [DB_DATA] VARCHAR(50)
            );

    BEGIN TRY
        BEGIN TRANSACTION;

		PRINT 'Inicia';
    -- ----------------------------------------------------------------------------------
    -- Obtenemos el codigo del cliente
    -- ----------------------------------------------------------------------------------
        SELECT
			@pCLIENT_ID_LOCAL = (SELECT TOP 1
										[L].[CLIENT_OWNER]
                                FROM
										[wms].[OP_WMS_LICENSES] [L]
                                WHERE
										[L].[LICENSE_ID] = @SOURCE_LICENSE);

    -- ----------------------------------------------------------------------------------
    -- Obtenemos el id del material
    -- ----------------------------------------------------------------------------------
		SELECT TOP 1
			@pMATERIAL_ID_LOCAL = [M].[MATERIAL_ID]
			,@MATERIAL_ID = [M].[MATERIAL_ID]
                                  FROM
			[wms].[OP_WMS_MATERIALS] [M]
                                  WHERE
			(
				[M].[BARCODE_ID] = @MATERIAL_BARCODE
				OR [M].[ALTERNATE_BARCODE] = @MATERIAL_BARCODE
			)
			AND [M].[CLIENT_OWNER] = @pCLIENT_ID_LOCAL;
    -- ----------------------------------------------------------------------------------
    -- Obtenemos si la tarea esta en pausa
    -- ----------------------------------------------------------------------------------

		SELECT TOP 1
			@pTASK_IS_PAUSED = [TL].[IS_PAUSED]
			,@TASK_SUBTYPE = [TL].[TASK_SUBTYPE]
			,@pTASK_IS_CANCELED = [TL].[IS_CANCELED]
			,@pTaskId = [TL].[SERIAL_NUMBER]
                        FROM
                            [wms].[OP_WMS_TASK_LIST] [TL]
                        WHERE
                            [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [TL].[MATERIAL_ID] = @MATERIAL_ID;

		PRINT @TASK_SUBTYPE;

		IF @TASK_SUBTYPE = 'REUBICACION_LP'
		BEGIN
			SET @NEW_LICENSE_ID = 0;
		END;

		PRINT 'Nueva licencia '
			+ CAST(@NEW_LICENSE_ID AS VARCHAR);

	
    -- ----------------------------------------------------------------------------------
    -- Validamos si la tarea enta en pausa
    -- ----------------------------------------------------------------------------------
        IF (@pTASK_IS_PAUSED <> 0)
        BEGIN
            SELECT
                @RESULT = 'ERROR, Tarea en PAUSA, verifique.';
			RAISERROR(@RESULT,16,1);
            RETURN -1;
        END;
    -- ----------------------------------------------------------------------------------
    -- Validamos si la tarea esta cancelada
    -- ----------------------------------------------------------------------------------
        IF (@pTASK_IS_CANCELED <> 0)
        BEGIN
            SELECT
                @RESULT = 'ERROR, Tarea ha sido cancelada, verifique.';
			RAISERROR(@RESULT,16,1);
            RETURN -1;
        END;


    -- ----------------------------------------------------------------------------------
    -- Obtenemos la poliza de la licencia
    -- ----------------------------------------------------------------------------------
        SELECT
            @pCODIGO_POLIZA = (SELECT TOP 1
                                [L].[CODIGO_POLIZA]
                               FROM
                                [wms].[OP_WMS_LICENSES] [L]
                               WHERE
									[L].[LICENSE_ID] = @SOURCE_LICENSE);

    -- ----------------------------------------------------------------------------------
    -- Obtenemos el regimen de la licencia
    -- ----------------------------------------------------------------------------------
        SELECT
            @pREGIMEN = (SELECT TOP 1
                            [L].[REGIMEN]
                         FROM
                            [wms].[OP_WMS_LICENSES] [L]
                         WHERE
								[L].[LICENSE_ID] = @SOURCE_LICENSE);

    -- ----------------------------------------------------------------------------------
    -- Obtenemos el acuerdo comercial de la licencia
    -- ----------------------------------------------------------------------------------
        SELECT
            @TERMS_OF_TRADE = (SELECT TOP 1
                                [IL].[TERMS_OF_TRADE]
                               FROM
                                [wms].[OP_WMS_LICENSES] [L]
                               INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [IL].[LICENSE_ID])
                               WHERE
									[L].[LICENSE_ID] = @SOURCE_LICENSE);

    -- ----------------------------------------------------------------------------------
    -- Obtenemos el codigo de Bodega
    -- ----------------------------------------------------------------------------------
        SELECT
            @CURRENT_WAREHOUSE = (SELECT TOP 1
                                    [L].[CURRENT_WAREHOUSE]
                                  FROM
                                    [wms].[OP_WMS_LICENSES] [L]
                                  WHERE
										[L].[LICENSE_ID] = @SOURCE_LICENSE);

        SELECT TOP 1
            @TARGET_WAREHOUSE = [S].[WAREHOUSE_PARENT]
        FROM
            [wms].[OP_WMS_SHELF_SPOTS] [S]
        WHERE
            @TARGET_LOCATION = [S].[LOCATION_SPOT];

    

    -- ----------------------------------------------------------------------------------
    -- Validamos el sku
    -- ----------------------------------------------------------------------------------
        IF @pMATERIAL_ID_LOCAL IS NULL
        BEGIN
            SELECT
				@RESULT = 'ERROR, SKU Invalido: ['
				+ @MATERIAL_BARCODE + '/'
                + @pCLIENT_ID_LOCAL + '] verifique.';
			RAISERROR(@RESULT,16,1);
            RETURN -1;
        END;

    -- ----------------------------------------------------------------------------------
    -- Obtenemos la cantidad del inventario de la licencia
    -- ----------------------------------------------------------------------------------
        SELECT
            @pINV_AVAILABLE = (SELECT TOP 1
                                [QTY]
                               FROM
                                [wms].[OP_WMS_INV_X_LICENSE] [IL]
                               WHERE
                                [IL].[LICENSE_ID] = @SOURCE_LICENSE
									AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL);

    -- ----------------------------------------------------------------------------------
    -- Validamos si suficiente inventario
    -- ----------------------------------------------------------------------------------
        IF (@pINV_AVAILABLE < @QUANTITY_UNITS)
        BEGIN
            SELECT
                @RESULT = 'ERROR, Inventario insuficiente['
                + CONVERT(VARCHAR(20), @pINV_AVAILABLE)
                + '] en licencia origen: ['
				+ CONVERT(VARCHAR(20), @SOURCE_LICENSE)
				+ '] verifique.';
			RAISERROR(@RESULT,16,1);
            RETURN -1;
        END;

    -- ----------------------------------------------------------------------------------
    -- Obtenemos el lote y fecha de expiracion de la licencia
    -- ----------------------------------------------------------------------------------
        SELECT TOP 1
            @BATCH = [IL].[BATCH]
           ,@DATE_EXPIRATION = [IL].[DATE_EXPIRATION]
           ,@VIN = [IL].[VIN]
			,@STATUS_NAME = [S].[STATUS_CODE]
        FROM
            [wms].[OP_WMS_INV_X_LICENSE] [IL]
		LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON [S].[STATUS_ID] = [IL].[STATUS_ID]
        WHERE
            [IL].[LICENSE_ID] = @SOURCE_LICENSE
            AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

    -- ----------------------------------------------------------------------------------
    -- Validamos si la zona maneja explocion de materiales
    -- ----------------------------------------------------------------------------------
        IF @NEW_LICENSE_ID > 0
        BEGIN


            PRINT ('1-Agrega');
            PRINT (@DATE_EXPIRATION);
      -- ----------------------------------------------------------------------------------
      -- Agregamos el sku a la licencia creada
      -- ----------------------------------------------------------------------------------

            EXEC [wms].[OP_WMS_SP_AGREGA_SKU_LICENCIA] @pLICENSE_ID = @NEW_LICENSE_ID,
				@pBARCODE = @MATERIAL_BARCODE,
				@pQTY = @QUANTITY_UNITS,
				@pLAST_LOGIN = @LOGIN_ID,
				@pVOLUME_FACTOR = 0, @pWEIGTH = 0,
                @pComments = '', @pSerial = '',
				@pAcuerdoComercial = @TERMS_OF_TRADE,
				@pTOTAL_SKUs = 1, @pSTATUS = 'PROCESSED',
				@pResult = @RESULT OUTPUT,
				@DATE_EXPIRATION = @DATE_EXPIRATION,
				@BATCH = @BATCH, @VIN = @VIN,
				@PARAM_NAME = @STATUS_NAME;
            IF @RESULT <> 'OK'
            BEGIN
                SELECT
                    @RESULT;
				RAISERROR(@RESULT,16,1);
                RETURN -1;
            END;
        END;
        ELSE
        BEGIN
      -- ----------------------------------------------------------------------------------
      -- Obtenemos la primera licencia de la ubicacion
      -- ----------------------------------------------------------------------------------
            SELECT TOP 1
                @NEW_LICENSE_ID = [L].[LICENSE_ID]
            FROM
                [wms].[OP_WMS_LICENSES] [L]
            WHERE
                [L].[CURRENT_LOCATION] = @TARGET_LOCATION;

      -- ----------------------------------------------------------------------------------
      -- Validamos si exite una licencia en la ubicacion
      -- ----------------------------------------------------------------------------------
            PRINT ('03-Val');
            PRINT (@NEW_LICENSE_ID);
            IF @NEW_LICENSE_ID IS NULL
                OR @NEW_LICENSE_ID = 0
            BEGIN
        -- ----------------------------------------------------------------------------------
        -- Creamos una licencia para el producto
        -- ----------------------------------------------------------------------------------
				INSERT  INTO @OPERACION
							( [RESULTADO] ,
							  [MENSAJE] ,
							  [CODIGO] ,
							  [DB_DATA]
							)
                EXEC [wms].[OP_WMS_SP_CREA_LICENCIA] @pCODIGO_POLIZA = @pCODIGO_POLIZA,
                    @pLOGIN = @LOGIN_ID,
                    @pLICENCIA_ID = @NEW_LICENSE_ID OUTPUT,
					@pCLIENT_OWNER = @pCLIENT_ID_LOCAL,
					@pREGIMEN = @pREGIMEN,
					@pResult = @RESULT OUTPUT,
					@pTaskId = @pTaskId;
                IF @RESULT <> 'OK'
                BEGIN
                    SELECT
                        @RESULT;
					RAISERROR(@RESULT,16,1);
                    RETURN -1;
                END;
            END;
			

			UPDATE
				[wms].[OP_WMS_INV_X_LICENSE]
			SET	
				[BATCH] = @BATCH
				,[DATE_EXPIRATION] = @DATE_EXPIRATION
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [il]
			WHERE
				[il].[LICENSE_ID] = @NEW_LICENSE_ID
				AND [il].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;

			
			SELECT @STATUS_NAME = [S].[STATUS_CODE]
			 FROM
				[wms].[OP_WMS_INV_X_LICENSE] [il]
				INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] S ON [S].[STATUS_ID] = [il].[STATUS_ID]
			WHERE
				[il].[LICENSE_ID] = @NEW_LICENSE_ID
				AND [il].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;  
			

      -- ----------------------------------------------------------------------------------
      -- Agregamos el sku a la licencia creada
      -- ----------------------------------------------------------------------------------
            EXEC [wms].[OP_WMS_SP_AGREGA_SKU_LICENCIA] @pLICENSE_ID = @NEW_LICENSE_ID,
				@pBARCODE = @MATERIAL_BARCODE,
				@pQTY = @QUANTITY_UNITS,
				@pLAST_LOGIN = @LOGIN_ID,
				@pVOLUME_FACTOR = 0, @pWEIGTH = 0,
                @pComments = '', @pSerial = '',
				@pAcuerdoComercial = @TERMS_OF_TRADE,
				@pTOTAL_SKUs = 1, @pSTATUS = 'PROCESSED',
				@pResult = @RESULT OUTPUT,
				@DATE_EXPIRATION = @DATE_EXPIRATION,
				@BATCH = @BATCH, @VIN = @VIN,
				@PARAM_NAME = @STATUS_NAME;
            IF @RESULT <> 'OK'
            BEGIN
                SELECT
                    @RESULT;
				RAISERROR(@RESULT,16,1);
                RETURN -1;
            END;
        END;
        PRINT ('2-Registrar');
    -- ----------------------------------------------------------------------------------
    -- Se crea la transaccion del producto ingresado 
    -- ----------------------------------------------------------------------------------
        EXEC [wms].[OP_WMS_SP_REGISTER_INV_TRANS] @pTRADE_AGREEMENT = @TERMS_OF_TRADE,
			@pLOGIN_ID = @LOGIN_ID,
			@pTRANS_TYPE = 'TAREA_REUBICACION',
            @pTRANS_EXTRA_COMMENTS = 'N/A',
            @pMATERIAL_BARCODE = @MATERIAL_BARCODE,
			@pMATERIAL_CODE = @MATERIAL_ID,
			@pSOURCE_LICENSE = @SOURCE_LICENSE,
            @pTARGET_LICENSE = @NEW_LICENSE_ID,
            @pSOURCE_LOCATION = @SOURCE_LOCATION,
            @pTARGET_LOCATION = @TARGET_LOCATION,
            @pCLIENT_OWNER = @pCLIENT_ID_LOCAL,
            @pQUANTITY_UNITS = @QUANTITY_UNITS,
            @pSOURCE_WAREHOUSE = @CURRENT_WAREHOUSE,
            @pTARGET_WAREHOUSE = @TARGET_WAREHOUSE,
            @pTRANS_SUBTYPE = 'REABASTECIMIENTO',
			@pCODIGO_POLIZA = @pCODIGO_POLIZA,
			@pLICENSE_ID = @NEW_LICENSE_ID,
			@pSTATUS = 'PROCESSED', @pTRANS_MT2 = 0,
			@VIN = @VIN, @pRESULT = @RESULT OUTPUT,
			@pTASK_ID = @WAVE_PICKING_ID, @SERIAL = '',
			@BATCH = @BATCH,
			@DATE_EXPIRATION = @DATE_EXPIRATION;
        IF @RESULT <> 'OK'
        BEGIN
            SELECT
                @RESULT;
			RAISERROR(@RESULT,16,1);
            RETURN -1;
        END;

    --    -- ----------------------------------------------------------------------------------
    --    -- Se crea la transaccion de la re-abastecimiento
    --    -- ----------------------------------------------------------------------------------
    --    INSERT INTO [wms].[OP_WMS_TRANS] ([TERMS_OF_TRADE]
    --    , [TRANS_DATE]
    --    , [LOGIN_ID]
    --    , [LOGIN_NAME]
    --    , [TRANS_TYPE]
    --    , [TRANS_DESCRIPTION]
    --    , [TRANS_EXTRA_COMMENTS]
    --    , [MATERIAL_BARCODE]
    --    , [MATERIAL_CODE]
    --    , [MATERIAL_DESCRIPTION]
    --    , [MATERIAL_TYPE]
    --    , [MATERIAL_COST]
    --    , [SOURCE_LICENSE]
    --    , [TARGET_LICENSE]
    --    , [SOURCE_LOCATION]
    --    , [TARGET_LOCATION]
    --    , [CLIENT_OWNER]
    --    , [CLIENT_NAME]
    --    , [QUANTITY_UNITS]
    --    , [SOURCE_WAREHOUSE]
    --    , [TARGET_WAREHOUSE]
    --    , [TRANS_SUBTYPE]
    --    , [CODIGO_POLIZA]
    --    , [LICENSE_ID], STATUS, WAVE_PICKING_ID
    --    , [TASK_ID]
    --    , [IS_FROM_SONDA]
    --    , [BATCH]
    --    , DATE_EXPIRATION)
    --      VALUES ((SELECT TOP 1 TERMS_OF_TRADE FROM [wms].OP_WMS_INV_X_LICENSE WHERE LICENSE_ID = @SOURCE_LICENSE AND MATERIAL_ID = @pMATERIAL_ID_LOCAL), GETDATE(), @LOGIN_ID, (SELECT TOP 1 * FROM [wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN_ID)), 'TAREA_REABASTECIMIENTO', ISNULL((SELECT PARAM_CAPTION FROM [wms].OP_WMS_FUNC_GETTRANS_DESC('TAREA_REABASTECIMIENTO')), 'TAREA_REABASTECIMIENTO'), NULL, @MATERIAL_BARCODE, @pMATERIAL_ID_LOCAL, (SELECT * FROM [wms].OP_WMS_FUNC_GETMATERIAL_DESC(@MATERIAL_BARCODE, @pCLIENT_ID_LOCAL)), NULL, NULL, @SOURCE_LICENSE, NULL, @SOURCE_LOCATION, 'PUERTA_1', @pCLIENT_ID_LOCAL, (SELECT * FROM [wms].OP_WMS_FUNC_GETCLIENT_NAME(@pCLIENT_ID_LOCAL)), (@QUANTITY_UNITS * -1), ISNULL((SELECT ISNULL([WAREHOUSE_PARENT], 'BODEGA_DEF') FROM [wms].OP_WMS_SHELF_SPOTS WHERE LOCATION_SPOT = @SOURCE_LOCATION), 'BODEGA_DEF'), NULL, 'TAREA_REABASTECIMIENTO', @pCODIGO_POLIZA, @SOURCE_LICENSE, 'PROCESSED', @WAVE_PICKING_ID, @WAVE_PICKING_ID, 0, @BATCH, @DATE_EXPIRATION)

    -- ----------------------------------------------------------------------------------
    -- Se rebaja el inventario de la licencia origen
    -- ----------------------------------------------------------------------------------
        UPDATE
            [wms].[OP_WMS_INV_X_LICENSE]
		SET	
            [QTY] = [QTY] - @QUANTITY_UNITS
           ,[LAST_UPDATED] = GETDATE()
           ,[LAST_UPDATED_BY] = @LOGIN_ID
        WHERE
            [LICENSE_ID] = @SOURCE_LICENSE
            AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;



    -- ----------------------------------------------------------------------------------
    -- Se actualiza la licencia origen
    -- ----------------------------------------------------------------------------------
        UPDATE
            [wms].[OP_WMS_LICENSES]
		SET	
            [LAST_UPDATED] = GETDATE()
           ,[LAST_UPDATED_BY] = @LOGIN_ID
        WHERE
            [LICENSE_ID] = @SOURCE_LICENSE;

        UPDATE
            [wms].[OP_WMS_LICENSES]
		SET	
            [CURRENT_LOCATION] = @TARGET_LOCATION
        WHERE
            [LICENSE_ID] = @NEW_LICENSE_ID;

    -- ----------------------------------------------------------------------------------
    -- Valida si la ubicaicon es de piso
    -- ----------------------------------------------------------------------------------
        IF @TYPE_LOCATION = 'PISO'
        BEGIN
            UPDATE
                [wms].[OP_WMS_LICENSES]
			SET	
                [USED_MT2] = @MT2
            WHERE
                [LICENSE_ID] = @SOURCE_LICENSE;
        END;

    -- ----------------------------------------------------------------------------------
    -- Validamos si el material es master pack
    -- ----------------------------------------------------------------------------------
        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [wms].[OP_WMS_MATERIALS] [M]
                    WHERE
                        [M].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
                        AND [M].[IS_MASTER_PACK] = 1 )
        BEGIN
            EXEC [wms].[OP_WMS_INSERT_MASTER_PACK_BY_REALLOC_PARTIAL] @SOURCE_LICENSE = @SOURCE_LICENSE,
                @TARGET_LICENSE = @NEW_LICENSE_ID,
                @MATERIAL_ID = @pMATERIAL_ID_LOCAL,
                @QTY_REALLOC = @QUANTITY_UNITS;
        END;

    -- ----------------------------------------------------------------------------------
    -- Actualizamo la cantidad de la tarea
    -- ----------------------------------------------------------------------------------
        UPDATE
            [wms].[OP_WMS_TASK_LIST]
		SET	
			[QUANTITY_PENDING] = [QUANTITY_PENDING]
			- @QUANTITY_UNITS
        WHERE
            [WAVE_PICKING_ID] = @WAVE_PICKING_ID
            AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
            AND [LICENSE_ID_SOURCE] = @SOURCE_LICENSE
            AND [LOCATION_SPOT_TARGET] = @TARGET_LOCATION;

    -- ----------------------------------------------------------------------------------
    -- Validamos si podemos finalizar la tarea
    -- ----------------------------------------------------------------------------------    
        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [wms].[OP_WMS_TASK_LIST] [T]
                    WHERE
                        [T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
                        AND [T].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
                        AND [T].[LICENSE_ID_SOURCE] = @SOURCE_LICENSE
                        AND [LOCATION_SPOT_TARGET] = @TARGET_LOCATION
                        AND [T].[QUANTITY_PENDING] = 0 )
        BEGIN
            UPDATE
                [wms].[OP_WMS_TASK_LIST]
			SET	
                [IS_COMPLETED] = 1
               ,[COMPLETED_DATE] = GETDATE()
            WHERE
                [WAVE_PICKING_ID] = @WAVE_PICKING_ID
                AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL
                AND [CODIGO_POLIZA_TARGET] = @pCODIGO_POLIZA
                AND [LOCATION_SPOT_TARGET] = @TARGET_LOCATION
                AND [LICENSE_ID_SOURCE] = @SOURCE_LICENSE;

        END;

        EXEC [wms].[OP_WMS_SP_MASTER_PACK_CASCADE_EXPLODE_IN_REPLENISHMENT] @MATERIAL_ID = @pMATERIAL_ID_LOCAL,
			@NEW_LICENSE = @NEW_LICENSE_ID,
			@SOURCE_LICENSE = @SOURCE_LICENSE,
			@WAVE_PICKING_ID = @WAVE_PICKING_ID,
			@LOGIN_ID = @LOGIN_ID;

        COMMIT TRANSACTION;

        SELECT
            @RESULT = 'OK';

        SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('1' AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH

		PRINT ERROR_MESSAGE();
		IF @@TRANCOUNT > 0
		BEGIN
        ROLLBACK TRANSACTION;
		END; 
			
        SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,CAST('' AS VARCHAR) [DbData];

        SELECT
            @RESULT = ERROR_MESSAGE();
    END CATCH;

END;