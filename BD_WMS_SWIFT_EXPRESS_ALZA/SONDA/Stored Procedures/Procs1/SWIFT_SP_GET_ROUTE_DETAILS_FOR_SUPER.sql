-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/4/2018 @ GFORCE-Team Sprint Elefante 
-- Description:			Obtiene la informacion y los detalles de la ruta para sonda super

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ROUTE_DETAILS_FOR_SUPER]
					@LOGIN = 'adolfo@SONDA',
					@TASK_TYPE = 'sale'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROUTE_DETAILS_FOR_SUPER]
    (
     @LOGIN VARCHAR(50)
    ,@TASK_TYPE VARCHAR(50)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    SELECT
        [RP].[RELATED_CLIENT_CODE] [CLIENT_CODE]
       ,[RP].[RELATED_CLIENT_NAME] [CLIENT_NAME]
       ,ISNULL([H].[GPS_URL], [RP].[EXPECTED_GPS]) [GPS]
       ,[T].[TASK_STATUS]
       ,[H].[DOC_NUM]
       ,[SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL]([H].[SALES_ORDER_ID]) [DOC_TOTAL]
       ,CONVERT(VARCHAR, DATEADD(SECOND,
                                 DATEDIFF(SECOND, [T].[ACCEPTED_STAMP],
                                          [T].[COMPLETED_STAMP]), 0), 108) AS [DELAY]
       ,[T].[REASON]
       ,CASE WHEN [T].[CANCELED_STAMP] IS NOT NULL THEN '#ff0000'
             WHEN [T].[TASK_STATUS] = 'COMPLETED' THEN '#bfff00'
             WHEN [T].[TASK_STATUS] = 'ACCEPTED' THEN '#ffff00'
             WHEN [T].[TASK_STATUS] = 'ASSIGNED' THEN '#C0C0C0'
        END [ICON_COLOR]
       ,ROW_NUMBER() OVER (ORDER BY ISNULL([T].[ACCEPTED_STAMP], GETDATE())
       , [RP].[TASK_SEQ] ASC) AS [ORDER]
    FROM
        [SONDA].[SONDA_ROUTE_PLAN] [RP]
    INNER JOIN [SONDA].[SWIFT_TASKS] [T] ON [RP].[TASK_ID] = [T].[TASK_ID]
    LEFT JOIN [SONDA].[SONDA_SALES_ORDER_HEADER] [H] ON [H].[TASK_ID] = [T].[TASK_ID]
    WHERE
        [RP].[ASSIGEND_TO] = @LOGIN
        AND [RP].[TASK_TYPE] = @TASK_TYPE
    ORDER BY
        ISNULL([T].[ACCEPTED_STAMP], GETDATE())
       ,[RP].[TASK_SEQ] ASC;
END;
