-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        Obtiene las polizas pendientes por costear

-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20191217 GForce@Madagascar
-- Description:	        incluyo en query polizas de traslado a regimen general

-- Autor:	            henry.rodriguez
-- Fecha de Creacion: 	24-Enero-2020 G-Force@Kioto - branch @Kioto
-- Description:	        Se agrega el codigo y fecha de ticket asociada a la poliza.


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_POLIZA_HEADER_PENDING_AUTHORIZED] @START_DATE = '2017-03-01 00:00:00.000'
                                                                  ,@END_DATE ='2017-05-30 23:59:00.000'
                                                                  ,@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE wms.[OP_WMS_GET_POLIZA_HEADER_PENDING_AUTHORIZED]
(
    @START_DATE DATETIME,
    @END_DATE DATETIME,
    @LOGIN VARCHAR(25)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

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
           [PH].[FECHA_DOCUMENTO],
           [PH].[FECHA_LLEGADA],
           [PH].[POLIZA_ASEGURADA],
           [ID].[POLIZA_INSURANCE] AS [POLIZA_ASEGURADA_DESCRIPCION],
           CONVERT(NUMERIC, ISNULL(COALESCE(NULLIF([PH].[ACUERDO_COMERCIAL], ''), '0'), 0)) AS ACUERDO_COMERCIAL_ID,
           CONVERT(VARCHAR(10), [PH].[ACUERDO_COMERCIAL]) + '-' + [TH].[ACUERDO_COMERCIAL_NOMBRE] AS [ACUERDO_COMERCIAL_NOMBRE],
           [T].[TRANS_TYPE],
           [C].[CLIENT_NAME],
           [TK].[TICKET_NUMBER],
           [TK].[CREATED_DATE] AS 'TICKET_DATE'
    FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
        INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C]
            ON ([C].[CLIENT_CODE] = [PH].[CLIENT_CODE])
        INNER JOIN [wms].[OP_WMS_TRANS] [T]
            ON (
                   [T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
                   AND
                   (
                       [T].[TRANS_TYPE] = 'INICIALIZACION_GENERAL'
                       OR [T].[TRANS_TYPE] = 'INGRESO_GENERAL'
                       OR [T].[TRANS_TYPE] = 'RECEP_GENERAL_X_TRASLADO'
                   )
               )
        LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
            ON (
                   [PH].[DOC_ID] = [PD].[DOC_ID]
                   AND [PD].[MATERIAL_ID] = [T].[MATERIAL_CODE]
                   AND ISNULL([PD].[IS_AUTHORIZED], 0) = 1
               )
        INNER JOIN [#WAREHOUSES] [W]
            ON ([W].[WAREHOUSE_ID] = [T].[TARGET_WAREHOUSE])
        LEFT JOIN [wms].OP_WMS_FN_GET_INSURANCE_DOC() [ID]
            ON ([PH].[POLIZA_ASEGURADA] = [ID].[DOC_ID])
        LEFT JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH]
            ON ([TH].[ACUERDO_COMERCIAL_ID] = [PH].[ACUERDO_COMERCIAL])
        LEFT JOIN [wms].[OP_WMS_TICKETS] [TK]
            ON ([TK].[POLIZA_DOC_ID] = [PH].[DOC_ID])
    WHERE [PH].[STATUS] <> 'COSTED'
          AND CAST([PH].[FECHA_DOCUMENTO] AS DATE)
          BETWEEN @START_DATE AND @END_DATE
          AND ISNULL([PD].[IS_AUTHORIZED], 0) = 0;

END;