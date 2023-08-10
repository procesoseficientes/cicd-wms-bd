-- =============================================
-- Autor:					christian.hernandez
-- Fecha de Creacion: 		11/15/2018 @ G-Force Team Sprint Nutria
-- Historia/Bug:			Product Backlog Item 23773: Micro Encuestas en Preventa
-- Description:	11/15/2018 - SP que obtiene las microencuestas por ruta		     


-- Autor:					christian.hernandez
-- Fecha de descripcion: 		02/12/2019 @ G-Force Team Sprint Salamandra
-- Historia/Bug:			Product Backlog Item 26937: Aplicación de MicroEncuestas a Clientes del Canal
-- Description:	 - 			Obtiene los canales asignados a la ruta para asocirlos despues en el movil

-- Autor:					rudi.garcia
-- Fecha de descripcion: 		02/12/2019 @ G-Force Team Sprint Venado
-- Historia/Bug:			Product Backlog Item 26937: Aplicación de MicroEncuestas a Clientes del Canal
-- Description:	 - 			Obtiene las encuestas para la ruta.     

-- Modificacion:	alejandro.ochoa
-- Fecha:			17/05/2019 @ G-Force Team Sprint Venado
-- Description:		Se elimina el uso del SP SWIFT_SP_GET_CUSTUMER_FOR_SCOUTING para mejorar el performance
--					y para obtener unicamente los canales de las encuestas asociadas a la ruta.

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SONDA_SP_GET_QUIZ_BY_ROUTE]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_QUIZ_BY_ROUTE]
(@CODE_ROUTE VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;

    -- -------------------
    -- Declaramos las variables necesarioas.
    -- -------------------
    DECLARE @TODAY DATE = GETDATE();

    DECLARE @TABLE_QUIZ TABLE
    (
        [QUIZ_ID] INT,
        [NAME_QUIZ] VARCHAR(50),
        [VALID_START_DATETIME] DATETIME,
        [VALID_END_DATETIME] DATETIME,
        [ORDER] INT,
        [REQUIRED] INT,
        [QUIZ_START] INT,
        [CHANNELS_ON_QUIZ] INT
    );

    DECLARE @TABLE_QUIZ_TEMP TABLE
    (
        [QUIZ_ID] INT,
        [NAME_QUIZ] VARCHAR(50),
        [VALID_START_DATETIME] DATETIME,
        [VALID_END_DATETIME] DATETIME,
        [ORDER] INT,
        [REQUIRED] INT,
        [QUIZ_START] INT,
        [CHANNELS_ON_QUIZ] INT
    );

    -- -------------------
    -- Obtenemos las encuestas por ruta
    -- -------------------

    INSERT INTO @TABLE_QUIZ
    (
        [QUIZ_ID],
        [NAME_QUIZ],
        [VALID_START_DATETIME],
        [VALID_END_DATETIME],
        [ORDER],
        [REQUIRED],
        [QUIZ_START],
        [CHANNELS_ON_QUIZ]
    )
    SELECT [SQ].[QUIZ_ID],
           [SQ].[NAME_QUIZ],
           [SQ].[VALID_START_DATETIME],
           [SQ].[VALID_END_DATETIME],
           [SQ].[ORDER],
           [SQ].[REQUIRED],
           [SQ].[QUIZ_START],
           1 AS [CHANNELS_ON_QUIZ]
    FROM [SONDA].[SWIFT_QUIZ] [SQ]
        INNER JOIN [SONDA].[SWIFT_ASIGNED_QUIZ] [SAQ]
            ON [SQ].[QUIZ_ID] = [SAQ].[QUIZ_ID]
    WHERE [SAQ].[ROUTE_CODE] = @CODE_ROUTE
          AND @TODAY
          BETWEEN [SQ].[VALID_START_DATETIME] AND [SQ].[VALID_END_DATETIME];

    -- -------------------
    -- Obtenemos las encuestas de la ruta que estan asociadas a canales
    -- -------------------

    INSERT INTO @TABLE_QUIZ_TEMP
    (
        [QUIZ_ID],
        [NAME_QUIZ],
        [VALID_START_DATETIME],
        [VALID_END_DATETIME],
        [ORDER],
        [REQUIRED],
        [QUIZ_START],
        [CHANNELS_ON_QUIZ]
    )
    SELECT DISTINCT
           [SQ].[QUIZ_ID],
           [SQ].[NAME_QUIZ],
           [SQ].[VALID_START_DATETIME],
           [SQ].[VALID_END_DATETIME],
           [SQ].[ORDER],
           [SQ].[REQUIRED],
           [SQ].[QUIZ_START],
           1 AS [CHANNELS_ON_QUIZ]
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

    -- -------------------
    -- Realizamos un marge de las encuestas por ruta y las por canal, para solo no enviar encuestas duplicadas
    -- -------------------

    MERGE @TABLE_QUIZ AS [TG]
    USING @TABLE_QUIZ_TEMP AS [SC]
    ON ([TG].[QUIZ_ID] = [SC].[QUIZ_ID])
    WHEN MATCHED THEN
        UPDATE SET [TG].[CHANNELS_ON_QUIZ] = 3
    WHEN NOT MATCHED THEN
        INSERT
        (
            [QUIZ_ID],
            [NAME_QUIZ],
            [VALID_START_DATETIME],
            [VALID_END_DATETIME],
            [ORDER],
            [REQUIRED],
            [QUIZ_START],
            [CHANNELS_ON_QUIZ]
        )
        VALUES
        ([QUIZ_ID], [NAME_QUIZ], [VALID_START_DATETIME], [VALID_END_DATETIME], [ORDER], [REQUIRED], [QUIZ_START], 2);



    -- -------------------
    -- Retornamos el resultado
    -- -------------------

    SELECT [TQ].[QUIZ_ID],
           [TQ].[NAME_QUIZ],
           [TQ].[VALID_START_DATETIME],
           [TQ].[VALID_END_DATETIME],
           [TQ].[ORDER],
           [TQ].[REQUIRED],
           [TQ].[QUIZ_START],
           [TQ].[CHANNELS_ON_QUIZ]
    FROM @TABLE_QUIZ [TQ];

END;




