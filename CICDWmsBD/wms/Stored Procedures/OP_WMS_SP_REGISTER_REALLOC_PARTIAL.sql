-- =============================================
-- Autor:					---------
-- Fecha de Creacion: 		---------
-- Description:			    ---------

-- Modificacion #001 03-10-2016 @ A-TEAM Sprint 2
-- juancarlos.escalante
-- Se modificó el insert para que se registre el id de la tarea


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-13 Team ERGON - Sprint ERGON V
-- Description:	 Se agrega llamada a SP de OP_WMS_INSERT_MASTER_PACK_BY_REALLOC_PARTIAL  para manera reubicaciones de masterpack. 


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-16 ErgonTeam@BreathOfTheWild
-- Description:	 Validar que si el material maneja serie, realizar de diferente forma el insert de la transacción para que genere una linea por cada serie que este involucrada en la reubicación, verificando la tabla tabla de [OP_WMS_MATERIAL_X_SERIAL_NUMBER], donde las series esten estado 2 (EN_PROCESO) donde corresponda la licencia y el material, con cantidad de 1. 

-- Modificación: rudi.garcia
-- Fecha de Modificación: 2017-09-28 RebornTeam@Collin
-- Description:	 Se agrego la licencia origen cuando esta sea una rebucacion parcial

-- Modificación: rudi.garcia
-- Fecha de Modificación: 20-Dec-2017 RebornTeam@Quiterio
-- Description:	 Se agrego la actualizacion de la licencia orgien para los metros cuadrados

-- Modificacion 1/30/2018 @ REBORN-Team Sprint Trotzdem
-- rodrigo.gomez
-- Se agrega la validacion de clases en la ubicacion para la licencia

-- Modificacion 13-Abr-18 @ GForce Team Sprint Buho 
-- marvin.solares
-- Se graba el valor [PICKING_DEMAND_HEADER_ID] que viene de la licencia origen

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180906 GForce@Jaguarundi
-- Description:			    hereda el id de la ola de la licencia original a la licencia destino

-- Modificacion:			marvin.solares
-- Fecha: 					20180920 GForce@Kiwi 
-- Description:			    se adapta sp para que proceda a colocar el inventario recepcionado a una licencia ya existente de la ubicacion seleccionada

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Mamba
-- Description:		Se modifica para que inserte correctamente el acuerdo comercial en la transaccion

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	11-Julio-2019 GForce@Dublin
-- Description:			Se agrega herencia de ID_PROJECT en caso la licencia este asociado un proyecto.

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	18-Julio-2019 GForce@Dublin
-- Description:			Se agrega validacion si maneja proyecto actualiza la cantidad en el inventario reservado

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	26-Julio-2019 GForce@Dublin
-- Description:			Se agrega STATUS_CODE en insert a la tabla TRANS.

-- Modificacion 		1/29/2020 G-Force@Paris 
-- Autor: 				carlos.lara
-- Historia/Bug:		Product Backlog Item 34990: Registro de espacios físicos por posición
-- Descripcion: 		1/29/2020 - Se agrego el parametro TOTAL_POSITION para asignarle un total de posiciones fisicas
--						a la nueva licencia

