-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_GET_PILOT @PILOT_CODE = NULL
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_PILOT ( @PILOT_CODE INT = NULL )
AS
    BEGIN
        SET NOCOUNT ON;
  --

        SELECT  [P].[PILOT_CODE] ,
                [P].[NAME] ,
                [P].[LAST_NAME] ,
                [P].[IDENTIFICATION_DOCUMENT_NUMBER] ,
                [P].[LICENSE_NUMBER] ,
                [P].[LICESE_TYPE] ,
                [P].[LICENSE_EXPIRATION_DATE] ,
                [P].[ADDRESS] ,
                [P].[TELEPHONE] ,
                [P].[MAIL] ,
                [P].[COMMENT] ,
                [R].[ROLE_ID] ,
                [R].[ROLE_NAME] ,
                [UP].[USER_CODE] ,
                [L].[LOGIN_NAME] ,
                [P].[LAST_UPDATE] ,
                [P].[LAST_UPDATE_BY]
        FROM    [wms].[OP_WMS_PILOT] [P]
                LEFT JOIN [wms].[OP_WMS_USER_X_PILOT] [UP] ON ( [UP].[PILOT_CODE] = [P].[PILOT_CODE]
                                                              AND [UP].PILOT_CODE > 0
                                                              )
                LEFT JOIN [wms].[OP_WMS_LOGINS] [L] ON ( [L].[LOGIN_ID] = [UP].[USER_CODE] )
                LEFT JOIN [wms].[OP_WMS_ROLES] [R] ON ( [L].[ROLE_ID] = [R].[ROLE_ID] )
        WHERE   ( @PILOT_CODE IS NULL
                  OR [P].[PILOT_CODE] = @PILOT_CODE
                );


    END;