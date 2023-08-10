-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180829 GForce@Ibice
-- Description:			obtiene el detalle de una orde de compra en sap de la cual se hizo una recepcion para posterior envió a sap r3

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181106 GForce@Mamba
-- Description:			se modifica para que solo devuelva las líneas de documento sin series, pues debido a un cambio de rfc se desarrollo otro sp que procesa y devuelve las series amarradas al documento de recepcion

/*
-- Ejemplo de Ejecucion:
         EXEC [wms].[OP_WMS_SP_GET_RECEPTION_DETAILS_BY_SAP_R3] @RECEPTION_HEADER = 104
*/
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_DETAILS_BY_SAP_R3]
(@RECEPTION_HEADER INT)
AS
BEGIN
    --
    SET NOCOUNT ON;
    --
    DECLARE @WAREHOUSE_CODE_PARAMETER VARCHAR(15) = NULL,
            @DOC_ID VARCHAR(50) = '-1',
            @DATE_CONFIRMED DATETIME,
            @COD_SUPPLIER VARCHAR(50),
            @NAME_SUPPLIER VARCHAR(100),
            @OWNER VARCHAR(50);
    --
    CREATE TABLE [#SERIE]
    (
        [SERIES] INT
    );
    --
    SELECT TOP 1
           @DOC_ID = [RDH].[DOC_ID],
           @OWNER = [RDH].[OWNER],
           @DATE_CONFIRMED = [RDH].[DATE_CONFIRMED],
           @COD_SUPPLIER = [RDH].[CODE_SUPPLIER],
           @NAME_SUPPLIER = [RDH].[NAME_SUPPLIER]
    FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
    WHERE [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER;


    CREATE TABLE [#RECEPTION]
    (
        [EBELN] VARCHAR(50),
        [BUKRS] VARCHAR(250),
        [AEDAT] DATETIME,
        [LIFNR] VARCHAR(50),
        [EKORG] VARCHAR(250),
        [MATNR] VARCHAR(250),
        [WERKS] VARCHAR(50),
        [LGORT] VARCHAR(4),
        [MENGE] DECIMAL(19, 6),
        [NAME1_LIFNR] VARCHAR(250),
        [EBELP] INT,
        [MEINS] VARCHAR(250),
        [MSEHL] VARCHAR(250),
        [BSART] VARCHAR(3),
        [CHARG] VARCHAR(9),
        [MOVE_TYPE] VARCHAR(3),
        [INPUT_TYPE] VARCHAR(2),
        [FRBNR] VARCHAR(33),
        [XBLNR] VARCHAR(35),
        [BKTXT] VARCHAR(116),
        [DOC_ID_POLIZA] DECIMAL(18, 0),
        [MATERIAL_ID] VARCHAR(50),
        [ROW_NUMBER] INT
    );

    -- ------------------------------------------------------------------------------------
    -- Obtiene la bodega por defecto para recepciones
    -- ------------------------------------------------------------------------------------
    SELECT @WAREHOUSE_CODE_PARAMETER = [C].[TEXT_VALUE]
    FROM [wms].[OP_WMS_CONFIGURATIONS] AS [C]
    WHERE [C].[PARAM_NAME] = 'ERP_WAREHOUSE_PURCHASE_ORDER';

    INSERT INTO [#RECEPTION]
    (
        [EBELN],
        [BUKRS],
        [AEDAT],
        [LIFNR],
        [EKORG],
        [MATNR],
        [WERKS],
        [LGORT],
        [MENGE],
        [NAME1_LIFNR],
        [EBELP],
        [MEINS],
        [MSEHL],
        [BSART],
        [CHARG],
        [MOVE_TYPE],
        [INPUT_TYPE],
        [FRBNR],
        [XBLNR],
        [BKTXT],
        [DOC_ID_POLIZA],
        [MATERIAL_ID],
        [ROW_NUMBER]
    )
    SELECT @DOC_ID [EBELN],
           [P].[BUKRS] [BUKRS], --este campo esta pendiente de definir de donde se va a extraer y si es importante para esta rfc
           @DATE_CONFIRMED [AEDAT],
           @COD_SUPPLIER [LIFNR],
           [P].[EKORG] [EKORG], --este campo esta pendiente de definir de donde se va a extraer y si es importante para esta rfc
           [P].[MATNR],
           [H].[OWNER] [WERKS],
           [D].[WAREHOUSE_CODE] [LGORT],
           [D].[QTY_CONFIRMED] [MENGE],
           [P].[NAME1_LIFNR] [NAME1_LIFNR],
           [D].[LINE_NUM] [EBELP],
                                --,[M].[BASE_MEASUREMENT_UNIT] [MEINS]
                                --,[CF].[TEXT_VALUE] [MSEHL]
           [P].[MEINS] [MEINS],
           [P].[MSEHL] [MSEHL],
           '101' [BSART],
           CASE
               WHEN [P].[RESWK] = '' THEN
                   'MAT-NUEVO'
               ELSE
                   [P].[CHARG]
           END [CHARG],
           '101' [MOVE_TYPE],
           'OC' [INPUT_TYPE],
           'Creada: ' + [T].[TASK_OWNER] [FRBNR],
           'Recibida: ' + [T].[TASK_ASSIGNEDTO] [XBLNR],
           'Tarea Swift3PL: ' + CAST([H].[TASK_ID] AS VARCHAR(100)) [BKTXT],
           [H].[DOC_ID_POLIZA],
           [M].[MATERIAL_ID],
           ROW_NUMBER() OVER (ORDER BY [D].[LINE_NUM] ASC) AS [ROW_NUMBER]
    FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
        INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
            ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [T]
            ON [T].[SERIAL_NUMBER] = [H].[TASK_ID]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
        INNER JOIN [SWIFT_R3_INTER].[dbo].[RFC_PURCHASES] [P]
            ON [P].[EBELN] = [H].[DOC_ID]
               AND [P].[EBELP] = [D].[LINE_NUM]
    WHERE [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER
          AND [D].[IS_CONFIRMED] = 1
          AND [D].[QTY_CONFIRMED] > 0
    ORDER BY [D].[LINE_NUM] ASC;

    DECLARE @LINE_NUM INT,
            @QTY NUMERIC(18, 4),
            @SERIAL_NUMBER_ID NUMERIC,
            @DOC_ID_POLIZA INT,
            @MATERIAL_ID VARCHAR(50);

    SELECT *
    FROM [#RECEPTION]
    ORDER BY [ROW_NUMBER] ASC;



END;