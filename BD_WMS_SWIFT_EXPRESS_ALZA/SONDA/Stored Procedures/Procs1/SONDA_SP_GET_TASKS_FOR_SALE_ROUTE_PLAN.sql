-- =============================================
-- Autor:				Christian Hernandez 
-- Fecha de Creacion: 	05/25/2018
-- Description:			Genera las tareas para el dia actual para las rutas de venta por el codigo de ruta 

-- =============================================

CREATE PROCEDURE SONDA.SONDA_SP_GET_TASKS_FOR_SALE_ROUTE_PLAN
    @CODE_ROUTE VARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;

        SELECT DISTINCT	[RP].[TASK_ID] ,
                [RP].[CODE_FREQUENCY] ,
                [RP].[SCHEDULE_FOR] ,
                [RP].[ASSIGNED_BY] ,
                [RP].[DOC_PARENT] ,
                [RP].[EXPECTED_GPS] ,
                [dbo].[FUNC_REMOVE_SPECIAL_CHARS]([RP].[TASK_COMMENTS]) [TASK_COMMENTS] ,
                [RP].[TASK_SEQ] ,
                [RP].[TASK_ADDRESS] ,
                [RP].[RELATED_CLIENT_PHONE_1] ,
                [RP].[EMAIL_TO_CONFIRM] ,
                [RP].[RELATED_CLIENT_CODE] ,
                [dbo].[FUNC_REMOVE_SPECIAL_CHARS]([RP].[RELATED_CLIENT_NAME]) [RELATED_CLIENT_NAME] ,
                [RP].[TASK_PRIORITY] ,
                [RP].[TASK_STATUS] ,
                [RP].[SYNCED] ,
                [RP].[NO_PICKEDUP] ,
                [RP].[NO_VISIT_REASON] ,
                [RP].[IS_OFFLINE] ,
                [RP].[DOC_NUM] ,
                [RP].[TASK_TYPE] ,
                [RP].[TASK_DATE] ,
                [RP].[CREATED_STAMP] ,
                [RP].[ASSIGEND_TO] ,
                [RP].[CODE_ROUTE] ,
                [RP].[TARGET_DOC] ,
                [RP].[IN_PLAN_ROUTE] ,
                [RP].[CREATE_BY] ,
                ISNULL([C].[RGA_CODE], '') RGA_CODE ,
                ISNULL([C].[TAX_ID_NUMBER], 'C.F') NIT ,
                C.PHONE_CUSTOMER ,
                [LCR].CODE_PRICE_LIST
        FROM    [SONDA].[SONDA_ROUTE_PLAN] [RP]
                INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C] ON [C].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE]
                LEFT JOIN [SONDA].SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE [LCR] ON [LCR].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
        WHERE   [RP].[CODE_ROUTE] = @CODE_ROUTE
                AND [RP].TASK_TYPE = 'SALE'
        ORDER BY [RP].[TASK_SEQ];

    END;
