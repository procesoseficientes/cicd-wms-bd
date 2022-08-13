-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que marca una recepcion como mandada a ERP 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 SE modifica para que consulte DocNum en base al docEntry obtenido y lo guarde en la tabla 

-- Modificacion 10/4/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se agrega el cambio para la lectura de external_source desde erp

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-10 Nexus@AgeOfEmpires
-- Description:	 Se agrega para que valide si el producto esta configurado para explotar en recepción lo explote en este momento que ya envió la interfaz de recepción. 

-- Modificacion 22-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Ajuste por intercompany, se obtiene el doc num de forma dinamica

-- Modificacion 19/9/2017 @ Reborn-Team Sprint Collin
-- rudi.garcia
-- Se agrego la sp "[OP_WMS_UNLOCK_INVENTORY_LOCKED_BY_INTERFACES]" para que desbloquera el inventario y se actualizao el campo "[LOCKED_BY_INTERFACES]" de la tabla.

-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
-- rodrigo.gomez
-- Se valida el parametro de explosion por bodegas de los materiales

-- Modificacion 11-Jan-18 @ Nexus Team Sprint Ramsey
-- alberto.ruiz
-- Se arregla validacion si tiene excepcion

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_RECEPTION_AS_SEND_TO_ERP]
				@RECEPTION_DOCUMENT_ID = 4045
				,@POSTED_RESPONSE = 'Exito al guardar en sap'
				,@ERP_REFERENCE = '3088'
				--
			select * from [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] where [ERP_RECEPTION_DOCUMENT_HEADER_ID] = 4045
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_RECEPTION_AS_SEND_TO_ERP]
    (
     @RECEPTION_DOCUMENT_ID INT
    ,@POSTED_RESPONSE VARCHAR(500)
    ,@ERP_REFERENCE VARCHAR(50)
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    BEGIN TRY
        DECLARE
            @DOC_NUM INT
           ,@QUERY NVARCHAR(MAX)
           ,@MATERIAL_ID VARCHAR(50)
           ,@LOGIN VARCHAR(50)
           ,@LICENSE_ID DECIMAL
           ,@EXPLOSION_TYPE VARCHAR(200)
           ,@OWNER VARCHAR(50)
           ,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
           ,@ERP_DATABASE VARCHAR(50)
           ,@SCHEMA_NAME VARCHAR(50)
           ,@ERP_TABLE VARCHAR(50)
           ,@WAREHOUSE_CODE_PARAMETER VARCHAR(25) = NULL
           ,@WAREHOUSE_CODE VARCHAR(25) = NULL;


		   INSERT INTO [wms].[OP_LOG]
		   		(
		   			[ERR_DATETIME]
		   			,[ERR_TEXT]
		   			,[ERR_SQL]
		   		)
		   VALUES
		   		(
		   			GETDATE()  -- ERR_DATETIME - datetime
		   			,'Inicia OP_WMS_SP_MARK_RECEPTION_AS_SEND_TO_ERP'  -- ERR_TEXT - varchar(200)
		   			,'Parametros: ReceptionDocumentId ' + CAST( @RECEPTION_DOCUMENT_ID AS VARCHAR) + ' , Posted Response: '  + @POSTED_RESPONSE + ' , ErpReference: ' +@ERP_REFERENCE -- ERR_SQL - varchar(max)
		   		)
    -- ------------------------------------------------------------------------------------
    -- Obtiene la bodega de las configuraciones
    -- ------------------------------------------------------------------------------------
        SELECT
            @WAREHOUSE_CODE_PARAMETER = [C].[TEXT_VALUE]
        FROM
            [wms].[OP_WMS_CONFIGURATIONS] AS [C]
        WHERE
            [C].[PARAM_NAME] = 'ERP_WAREHOUSE_PURCHASE_ORDER';

			PRINT @WAREHOUSE_CODE_PARAMETER
    --
        SELECT TOP 1
            @WAREHOUSE_CODE = [W].[WAREHOUSE_ID]
        FROM
            [wms].[OP_WMS_WAREHOUSES] [W]
        WHERE
            [W].[ERP_WAREHOUSE] = @WAREHOUSE_CODE_PARAMETER;

			PRINT @WAREHOUSE_CODE

    -- ------------------------------------------------------------------------------------
    -- Determina la tabla de ERP
    -- ------------------------------------------------------------------------------------
        SELECT
            @ERP_TABLE = CASE WHEN [SOURCE] = 'RECEPCION_GENERAL' THEN 'OIGE'
                              ELSE 'OPDN'
                         END
        FROM
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;

			PRINT @ERP_TABLE

    -- ------------------------------------------------------------------------------------
    -- Obtiene el tipo de explosion
    -- ------------------------------------------------------------------------------------
        SELECT TOP 1
            @EXPLOSION_TYPE = [C].[TEXT_VALUE]
        FROM
            [wms].[OP_WMS_CONFIGURATIONS] [C]
        WHERE
            [C].[PARAM_TYPE] = 'SISTEMA'
            AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
            AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION';

    -- ------------------------------------------------------------------------------------
    -- Obtiene el dueño de la recepcion
    -- ------------------------------------------------------------------------------------
        SELECT
            @OWNER = [RDH].[OWNER]
        FROM
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
        WHERE
            [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;

    -- ------------------------------------------------------------------------------------
    -- Obtiene la fuente del dueño de la recepcion
    -- ------------------------------------------------------------------------------------
        SELECT
            @INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
           ,@ERP_DATABASE = [C].[ERP_DATABASE]
           ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
        FROM
            [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
        INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
        WHERE
            [C].[CLIENT_CODE] =  @OWNER
            AND [ES].[READ_ERP] = 1;
			

    -- ------------------------------------------------------------------------------------
    -- Obtiene el doc num del ERP
    -- ------------------------------------------------------------------------------------
        SELECT
            @QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE =' + @ERP_DATABASE + '
					,@TABLE = ' + @ERP_TABLE + '
					,@DOC_ENTRY = ' + @ERP_REFERENCE + '
					,@DOC_NUM = @DOC_NUM OUTPUT';
        PRINT @QUERY;
    --
        EXEC [sp_executesql] @QUERY, N'@DOC_NUM INT =-1 OUTPUT',
            @DOC_NUM = @DOC_NUM OUTPUT;

    -- ------------------------------------------------------------------------------------
    -- Actualiza la recepcion
    -- ------------------------------------------------------------------------------------
        UPDATE
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
        SET
            [LAST_UPDATE] = GETDATE()
           ,[LAST_UPDATE_BY] = 'INTERFACE'
           ,[IS_POSTED_ERP] = 1
           ,[POSTED_ERP] = GETDATE()
           ,[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE,
                                        @DOC_NUM)
           ,[ERP_REFERENCE] = @ERP_REFERENCE
           ,[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
           ,[LOCKED_BY_INTERFACES] = 0
           ,[IS_SENDING] = 0
        WHERE
            [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;

    -- ------------------------------------------------------------------------------------
    -- Desbloquea el inventario
    -- ------------------------------------------------------------------------------------
        EXEC [wms].[OP_WMS_UNLOCK_INVENTORY_LOCKED_BY_INTERFACES] @RECEPTION_DOCUMENT_ID = @RECEPTION_DOCUMENT_ID;
    -- ------------------------------------------------------------------------------------
    -- Obtiene los master packs que explotan en recepcion
    -- ------------------------------------------------------------------------------------
        SELECT DISTINCT
            [MPH].[MATERIAL_ID]
           ,[MPH].[LICENSE_ID]
           ,[T].[TASK_ASSIGNEDTO]
        INTO
            [#MASTERPACK_TO_EXPLODE]
        FROM
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
        INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
        INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH] ON [MPH].[POLICY_HEADER_ID] = [T].[DOC_ID_SOURCE]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [MPH].[MATERIAL_ID] = [M].[MATERIAL_ID]
        LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [WH] ON [H].[ERP_WAREHOUSE_CODE] = [WH].[ERP_WAREHOUSE]
        LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [MW] ON (
                                                              [M].[MATERIAL_ID] = [MW].[MATERIAL_ID]
                                                              AND [MW].[WAREHOUSE_ID] = COALESCE([D].[WAREHOUSE_CODE],
                                                              [WH].[WAREHOUSE_ID],
                                                              @WAREHOUSE_CODE)
                                                              )
        LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP] ON [MP].[MATERIAL_PROPERTY_ID] = [MW].[MATERIAL_PROPERTY_ID]
                                                           AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
        WHERE
            [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID
            AND [M].[IS_MASTER_PACK] = 1
            AND (
                 (
                  [MW].[VALUE] IS NULL
                  AND [M].[EXPLODE_IN_RECEPTION] = 1
                 )
                 OR [MW].[VALUE] = '1'
                );

    -- ------------------------------------------------------------------------------------
    -- Ciclo para explotar cada master pack
    -- ------------------------------------------------------------------------------------
        WHILE EXISTS ( SELECT TOP 1
                        1
                       FROM
                        [#MASTERPACK_TO_EXPLODE] )
        BEGIN
            SELECT TOP 1
                @MATERIAL_ID = [M].[MATERIAL_ID]
               ,@LICENSE_ID = [M].[LICENSE_ID]
               ,@LOGIN = [M].[TASK_ASSIGNEDTO]
            FROM
                [#MASTERPACK_TO_EXPLODE] [M];

    -- ---------------------------------------------------------------------------------
    -- validar si explotara en cascada o directo al ultimo nivel 
    -- ---------------------------------------------------------------------------------  
            IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
            BEGIN
                EXEC [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @LICENSE_ID,
                    @LOGIN_ID = @LOGIN, @MATERIAL_ID = @MATERIAL_ID;
            END;
            ELSE
            BEGIN
                EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID,
                    @MATERIAL_ID = @MATERIAL_ID, @LAST_UPDATE_BY = @LOGIN,
                    @MANUAL_EXPLOTION = 0;
            END;
    --
            DELETE
                [#MASTERPACK_TO_EXPLODE]
            WHERE
                [MATERIAL_ID] = @MATERIAL_ID
                AND [LICENSE_ID] = @LICENSE_ID
                AND [TASK_ASSIGNEDTO] = @LOGIN;
        END;

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado final
    -- ------------------------------------------------------------------------------------
        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,'0' [DbData];
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@ERROR [Codigo];
    END CATCH;
END;