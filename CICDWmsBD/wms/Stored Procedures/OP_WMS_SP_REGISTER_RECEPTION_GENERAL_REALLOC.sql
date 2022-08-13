-- =============================================
-- Autor:					---------
-- Fecha de Creacion: 		---------
-- Description:			    ---------

-- Modificacion #001 03-10-2016 @ A-TEAM Sprint 2
-- juancarlos.escalante
-- Se modificó el insert para que se registre el id de la tarea

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20191217 GForce@Madagascar
-- Description:			    guardo la bodega en lugar de la zona al registrar la transaccion

/*
-- Ejemplo de Ejecucion:
		--
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_RECEPTION_GENERAL_REALLOC]
    -- Add the parameters for the stored procedure here
    @pTRADE_AGREEMENT VARCHAR(25),
    @pLOGIN_ID VARCHAR(25),
    @pTRANS_TYPE VARCHAR(25),
    @pTRANS_EXTRA_COMMENTS VARCHAR(50),
    @pMATERIAL_BARCODE VARCHAR(25),
    @pMATERIAL_CODE VARCHAR(25),
    @pSOURCE_LICENSE NUMERIC(18, 0),
    @pTARGET_LICENSE NUMERIC(18, 0),
    @pSOURCE_LOCATION VARCHAR(25),
    @pTARGET_LOCATION VARCHAR(25),
    @pCLIENT_OWNER VARCHAR(25),
    @pQUANTITY_UNITS NUMERIC(18, 2),
    @pSOURCE_WAREHOUSE VARCHAR(25),
    @pTARGET_WAREHOUSE VARCHAR(25),
    @pTRANS_SUBTYPE VARCHAR(25),
    @pCODIGO_POLIZA VARCHAR(25),
    @pLICENSE_ID NUMERIC(18, 0),
    @pSTATUS VARCHAR(25),
    @pWAVE_PICKING_ID NUMERIC(18, 0),
    @pTRANS_MT2 NUMERIC(18, 2),
    @pRESULT VARCHAR(300) OUTPUT,
    -- Inicio Modificacion #001
    @pTASK_ID NUMERIC(18, 0) = NULL
-- Fin Modificacion #001
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @pMATERIAL_ID VARCHAR(50);
    DECLARE @pCLIENT_OWNER_LOCAL VARCHAR(25);

    BEGIN TRY

        SELECT @pCLIENT_OWNER_LOCAL =
        (
            SELECT CLIENT_OWNER
            FROM [wms].OP_WMS_LICENSES
            WHERE LICENSE_ID = @pSOURCE_LICENSE
        );

        SELECT @pMATERIAL_ID =
        (
            SELECT MATERIAL_ID
            FROM [wms].OP_WMS_MATERIALS
            WHERE (
                      BARCODE_ID = @pMATERIAL_BARCODE
                      OR ALTERNATE_BARCODE = @pMATERIAL_BARCODE
                  )
                  AND CLIENT_OWNER = @pCLIENT_OWNER_LOCAL
        );

        INSERT INTO [wms].[OP_WMS_TRANS]
        (
            [TERMS_OF_TRADE],
            [TRANS_DATE],
            [LOGIN_ID],
            [LOGIN_NAME],
            [TRANS_TYPE],
            [TRANS_DESCRIPTION],
            [TRANS_EXTRA_COMMENTS],
            [MATERIAL_BARCODE],
            [MATERIAL_CODE],
            [MATERIAL_DESCRIPTION],
            [MATERIAL_TYPE],
            [MATERIAL_COST],
            [SOURCE_LICENSE],
            [TARGET_LICENSE],
            [SOURCE_LOCATION],
            [TARGET_LOCATION],
            [CLIENT_OWNER],
            [CLIENT_NAME],
            [QUANTITY_UNITS],
            [SOURCE_WAREHOUSE],
            [TARGET_WAREHOUSE],
            [TRANS_SUBTYPE],
            [CODIGO_POLIZA],
            [LICENSE_ID],
            STATUS,
            WAVE_PICKING_ID,
            TRANS_MT2,
            -- Inicio Modificacion #001
            TASK_ID
        -- Fin Modificacion #001
        )
        VALUES
        (   @pTRADE_AGREEMENT, CURRENT_TIMESTAMP, @pLOGIN_ID,
            (
                SELECT * FROM [wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID)
            ), @pTRANS_TYPE, ISNULL(
                             (
                                 SELECT * FROM [wms].OP_WMS_FUNC_GETTRANS_DESC(@pTRANS_TYPE)
                             ),
                             'INGRESO GENERAL'
                                   ), 'INGRESO A GENERAL POR REUBICACION DESDE FISCAL', @pMATERIAL_BARCODE,
            @pMATERIAL_ID,
            (
                SELECT *
                FROM [wms].OP_WMS_FUNC_GETMATERIAL_DESC(@pMATERIAL_BARCODE, @pCLIENT_OWNER)
            ), ISNULL(
               (
                   SELECT MATERIAL_CLASS
                   FROM [wms].OP_WMS_MATERIALS
                   WHERE MATERIAL_ID = @pMATERIAL_ID
               ),
               'N/A'
                     ), [wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID, @pCLIENT_OWNER_LOCAL),
            @pSOURCE_LICENSE, @pTARGET_LICENSE, @pSOURCE_LOCATION, @pTARGET_LOCATION, @pCLIENT_OWNER_LOCAL,
            (
                SELECT * FROM [wms].OP_WMS_FUNC_GETCLIENT_NAME(@pCLIENT_OWNER_LOCAL)
            ), @pQUANTITY_UNITS, ISNULL(
                                 (
                                     SELECT ISNULL(WAREHOUSE_PARENT, 'BODEGA_DEF')
                                     FROM [wms].OP_WMS_SHELF_SPOTS
                                     WHERE LOCATION_SPOT = @pSOURCE_LOCATION
                                 ),
                                 'BODEGA_DEF'
                                       ),
            ISNULL(
            (
                SELECT ISNULL(WAREHOUSE_PARENT, 'BODEGA_DEF')
                FROM [wms].OP_WMS_SHELF_SPOTS
                WHERE LOCATION_SPOT = @pTARGET_LOCATION
            ),
            'BODEGA_DEF'
                  ), 'RECEPTION', @pCODIGO_POLIZA, @pLICENSE_ID, @pSTATUS, @pWAVE_PICKING_ID, @pTRANS_MT2,
            -- Inicio Modificacion #001
            @pTASK_ID
            -- Fin Modificacion #001
            );

        UPDATE [wms].OP_WMS_LICENSES
        SET LAST_LOCATION = CURRENT_LOCATION,
            CURRENT_LOCATION = @pTARGET_LOCATION,
            LAST_UPDATED_BY = @pLOGIN_ID,
            CURRENT_WAREHOUSE = ISNULL(
                                (
                                    SELECT ISNULL(WAREHOUSE_PARENT, 'BODEGA_DEF')
                                    FROM [wms].OP_WMS_SHELF_SPOTS
                                    WHERE LOCATION_SPOT = @pTARGET_LOCATION
                                ),
                                'BODEGA_DEF'
                                      ),
            STATUS = 'ALLOCATED',
            USED_MT2 = @pTRANS_MT2
        WHERE LICENSE_ID = @pLICENSE_ID;

        SELECT @pRESULT = 'OK';

    END TRY
    BEGIN CATCH
        SELECT @pRESULT = 'REGISTER_RECEPTION_GENERAL_REALLOC: ' + ERROR_MESSAGE();
    END CATCH;

END;