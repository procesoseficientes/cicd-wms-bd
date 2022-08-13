-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Septiembre-2019 G-Force@Gumarcaj
-- Description:			Sp que obtiene el resumen de un manifiesto

-- Modificado por:		henry.rodriguez
-- Fecha: 				23-Septiembre-2019 G-Force@Gumarcaj
-- Description:			Se agregan consulta para obtener informacion del cliente y nombre de material

-- Modificado por:		henry.rodriguez
-- Fecha: 				22-Noviembre-2019 G-Force@Kioto
-- Description:			Se corrige funcionalidad para obtener los datos.

-- Modificado por:		henry.rodriguez
-- Fecha: 				26-Noviembre-2019 G-Force@Kioto
-- Description:			Se actualiza sp para obtener las cantidades.

-- Modificado por:		henry.rodriguez
-- Fecha: 				26-Noviembre-2019 G-Force@Kioto
-- Description:			Se agrega tabla para almacenar los clientes sin ser repetidos

-- Modificado por:		henry.rodriguez
-- Fecha: 				07-Enero-2020 G-Force@Oklahoma-NEXT
-- Description:			Se agregan campos de peso, volumen, costo por material y agrupacion por precio.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[GetExternalManifest] @ManifestHeaderId = 1108
				
*/
-- =============================================  
CREATE PROCEDURE [wms].[GetExternalManifest] (@ManifestHeaderId INT)
AS
BEGIN

    -- ------------------------------------------------------------------------------------
    -- DECLARAMOS TABLA EN DONDE SE ALMACENARAN LOS DATOS DEL CLIENTE
    -- ------------------------------------------------------------------------------------
    DECLARE @TEMP_CUSTOMER_NEXT TABLE
    (
        [CUSTOMER_CODE] VARCHAR(15),
        [CUSTOMER_NAME] VARCHAR(100),
        [PHONE1] NVARCHAR(20),
        [PHONE2] NVARCHAR(20),
        [CELULAR] NVARCHAR(50),
        [LATITUDE] NVARCHAR(50),
        [LONGITUDE] NVARCHAR(50),
        [IMG_FACADE] VARCHAR(MAX),
        [EMAIL] VARCHAR(100),
        [OWNER] VARCHAR(30)
    );

    -- ------------------------------------------------------------------------------------
    -- DECLARAMOS TABLA EN DONDE SE ALMACENARAN LOS CLIENTES QUE NO SE REPITEN
    -- ------------------------------------------------------------------------------------
    DECLARE @TEMP_CUSTOMER_NEXT_NOT_REPEATED TABLE
    (
        [CUSTOMER_CODE] VARCHAR(15),
        [CUSTOMER_NAME] VARCHAR(100),
        [PHONE1] NVARCHAR(20),
        [PHONE2] NVARCHAR(20),
        [CELULAR] NVARCHAR(50),
        [LATITUDE] NVARCHAR(50),
        [LONGITUDE] NVARCHAR(50),
        [IMG_FACADE] VARCHAR(MAX),
        [EMAIL] VARCHAR(100),
        [OWNER] VARCHAR(30)
    );

    -- ------------------------------------------------------------------------------------
    -- INSERTAMOS LOS DATOS PARA LAS FUENTES EXTERNAS.
    -- ------------------------------------------------------------------------------------
    DECLARE @TEMP_OWNERS TABLE
    (
        [COMPANY_ID] INT,
        [INTERFACE_DATA_BASE_NAME] VARCHAR(50),
        [ERP_DATABASE] VARCHAR(50),
        [SCHEMA_NAME] VARCHAR(50),
        [CLIENT_CODE] VARCHAR(25)
    );

    INSERT INTO @TEMP_OWNERS
    (
        [COMPANY_ID],
        [INTERFACE_DATA_BASE_NAME],
        [ERP_DATABASE],
        [SCHEMA_NAME],
        [CLIENT_CODE]
    )
    SELECT [C].[COMPANY_ID],
           [ES].[INTERFACE_DATA_BASE_NAME],
           [C].[ERP_DATABASE],
           [ES].[SCHEMA_NAME],
           [C].[CLIENT_CODE]
    FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
        INNER JOIN [wms].[OP_WMS_COMPANY] [C]
            ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
    WHERE [ES].[READ_ERP] = 1;

    -- ------------------------------------------------------------------------------------
    -- INSERTAMOS LOS DATOS DEL CLIENTE QUE SE OBTIENEN EN LA TABLA TEMPORAL
    -- ------------------------------------------------------------------------------------

    WHILE (EXISTS (SELECT TOP 1 1 FROM @TEMP_OWNERS))
    BEGIN
        DECLARE @ID INT;
        DECLARE @INTERFACE_DATA_BASE_NAME VARCHAR(200),
                @ERP_DATABASE VARCHAR(200),
                @SCHEMA_NAME VARCHAR(200),
                @QUERY NVARCHAR(2000),
                @CLIENT_CODE VARCHAR(30);

        SELECT TOP 1
            @ID = [COMPANY_ID],
            @INTERFACE_DATA_BASE_NAME = [INTERFACE_DATA_BASE_NAME],
            @ERP_DATABASE = [ERP_DATABASE],
            @SCHEMA_NAME = [SCHEMA_NAME],
            @CLIENT_CODE = [CLIENT_CODE]
        FROM @TEMP_OWNERS;

        IF @ERP_DATABASE IS NOT NULL
           AND @ERP_DATABASE <> ''
        BEGIN
            SELECT @QUERY
                = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME
                  + '.SWIFT_SP_GET_CUSTOMERS_FOR_NEXT @DATABASE =''' + @ERP_DATABASE + ''',@OWNER =''' + @CLIENT_CODE
                  + '''';
            --

            INSERT INTO @TEMP_CUSTOMER_NEXT
            (
                [CUSTOMER_CODE],
                [CUSTOMER_NAME],
                [PHONE1],
                [PHONE2],
                [CELULAR],
                [LATITUDE],
                [LONGITUDE],
                [IMG_FACADE],
                [EMAIL],
                [OWNER]
            )
            EXEC [sp_executesql] @QUERY;

        END;

        DELETE FROM @TEMP_OWNERS
        WHERE [COMPANY_ID] = @ID;

    END;

    --------------------------------------------------------------------------------------

    INSERT INTO @TEMP_CUSTOMER_NEXT_NOT_REPEATED
    (
        [CUSTOMER_CODE],
        [CUSTOMER_NAME],
        [PHONE1],
        [PHONE2],
        [CELULAR],
        [LATITUDE],
        [LONGITUDE],
        [IMG_FACADE],
        [EMAIL]
    )
    SELECT DISTINCT
        [CUSTOMER_CODE],
        [CUSTOMER_NAME],
        [PHONE1],
        [PHONE2],
        [CELULAR],
        [LATITUDE],
        [LONGITUDE],
        [IMG_FACADE],
        [EMAIL]
    FROM @TEMP_CUSTOMER_NEXT;

    SELECT ROW_NUMBER() OVER (ORDER BY [MH].[MANIFEST_HEADER_ID] ASC) [PrimaryKey],
           --ENCABEZADO MANIFIESTO
           [MH].[MANIFEST_HEADER_ID] [ExternalId],
           [MH].[DRIVER] [DriverId],
           MAX(ISNULL([P].[NAME], '') + ISNULL([P].[LAST_NAME], '')) [DriverName],
           [MH].[VEHICLE] [VehicleId],
           MAX(ISNULL([V].[BRAND], '') + ISNULL([V].[LINE], '') + ISNULL([V].[MODEL], '') + ISNULL([V].[COLOR], '')) [VehicleDescription],
           [MH].[DISTRIBUTION_CENTER] [DistributionCenter],
           [MH].[STATUS] [Status],
           [MH].[MANIFEST_TYPE] [Type],
           1 [IsExternal],
           [TCN].[PHONE1] [Telephone],
           [TCN].[LATITUDE] [Latitude],
           [TCN].[LONGITUDE] [Longitude],
           [TCN].[IMG_FACADE] [Img_Facade],
           [TCN].[EMAIL] [Email],
           --DETALLE MANIFIESTO
           MAX([MD].[MANIFEST_DETAIL_ID]) [ExternalDetailId],
           [MD].[MANIFEST_HEADER_ID] [ManifestId],
           MAX([MD].[CODE_ROUTE]) [CodeRoute],
           [MD].[CLIENT_CODE] [ClientCode],
           [MD].[WAVE_PICKING_ID] [WavePickingId],
           [MD].[MATERIAL_ID] [MaterialId],
           MAX([M].[MATERIAL_NAME]) [MaterialName],
           SUM([MD].[QTY]) [Qty],
           MAX([MD].[STATUS]) [DetailStatus],
           [MD].[ADDRESS_CUSTOMER] [AddressCustomer],
           [MD].[CLIENT_NAME] [ClientName],
           MAX([MD].[LINE_NUM]) [LineNum],
           MAX([MD].[PICKING_DEMAND_HEADER_ID]) [DetailManifestDocumentId],
           MAX([MD].[PRICE]) [Price],
           MAX([MD].[LINE_DISCOUNT]) [LineDiscount],
           SUM([MD].[LINE_TOTAL]) [LineTotal],
           MAX([MD].[HEADER_DISCOUNT]) [DocumentDiscount],
           --encabezado documento
           MAX([PH].[PICKING_DEMAND_HEADER_ID]) [DocumentId],
           MAX([PH].[DOC_NUM]) [DocNum],
           MAX([PH].[CODE_ROUTE]) [DocumentCodeRoute],
           MAX([PH].[TOTAL_AMOUNT]) [TotalAmount],
           MAX([PH].[WAVE_PICKING_ID]) [DocumentWavePickingId],
           MAX([PH].[DEMAND_TYPE]) [DocumentType],
           MAX([PH].[DISCOUNT]) [Discount],
           [PH].[CLIENT_CODE] [DocumentClientCode],
           [PH].[CLIENT_NAME] [DocumentClientName],
           MAX([PH].[ADDRESS_CUSTOMER]) [DocumentAddressCustomer],
           MAX([PH].[OWNER]) [Owner],
           --detalle documento
           MAX([MD].[MANIFEST_DETAIL_ID]) [DetailId],
           MAX([MD].[PICKING_DEMAND_HEADER_ID]) [DetailDocumentId],
           [MD].[MATERIAL_ID] [DetailMaterialId],
           MAX([M].[MATERIAL_NAME]) [DetailMaterialName],
           SUM([MD].[QTY]) [DetailQty],
           MAX([MD].[LINE_NUM]) [DetailLineNum],
           [MD].[PRICE] [DetailPrice],
           CAST('' AS VARCHAR(20)) [Tone],
           CAST('' AS VARCHAR(20)) [Caliber],
           CAST(0 AS [NUMERIC](18, 6)) [DetailDiscount],
           CAST('' AS VARCHAR(50)) [DiscountType],
           MAX([MD].[VOLUME_FACTOR_X_UNIT]) [VolumeFactorXUnit],
           MAX([MD].[WEIGHT_X_UNIT]) [WeightXUnit],
           MAX([MD].[VOLUME_FACTOR_X_LINE]) [VolumeFactorXLine],
           MAX([MD].[WEIGHT_X_LINE]) [WeightXLine],
           MAX([MD].[WEIGHT_MEASUREMENT]) [WeightMeasurement],
           MAX([MD].[COST_BY_MATERIAL]) [CostByMaterial]
    FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
        INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
            ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
        INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
            ON [MD].[PICKING_DEMAND_HEADER_ID] = [PH].[PICKING_DEMAND_HEADER_ID]
        --INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PD] ON [PD].[PICKING_DEMAND_HEADER_ID] = [PH].[PICKING_DEMAND_HEADER_ID]
        LEFT OUTER JOIN [wms].[OP_WMS_PILOT] [P]
            ON [P].[PILOT_CODE] = [MH].[DRIVER]
        LEFT OUTER JOIN [wms].[OP_WMS_VEHICLE] [V]
            ON [V].[VEHICLE_CODE] = [MH].[VEHICLE]
        LEFT JOIN @TEMP_CUSTOMER_NEXT_NOT_REPEATED [TCN]
            ON ([MD].[CLIENT_CODE] = [TCN].[CUSTOMER_CODE])
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON ([MD].[MATERIAL_ID] = [M].[MATERIAL_ID])
    WHERE [MH].[MANIFEST_HEADER_ID] = @ManifestHeaderId
    GROUP BY [MD].[CLIENT_CODE],
             [MD].[MATERIAL_ID],
             [MD].[WAVE_PICKING_ID],
             [MD].[MANIFEST_HEADER_ID],
             [MH].[STATUS],
             [MH].[MANIFEST_HEADER_ID],
             [MH].[DRIVER],
             [MH].[VEHICLE],
             [MH].[DISTRIBUTION_CENTER],
             [MH].[MANIFEST_TYPE],
             [MD].[ADDRESS_CUSTOMER],
             [MD].[CLIENT_NAME],
             [TCN].[LATITUDE],
             [TCN].[LONGITUDE],
             [PH].[CLIENT_CODE],
             [PH].[CLIENT_NAME],
             [TCN].[PHONE1],
             [TCN].[LATITUDE],
             [TCN].[LONGITUDE],
             [TCN].[IMG_FACADE],
             [TCN].[EMAIL],
			 [MD].[PRICE];

END;