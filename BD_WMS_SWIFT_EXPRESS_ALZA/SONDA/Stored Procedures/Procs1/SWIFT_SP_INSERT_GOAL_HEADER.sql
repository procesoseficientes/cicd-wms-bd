-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	04-07-2018
-- Description:			Inserta el encabezado de las metas
--						Devuelve el id de la meta creado.

-- Modificacion 		8/5/2019 @ G-Force Team Sprint Groenlandia
-- Autor: 				diego.as
-- Historia/Bug:		Impediment 31075: Ajuste de funcionalidad de metas BO Swift Express
-- Descripcion: 		8/5/2019 - Se agrega insercion de campo PERIOD_DAYS y se formatea codigo

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SWIFT_SP_GET_GOAL_HEADER
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_GOAL_HEADER]
    @GOAL_NAME AS VARCHAR(250),
    @TEAM_ID AS INT,
    @GOAL_AMOUNT AS DECIMAL(18, 6),
    @GOAL_DATE_FROM AS DATETIME,
    @GOAL_DATE_TO AS DATETIME,
    @STATUS AS VARCHAR(250),
    @INCLUDE_SATURDAY AS INT,
    @LAST_UPDATE_BY AS VARCHAR(50),
    @SALE_TYPE AS VARCHAR(25),
    @PERIOD_DAYS INT
AS
BEGIN
    DECLARE @ID AS INT;
    DECLARE @VALID_RANGE AS INT,
            @SUPERVISOR_ID INT;
    BEGIN TRY
        -- ---------------------------------------------------------------
        -- Se valida si el rango de fechas no se traslapa con el de otra meta para ese team y tipo de transacción. 
        -- ---------------------------------------------------------------
        SELECT @VALID_RANGE = COUNT(1)
        FROM [SONDA].[SWIFT_GOAL_HEADER]
        WHERE (
                  @GOAL_DATE_FROM
              BETWEEN [GOAL_DATE_FROM] AND [GOAL_DATE_TO]
                  OR @GOAL_DATE_TO
              BETWEEN [GOAL_DATE_FROM] AND [GOAL_DATE_TO]
              )
              AND [TEAM_ID] = @TEAM_ID
              AND [SALE_TYPE] = @SALE_TYPE
              AND [STATUS] <> 'CANCELED';

        -- ---------------------------------------------------------------
        -- Obtiene el ID del supervisor del equipo
        -- ---------------------------------------------------------------
        SELECT TOP (1)
               @SUPERVISOR_ID = [T].[SUPERVISOR]
        FROM [SONDA].[SWIFT_TEAM] [T]
        WHERE [T].[TEAM_ID] = @TEAM_ID
        ORDER BY [T].[TEAM_ID];

        -- ---------------------------------------------------------------
        -- Realiza el proceso de insercion del encabezado de la meta
        -- ---------------------------------------------------------------
        IF @VALID_RANGE = 0
        BEGIN

            INSERT INTO [SONDA].[SWIFT_GOAL_HEADER]
            (
                [GOAL_NAME],
                [TEAM_ID],
                [SUPERVISOR_ID],
                [GOAL_AMOUNT],
                [GOAL_DATE_FROM],
                [GOAL_DATE_TO],
                [STATUS],
                [INCLUDE_SATURDAY],
                [LAST_UPDATE],
                [LAST_UPDATE_BY],
                [SALE_TYPE],
                [PERIOD_DAYS]
            )
            VALUES
            (@GOAL_NAME, @TEAM_ID, @SUPERVISOR_ID, @GOAL_AMOUNT, @GOAL_DATE_FROM, @GOAL_DATE_TO, @STATUS,
             @INCLUDE_SATURDAY, GETDATE(), @LAST_UPDATE_BY, @SALE_TYPE, @PERIOD_DAYS);

            -- -----------------------------------------------------------
            -- Se obtiene el ID generado
            -- -----------------------------------------------------------
            SET @ID = SCOPE_IDENTITY();

            -- -----------------------------------------------------------
            -- Se devuelve resultado positivo
            -- -----------------------------------------------------------
            SELECT 1 AS [Resultado],
                   'Proceso Exitoso' [Mensaje],
                   0 [Codigo],
                   CONVERT(VARCHAR(250), @ID) [DbData];
        END;
        ELSE
            SELECT -1 AS [Resultado],
                   'Rango de fechas no válido' [Mensaje],
                   0 [Codigo],
                   '0' [DbData];
    END TRY
    BEGIN CATCH
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@ERROR [Codigo];
    END CATCH;
END;
  
