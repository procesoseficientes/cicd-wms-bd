-- =============================================
-- Autor:				jonathan.salvador
-- Fecha de Creacion: 	12/4/2019 @  GForce@Lima
-- Historia/Bug:		34584 - Validacion de usuario en login swiftsuper
-- Descripcion: 		SP que valida las credenciales de usuario y si tiene bodegas asociadas


-- Autor:					Michael.Mazariegos
-- Fecha de Modificacion: 	02/01/2020 @ GForce@Oklahoma
-- Historia/Bug:			Product Backlog Item 34681: Auditoria de Apertura Contenedor Físcal
-- Descripcion: 			Se agrego validacion para saber el tipo de rol del usuario.

/*
-- Ejemplo de Ejecucion:

	EXEC [wms].[OP_WMS_SP_VALIDATE_USER_CREDENTIALS_SUPER]
	@LOGIN_ID = 'ADMIN'
	,@DOMAIN = 'wms'
	,@PASSWORD = '124'
  
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_USER_CREDENTIALS_SUPER]
(
    @LOGIN_ID VARCHAR(50),
    @DOMAIN VARCHAR(50),
    @PASSWORD VARCHAR(50)
)
AS
BEGIN
    --
    SET NOCOUNT ON;

    --
    DECLARE @ERROR VARCHAR(MAX);

    -- ------------------------------------------------------------------------------------
    -- valido si esta activo el usuario
    -- ------------------------------------------------------------------------------------
    IF
    (
        SELECT TOP (1)
               1
        FROM [wms].[OP_WMS_LOGINS]
        WHERE [LOGIN_ID] = @LOGIN_ID
              AND [LOGIN_STATUS] <> 'ACTIVO'
        ORDER BY [LOGIN_ID]
    ) = 1
    BEGIN
        SELECT 1 AS [Resultado],
               'El usuario ' + @LOGIN_ID + ' esta bloqueado' [Mensaje],
               0 [Codigo];
    END;
    -- ----------------------------------------------------------------------
    -- Se valida el dominio
    -- ----------------------------------------------------------------------
    IF
    (
        SELECT TOP (1)
               1
        FROM [dbo].[OP_WMS_DOMAINS]
        WHERE [DOMAIN] = @DOMAIN
        ORDER BY [ID]
    ) = 1
    BEGIN
        -- ----------------------------------------------------------------------
        -- Se valida si el usuario pertenece al dominio
        -- ----------------------------------------------------------------------
        IF
        (
            SELECT TOP (1)
                   1
            FROM [wms].[OP_WMS_LOGINS] AS [L]
                INNER JOIN [dbo].[OP_WMS_DOMAINS] AS [D]
                    ON ([D].[ID] = [L].[DOMAIN_ID])
            WHERE [L].[LOGIN_ID] = @LOGIN_ID
                  AND [D].[DOMAIN] = @DOMAIN
            ORDER BY [L].[LOGIN_ID]
        ) = 1
        BEGIN
            -- ----------------------------------------------------------------------
            -- Se validan las credenciales del usuario
            -- ----------------------------------------------------------------------
            IF
            (
                SELECT TOP (1)
                       1
                FROM [wms].[OP_WMS_LOGINS] AS [L]
                WHERE [L].[LOGIN_ID] = @LOGIN_ID
                      AND [L].[LOGIN_PWD] = @PASSWORD
                ORDER BY [L].[LOGIN_ID]
            ) = 1
            BEGIN


                IF NOT EXISTS
                (
                    SELECT [WBU].[WAREHOUSE_ID]
                    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] AS [WBU]
                    WHERE [WBU].[LOGIN_ID] = @LOGIN_ID
                )
                BEGIN
                    SELECT 1 AS [Resultado],
                           'Usuario no tiene bodegas asociadas' [Mensaje],
                           0 [Codigo];
                END;
                ELSE
                BEGIN
                    -- ---------------------------------------------------------------
                    -- Se permite el inicio de sesion al operador y se verifica si el usuario es de tipo auditor o chequeador
                    -- ---------------------------------------------------------------
                    SELECT CASE
                               WHEN L.ROLE_ID = 'AUDITOR'
                                    OR L.ROLE_ID = 'CHEQUEADOR' THEN
                                   1
                               ELSE
                                   0
                           END [isChecker],
                           1 AS [Resultado],
                           'Proceso Exitoso' [Mensaje],
                           1 [Codigo]
                    FROM wms.OP_WMS_LOGINS AS L
                    WHERE L.LOGIN_ID = @LOGIN_ID
                          AND L.LOGIN_PWD = @PASSWORD;
                --------------------------------------------
                END;
            END;
            ELSE
            BEGIN
                SELECT 1 AS [Resultado],
                       'Los datos de inicio de sesión son incorrectos, por favor, verifique y vuelva a intentar' [Mensaje],
                       0 [Codigo];

            END;
        END;
        ELSE
        BEGIN
            SELECT 1 AS [Resultado],
                   'El usuario proporcionado no pertenece al dominio ' + @DOMAIN
                   + ', por favor, verifique y vuelva a intentar' [Mensaje],
                   0 [Codigo];
        END;
    END;
    ELSE
    BEGIN
        SELECT 1 AS [Resultado],
               'El dominio ' + @DOMAIN + ' no es válido, por favor, verifique y vuelva a intentar' [Mensaje],
               0 [Codigo];
    END;
END;