-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-03-13 @ Team ERGON - Sprint VERGON 
-- Description:	        sp que obtiene el inventario 

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-15 Team ERGON - Sprint ERGON V
-- Description:	 Se agrego el codigo y nombre del proveedor

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego bodegas de usuario logueado 

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	29-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego ZONE

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	22-05-2017 Team Ergon SPRINT Sheik
-- Description:			    Se agrego HANDLE_SERIAL

-- Modificacion 18-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se agregan columnas de vencimiento 

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agregaron STATUS_NAME, [BLOCKS_INVENTORY] y COLOR

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-15 @ Team REBORN - Sprint 
-- Description:	   Se agrego TONE y CALIBER

-- Autor:				diego.as
-- Fecha de Creacion: 	2018-04-11 G-Force - Sprint Buho
-- Description:			Se agrega LEFT JOIN a tablas [OP_WMS_LICENSES] y [OP_WMS_NEXT_PICKING_DEMAND_HEADER]
--						para devolver los campos [DOC_NUM], [PROJECT], [CLIENT_NAME], [LOCKED_BY_INTERFACES]	

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190109 GForce@Quetzal
-- Descripcion:			Se agrega peso y unidad de peso

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	20190409 GForce@Wapiti
-- Descripcion:			Se agrego el campo PK_LINE, DATE_EXPIRATION, STATUS_ID

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190725 GForce@Dublin
-- Descripcion:			Se agrega la informacion del proyecto en el inventario en linea

-- Modificacion 		1/25/2020 @ G-Force Team Sprint Paris
-- Autor: 				CARLOS.LARA
-- Historia/Bug:		Product Backlog Item 34990: Registro de espacios físicos por posición
-- Descripcion: 		1/25/2020 - Se agrego el campo TOTAL_POSITION de la tabla [wms].[OP_WMS_INV_X_LICENSE]

