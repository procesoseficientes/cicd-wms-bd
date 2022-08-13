-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-26 @ Team ERGON - Sprint Sheik
-- Description:	        Obtiene las polizas costeadas pendiente de autorizar

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20191217 GForce@Madagascar
-- Description:	        Agrego filtro para mostrar polizas que vienen de traslado a general


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_POLIZA_TO_AUTHORIZE] @START_DATE = '2014-01-01 23:59:00.000'
                                                                  ,@END_DATE ='2018-02-03 23:59:00.000'
                                                                  ,@LOGIN = 'ADMIN'
                                                                  ,@WAREHOUSES_ID = 'BODEGA_01|BODEGA_01_ANEXO|BODEGA_02|BODEGA_03|BODEGA_04|BODEGA_05|BODEGA_C002'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_POLIZA_TO_AUTHORIZE]
(
    @START_DATE DATETIME,
    @END_DATE DATETIME,
    @LOGIN VARCHAR(25),
    @WAREHOUSES_ID VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    DECLARE @DELIMITER CHAR(1) = '|';



    -- SE OBTIENEN BODEGAS DE USUARIO LOGUEADO

    CREATE TABLE #WAREHOUSES
    (
        WAREHOUSE_ID VARCHAR(25),
        NAME VARCHAR(50),
        COMMENTS VARCHAR(150),
        ERP_WAREHOUSE VARCHAR(50),
        ALLOW_PICKING NUMERIC,
        DEFAULT_RECEPTION_LOCATION VARCHAR(25),
        SHUNT_NAME VARCHAR(25),
        WAREHOUSE_WEATHER VARCHAR(50),
        WAREHOUSE_STATUS INT,
        IS_3PL_WAREHUESE INT,
        WAHREHOUSE_ADDRESS VARCHAR(250),
        GPS_URL VARCHAR(100),
        WAREHOUSE_BY_USER_ID INT
    );

    INSERT INTO #WAREHOUSES
    EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN;

    --SE MESTRA EL RESULTADO


    SELECT DISTINCT
           [PH].[DOC_ID],
           [PH].[CODIGO_POLIZA],
           [PH].[NUMERO_ORDEN],
           [PH].[CLIENT_CODE],
           [VC].[CLIENT_NAME],
           [PH].[FECHA_DOCUMENTO],
           [PH].[FECHA_LLEGADA],
           --,[PH].[POLIZA_ASEGURADA]    
           [T].[TRANS_TYPE],
           [PD].[LINE_NUMBER],
           [PD].[SKU_DESCRIPTION],
           [PD].[QTY],
           [PD].[CUSTOMS_AMOUNT],
           [PD].[LAST_UPDATED_BY],
           [PD].[LAST_UPDATED],
           [PD].[MATERIAL_ID],
           [PD].[UNITARY_PRICE],
           [ID].[POLIZA_INSURANCE] AS [POLIZA_ASEGURADA],
           CONVERT(NUMERIC, ISNULL([PH].[ACUERDO_COMERCIAL], 0)) AS ACUERDO_COMERCIAL_ID,
           CONVERT(VARCHAR(10), [PH].[ACUERDO_COMERCIAL]) + '-' + [TH].[ACUERDO_COMERCIAL_NOMBRE] AS [ACUERDO_COMERCIAL],
           CASE [PD].[IS_AUTHORIZED]
               WHEN 1 THEN
                   'Cerrado'
               WHEN 0 THEN
                   'Abierto'
               ELSE
                   'Abierto'
           END AS [STATUS]
    FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
        INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
            ON [PH].[DOC_ID] = [PD].[DOC_ID]
        INNER JOIN [wms].[OP_WMS_TRANS] [T]
            ON (
                   [T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
                   AND [PD].[MATERIAL_ID] = [T].[MATERIAL_CODE]
                   AND
                   (
                       [T].[TRANS_TYPE] = 'INICIALIZACION_GENERAL'
                       OR [T].[TRANS_TYPE] = 'INGRESO_GENERAL'
                       OR [T].TRANS_TYPE = 'RECEP_GENERAL_X_TRASLADO'
                   )
               )
        INNER JOIN [#WAREHOUSES] [W]
            ON ([W].[WAREHOUSE_ID] = [T].[TARGET_WAREHOUSE])
        INNER JOIN [wms].OP_WMS_FUNC_SPLIT_3(@WAREHOUSES_ID, @DELIMITER) [WF]
            ON ([T].[TARGET_WAREHOUSE] = [WF].[VALUE])
        LEFT JOIN [wms].OP_WMS_FN_GET_INSURANCE_DOC() [ID]
            ON ([PH].[POLIZA_ASEGURADA] = [ID].[DOC_ID])
        LEFT JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH]
            ON ([TH].[ACUERDO_COMERCIAL_ID] = [PH].[ACUERDO_COMERCIAL])
        LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC]
            ON [PH].[CLIENT_CODE] = [VC].[CLIENT_CODE]
    WHERE [PH].[FECHA_DOCUMENTO]
    BETWEEN @START_DATE AND @END_DATE;


END;