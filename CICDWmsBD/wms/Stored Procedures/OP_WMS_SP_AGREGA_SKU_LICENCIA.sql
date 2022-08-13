-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	27-6-2016
-- Description:			Insertar un detalle a la licencia

-- Modificacion:        hector.gonzalez
-- Fecha de Creacion: 	13-03-2016
-- Description:			    Se agrego la suma a QTY_ENTERED al UPDATE

-- Modificacion 07-Nov-16 @ A-Team Sprint 4
-- alberto.ruiz
-- Se agrego la consulta para saber si maneja serie o no el material

-- Modificacion 29-03-17 @ ErgonTeam Sprint Hyper
-- hector.gonzalez
-- Se agrego la obtencion del acuerdo comercial de la licencia 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-19 Team ERGON - Sprint epona
-- Description:	 Validar que si el material maneja batch y ya existe el material retorne un error comunicando que no pueden existir el mismo producto con diferentes batch en la misma licencia. 
--                Validar que si el existe un material masterpack o componente en la licencia no pueda contener el mismo tipo de producto por ejemplo unidades de producto A y cajas de producto A 

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-06-20 Team ERGON - Sprint BreathOfTheWeild
-- Description:	 Se agrego que si el material maneja serie, que obtenga el lote ingresado para la [OP_WMS_INV_X_LICENSE]

-- Modificacion 31-05-17 @ ErgonTeam Sprint sheik
-- hector.gonzalez
-- Se modifico la forma en la que hace el update, se valida si maneja serie para obtener el numero exacto de series que tiene el material

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-04 @ Team REBORN - Sprint 
-- Description:	   Se agrega SP OP_WMS_SP_ADD_STATUS_OF_MATERIAL_BY_LICENSE y validacion para ver si es el mismo sku en la misma licencia

-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-09-12 @ Team REBORN - Sprint Collin
-- Description:	   Se agrega los parametros tono, calibre y se agrego la funcionalidad de poder insertar en la tabla de tono y cablibre.

-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-09-19 @ Team REBORN - Sprint Collin
-- Description:	   Se agrego el la validacion de que la recepcion proviene de erp.

-- Modificacion 1/30/2018 @ REBORN-Team Sprint Trotzdem
-- rodrigo.gomez
-- Se agrega la validacion de clases en la ubicacion para la licencia

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180726 GForce@FocaMonje 
-- Description:			    se agrega validacion de materiales para recepcion dirigida para recepcion por erp
--							se valida siempre y cuando el parametro diga que se tiene que validar

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181910 GForce@Langosta
-- Description:			se corrige bug al reemplazar la cantidad desde el movil

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20182510 GForce@Mamba
-- Description:         Se agrega parametro de licencia origen, la cual se envia desde una reubicacion parcial, con este parametro 
--						validamos que al contar el inventario para documentos excluya el inventario de la licencia origen

-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2018-Oct-2018 GForce@Mamba
-- Description:         Se agregaron los campos de unidad de medida.


-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	19-Dec-2018 GForce@Perezoso
-- Description:         Se agrego la validacion de que no tome en cuenta las licencias que no esten ubicadas cuando la recepcion es por documento y este acitivo el parametro

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190207 GForce@Suricato
-- Descripcion:			se graba informacion del proveedor en el registro de inventario por licencia para agilizar las consultas sobre el inventario

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	11-Julio-2019 GForce@Dublin
-- Descripcion:			Se agregan campos IDLE y PROJECT_ID que se heredan de la licencia original y se insertan el la nueva en caso de reubicacion.

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	18-Julio-2019 GForce@Dublin
-- Descripcion:			Se inserta nuevo registro con la licencia nueva si maneja proyecto la reubicacion en el inventario reservado por proyecto.


-- Autor:				marvin.solares
-- Fecha de Creacion: 	31-Julio-2019 GForce@Dublin
-- Descripcion:			se agrega clausula where en query de proveedor

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	11-Diciembre-2019 GForce@Kioto
-- Descripcion:			Se agrega validacion que permite autorizar el almacenar excedente del material de la poliza

-- Autor:				Elder Lucas
-- Fecha de Creacion: 	19-Mayo-2021
-- Descripcion:			Se maneja nuevo tipo de error cuando el estado del material recibido no cooincide con el estado escogido en la demanda de despacho

