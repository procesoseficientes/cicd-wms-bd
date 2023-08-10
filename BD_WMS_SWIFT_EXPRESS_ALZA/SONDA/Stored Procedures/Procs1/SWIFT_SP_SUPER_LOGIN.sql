-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/28/2018 @ NEXUS-Team Sprint  
-- Description:			Verifica que el usuario a ingresar sea un supervisor y retorna un objeto operacion con el ID del equipo.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_SUPER_LOGIN]
					@LOGIN = 'supervisor1@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SUPER_LOGIN] (@LOGIN VARCHAR(50))
AS
BEGIN
    DECLARE
        @IS_SUPERVISOR INT = -1
       ,@TEAM_ID INT = 0
       ,@MESSAGE VARCHAR(500) = 'El usuario usuario seleccionado no tiene acceso a la aplicación'
       ,@CODE INT = 1001;
	
    SET NOCOUNT ON;
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene informacion del equipo basado en el LOGIN
	-- ------------------------------------------------------------------------------------
    SELECT TOP 1
        @IS_SUPERVISOR = 1
       ,@TEAM_ID = [T].[TEAM_ID]
       ,@MESSAGE = 'Proceso Exitoso'
       ,@CODE = 200
    FROM
        [SONDA].[SWIFT_TEAM] [T]
    INNER JOIN [SONDA].[USERS] [U] ON [U].[CORRELATIVE] = [T].[SUPERVISOR]
    WHERE
        [U].[LOGIN] = @LOGIN;

	-- ------------------------------------------------------------------------------------
	-- Muestra resultado final
	-- ------------------------------------------------------------------------------------
    SELECT
        @IS_SUPERVISOR [Resultado]
       ,@MESSAGE [Mensaje]
       ,@CODE [Codigo]
       ,CAST(@TEAM_ID AS VARCHAR) [DbData];
END;