/*
-- Ejemplo de Ejecucion:
exec sp_executesql @statement=N'OP_WMS_SP_REGISTER_REALLOC_PARTIAL @pTRADE_AGREEMENT = NULL, @pLOGIN_ID = N''BGOMEZ'', 
@pTRANS_TYPE = N''REUBICACION_PARCIAL'',
@pTRANS_EXTRA_COMMENTS = N''N/A'', 
@pMATERIAL_BARCODE = N''10112'', 
@pMATERIAL_CODE = N''ALZA/10112'', 
@pSOURCE_LICENSE = 658198, 
@pTARGET_LICENSE = 658199, 
@pSOURCE_LOCATION = N'''', 
@pTARGET_LOCATION = N''P09-15B-N5-B'', 
@pCLIENT_OWNER = N''ALZA'', 
@pQUANTITY_UNITS = 150, 
@pSOURCE_WAREHOUSE = N'''', 
@pTARGET_WAREHOUSE = N'''',
@pTRANS_SUBTYPE = N'''', 
@pCODIGO_POLIZA = N''559037'', 
@pLICENSE_ID = 658199, 
@pSTATUS = N''PROCESSED'', 
@pWAVE_PICKING_ID = 0, 
@pTRANS_MT2 = 0,
@pRESULT = N'''', 
@pTASK_ID = NULL, 
@pTOTAL_POSITION= 1'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_REALLOC_PARTIAL]
    @pTRADE_AGREEMENT VARCHAR(25),
    @pLOGIN_ID VARCHAR(25),
    @pTRANS_TYPE VARCHAR(25),
    @pTRANS_EXTRA_COMMENTS VARCHAR(50), --////
    @pMATERIAL_BARCODE VARCHAR(25),
    @pMATERIAL_CODE VARCHAR(25),        --////
    @pSOURCE_LICENSE NUMERIC(18, 0),
    @pTARGET_LICENSE NUMERIC(18, 0),
    @pSOURCE_LOCATION VARCHAR(25),
    @pTARGET_LOCATION VARCHAR(25),
    @pCLIENT_OWNER VARCHAR(25),
    @pQUANTITY_UNITS NUMERIC(18, 2),
    @pSOURCE_WAREHOUSE VARCHAR(25),     --////
    @pTARGET_WAREHOUSE VARCHAR(25),     --////
    @pTRANS_SUBTYPE VARCHAR(25),        --////
    @pCODIGO_POLIZA VARCHAR(25),
    @pLICENSE_ID NUMERIC(18, 0),
    @pSTATUS VARCHAR(25),
    @pWAVE_PICKING_ID NUMERIC(18, 0),
    @pTRANS_MT2 NUMERIC(18, 2),
    @pRESULT VARCHAR(300) OUTPUT,
    @pTASK_ID NUMERIC(18, 0) = NULL,
    @pTOTAL_POSITION INT = 0
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT,
            @pMATERIAL_ID VARCHAR(50),
            @pSOURCE_LOCATION_LOCAL VARCHAR(50),
            @pCURRENT_SOURCE_INV NUMERIC(18, 2),
            @pCLIENT_OWNER_LOCAL VARCHAR(25),
            @BATCH VARCHAR(50),
            @DATE_EXPIRATION DATETIME,
            @LOGIN_NAME VARCHAR(100),
            @MATERIAL_CLASS VARCHAR(25),
            @CLIENT_NAME VARCHAR(50),
            @WAREHOUSE_PARENT_SOURCE VARCHAR(50) = 'BODEGA_DEF',
            @WAREHOUSE_PARENT_TARGET VARCHAR(50) = 'BODEGA_DEF',
            @HANDLE_SERIAL INT = 0,
            @ORIGINAL_LICENSE INT = @pSOURCE_LICENSE,
            @CURRENT_CLASS INT = 0,
            @PICKING_HEADER_ID INT,
            @LOCKED_BY_INTERFACES INT = 0,
            @WAVE_PICKING_ID INT = 0,
            @ALLOW_FAST_PICKING INT = 0,
            @IDLE_INV INT,
            @ID_PROJECT UNIQUEIDENTIFIER = NULL,
            @PROJECT_CODE VARCHAR(50),
            @PROJECT_NAME VARCHAR(150),
            @PROJECT_SHORT_NAME VARCHAR(25),
            @STATUS_CODE VARCHAR(50);

    DECLARE @LICENSE_CLASSES TABLE
    (
        CLASS_ID INT,
        CLASS_NAME VARCHAR(50),
        CLASS_DESCRIPTION VARCHAR(250),
        CLASS_TYPE VARCHAR(50),
        CREATED_BY VARCHAR(50),
        CREATED_DATETIME DATETIME,
        LAST_UPDATED_BY VARCHAR(50),
        LAST_UPDATED DATETIME,
        PRIORITY INT
    );
    --
    DECLARE @LOCATION_CLASSES TABLE
    (
        CLASS_ID INT,
        CLASS_NAME VARCHAR(50),
        CLASS_DESCRIPTION VARCHAR(250),
        CLASS_TYPE VARCHAR(50),
        CREATED_BY VARCHAR(50),
        CREATED_DATETIME DATETIME,
        LAST_UPDATED_BY VARCHAR(50),
        LAST_UPDATED DATETIME,
        PRIORITY INT
    );
    --
    DECLARE @COMPATIBLE_CLASSES TABLE
    (
        CLASS_ID INT
    );

    BEGIN TRY
        BEGIN TRAN;
        -- ------------------------------------------------------------------------------------
        -- Obtiene el acuerdo comercial si no lo tiene 
        -- ------------------------------------------------------------------------------------
        IF (@pTRADE_AGREEMENT IS NULL OR @pTRADE_AGREEMENT = '')
        BEGIN
            SELECT @pTRADE_AGREEMENT = CAST(ACUERDO_COMERCIAL AS VARCHAR(50))
            FROM wms.OP_WMS_ACUERDOS_X_CLIENTE
            WHERE CLIENT_ID = @pCLIENT_OWNER;
        END;


        -- ------------------------------------------------------------------------------------
        -- Obtiene las clases de la ubicacion y licencia
        -- ------------------------------------------------------------------------------------

        INSERT INTO @LICENSE_CLASSES
        SELECT CLASS_ID,
               CLASS_NAME,
               CLASS_DESCRIPTION,
               CLASS_TYPE,
               CREATED_BY,
               CREATED_DATETIME,
               LAST_UPDATED_BY,
               LAST_UPDATED,
               PRIORITY
        FROM wms.OP_WMS_FN_GET_CLASSES_BY_LICENSE(@pLICENSE_ID);
        --
		
        INSERT INTO @LOCATION_CLASSES
        SELECT CLASS_ID,
               CLASS_NAME,
               CLASS_DESCRIPTION,
               CLASS_TYPE,
               CREATED_BY,
               CREATED_DATETIME,
               LAST_UPDATED_BY,
               LAST_UPDATED,
               PRIORITY
        FROM wms.OP_WMS_FN_GET_CLASSES_BY_LOCATION(@pTARGET_LOCATION);
		PRINT 'LON 001'
        -- ------------------------------------------------------------------------------------
        -- Obtiene las clases compatibles con la licencia
        -- ------------------------------------------------------------------------------------
		
        INSERT INTO @COMPATIBLE_CLASSES
        SELECT CLASS_ID
        FROM wms.OP_WMS_CLASS;
        --
        WHILE EXISTS (SELECT TOP 1 1 FROM @LICENSE_CLASSES)
        BEGIN
            SELECT TOP 1
                   @CURRENT_CLASS = CLASS_ID
            FROM @LICENSE_CLASSES;
            --
            DELETE CC
            FROM @COMPATIBLE_CLASSES CC
                LEFT JOIN wms.OP_WMS_CLASS_ASSOCIATION CA
                    ON CC.CLASS_ID = CA.CLASS_ASSOCIATED_ID
                       AND CA.CLASS_ID = @CURRENT_CLASS
            WHERE CA.CLASS_ID IS NULL;
            --
            DELETE FROM @LICENSE_CLASSES
            WHERE CLASS_ID = @CURRENT_CLASS;
			PRINT 'LON 002'
        END;
        --
        INSERT INTO @COMPATIBLE_CLASSES
        SELECT CLASS_ID
        FROM wms.OP_WMS_FN_GET_CLASSES_BY_LICENSE(@pLICENSE_ID);
		PRINT 'LON 003'
        -- ------------------------------------------------------------------------------------
        -- Valida si las clases de la licencia son compatibles con las de la ubicacion
        -- ------------------------------------------------------------------------------------
        DELETE LC
        FROM @LOCATION_CLASSES LC
            INNER JOIN @COMPATIBLE_CLASSES C
                ON LC.CLASS_ID = C.CLASS_ID;

        IF EXISTS (SELECT TOP 1 1 FROM @LOCATION_CLASSES)
        BEGIN
            SELECT @pRESULT = 'Las clases de la licencia no son compatibles con las clases de la ubicacion actual';
            RAISERROR(@pRESULT, 16, 1);
            RETURN -1;
			PRINT 'LON 004'
        END;
        ---------------------------------------------------------------------------------
        -- Asigna valores 
        ---------------------------------------------------------------------------------  
        SELECT TOP 1
               @WAREHOUSE_PARENT_TARGET = ISNULL(WAREHOUSE_PARENT, 'BODEGA_DEF'),
               @ALLOW_FAST_PICKING = ALLOW_FAST_PICKING
        FROM wms.OP_WMS_SHELF_SPOTS
        WHERE LOCATION_SPOT = @pTARGET_LOCATION;
		PRINT 'LON 005'

        SELECT TOP 1
               @LOGIN_NAME = L.LOGIN_NAME
        FROM wms.OP_WMS_FUNC_GETLOGIN_NAME(@pLOGIN_ID) L;

        SELECT TOP 1
               @pCLIENT_OWNER_LOCAL = L.CLIENT_OWNER,
               @CLIENT_NAME = C.CLIENT_NAME,
               @WAVE_PICKING_ID = L.WAVE_PICKING_ID
        FROM wms.OP_WMS_LICENSES L
            INNER JOIN wms.OP_WMS_VIEW_CLIENTS C
                ON L.CLIENT_OWNER = C.CLIENT_CODE
        WHERE L.LICENSE_ID = @pSOURCE_LICENSE;
		PRINT 'LON 005.1'
        SELECT TOP 1
               @pMATERIAL_ID = M.MATERIAL_ID,
               @MATERIAL_CLASS = M.MATERIAL_CLASS,
               @HANDLE_SERIAL = M.SERIAL_NUMBER_REQUESTS
        FROM wms.OP_WMS_MATERIALS M
        WHERE (
                  BARCODE_ID = @pMATERIAL_BARCODE
                  OR ALTERNATE_BARCODE = @pMATERIAL_BARCODE
              )
              AND CLIENT_OWNER = @pCLIENT_OWNER_LOCAL;

        SELECT TOP 1
               @pSOURCE_LOCATION_LOCAL = ISNULL(CURRENT_LOCATION, @pSOURCE_LOCATION),
               @WAREHOUSE_PARENT_SOURCE = CURRENT_WAREHOUSE,
               @PICKING_HEADER_ID = PICKING_DEMAND_HEADER_ID
        FROM wms.OP_WMS_LICENSES
        WHERE LICENSE_ID = @pSOURCE_LICENSE;
				PRINT 'LON 005.2'
        SELECT TOP 1
               @pCURRENT_SOURCE_INV = ISNULL(IL.QTY, 0),
               @BATCH = IL.BATCH,
               @DATE_EXPIRATION = IL.DATE_EXPIRATION,
               @LOCKED_BY_INTERFACES = IL.LOCKED_BY_INTERFACES,
               @IDLE_INV = IL.IDLE,
               @ID_PROJECT = IL.PROJECT_ID,
               @STATUS_CODE = SML.STATUS_CODE
        FROM wms.OP_WMS_INV_X_LICENSE IL
            LEFT JOIN wms.OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE SML
                ON (
                       IL.LICENSE_ID = SML.LICENSE_ID
                       AND IL.STATUS_ID = SML.STATUS_ID
                   )
        WHERE IL.LICENSE_ID = @pSOURCE_LICENSE
              AND IL.MATERIAL_ID = @pMATERIAL_ID;
		PRINT 'LON 005.3'
        SELECT TOP 1
               @ORIGINAL_LICENSE = T.ORIGINAL_LICENSE
        FROM wms.OP_WMS_TRANS T
        WHERE T.TRANS_TYPE = 'REUBICACION_PARCIAL'
              AND T.TARGET_LICENSE = @ORIGINAL_LICENSE;

        ---------------------------------------------------------------------------------
        -- OBTIENE LOS DATOS DEL PROYECTO SI MANEJA.
        ---------------------------------------------------------------------------------
        IF @ID_PROJECT IS NOT NULL
        BEGIN
            SELECT @PROJECT_CODE = OPPORTUNITY_CODE,
                   @PROJECT_NAME = OPPORTUNITY_NAME,
                   @PROJECT_SHORT_NAME = SHORT_NAME
            FROM wms.OP_WMS_PROJECT
            WHERE ID = @ID_PROJECT;
        END;
				PRINT 'LON 005.4'
        ---------------------------------------------------------------------------------
        -- validar unidades
        ---------------------------------------------------------------------------------  
        IF (@pCURRENT_SOURCE_INV < @pQUANTITY_UNITS)
        BEGIN
            SELECT @pRESULT
                = 'ERROR, Licencia: ' + CONVERT(VARCHAR(20), @pSOURCE_LICENSE) + ' No tiene suficiente inventario('
                  + CONVERT(VARCHAR(20), @pCURRENT_SOURCE_INV) + ' del SKU: ' + @pMATERIAL_BARCODE + ' para rebajar '
                  + CONVERT(VARCHAR(20), @pQUANTITY_UNITS);
            RETURN -1;
        END;
				PRINT 'LON 005.5'
        -- ------------------------------------------------------------------------------------
        -- Validar duplicidad de transacción
        -- ------------------------------------------------------------------------------------
        IF EXISTS
        (
            SELECT TOP 1
                   1
            FROM wms.OP_WMS_TRANS
            WHERE MATERIAL_CODE = @pMATERIAL_ID
                  AND SOURCE_LICENSE = @pSOURCE_LICENSE
                  AND TARGET_LICENSE = @pTARGET_LICENSE
                  AND QUANTITY_UNITS = @pQUANTITY_UNITS
        )
        BEGIN

            --Ya operó unicamente retornar éxito sin operar nada 
            ROLLBACK;
            SELECT @pRESULT = 'OK';

            SELECT 1 AS Resultado,
                   'Proceso Exitoso' AS Mensaje,
                   1 AS Codigo,
                   '' AS DbData;

            RETURN;
			PRINT 'LON 006'
        END;
				PRINT 'LON 005.6'
        IF @HANDLE_SERIAL = 1
        BEGIN
				PRINT 'LON 005.6.1'
            INSERT INTO wms.OP_WMS_TRANS
            (
                TERMS_OF_TRADE,
                TRANS_DATE,
                LOGIN_ID,
                LOGIN_NAME,
                TRANS_TYPE,
                TRANS_DESCRIPTION,
                TRANS_EXTRA_COMMENTS,
                MATERIAL_BARCODE,
                MATERIAL_CODE,
                MATERIAL_DESCRIPTION,
                MATERIAL_TYPE,
                MATERIAL_COST,
                SOURCE_LICENSE,
                TARGET_LICENSE,
                SOURCE_LOCATION,
                TARGET_LOCATION,
                CLIENT_OWNER,
                CLIENT_NAME,
                QUANTITY_UNITS,
                SOURCE_WAREHOUSE,
                TARGET_WAREHOUSE,
                TRANS_SUBTYPE,
                CODIGO_POLIZA,
                LICENSE_ID,
                STATUS,
                WAVE_PICKING_ID,
                TRANS_MT2,
                TASK_ID,
                BATCH,
                DATE_EXPIRATION,
                SERIAL,
                ORIGINAL_LICENSE,
                STATUS_CODE,
                PROJECT_ID,
                PROJECT_CODE,
                PROJECT_NAME,
                PROJECT_SHORT_NAME
            )
            SELECT @pTRADE_AGREEMENT,
                   CURRENT_TIMESTAMP,
                   @pLOGIN_ID,
                   @LOGIN_NAME,
                   'REUBICACION_PARCIAL',
                   ISNULL(
                   (
                       SELECT TOP 1
                              *
                       FROM wms.OP_WMS_FUNC_GETTRANS_DESC('REUBICACION_PARCIAL')
                   ),
                   'REUBICACION PARCIAL INGRESO'
                         ),
                   'REUBICACION',
                   @pMATERIAL_BARCODE,
                   @pMATERIAL_ID,
                   (
                       SELECT *
                       FROM wms.OP_WMS_FUNC_GETMATERIAL_DESC(@pMATERIAL_BARCODE, @pCLIENT_OWNER)
                   ),
                   @MATERIAL_CLASS,
                   wms.OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL(@pMATERIAL_ID, @pCLIENT_OWNER_LOCAL),
                   @pSOURCE_LICENSE,
                   @pTARGET_LICENSE,
                   @pSOURCE_LOCATION_LOCAL,
                   @pTARGET_LOCATION,
                   @pCLIENT_OWNER_LOCAL,
                   @CLIENT_NAME,
                   1,
                   @WAREHOUSE_PARENT_SOURCE,
                   @WAREHOUSE_PARENT_TARGET,
                   'REUBICACION',
                   @pCODIGO_POLIZA,
                   @pLICENSE_ID,
                   @pSTATUS,
                   @pWAVE_PICKING_ID,
                   @pTRANS_MT2,
                   @pTASK_ID,
                   @BATCH,
                   @DATE_EXPIRATION,
                   S.SERIAL,
                   @ORIGINAL_LICENSE,
                   @STATUS_CODE,
                   @ID_PROJECT,
                   @PROJECT_CODE,
                   @PROJECT_NAME,
                   @PROJECT_SHORT_NAME
            FROM wms.OP_WMS_MATERIAL_X_SERIAL_NUMBER S
            WHERE S.LICENSE_ID = @pSOURCE_LICENSE
                  AND S.ASSIGNED_TO = @pLOGIN_ID
                  AND S.STATUS = 2;
				  PRINT 'LON 006'
        END;
        ELSE
        BEGIN
				PRINT 'LON 005.6.2'
            INSERT INTO wms.OP_WMS_TRANS
            (
                TERMS_OF_TRADE,
                TRANS_DATE,
                LOGIN_ID,
                LOGIN_NAME,
                TRANS_TYPE,
                TRANS_DESCRIPTION,
                TRANS_EXTRA_COMMENTS,
                MATERIAL_BARCODE,
                MATERIAL_CODE,
                MATERIAL_DESCRIPTION,
                MATERIAL_TYPE,
                MATERIAL_COST,
                SOURCE_LICENSE,
                TARGET_LICENSE,
                SOURCE_LOCATION,
                TARGET_LOCATION,
                CLIENT_OWNER,
                CLIENT_NAME,
                QUANTITY_UNITS,
                SOURCE_WAREHOUSE,
                TARGET_WAREHOUSE,
                TRANS_SUBTYPE,
                CODIGO_POLIZA,
                LICENSE_ID,
                STATUS,
                WAVE_PICKING_ID,
                TRANS_MT2,
                TASK_ID,
                BATCH,
                DATE_EXPIRATION,
                ORIGINAL_LICENSE,
                STATUS_CODE,
                PROJECT_ID,
                PROJECT_CODE,
                PROJECT_NAME,
                PROJECT_SHORT_NAME
            )
            VALUES
            (   @pTRADE_AGREEMENT, CURRENT_TIMESTAMP, @pLOGIN_ID, @LOGIN_NAME, 'REUBICACION_PARCIAL',
                ISNULL(
                (
                    SELECT TOP 1
                           *
                    FROM wms.OP_WMS_FUNC_GETTRANS_DESC('REUBICACION_PARCIAL')
                ),
                'REUBICACION PARCIAL INGRESO'
                      ), 'REUBICACION', @pMATERIAL_BARCODE, @pMATERIAL_ID,
                (
                    SELECT *
                    FROM wms.OP_WMS_FUNC_GETMATERIAL_DESC(@pMATERIAL_BARCODE, @pCLIENT_OWNER)
                ), @MATERIAL_CLASS,
                wms.OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL(@pMATERIAL_ID, @pCLIENT_OWNER_LOCAL),
                @pSOURCE_LICENSE, @pTARGET_LICENSE, @pSOURCE_LOCATION_LOCAL, @pTARGET_LOCATION, @pCLIENT_OWNER_LOCAL,
                @CLIENT_NAME, @pQUANTITY_UNITS, @WAREHOUSE_PARENT_SOURCE, @WAREHOUSE_PARENT_TARGET, 'REUBICACION',
                @pCODIGO_POLIZA, @pLICENSE_ID, @pSTATUS, @pWAVE_PICKING_ID, @pTRANS_MT2, @pTASK_ID, @BATCH,
                @DATE_EXPIRATION, @ORIGINAL_LICENSE, @STATUS_CODE, @ID_PROJECT, @PROJECT_CODE, @PROJECT_NAME,
                @PROJECT_SHORT_NAME);

        END;
				PRINT 'LON 007'
        --UPDATE TARGET LICENSE
        UPDATE wms.OP_WMS_LICENSES
        SET LAST_LOCATION = CURRENT_LOCATION,
            CURRENT_LOCATION = @pTARGET_LOCATION,
            LAST_UPDATED_BY = @pLOGIN_ID,
            CURRENT_WAREHOUSE = @WAREHOUSE_PARENT_TARGET,
            STATUS = 'ALLOCATED',
            REGIMEN = ISNULL(
                        (
                            SELECT Z.REGIMEN
                            FROM wms.OP_WMS_LICENSES Z
                            WHERE LICENSE_ID = @pSOURCE_LICENSE
                        ),
                        'S/R'
                              ),
            USED_MT2 = @pTRANS_MT2,
            PICKING_DEMAND_HEADER_ID = @PICKING_HEADER_ID,
            WAVE_PICKING_ID = @WAVE_PICKING_ID
        WHERE LICENSE_ID = @pLICENSE_ID;
						PRINT 'LON 007.1'
        --Se hereda en la nueva licencia si la licencia origen esta bloqueada
        UPDATE wms.OP_WMS_INV_X_LICENSE
        SET IDLE = @IDLE_INV,
            PROJECT_ID = @ID_PROJECT,
            LOCKED_BY_INTERFACES = @LOCKED_BY_INTERFACES,
            TOTAL_POSITION = @pTOTAL_POSITION
        WHERE LICENSE_ID = @pTARGET_LICENSE;

        --UPDATE SOURCE LICENSE INVENTORY
        UPDATE wms.OP_WMS_INV_X_LICENSE
        SET QTY = QTY - @pQUANTITY_UNITS
        WHERE LICENSE_ID = @pSOURCE_LICENSE
              AND MATERIAL_ID = @pMATERIAL_ID;
			  PRINT 'LON 007.2'
        -- --------------------------------------------------------------------------
        -- ACTUALIZA LA CANTIDAD DE LA LICENCIA Y RESERVADO EN LA LICENCIA ORIGINAL
        -- SI MANEJA PROYECTO EN EL INVENTARIO RESERVADO
        -- --------------------------------------------------------------------------
        IF @ID_PROJECT IS NOT NULL
        BEGIN
            UPDATE wms.OP_WMS_INVENTORY_RESERVED_BY_PROJECT
            SET QTY_LICENSE = QTY_LICENSE - @pQUANTITY_UNITS,
                QTY_RESERVED = QTY_RESERVED - @pQUANTITY_UNITS
            WHERE PROJECT_ID = @ID_PROJECT
                  AND LICENSE_ID = @pSOURCE_LICENSE
                  AND MATERIAL_ID = @pMATERIAL_ID;
        END;

        -- -------------------------------------
        -- Se agrego la actualizacion de los metros cuadrados para la licencia origen
        -- -------------------------------------
		PRINT 'LON 007.3'
        UPDATE wms.OP_WMS_LICENSES
        SET USED_MT2 = USED_MT2 - @pTRANS_MT2
        WHERE LICENSE_ID = @pSOURCE_LICENSE;

        IF @HANDLE_SERIAL = 1
        BEGIN
		PRINT 'LON 007.3.1'
            UPDATE wms.OP_WMS_MATERIAL_X_SERIAL_NUMBER
            SET LICENSE_ID = @pTARGET_LICENSE,
                STATUS = 1,
                ASSIGNED_TO = NULL
            WHERE LICENSE_ID = @pSOURCE_LICENSE
                  AND ASSIGNED_TO = @pLOGIN_ID
                  AND STATUS = 2;
            DECLARE @SERIE_COUNT INT;
            SELECT @SERIE_COUNT = ISNULL(COUNT(*), 0)
            FROM wms.OP_WMS_MATERIAL_X_SERIAL_NUMBER S
            WHERE S.LICENSE_ID = @pTARGET_LICENSE
                  AND S.MATERIAL_ID = @pMATERIAL_ID;

            UPDATE wms.OP_WMS_INV_X_LICENSE
            SET QTY = @SERIE_COUNT,
                ENTERED_QTY = @SERIE_COUNT
            WHERE LICENSE_ID = @pTARGET_LICENSE
                  AND MATERIAL_ID = @pMATERIAL_ID;

        END;
		PRINT 'LON 007.4'

        IF EXISTS
        (
            SELECT TOP 1
                   1
            FROM wms.OP_WMS_MATERIALS M
            WHERE M.MATERIAL_ID = @pMATERIAL_ID
                  AND M.IS_MASTER_PACK = 1
        )
        BEGIN
			PRINT 'LON 007.4.1' + cast(@pSOURCE_LICENSE as varchar)+cast(@pTARGET_LICENSE as varchar)+@pMATERIAL_ID+cast(@pQUANTITY_UNITS as varchar)
            EXEC wms.OP_WMS_INSERT_MASTER_PACK_BY_REALLOC_PARTIAL @SOURCE_LICENSE = @pSOURCE_LICENSE,
                                                                          @TARGET_LICENSE = @pTARGET_LICENSE,
                                                                          @MATERIAL_ID = @pMATERIAL_ID,
                                                                          @QTY_REALLOC = @pQUANTITY_UNITS;
			PRINT 'LON 007.4.2'
        END;
		PRINT 'LON 007.5'
        -- ------------------------------------------------------------------------------------
        -- si estamos ubicando en una ubicacion con la propiedad ALLOW_FAST_PICKING = TRUE
        -- debemos trasladar el inventario de la licencia creada en la recepcion hacia 
        -- una licencia previamente creada en dicha ubicacion
        -- ------------------------------------------------------------------------------------
        IF @ALLOW_FAST_PICKING = 1
        BEGIN
            EXEC wms.OP_WMS_SP_UPDATE_PARTIAL_LICENSE_FAST_PICKING @LOGIN_ID = @pLOGIN_ID,           -- varchar(50)
                                                                           @LICENSE_ID = @pTARGET_LICENSE,   -- int
                                                                           @LOCATION_ID = @pTARGET_LOCATION, -- varchar(25)
                                                                           @TRANS_TYPE = @pTRANS_TYPE,       -- varchar(25)
                                                                           @MATERIAL_ID_REALLOC = @pMATERIAL_ID,
                                                                           @QTY_REALLOC = @pQUANTITY_UNITS;
        END;

        COMMIT;
        SELECT @pRESULT = 'OK';

        SELECT 1 AS Resultado,
               'Proceso Exitoso' AS Mensaje,
               1 AS Codigo,
               '' AS DbData;
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;
        SELECT @pRESULT = 'OP_WMS_SP_REGISTER_REALLOC_PARTIAL: ' + ERROR_MESSAGE();

        SELECT -1 AS Resultado,
               ERROR_MESSAGE() AS Mensaje,
               @@ERROR AS Codigo,
               '' AS DbData;
    END CATCH;

END;