-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	04-07-2018
-- Description:			Inserta el encabezado de las metas
--						Devuelve el id de la meta creado.

-- Modificacion 		8/6/2019 @ G-Force Team Sprint Groenlandia
-- Autor: 				diego.as
-- Historia/Bug:		Impediment 31075: Ajuste de funcionalidad de metas BO Swift Express
-- Descripcion: 		8/6/2019 - Se agrega actualizacion de campo PERIOD_DAYS

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SWIFT_SP_UPDATE_GOAL_HEADER
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_GOAL_HEADER]
(
    @GOAL_HEADER_ID INT,
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
)
AS
BEGIN
    DECLARE @ID AS INT;
    DECLARE @VALID_RANGE AS INT,
            @SUPERVISOR_ID INT;
    BEGIN TRY

        --Se valida si el rango de fechas no se traslapa con el de otra meta para ese team y tipo de transacción.
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
              AND [STATUS] <> 'CANCELED'
              AND [GOAL_HEADER_ID] <> @GOAL_HEADER_ID;

        SELECT TOP(1)
               @SUPERVISOR_ID = [T].[SUPERVISOR]
        FROM [SONDA].[SWIFT_TEAM] [T]
        WHERE [T].[TEAM_ID] = @TEAM_ID
		ORDER BY [T].[TEAM_ID];

        IF @VALID_RANGE = 0
        BEGIN
            UPDATE [SONDA].[SWIFT_GOAL_HEADER]
            SET [GOAL_NAME] = @GOAL_NAME,
                [TEAM_ID] = @TEAM_ID,
                [SUPERVISOR_ID] = @SUPERVISOR_ID,
                [GOAL_AMOUNT] = @GOAL_AMOUNT,
                [GOAL_DATE_FROM] = @GOAL_DATE_FROM,
                [GOAL_DATE_TO] = @GOAL_DATE_TO,
                [STATUS] = @STATUS,
                [INCLUDE_SATURDAY] = @INCLUDE_SATURDAY,
                [LAST_UPDATE] = GETDATE(),
                [LAST_UPDATE_BY] = @LAST_UPDATE_BY,
                [SALE_TYPE] = @SALE_TYPE,
                [PERIOD_DAYS] = @PERIOD_DAYS
            WHERE [GOAL_HEADER_ID] = @GOAL_HEADER_ID;

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

  
