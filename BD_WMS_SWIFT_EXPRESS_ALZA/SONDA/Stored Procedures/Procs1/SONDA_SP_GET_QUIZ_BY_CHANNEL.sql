

-- Autor:					christian.hernandez
-- Fecha de descripcion: 		02/12/2019 @ G-Force Team Sprint Salamandra
-- Historia/Bug:			Product Backlog Item 26937: Aplicación de MicroEncuestas a Clientes del Canal
-- Description:	 - 			Obtiene los canales de las encuestas vigentes    


-- Modificacion:	alejandro.ochoa
-- Fecha:			17/05/2019 @ G-Force Team Sprint Venado
-- Description:		Se elimina el uso del SP SWIFT_SP_GET_CUSTUMER_FOR_SCOUTING para mejorar el performance
--					y para obtener unicamente los canales de las encuestas asociadas a la ruta.

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SONDA_SP_GET_QUIZ_BY_CHANNEL]
*/
-- =============================================


CREATE PROCEDURE [SONDA].[SONDA_SP_GET_QUIZ_BY_CHANNEL]
(@CODE_ROUTE VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;


    -- -------------------
    -- Declaramos las variables necesarioas.
    -- -------------------
    DECLARE @TODAY DATE = GETDATE();
    -- -------------------
    -- Retornamos el resultado
    -- -------------------

    SELECT DISTINCT
           ROW_NUMBER() OVER (ORDER BY [SAQ].[CODE_CHANNEL]) AS [CHANNEL_BY_QUIZ_ID],
           [SQ].[QUIZ_ID],
           [SAQ].[CODE_CHANNEL]
    FROM [SONDA].[SWIFT_QUIZ] [SQ]
        INNER JOIN [SONDA].[SWIFT_ASIGNED_QUIZ] [SAQ]
            ON ([SQ].[QUIZ_ID] = [SAQ].[QUIZ_ID])
        INNER JOIN [SONDA].[SWIFT_ASIGNED_QUIZ] [QBR]
            ON (
                   [QBR].[QUIZ_ID] = [SAQ].[QUIZ_ID]
                   AND [QBR].[ROUTE_CODE] = @CODE_ROUTE
               )
    WHERE @TODAY
          BETWEEN [SQ].[VALID_START_DATETIME] AND [SQ].[VALID_END_DATETIME]
          AND [SAQ].[CODE_CHANNEL] IS NOT NULL;

END;





