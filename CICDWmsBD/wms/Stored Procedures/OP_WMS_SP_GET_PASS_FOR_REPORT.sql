-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	27-Nov-2017 @ Team Reborn - Sprint Nach
-- Description:	 Sp el pase de salida para el reporte

-- Autor:			henry.rodriguez
-- Fecha:			07-Agosto-2019 G-Force@Estambul
-- Descripcion:		Se agrega parametro para saber si es la HH la que ejecuta el sp.

-- Autor:			fabrizzio.rivera
-- Fecha:			18-Junio-2020
-- Descripcion:		Se filtra el estatus a solo los terminados

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_PASS_FOR_REPORT] @PASS_ID = 7,  @DISTRIBUTION_CENTER_ID = 'CEDI_GT'
EXEC [wms].[OP_WMS_SP_GET_PASS_FOR_REPORT] @PASS_ID = 11460,  @DISTRIBUTION_CENTER_ID = 'CEDI_GT'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PASS_FOR_REPORT]
(
    @PASS_ID INT,
    @DISTRIBUTION_CENTER_ID VARCHAR(50),
    @IS_HANDHELD INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    DECLARE @COMPANY_NAME VARCHAR(150),
            @DOC_NUM_FLETE VARCHAR(100),
            @EXTERNAL_SOURCE_ID INT,
            @SOURCE_NAME VARCHAR(50),
            @DATA_BASE_NAME VARCHAR(50),
            @SCHEMA_NAME VARCHAR(50),
            @QUERY NVARCHAR(MAX),
            @DELIMITER CHAR(1) = '|',
            @ERP_WAREHOUSE VARCHAR(50),
            @DOC_NUM VARCHAR(MAX) = '';

    CREATE TABLE [#INFORMATION_OF_SELLER]
    (
        [DOC_NUM] INT,
        [SELLER] VARCHAR(155),
        [TRNSP_NAME] VARCHAR(40),
        [COMMENTS] VARCHAR(254),
        [PYMNT_GROUP] VARCHAR(100),
        [BRANCH_NAME] VARCHAR(250)
    );

    DECLARE @VALIDATE_INFO_SELLER INT = 0;

    SELECT TOP 1
           @COMPANY_NAME = [SC].[COMPANY_NAME]
    FROM [wms].[OP_SETUP_COMPANY] [SC];


    DECLARE @LOGINS TABLE
    (
        [LOGIN_ID] VARCHAR(25)
    );

    INSERT INTO @LOGINS
    (
        [LOGIN_ID]
    )
    SELECT DISTINCT
           [WU].[LOGIN_ID]
    FROM [wms].[OP_WMS_WAREHOUSES] [W]
        INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
            ON ([W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID])
    WHERE [W].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID;


    SELECT TOP 1
           @EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID],
           @SOURCE_NAME = [ES].[SOURCE_NAME],
           @DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME],
           @SCHEMA_NAME = [ES].[SCHEMA_NAME],
           @QUERY = N''
    FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
    WHERE [ES].[EXTERNAL_SOURCE_ID] > 0
          AND [ES].[READ_ERP] = 1
    ORDER BY [ES].[EXTERNAL_SOURCE_ID];

    SELECT DISTINCT
           @DOC_NUM = @DOC_NUM + ',' + CAST([PD].[DOC_NUM] AS VARCHAR(18))
    FROM [wms].[OP_WMS_PASS_DETAIL] [PD]
    WHERE [PD].[PICKING_DEMAND_HEADER_ID] > 0
          AND [PD].[PASS_HEADER_ID] = @PASS_ID;

    SET @DOC_NUM = SUBSTRING(@DOC_NUM, 2, LEN(@DOC_NUM));

    -- --------------------------------------------------------------------
    -- VALIDA SI LA HH HA REALIZADO LA EJECUCION 
    -- --------------------------------------------------------------------
    IF (@IS_HANDHELD <> 1)
    BEGIN
        SELECT @VALIDATE_INFO_SELLER = [VALUE]
        FROM [wms].[OP_WMS_PARAMETER]
        WHERE [GROUP_ID] = 'PASS'
              AND [PARAMETER_ID] = 'SHOW_SELLER_INFORMATION';
    END;


    IF (@DOC_NUM <> '' AND @VALIDATE_INFO_SELLER = 1)
    BEGIN
        PRINT ('rd-01:' + @DOC_NUM);
        SELECT @QUERY
            = N'INSERT INTO [#INFORMATION_OF_SELLER]
    EXEC ' + @DATA_BASE_NAME + N'.' + @SCHEMA_NAME + N'.SWIFT_SP_GET_INFORMATION_OF_SELLER @DOC_NUM = ''' + @DOC_NUM
              + N'''
  '     ;
        EXEC (@QUERY);
    END;

    SELECT [PD].[DOC_NUM],
           [PD].[PICKING_DEMAND_HEADER_ID],
           [PD].[PASS_HEADER_ID],
           [PD].[CLIENT_CODE],
           [PD].[CLIENT_NAME],
           [PD].[WAVE_PICKING_ID],
           ISNULL([CMP].[COMPONENT_MATERIAL], [PD].[MATERIAL_ID]) [MATERIAL_ID],
           ISNULL([M].[MATERIAL_NAME], [PD].[MATERIAL_NAME]) [MATERIAL_NAME],
           ISNULL(MAX([CMP].[QTY]), 1) * SUM([PD].[QTY]) AS [QTY]
    INTO [#DETAIL]
    FROM [wms].[OP_WMS_PASS_DETAIL] [PD]
        LEFT JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP]
            ON [CMP].[MASTER_PACK_CODE] = [PD].[MATERIAL_ID]
        LEFT JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON [CMP].[COMPONENT_MATERIAL] = [M].[MATERIAL_ID]
    WHERE [PD].[PASS_HEADER_ID] = @PASS_ID
    GROUP BY ISNULL([CMP].[COMPONENT_MATERIAL], [PD].[MATERIAL_ID]),
             ISNULL([M].[MATERIAL_NAME], [PD].[MATERIAL_NAME]),
             [PD].[DOC_NUM],
             [PD].[PICKING_DEMAND_HEADER_ID],
             [PD].[PASS_HEADER_ID],
             [PD].[CLIENT_CODE],
             [PD].[CLIENT_NAME],
             [PD].[WAVE_PICKING_ID];

    -- ------------------------------------------------------------------------------------
    -- El siguiente segmento unicamente aplica al cliente wms, para colocar el numuero de orden de la poliza a egresar.
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
           @DOC_NUM_FLETE = [p].[NUMERO_ORDEN]
    FROM [wms].[OP_WMS_TASK_LIST] [t]
        INNER JOIN [#DETAIL]
            ON [#DETAIL].[WAVE_PICKING_ID] = [t].[WAVE_PICKING_ID]
        INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [p]
            ON [t].[CODIGO_POLIZA_SOURCE] = [p].[CODIGO_POLIZA]
               AND [t].[CLIENT_OWNER] = 'wms';

    -- ------------------------------------------------------------------------------------
    -- Finaliza semento de wms
    -- ------------------------------------------------------------------------------------



    SELECT DISTINCT
        --Encabezado
           [P].[PASS_ID],
           @COMPANY_NAME AS [COMPANY_NAME],
           @DISTRIBUTION_CENTER_ID AS [DISTRIBUTION_CENTER_ID],
           [P].[HANDLER],
           [P].[AUTORIZED_BY],
           [P].[CREATED_DATE] [LAST_UPDATED],
           (CASE
                WHEN [P].[TYPE] = 'SALES_ORDER' THEN
                    'VENTA'
                WHEN [P].[TYPE] = 'TRANSFER_REQUEST' THEN
                    'TRANSFERENCIA'
                WHEN [P].[TYPE] = 'GENERAL_DISPATCH' THEN
                    'DESPACHO GENERAL'
            END
           ) [TYPE],
           --Detalle 
           [PD].[CLIENT_CODE],
           [PD].[CLIENT_NAME],
           [PD].[WAVE_PICKING_ID],
           (CASE
                WHEN [P].[TYPE] = 'TRANSFER_REQUEST' THEN
                    [PDH].[DOC_NUM_SEQUENCE]
                WHEN [P].[TYPE] = 'GENERAL_DISPATCH' THEN
                    [PD].[DOC_NUM]
                ELSE
                    ISNULL(ISNULL([TRH].[DOC_NUM], [PD].[DOC_NUM]), 0)
            END
           ) [DOC_NUM],
           ISNULL([PDH].[ERP_REFERENCE], @DOC_NUM_FLETE) [ERP_REFERENCE],
           [PD].[MATERIAL_ID],
           [PD].[MATERIAL_NAME],
           [PD].[QTY] [QTY],
           [P].[VEHICLE_PLATE],
           [PT].[NAME] + ' ' + [PT].[LAST_NAME] AS [VEHICLE_DRIVER],
           ISNULL([P].[TXT], [PDH].[ADDRESS_CUSTOMER]) [ADDRESS_CUSTOMER],
           [SELLER],
           [TRNSP_NAME],
           [COMMENTS],
           [PYMNT_GROUP],
           [BRANCH_NAME],
           [PDH].[DEMAND_DELIVERY_DATE]
    FROM [wms].[OP_WMS3PL_PASSES] [P]
        INNER JOIN @LOGINS [L]
            ON (
                   [L].[LOGIN_ID] = [P].[CREATED_BY]
                   OR [L].[LOGIN_ID] = [P].[LAST_UPDATED_BY]
               )
        LEFT JOIN [#DETAIL] [PD]
            ON ([P].[PASS_ID] = [PD].[PASS_HEADER_ID])
        LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
            ON ([PD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID])
        LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH]
            ON [TRH].[TRANSFER_REQUEST_ID] = [PDH].[TRANSFER_REQUEST_ID]
        LEFT JOIN [#INFORMATION_OF_SELLER] [IS]
            ON ([PD].[DOC_NUM] = [IS].[DOC_NUM])
        LEFT JOIN [wms].[OP_WMS_PILOT] [PT]
            ON ([P].[DRIVER_ID] = [PT].[PILOT_CODE])
    WHERE [P].[PASS_ID] = @PASS_ID
   AND [P].STATUS = 'FINALIZED';
END;