/*

Ejemplo de ejecucion:

DECLARE
	@pTOTAL_SKUs NUMERIC(18 ,0)
	,@pResult VARCHAR(500);
EXEC [wms].[OP_WMS_SP_AGREGA_SKU_LICENCIA] @pLICENSE_ID = NULL , -- numeric(18, 0)
	@pBARCODE = '' , -- varchar(25)
	@pQTY = NULL , -- numeric(18, 4)
	@pLAST_LOGIN = '' , -- varchar(25)
	@pVOLUME_FACTOR = NULL , -- numeric(18, 2)
	@pWEIGTH = NULL , -- numeric(18, 2)
	@pComments = '' , -- varchar(250)
	@pSerial = '' , -- varchar(50)
	@pAcuerdoComercial = '' , -- varchar(15)
	@pTOTAL_SKUs = @pTOTAL_SKUs OUTPUT , -- numeric(18, 0)
	@pSTATUS = '' , -- varchar(25)
	@pResult = @pResult OUTPUT , -- varchar(500)
	@DATE_EXPIRATION = '2017-09-20 00:59:05' , -- date
	@BATCH = '' , -- varchar(50)
	@VIN = '' , -- varchar(40)
	@PARAM_NAME = '' , -- varchar(50)
	@ACTION = '' , -- varchar(20)
	@TONE = '' , -- varchar(20)
	@CALIBER = '' -- varchar(20)

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AGREGA_SKU_LICENCIA]
(
    @pLICENSE_ID NUMERIC(18, 0),
    @pBARCODE VARCHAR(25),
    @pQTY NUMERIC(18, 4),
    @pLAST_LOGIN VARCHAR(25),
    @pVOLUME_FACTOR NUMERIC(18, 2),
    @pWEIGTH NUMERIC(18, 2),
    @pComments VARCHAR(250),
    @pSerial VARCHAR(50),
    @pAcuerdoComercial VARCHAR(15),
    @pTOTAL_SKUs NUMERIC(18, 0) OUTPUT,
    @pSTATUS VARCHAR(25),
    @pResult VARCHAR(500) OUTPUT,
    @DATE_EXPIRATION DATE,
    @BATCH VARCHAR(50),
    @VIN VARCHAR(40),
    @PARAM_NAME VARCHAR(50) = 'ESTADO_DEFAULT',
    @ACTION VARCHAR(20) = 'ADD', --INSERT ADD UPDATE
    @TONE VARCHAR(20) = NULL,
    @CALIBER VARCHAR(20) = NULL,
    @SOURCE_LICENSE_ID NUMERIC(18, 0) = NULL,
    @ENTERED_MEASUREMENT_UNIT VARCHAR(50) = NULL,
    @ENTERED_MEASUREMENT_UNIT_QTY NUMERIC(18, 4) = NULL,
    @ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR NUMERIC(18, 4) = NULL,
	@TASK_ID_RECTIFICATION NUMERIC = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT,
            @ErrorCode INT,
            @pMATERIAL_ID VARCHAR(50),
            @pSERIAL_ID VARCHAR(50),
            @pAUDIT_ID NUMERIC(18, 0),
            @pCLIENT_ID_LOCAL VARCHAR(25),
            @pIS_CAR NUMERIC(18, 0),
            @ERROR VARCHAR(500),
            @STATUS_CODE VARCHAR(50) = '',
            @STATUS_NAME VARCHAR(100) = '',
            @BLOCKS_INVENTORY INT = 0,
            @ALLOW_REALLOC INT = 0,
            @TARGET_LOCATION VARCHAR(25) = '',
            @DESCRIPTION VARCHAR(200) = '',
            @COLOR VARCHAR(20) = '',
            @STATUS_ID INT,
            @HANDEL_SERIEAL INT = 0,
            @HANDEL_TONE INT = 0,
            @HANDEL_CALIBER INT = 0,
            @TONE_AND_CALIBER_ID INT = NULL,
            @LOCKED_BY_INTERFACES INT = 0,
            @RECEPTION_HEADER_ID INT = 0,
            @POLIZA_RECEPTION VARCHAR(25),
            @MAX_QTY NUMERIC(18, 4),
            @CURRENT_CLASS INT = 0,
            @ALLOW_DECIMAL_VALUE INT = 0,
            @MATERIAL_CLASS INT,
            @IDLE INT = 0,
            @PROJECT_ID UNIQUEIDENTIFIER = NULL,
            @PK_LINE AS INTEGER = 0,
            @ALLOWS_TO_STORE_MORE_QUANTITY INT = 0,
            @REGIME VARCHAR(50) = 'GENERAL',
            @QTY_TRANS_MATERIAL NUMERIC(18, 4) = 0,
            @QTY_TOTAL_IN_TRANS NUMERIC(18, 4) = 0,
			@STATUS_CODE_SOURCE VARCHAR(30),
			@TASK_SUBTYPE VARCHAR(30);
    --,@ERROR_CODE INT = -1;

    DECLARE @STATUS_TB TABLE
    (
        [RESULTADO] INT,
        [MENSAJE] VARCHAR(15),
        [CODIGO] INT,
        [STATUS_ID] INT
    );

    DECLARE @LICENSE_CLASSES TABLE
    (
        [CLASS_ID] INT,
        [CLASS_NAME] VARCHAR(50),
        [CLASS_DESCRIPTION] VARCHAR(250),
        [CLASS_TYPE] VARCHAR(50),
        [CREATED_BY] VARCHAR(50),
        [CREATED_DATETIME] DATETIME,
        [LAST_UPDATED_BY] VARCHAR(50),
        [LAST_UPDATED] DATETIME,
        [PRIORITY] INT
    );
    --
    DECLARE @COMPATIBLE_CLASSES TABLE
    (
        [CLASS_ID] INT
    );

    BEGIN TRY
        BEGIN
            BEGIN TRAN;
            IF @BATCH = ''
            BEGIN
                SELECT @DATE_EXPIRATION = NULL;
            END;

            SELECT @pSERIAL_ID = 'N/A';

            --SE OBTIENE EL CLIENTE
            SELECT @pCLIENT_ID_LOCAL =
            (
                SELECT [CLIENT_OWNER]
                FROM [wms].[OP_WMS_LICENSES]
                WHERE [LICENSE_ID] = @pLICENSE_ID
            );
            --SE OBTIENE EL MATERIAL ID
            SELECT @pMATERIAL_ID = [MATERIAL_ID],
                   @MATERIAL_CLASS = [MATERIAL_CLASS],
                   @ALLOW_DECIMAL_VALUE = [ALLOW_DECIMAL_VALUE]
            FROM [wms].[OP_WMS_MATERIALS]
            WHERE (
                      [BARCODE_ID] = @pBARCODE
                      OR [ALTERNATE_BARCODE] = @pBARCODE
                  )
                  AND [CLIENT_OWNER] = @pCLIENT_ID_LOCAL;

            -- ------------------------------------------------------------------------------------
            -- OBTENEMOS EL REGIMEN DE LA LICENCIA
            -- ------------------------------------------------------------------------------------
            SELECT @REGIME = [REGIMEN]
            FROM [wms].[OP_WMS_LICENSES]
            WHERE [LICENSE_ID] = @pLICENSE_ID;
            --
            IF @ALLOW_DECIMAL_VALUE = 0
               AND FLOOR(@pQTY) <> CEILING(@pQTY)
            BEGIN
                SELECT @ErrorCode = 132121;
                RAISERROR(N'La cantidad no debe de tener decimales.', 16, 1);
                RETURN;
            END;

            -- ------------------------------------------------------------------------------------
            -- OBTIENE EL PARAMETRO VALIDATE_POLICY_QUANTITY, VERIFICA SI PUEDE ALMACENAR EL PRODUCTO EXCEDENTE DE LA POLIZA
            -- ------------------------------------------------------------------------------------
            SELECT @ALLOWS_TO_STORE_MORE_QUANTITY = CAST([VALUE] AS INT)
            FROM [wms].[OP_WMS_PARAMETER]
            WHERE [GROUP_ID] = 'VALIDATION_FISCAL'
                  AND [PARAMETER_ID] = 'VALIDATE_POLICY_QUANTITY';

            -- ------------------------------------------------------------------------------------
            -- validacion de recepcion dirigida por ordenes de compra
            -- ------------------------------------------------------------------------------------
            DECLARE @VALIDA_DOCUMENTO_RECEPCION INT = 0;
            DECLARE @SOURCE_RECEPTION VARCHAR(20) = 'PURCHASE_ORDER';
			DECLARE @SOURCE_TRANSFER VARCHAR(20) = 'ERP_TRANSFER';
            DECLARE @SOURCE_INVOICE VARCHAR(20) = 'INVOICE';

            SELECT TOP 1
                @VALIDA_DOCUMENTO_RECEPCION = [NUMERIC_VALUE]
            FROM [wms].[OP_WMS_CONFIGURATIONS]
            WHERE [PARAM_TYPE] = 'SISTEMA'
                  AND [PARAM_GROUP] = 'RECEPCION'
                  AND [PARAM_NAME] = 'VALIDA_RECEPCION_DIRIGIDA';

            IF @VALIDA_DOCUMENTO_RECEPCION = 0
            BEGIN
                SET @SOURCE_RECEPTION = 'INVOICE'; --cuando el parámetro es 0 debe hacer el flujo normal
            END;

            -- ------------------------------------------------------------------------------------
            -- VERIFICA SI EL REGIMEN ES FISCAL
            -- ------------------------------------------------------------------------------------
            IF (@REGIME = 'FISCAL')
            BEGIN
                PRINT '';

                -- ------------------------------------------------------------------------------------
                -- VERIFICA LA CANTIDAD DE MATERIA A INGRESAR EN LA LICENCIA CON LA DEL DETALLE DE LA POLIZA
                -- ------------------------------------------------------------------------------------
                IF EXISTS
                (
                    SELECT TOP 1
                        1
                    FROM [wms].[OP_WMS_LICENSES] [L]
                        INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                            ON ([PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA])
                        INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
                            ON ([PD].[DOC_ID] = [PH].[DOC_ID])
                    WHERE [L].[LICENSE_ID] = @pLICENSE_ID
                )
                BEGIN

                    -- ------------------------------------------------------------------------------------
                    -- OBTIENE LA CANTIDAD MAXIMA DE LA POLIZA POR MATERIAL
                    -- ------------------------------------------------------------------------------------
                    SELECT @MAX_QTY = [PD].[QTY]
                    FROM [wms].[OP_WMS_LICENSES] [L]
                        INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                            ON ([PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA])
                        INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
                            ON ([PD].[DOC_ID] = [PH].[DOC_ID])
                    WHERE [L].[LICENSE_ID] = @pLICENSE_ID
                          AND [PD].[MATERIAL_ID] = @pMATERIAL_ID;


                    -- ------------------------------------------------------------------------------------
                    -- SI ES UN UPDATE DEL MATERIAL VALIDA LO QUE YA SE INGRESO DE LA CANTIDAD
                    -- ------------------------------------------------------------------------------------

                    SELECT @QTY_TRANS_MATERIAL = SUM([T].[QUANTITY_UNITS])
                    FROM [wms].[OP_WMS_LICENSES] [L]
                        INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                            ON ([PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA])
                        INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
                            ON ([PD].[DOC_ID] = [PH].[DOC_ID])
                        LEFT JOIN [wms].[OP_WMS_TRANS] [T]
                            ON (
                                   [T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
                                   AND [T].[MATERIAL_CODE] = [PD].[MATERIAL_ID]
                               )
                    WHERE [L].[LICENSE_ID] = @pLICENSE_ID
                          AND [PD].[MATERIAL_ID] = @pMATERIAL_ID
                          AND [T].[TRANS_TYPE] = 'INGRESO_FISCAL'
                    GROUP BY [PD].[MATERIAL_ID];

                    SET @QTY_TOTAL_IN_TRANS = @QTY_TRANS_MATERIAL + @pQTY;

                    -- ------------------------------------------------------------------------------------
                    -- SE AGREGA VERIFICACION SI SE TIENE ACTIVO EL PARAMETRO PARA ACEPTAR CANTIDAD EXCEDENTE DE LA POLIZA
                    -- ------------------------------------------------------------------------------------
                    IF (@QTY_TOTAL_IN_TRANS > @MAX_QTY AND @ALLOWS_TO_STORE_MORE_QUANTITY = 0)
                    BEGIN
                        SELECT @ErrorCode = 1111;
                        RAISERROR(
                                     N'La cantidad recepcionada excede a la cantidad del documento para el material.',
                                     16,
                                     1
                                 );
                        RETURN;
                    END;

                --
                END;


            END;

            --

            IF EXISTS
            (
                SELECT TOP 1
                    1
                FROM [wms].[OP_WMS_LICENSES] [L]
                    INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                        ON [PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA]
                    INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
                        ON [RH].[DOC_ID_POLIZA] = [PH].[DOC_ID]
                WHERE [L].[LICENSE_ID] = @pLICENSE_ID
                      AND
                      (
                          [RH].[SOURCE] = @SOURCE_RECEPTION
                          OR [RH].[SOURCE] = @SOURCE_INVOICE
						  OR [RH].[SOURCE] = @SOURCE_TRANSFER
                      )
                      AND [RH].[IS_POSTED_ERP] <> 1
            )
            BEGIN
                -- ------------------------------------------------------------------------------------
                -- Obtiene el reception headerid y taskid
                -- ------------------------------------------------------------------------------------
                DECLARE @TASK_ID NUMERIC(18, 0);

                SELECT TOP 1
                    @RECEPTION_HEADER_ID = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID],
                    @POLIZA_RECEPTION = [RH].[DOC_ID_POLIZA],
                    @TASK_ID = [RH].[TASK_ID],
					@STATUS_CODE_SOURCE = [TL].[STATUS_CODE],
					@TASK_SUBTYPE = [TL].[TASK_SUBTYPE]
                FROM [wms].[OP_WMS_LICENSES] [L]
                    INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                        ON [PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA]
                    INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
                        ON [RH].[DOC_ID_POLIZA] = [PH].[DOC_ID]
					INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
						ON [TL].SERIAL_NUMBER = [RH].[TASK_ID] 
                WHERE [L].[LICENSE_ID] = @pLICENSE_ID;

				
				-- ------------------------------------------------------------------------------------
                -- Se comprueba que el estado escogido para el material recibido coincida con el estado escogido en la demanda de despacho
                -- ------------------------------------------------------------------------------------	

				--IF (@TASK_SUBTYPE = 'RECEPCION_TRASLADO' AND @PARAM_NAME != @STATUS_CODE_SOURCE)
				--BEGIN 
				--SELECT
				--	@pRESULT = 'Error, el estado del material no coincide con el estado escogido en la demanda de despacho' --Debe mejorarse esta validación
				--	,@ErrorCode = 5007;
				--	RAISERROR (@pRESULT, 16, 1);
				--	END;

                -- ------------------------------------------------------------------------------------
                -- Obtiene el maximo a recepcionar en la recepcion
                -- ------------------------------------------------------------------------------------		
                SELECT [RD].[UNIT],
                       SUM(ISNULL([RD].[QTY], 0)) * ISNULL([UMM].[QTY], 1) [QTY]
                INTO [#MAX_QTY]
                FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
                    INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD]
                        ON [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
                    LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM]
                        ON [UMM].[MATERIAL_ID] = [RD].[MATERIAL_ID]
                           AND [RD].[UNIT] = [UMM].[MEASUREMENT_UNIT]
                WHERE [RD].[MATERIAL_ID] = @pMATERIAL_ID
                      AND [RH].[TASK_ID] = @TASK_ID
                GROUP BY [RD].[UNIT],
                         [RD].[QTY],
                         [UMM].[QTY];

                SELECT @MAX_QTY = SUM([QTY])
                FROM [#MAX_QTY];
                -- ------------------------------------------------------------------------------------
                -- Obtiene lo ya recepcionado, cuando action es 'UPDATE' no debo restar de MAX_QTY pues la cantidad entrante sera la nueva cantidad
                -- y esa es la cantidad que se debe validar
                -- ------------------------------------------------------------------------------------
                IF @ACTION <> 'UPDATE'
                BEGIN
                    SELECT @MAX_QTY = @MAX_QTY - ISNULL(SUM([IL].[QTY]), 0)
                    FROM [wms].[OP_WMS_LICENSES] [L]
                        INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
                            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
                    WHERE [IL].[MATERIAL_ID] = @pMATERIAL_ID
                          AND [L].[LICENSE_ID] <> ISNULL(@SOURCE_LICENSE_ID, 0)
                          AND [L].[CODIGO_POLIZA] = CAST(@POLIZA_RECEPTION AS VARCHAR(25))
                          AND [L].[CURRENT_WAREHOUSE] IS NOT NULL;
                END;

                -- ------------------------------------------------------------------------------------
                -- SE AGREGA VERIFICACION SI SE TIENE ACTIVO EL PARAMETRO PARA ACEPTAR CANTIDAD EXCEDENTE DE LA POLIZA
                -- ------------------------------------------------------------------------------------
                IF (@pQTY > @MAX_QTY AND @ALLOWS_TO_STORE_MORE_QUANTITY = 0)
                BEGIN
                    SELECT @ErrorCode = 1111;
                    RAISERROR(N'La cantidad recepcionada excede a la cantidad del documento para el material.', 16, 1);
                    RETURN;
                END;
            END;

            -- ------------------------------------------------------------------------------------
            -- Valida la compatibilidad de clases
            -- ------------------------------------------------------------------------------------
            INSERT INTO @LICENSE_CLASSES
            SELECT [CLASS_ID],
                   [CLASS_NAME],
                   [CLASS_DESCRIPTION],
                   [CLASS_TYPE],
                   [CREATED_BY],
                   [CREATED_DATETIME],
                   [LAST_UPDATED_BY],
                   [LAST_UPDATED],
                   [PRIORITY]
            FROM [wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@pLICENSE_ID);
            --
            INSERT INTO @COMPATIBLE_CLASSES
            SELECT [CLASS_ID]
            FROM [wms].[OP_WMS_CLASS];
            --
            WHILE EXISTS (SELECT TOP 1 1 FROM @LICENSE_CLASSES)
            BEGIN
                SELECT TOP 1
                    @CURRENT_CLASS = [CLASS_ID]
                FROM @LICENSE_CLASSES;
                --
                DELETE [CC]
                FROM @COMPATIBLE_CLASSES [CC]
                    LEFT JOIN [wms].[OP_WMS_CLASS_ASSOCIATION] [CA]
                        ON [CC].[CLASS_ID] = [CA].[CLASS_ASSOCIATED_ID]
                           AND [CA].[CLASS_ID] = @CURRENT_CLASS
                WHERE [CA].[CLASS_ID] IS NULL;
                --
                DELETE FROM @LICENSE_CLASSES
                WHERE [CLASS_ID] = @CURRENT_CLASS;
            END;
            --
            INSERT INTO @COMPATIBLE_CLASSES
            SELECT [CLASS_ID]
            FROM [wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](@pLICENSE_ID);
            --
            IF NOT EXISTS
            (
                SELECT TOP 1
                    1
                FROM @COMPATIBLE_CLASSES
                WHERE [CLASS_ID] = @MATERIAL_CLASS
            )
            BEGIN
                SELECT @ErrorCode = 1105;
                RAISERROR(N'La clase del material no es compatible con las clases actualmente en la licencia.', 16, 1);
                RETURN;
            END;

            --Obtenemos si el producto maneja serie y se valida el lote 

            SELECT TOP 1
                @HANDEL_SERIEAL = [M].[SERIAL_NUMBER_REQUESTS],
                @HANDEL_TONE = [M].[HANDLE_TONE],
                @HANDEL_CALIBER = [M].[HANDLE_CALIBER]
            FROM [wms].[OP_WMS_MATERIALS] [M]
            WHERE [M].[MATERIAL_ID] = @pMATERIAL_ID;

            -- ----------------------------------------------------------------------------------
            -- Se valida si el material maneja tono o calibre
            -- ----------------------------------------------------------------------------------

            IF @HANDEL_TONE <> 0
               OR @HANDEL_CALIBER <> 0
            BEGIN

                INSERT INTO @STATUS_TB
                (
                    [RESULTADO],
                    [MENSAJE],
                    [CODIGO],
                    [STATUS_ID]
                )
                EXEC [wms].[OP_WMS_SP_ADD_TONE_AND_CALIBER_BY_MATERIAL] @MATERIAL_ID = @pMATERIAL_ID,
                                                                            @TONE = @TONE,
                                                                            @CALIBER = @CALIBER;

                IF 1 <>
                (
                    SELECT TOP 1 [RESULTADO] FROM @STATUS_TB
                )
                BEGIN
                    SELECT @ERROR =
                    (
                        SELECT TOP 1 [MENSAJE] FROM @STATUS_TB
                    );
                    RAISERROR(@ERROR, 16, 1);
                END;
                ELSE
                BEGIN
                    SET @TONE_AND_CALIBER_ID =
                    (
                        SELECT TOP 1 [STATUS_ID] FROM @STATUS_TB
                    );
                    DELETE FROM @STATUS_TB;
                END;
            END;


            -- ----------------------------------------------------------------------------------
            -- Se valida si ya se inserto el sku en la misma licencia
            -- ----------------------------------------------------------------------------------
            IF EXISTS
            (
                SELECT 1
                FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
                WHERE [IXL].[LICENSE_ID] = @pLICENSE_ID
                      AND [IXL].[MATERIAL_ID] = @pMATERIAL_ID
            )
               AND @ACTION = 'INSERT'
               AND @HANDEL_SERIEAL <> 1
            BEGIN
                SET @pResult = 'SKU_REPETIDO';

                COMMIT TRAN;
                RETURN;

            END;

            --SE OBTIENE EL ACUERDO COMERCIAL DE LA LICENCIA
            SELECT @pAcuerdoComercial = [P].[ACUERDO_COMERCIAL]
            FROM [wms].[OP_WMS_POLIZA_HEADER] [P]
                INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                    ON [P].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA]
            WHERE [L].[LICENSE_ID] = @pLICENSE_ID;

            -- ----------------------------------------------------------------------------------
            -- Se obtinene los datos del estado
            -- ----------------------------------------------------------------------------------
            SELECT @STATUS_CODE = [C].[PARAM_NAME],
                   @STATUS_NAME = [C].[PARAM_CAPTION],
                   @BLOCKS_INVENTORY = CASE [C].[SPARE1]
                                           WHEN 'SI' THEN
                                               1
                                           WHEN 'NO' THEN
                                               0
                                           WHEN 1 THEN
                                               1
                                           ELSE
                                               0
                                       END,
                   @ALLOW_REALLOC = CASE [C].[SPARE2]
                                        WHEN 'SI' THEN
                                            1
                                        WHEN 'NO' THEN
                                            0
                                        WHEN 1 THEN
                                            1
                                        ELSE
                                            0
                                    END,
                   @TARGET_LOCATION = [C].[SPARE3],
                   @DESCRIPTION = [C].[TEXT_VALUE],
                   @COLOR = [C].[COLOR]
            FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
            WHERE [C].[PARAM_NAME] = @PARAM_NAME
                  AND [C].[PARAM_GROUP] = 'ESTADOS';


            -- ----------------------------------------------------------------------------------
            -- Se valida si se quiere hacer un UPDATE
            -- ----------------------------------------------------------------------------------
            IF @ACTION = 'UPDATE'
               AND @HANDEL_SERIEAL <> 1
            BEGIN
                UPDATE [wms].[OP_WMS_INV_X_LICENSE]
                SET [QTY] = @pQTY,
                    [ENTERED_QTY] = @pQTY,
                    [TERMS_OF_TRADE] = @pAcuerdoComercial,
                    [BATCH] = @BATCH,
                    [DATE_EXPIRATION] = @DATE_EXPIRATION,
                    [VIN] = @VIN,
                    [TONE_AND_CALIBER_ID] = @TONE_AND_CALIBER_ID
                WHERE [LICENSE_ID] = @pLICENSE_ID
                      AND [MATERIAL_ID] = @pMATERIAL_ID;

                UPDATE [S]
                SET [STATUS_CODE] = @STATUS_CODE,
                    [STATUS_NAME] = @STATUS_NAME,
                    [BLOCKS_INVENTORY] = @BLOCKS_INVENTORY,
                    [ALLOW_REALLOC] = @ALLOW_REALLOC,
                    [TARGET_LOCATION] = @TARGET_LOCATION,
                    [DESCRIPTION] = @DESCRIPTION,
                    [COLOR] = @COLOR
                FROM [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S]
                    INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IXL]
                        ON [S].[STATUS_ID] = [IXL].[STATUS_ID]
                WHERE [IXL].[LICENSE_ID] = @pLICENSE_ID
                      AND [IXL].[MATERIAL_ID] = @pMATERIAL_ID;

                COMMIT TRAN;
                SET @pResult = 'OK';

                SELECT 1 AS [Resultado],
                       'Proceso Exitoso' [Mensaje],
                       1 [Codigo],
                       '' [DbData];
                RETURN;
            END;

            --SE VALIDA SI EL PRODUCTO TIENE RELACIONADO UN MASTERPACK
            DECLARE @RES INT;
            EXEC [wms].[OP_WMS_SP_VALIDATE_MASTER_PACK_MATERIAL_IS_IN_LICENCE] @LICENCE_ID = @pLICENSE_ID,
                                                                                   @MATERIAL_ID = @pMATERIAL_ID,
                                                                                   @RESULT = @RES OUTPUT;

            IF @RES = 0
            BEGIN
                SELECT @ERROR = 'No puede ingresar un producto relacionado a un masterpack, ingresado';

                SELECT @ErrorCode = 1112;
                RAISERROR(@ERROR, 16, 1);
            END;



            --SE OBTIENE IS_CAR PARA SABER SI ES CARRO
            SELECT @pIS_CAR =
            (
                SELECT CASE
                           WHEN [M].[IS_CAR] IS NULL THEN
                               0
                           ELSE
                               [M].[IS_CAR]
                       END AS [IS_CAR]
                FROM [wms].[OP_WMS_MATERIALS] AS [M]
                WHERE (
                          [BARCODE_ID] = @pBARCODE
                          OR [ALTERNATE_BARCODE] = @pBARCODE
                      )
                      AND [CLIENT_OWNER] = @pCLIENT_ID_LOCAL
            );
            --SI ES CARRO SE OBTIENE EL AUDIT ID, SERIAL ID Y SE VERIFICA SI EXISTE ESE VIN
            IF (@pIS_CAR = 1)
            BEGIN

                SELECT @pAUDIT_ID =
                (
                    SELECT TOP 1
                        ISNULL([AUDIT_ID], 0)
                    FROM [wms].[OP_WMS_AUDIT_RECEPTION_CONTROL] AS [AUDIT_ID]
                    WHERE [CODIGO_POLIZA] =
                (
                    SELECT [CODIGO_POLIZA]
                    FROM [OP_WMS_LICENSES]
                    WHERE [LICENSE_ID] = @pLICENSE_ID
                )
                    ORDER BY [AUDIT_ID] DESC
                );

                SELECT @pSERIAL_ID =
                (
                    SELECT TOP 1
                        ISNULL([SERIAL_NUMBER], 'N/A') AS [SERIAL_NUMBER]
                    FROM [OP_WMS_AUDIT_RECEPTION_SERIES]
                    WHERE [AUDIT_ID] = @pAUDIT_ID
                          AND [MATERIAL_ID] = @pMATERIAL_ID
                );

                IF EXISTS
                (
                    SELECT [VIN]
                    FROM [wms].[OP_WMS_INV_X_LICENSE]
                    WHERE [VIN] = @VIN
                )
                BEGIN
                    SELECT @ERROR = 'El VIN que ingreso ya existe: ' + @VIN;

                    SELECT @ErrorCode = 1113;
                    RAISERROR(@ERROR, 16, 1);
                END;
            END;

            --Se valida el lote si no maneja serie
            IF @HANDEL_SERIEAL IS NULL
               OR @HANDEL_SERIEAL = 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1
                        1
                    FROM [wms].[OP_WMS_INV_X_LICENSE] [L]
                        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
                            ON [L].[MATERIAL_ID] = [M].[MATERIAL_ID]
                    WHERE [L].[LICENSE_ID] = @pLICENSE_ID
                          AND [M].[BATCH_REQUESTED] = 1
                          AND
                          (
                              [L].[BATCH] <> @BATCH
                              OR [L].[DATE_EXPIRATION] <> @DATE_EXPIRATION
                          )
                          AND [L].[MATERIAL_ID] = @pMATERIAL_ID
                )
                BEGIN
                    SELECT @ERROR
                        = 'No puede ingresar el mismo producto con diferente lote o fecha de expiración en la licencia.';

                    SELECT @ErrorCode = 1114;
                    RAISERROR(@ERROR, 16, 1);
                END;
            END;

            --Se valida si el material maneja tono o calibre       

            IF @HANDEL_TONE <> 0
               OR @HANDEL_CALIBER <> 0
            BEGIN
                IF EXISTS
                (
                    SELECT TOP 1
                        1
                    FROM [wms].[OP_WMS_INV_X_LICENSE] [L]
                    WHERE [L].[LICENSE_ID] = @pLICENSE_ID
                          AND [L].[MATERIAL_ID] = @pMATERIAL_ID
                          AND [L].[TONE_AND_CALIBER_ID] <> @TONE_AND_CALIBER_ID
                )
                BEGIN
                    SELECT @ERROR = 'El tono o calibre es diferente a la ingresada anteriormente.';

                    SELECT @ErrorCode = 1115;
                    RAISERROR(@ERROR, 16, 1);
                END;
            END;



            IF EXISTS
            (
                SELECT 1
                FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
                    INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S]
                        ON [IXL].[STATUS_ID] = [S].[STATUS_ID]
                WHERE [S].[STATUS_CODE] <> @PARAM_NAME
                      AND [IXL].[LICENSE_ID] = @pLICENSE_ID
                      AND [IXL].[MATERIAL_ID] = @pMATERIAL_ID
            )
            BEGIN
                SELECT @ERROR = 'No puede ingresar el mismo producto con diferente estado en la licencia.';

                SELECT @ErrorCode = 1116;
                RAISERROR(@ERROR, 16, 1);
            END;

            -- ----------------------------------------------------------------------------------
            -- Obtenemos la informacion del estado
            -- ----------------------------------------------------------------------------------

            IF @ACTION = 'INSERT'
               OR @ACTION = 'ADD'
            BEGIN

                INSERT INTO @STATUS_TB
                (
                    [RESULTADO],
                    [MENSAJE],
                    [CODIGO],
                    [STATUS_ID]
                )
                EXEC [wms].[OP_WMS_SP_ADD_STATUS_OF_MATERIAL_BY_LICENSE] @STATUS_CODE = @STATUS_CODE,
                                                                             @STATUS_NAME = @STATUS_NAME,
                                                                             @BLOCKS_INVENTORY = @BLOCKS_INVENTORY,
                                                                             @ALLOW_REALLOC = @ALLOW_REALLOC,
                                                                             @TARGET_LOCATION = @TARGET_LOCATION,
                                                                             @DESCRIPTION = @DESCRIPTION,
                                                                             @COLOR = @COLOR,
                                                                             @LICENSE_ID = @pLICENSE_ID;


                SELECT TOP 1
                    @STATUS_ID = [STATUS_ID]
                FROM @STATUS_TB;
            END;

            SELECT @LOCKED_BY_INTERFACES = 1
            FROM [wms].[OP_WMS_LICENSES] [L]
                INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
                    ON ([L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_SOURCE])
                INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
                    ON ([RDH].[TASK_ID] = [TL].[SERIAL_NUMBER])
            WHERE [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
                  AND [L].[LICENSE_ID] = @pLICENSE_ID
                  AND [RDH].[IS_POSTED_ERP] IN ( 0, -1 )
				  AND [RDH].[IS_FROM_ERP] = 1;


            -- ------------------------------------------------------------------------------------
            -- obtengo datos del proveedor y los agrego al detalle del inventario de la licencia
            -- ------------------------------------------------------------------------------------

            DECLARE @CODE_SUPPLIER VARCHAR(50),
                    @NAME_SUPPLIER VARCHAR(100);

            SELECT TOP 1
                @CODE_SUPPLIER = [CODE_SUPPLIER],
                @NAME_SUPPLIER = [NAME_SUPPLIER]
            FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
                INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                    ON [PH].[DOC_ID] = [RDH].[DOC_ID_POLIZA]
                INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                    ON [L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
            WHERE [L].[LICENSE_ID] = @pLICENSE_ID;

            -- ------------------------------------------------------------------------------------
            --OBTIENE LOS CAMPOS IDLE Y PROJECT_ID DE LA LICENCIA ORIGINAL
            -- ------------------------------------------------------------------------------------
            SELECT @IDLE = [IDLE],
                   @PROJECT_ID = [PROJECT_ID]
            FROM [wms].[OP_WMS_INV_X_LICENSE]
            WHERE [LICENSE_ID] = @SOURCE_LICENSE_ID
                  AND [MATERIAL_ID] = @pMATERIAL_ID;

            --SE VERIFICA SI EXISTE YA ESA LICENCIA Y ESE MATERIAL Y SI SI, SE HACE UN UPDATE A LA LICENCIA DE LO CONTRARIO SE HACE UN INSERT


            IF @HANDEL_SERIEAL <> 0
            BEGIN
                SELECT @pQTY = COUNT([MSN].[LICENSE_ID]),
                       @DATE_EXPIRATION = MAX([MSN].[DATE_EXPIRATION]),
                       @BATCH = MAX([MSN].[BATCH])
                FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MSN]
                WHERE [MSN].[LICENSE_ID] = @pLICENSE_ID
                      AND [MSN].[MATERIAL_ID] = @pMATERIAL_ID
                      AND [MSN].[STATUS] > 0;
            END;

            IF EXISTS
            (
                SELECT *
                FROM [wms].[OP_WMS_INV_X_LICENSE]
                WHERE [LICENSE_ID] = @pLICENSE_ID
                      AND [MATERIAL_ID] = @pMATERIAL_ID
            )
            BEGIN
                IF @HANDEL_SERIEAL <> 0
                BEGIN

                    UPDATE [wms].[OP_WMS_INV_X_LICENSE]
                    SET [QTY] = @pQTY,
                        [ENTERED_QTY] = @pQTY,
                        [TERMS_OF_TRADE] = @pAcuerdoComercial,
                        [BATCH] = @BATCH,
                        [DATE_EXPIRATION] = @DATE_EXPIRATION
                    WHERE [LICENSE_ID] = @pLICENSE_ID
                          AND [MATERIAL_ID] = @pMATERIAL_ID;
                END;
                ELSE
                BEGIN
                    UPDATE [wms].[OP_WMS_INV_X_LICENSE]
                    SET [QTY] = [QTY] + @pQTY,
                        [ENTERED_QTY] = [ENTERED_QTY] + @pQTY,
                        [TERMS_OF_TRADE] = @pAcuerdoComercial
                    WHERE [LICENSE_ID] = @pLICENSE_ID
                          AND [MATERIAL_ID] = @pMATERIAL_ID;

                    -- ------------------------------------------------------------------------------------
                    -- ACTUALIZA LA CANTIDAD SI YA EXISTE EL MATERIAL EN LA LICENCIA, INVENTARIO RESERVADO POR PROYECTO.
                    -- ------------------------------------------------------------------------------------
                    IF @PROJECT_ID IS NOT NULL
                    BEGIN
                        UPDATE [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
                        SET [QTY_LICENSE] = [QTY_LICENSE] + @pQTY,
                            [QTY_RESERVED] = [QTY_RESERVED] + @pQTY
                        WHERE [PROJECT_ID] = @PROJECT_ID
                              AND [LICENSE_ID] = @pLICENSE_ID
                              AND [MATERIAL_ID] = @pMATERIAL_ID;
                    END;

                END;

            END;
            ELSE
            BEGIN
                --
                INSERT INTO [wms].[OP_WMS_INV_X_LICENSE]
                (
                    [LICENSE_ID],
                    [MATERIAL_ID],
                    [QTY],
                    [LAST_UPDATED_BY],
                    [LAST_UPDATED],
                    [MATERIAL_NAME],
                    [VOLUME_FACTOR],
                    [WEIGTH],
                    [COMMENTS],
                    [SERIAL_NUMBER],
                    [BARCODE_ID],
                    [TERMS_OF_TRADE],
                    [STATUS],
                    [DATE_EXPIRATION],
                    [BATCH],
                    [ENTERED_QTY],
                    [VIN],
                    [HANDLE_SERIAL],
                    [STATUS_ID],
                    [TONE_AND_CALIBER_ID],
                    [LOCKED_BY_INTERFACES],
                    [ENTERED_MEASUREMENT_UNIT],
                    [ENTERED_MEASUREMENT_UNIT_QTY],
                    [ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR],
                    [CODE_SUPPLIER],
                    [NAME_SUPPLIER],
                    [IDLE],
                    [PROJECT_ID]
                )
                VALUES
                (   @pLICENSE_ID, @pMATERIAL_ID, @pQTY, @pLAST_LOGIN, CURRENT_TIMESTAMP,
                    (
                        SELECT *
                        FROM [wms].[OP_WMS_FUNC_GETMATERIAL_DESC](   @pBARCODE,
                             (
                                 SELECT [CLIENT_OWNER]
                                 FROM [wms].[OP_WMS_LICENSES]
                                 WHERE [LICENSE_ID] = @pLICENSE_ID
                             )
                                                                     )
                    ), ISNULL(
                       (
                           SELECT [VOLUME_FACTOR]
                           FROM [wms].[OP_WMS_MATERIALS]
                           WHERE [MATERIAL_ID] = @pMATERIAL_ID
                       ),
                       0
                             ), ISNULL(
                                (
                                    SELECT [WEIGTH]
                                    FROM [wms].[OP_WMS_MATERIALS]
                                    WHERE [MATERIAL_ID] = @pMATERIAL_ID
                                ),
                                0
                                      ), @pComments, @pSERIAL_ID, @pBARCODE, @pAcuerdoComercial, @pSTATUS,
                    @DATE_EXPIRATION, @BATCH, @pQTY, @VIN, @HANDEL_SERIEAL, @STATUS_ID, @TONE_AND_CALIBER_ID,
                    @LOCKED_BY_INTERFACES, @ENTERED_MEASUREMENT_UNIT, @ENTERED_MEASUREMENT_UNIT_QTY,
                    @ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR, @CODE_SUPPLIER, @NAME_SUPPLIER, @IDLE, @PROJECT_ID);

                -- ------------------------------------------------------------------------------------
                -- INSERTA UN NUEVO REGISTRO EN INVENTORY_RESERVER_BY_PROJECT, SI MANEJA PROYECTO
                -- ------------------------------------------------------------------------------------

                IF @PROJECT_ID IS NOT NULL
                BEGIN

                    DECLARE @uMATERIAL_NAME AS VARCHAR(150);
                    DECLARE @uTONE AS VARCHAR(20);
                    DECLARE @uCALIBER AS VARCHAR(20);
                    DECLARE @uBATCH AS VARCHAR(50);
                    DECLARE @uSTATUS_CODE AS VARCHAR(100);
                    DECLARE @uDATE_EXPIRATION DATE;

                    -- ------------------------------------------------------------------------------------
                    -- OBTIENE LOS DATOS DEL INVENTARIO RESERVADO DEL PROYECTO
                    -- ------------------------------------------------------------------------------------
                    SELECT @uMATERIAL_NAME = [MATERIAL_NAME],
                           @uTONE = [TONE],
                           @uCALIBER = [CALIBER],
                           @uBATCH = [BATCH],
                           @uSTATUS_CODE = [STATUS_CODE],
                           @uDATE_EXPIRATION = [DATE_EXPIRATION]
                    FROM [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
                    WHERE [PROJECT_ID] = @PROJECT_ID
                          AND [LICENSE_ID] = @SOURCE_LICENSE_ID
                          AND [MATERIAL_ID] = @pMATERIAL_ID;

                    -- ------------------------------------------------------------------------------------
                    -- OBTIENE LA NUEVA LINEA DE LA LICENCIA CREADA
                    -- ------------------------------------------------------------------------------------
                    SELECT @PK_LINE = [PK_LINE]
                    FROM [wms].[OP_WMS_INV_X_LICENSE]
                    WHERE [LICENSE_ID] = @pLICENSE_ID
                          AND [MATERIAL_ID] = @pMATERIAL_ID;

                    INSERT INTO [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
                    (
                        [PROJECT_ID],
                        [PK_LINE],
                        [LICENSE_ID],
                        [MATERIAL_ID],
                        [MATERIAL_NAME],
                        [QTY_LICENSE],
                        [QTY_RESERVED],
                        [QTY_DISPATCHED],
                        [RESERVED_PICKING],
                        [TONE],
                        [CALIBER],
                        [BATCH],
                        [DATE_EXPIRATION],
                        [STATUS_CODE]
                    )
                    VALUES
                    (   @PROJECT_ID,       -- PROJECT_ID - uniqueidentifier
                        @PK_LINE,          -- PK_LINE - numeric
                        @pLICENSE_ID,      -- LICENSE_ID - numeric
                        @pMATERIAL_ID,     -- MATERIAL_ID - varchar(50)
                        @uMATERIAL_NAME,   -- MATERIAL_NAME - varchar(150)
                        @pQTY,             -- QTY_LICENSE - numeric
                        @pQTY,             -- QTY_RESERVED - numeric
                        0,                 -- QTY_DISPATCHED - numeric
                        0,                 -- RESERVED_PICKING - numeric
                        @uTONE,            -- TONE - varchar(20)
                        @uCALIBER,         -- CALIBER - varchar(20)
                        @uBATCH,           -- BATCH - varchar(50)
                        @uDATE_EXPIRATION, -- DATE_EXPIRATION - date
                        @uSTATUS_CODE      -- STATUS_CODE - varchar(100)

                        );

                    -- ------------------------------------------------------------------------------------
                    -- INSERTA UN LOG DEL NUEVO REGISTRO DEL INVENTORY_RESERVED_BY_PROJECT
                    -- ------------------------------------------------------------------------------------

                    INSERT INTO [wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
                    (
                        [TYPE_LOG],
                        [PROJECT_ID],
                        [PK_LINE],
                        [LICENSE_ID],
                        [MATERIAL_ID],
                        [MATERIAL_NAME],
                        [QTY_LICENSE],
                        [QTY_RESERVED],
                        [QTY_DISPATCHED],
                        [PICKING_DEMAND_HEADER_ID],
                        [WAVE_PICKING_ID],
                        [CREATED_BY],
                        [CREATED_DATE]
                    )
                    VALUES
                    (   'INSERT',              -- TYPE_LOG - varchar(20)
                        @PROJECT_ID,           -- PROJECT_ID - uniqueidentifier
                        @PK_LINE,              -- PK_LINE - numeric
                        @pLICENSE_ID,          -- LICENSE_ID - numeric
                        @pMATERIAL_ID,         -- MATERIAL_ID - varchar(50)
                        @uMATERIAL_NAME,       -- MATERIAL_NAME - varchar(150)
                        @pQTY,                 -- QTY_LICENSE - numeric
                        @pQTY,                 -- QTY_RESERVED - numeric
                        0,                     -- QTY_DISPATCHED - numeric
                        0,                     -- PICKING_DEMAND_HEADER_ID - int
                        0,                     -- WAVE_PICKING_ID - numeric
                        'REUBICACION PARCIAL', -- CREATED_BY - varchar(64)
                        GETDATE()              -- CREATED_DATE - datetime
                        );

                END;

            END;

            SELECT @pResult = 'OK';

            UPDATE [wms].[OP_WMS_LICENSES]
            SET [STATUS] = 'ON_PROCESS',
                [LAST_UPDATED] = CURRENT_TIMESTAMP,
                [LAST_UPDATED_BY] = @pLAST_LOGIN
            WHERE [LICENSE_ID] = @pLICENSE_ID;


            SELECT @pTOTAL_SKUs =
            (
                SELECT COUNT([MATERIAL_ID]) AS [TOTAL_COUNT]
                FROM [wms].[OP_WMS_INV_X_LICENSE]
                WHERE [LICENSE_ID] = @pLICENSE_ID
            );
            SELECT 1 AS [Resultado],
                   'Proceso Exitoso' [Mensaje],
                   1 [Codigo],
                   '' [DbData];
            COMMIT TRAN;
        END;

    END TRY
    BEGIN CATCH

        ROLLBACK TRAN;

        SELECT @pResult = ERROR_MESSAGE();
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @ErrorCode [Codigo],
               '' [DbData];
    END CATCH;

END;