-- Modificación			Elder Lucas
-- Fecha: 				31 de enero de 2022
-- Descripcion:			Se agrega información de la zona para saber si esta permite o no picking

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_INVENTORY_ONLINE] @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_ONLINE]
(@LOGIN VARCHAR(25))
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @WAREHOUSES TABLE
    (
        [WAREHOUSE_ID] VARCHAR(25),
        [NAME] VARCHAR(50),
        [COMMENTS] VARCHAR(150),
        [ERP_WAREHOUSE] VARCHAR(50),
        [ALLOW_PICKING] NUMERIC,
        [DEFAULT_RECEPTION_LOCATION] VARCHAR(25),
        [SHUNT_NAME] VARCHAR(25),
        [WAREHOUSE_WEATHER] VARCHAR(50),
        [WAREHOUSE_STATUS] INT,
        [IS_3PL_WAREHUESE] INT,
        [WAHREHOUSE_ADDRESS] VARCHAR(250),
        [GPS_URL] VARCHAR(100),
        [WAREHOUSE_BY_USER_ID] INT
            UNIQUE ([WAREHOUSE_ID])
    );
    --
    DECLARE @VALORIZACION TABLE
    (
        [LICENSE_ID] NUMERIC,
        [VALOR_UNITARIO] NUMERIC(36, 6),
        [TOTAL_VALOR] NUMERIC(36, 6),
        [MATERIAL_ID] VARCHAR(50)
    );
    --
    DECLARE @PARAM_GROUP VARCHAR(25) = 'REGIMEN',
            @WAREHOUSE_REGIMEN VARCHAR(25) = 'FISCAL';

    -- ------------------------------------------------------------------------------------
    -- Obtiene todas las bodegas asociadas a un usuario
    -- ------------------------------------------------------------------------------------
    INSERT INTO @WAREHOUSES
    EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN;

    -- ------------------------------------------------------------------------------------
    -- Obtiene la valorizacion
    -- ------------------------------------------------------------------------------------
    INSERT INTO @VALORIZACION
    SELECT [V].[LICENSE_ID],
           [V].[VALOR_UNITARIO],
           [V].[TOTAL_VALOR],
           [V].[MATERIAL_ID]
    FROM [wms].[OP_WMS_VIEW_VALORIZACION] [V]
    WHERE [V].[QTY] > 0;

    -- ------------------------------------------------------------------------------------
    -- Se muestra el resultado
    -- ------------------------------------------------------------------------------------
    SELECT [ID].[PK_LINE],
           [ID].[BATCH_REQUESTED],
           [ID].[STATUS_ID],
           [ID].[HANDLE_TONE],
           [ID].[HANDLE_CALIBER],
           [ID].[TONE_AND_CALIBER_ID],
           [ID].[CLIENT_NAME],
           [ID].[NUMERO_ORDEN],
           [ID].[NUMERO_DUA],
           [ID].[FECHA_LLEGADA],
           [ID].[LICENSE_ID],
           [ID].[TERMS_OF_TRADE],
           [ID].[MATERIAL_ID],
           [ID].[MATERIAL_CLASS],
           [ID].[BARCODE_ID],
           [ID].[VOLUME_FACTOR],
           [ID].[ALTERNATE_BARCODE],
           [ID].[MATERIAL_NAME],
           [ID].[QTY],
		   ISNULL([CI].[COMMITED_QTY], 0) AS COMMITED_QTY,
           [ID].[CLIENT_OWNER],
           [ID].[REGIMEN],
           [ID].[CODIGO_POLIZA],
           [ID].[CURRENT_LOCATION],
           [ID].[VOLUMEN],
           [ID].[TOTAL_VOLUMEN],
           [ID].[LAST_UPDATED_BY],
           [ID].[SERIAL_NUMBER],
           [ID].[SKU_SERIE],
           [ID].[DATE_EXPIRATION],
           [ID].[BATCH],
           [ID].[CURRENT_WAREHOUSE],
           [ID].[DOC_ID],
           [ID].[USED_MT2],
           [ID].[VIN],
           [ID].[PENDIENTE_RECTIFICACION],
           [TH].[ACUERDO_COMERCIAL_ID],
           [TH].[ACUERDO_COMERCIAL_NOMBRE],
           [TH].[VALID_FROM],
           [TH].[VALID_TO],
           [TH].[EXPIRES],
           [TH].[CURRENCY],
           [TH].[STATUS],
           [TH].[WAREHOUSE_WEATHER],
           [TH].[LAST_UPDATED],
           [TH].[LAST_UPDATED_BY],
           [TH].[LAST_UPDATED_AUTH_BY],
           [TH].[COMMENTS],
           [TH].[REGIMEN],
           [TH].[AUTHORIZER],
           [PH].[REGIMEN] [REGIMEN_DOCUMENTO],
           [C].[SPARE1] AS [GRUPO_REGIMEN],
           [ID].[CODE_SUPPLIER],
           [ID].[NAME_SUPPLIER],
           [ID].[ZONE],
		   CASE [ID].[ALLOW_PICKING]
				WHEN 1 THEN 'SI'
				ELSE 'NO'
		   END AS [ALLOW_PICKING],
		   CASE [ID].[ALLOW_REALLOC]
				WHEN 1 THEN 'SI'
				ELSE 'NO'
		   END AS [ALLOW_REALLOC],
           CASE
               WHEN ISNULL([ID].[LOCKED_BY_INTERFACES], 0) = 1 THEN
                   0
               ELSE
           ([ID].[QTY] - ISNULL([CI].[COMMITED_QTY], 0))
           END AS [AVAILABLE_QTY],
           [V].[VALOR_UNITARIO],
           [V].[TOTAL_VALOR],
           CASE [ID].[HANDLE_SERIAL]
               WHEN 1 THEN
                   'Si'
               WHEN 0 THEN
                   'No'
               ELSE
                   'No'
           END [HANDLE_SERIAL],
           CASE [ID].[IS_EXTERNAL_INVENTORY]
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS [IS_EXTERNAL_INVENTORY],
           [PH].[FECHA_DOCUMENTO],
           CASE [PH].[WAREHOUSE_REGIMEN]
               WHEN @WAREHOUSE_REGIMEN THEN
                   [wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]([PH].[REGIMEN])
               ELSE
                   NULL
           END [DIAS_REGIMEN],
           CASE [PH].[WAREHOUSE_REGIMEN]
               WHEN @WAREHOUSE_REGIMEN THEN
                   DATEDIFF(DAY, GETDATE(), [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA]))
               ELSE
                   NULL
           END [DIAS_PARA_VENCER],
           CASE [PH].[WAREHOUSE_REGIMEN]
               WHEN @WAREHOUSE_REGIMEN THEN
                   [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])
               ELSE
                   NULL
           END [FECHA_VENCIMIENTO],
           CASE
               WHEN [PH].[WAREHOUSE_REGIMEN] = 'FISCAL'
                    AND DATEDIFF(
                                    DAY,
                                    GETDATE(),
                                    [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])
                                ) < 1 THEN
                   'Bloqueado'
               ELSE
                   'Libre'
           END [ESTADO_REGIMEN],
           [ID].[STATUS_NAME],
           [ID].[STATUS_CODE],
           [ID].[BLOCKS_INVENTORY],
           [ID].[COLOR],
           [ID].[TONE],
           [ID].[CALIBER],
           [DH].[DOC_NUM] AS [SALE_ORDER_ID],
           [DH].[PROJECT],
           [DH].[CLIENT_NAME] AS [CUSTOMER_NAME],
           CASE
               WHEN [ID].[LOCKED_BY_INTERFACES] = 1 THEN
                   'Si'
               WHEN [ID].[LOCKED_BY_INTERFACES] = 0 THEN
                   'No'
           END [LOCKED_BY_INTERFACES],
           [ID].[WEIGTH],
           [ID].[WEIGHT_MEASUREMENT],
           [L].[WAVE_PICKING_ID],
           [ID].[PROJECT_CODE],
           [ID].[PROJECT_SHORT_NAME],
           ISNULL(
           (
               SELECT TOP (1)
                      IXL.TOTAL_POSITION
               FROM [wms].OP_WMS_INV_X_LICENSE AS IXL
               WHERE IXL.LICENSE_ID = ID.LICENSE_ID
               ORDER BY IXL.LICENSE_ID
           ),
           1
                 ) [TOTAL_POSITION]
    FROM [wms].[OP_WMS_VIEW_INVENTORY_DETAIL_WHITH_SERIES] [ID]
        INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH]
            ON ([ID].[TERMS_OF_TRADE] = CAST([TH].[ACUERDO_COMERCIAL_ID] AS VARCHAR(50)))
        LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON ([PH].[CODIGO_POLIZA] = [ID].[CODIGO_POLIZA])
        LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
            ON (
                   [C].[PARAM_GROUP] = @PARAM_GROUP
                   AND [C].[PARAM_NAME] = [PH].[REGIMEN]
               )
        INNER JOIN @WAREHOUSES [W]
            ON [W].[WAREHOUSE_ID] = [ID].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT
        LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI]
            ON (
                   [ID].[MATERIAL_ID] = [CI].[MATERIAL_ID]
                   AND [ID].[CLIENT_OWNER] = [CI].[CLIENT_OWNER]
                   AND [CI].[LICENCE_ID] = [ID].[LICENSE_ID]
               )
        LEFT JOIN @VALORIZACION [V]
            ON (
                   [V].[LICENSE_ID] = [ID].[LICENSE_ID]
                   AND [ID].[MATERIAL_ID] = [V].[MATERIAL_ID]
               )
        LEFT JOIN [wms].[OP_WMS_LICENSES] AS [L]
            ON ([L].[LICENSE_ID] = [ID].[LICENSE_ID])
        LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] AS [DH]
            ON ([DH].[PICKING_DEMAND_HEADER_ID] = [L].[PICKING_DEMAND_HEADER_ID])
    WHERE [ID].[QTY] > 0;
END;