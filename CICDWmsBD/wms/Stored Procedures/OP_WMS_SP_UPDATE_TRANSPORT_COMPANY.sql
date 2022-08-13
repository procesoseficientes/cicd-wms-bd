-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que actualiza una empresa de transporte

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega is_own

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_SP_UPDATE_TRANSPORT_COMPANY @TRANSPORT_COMPANY_CODE = 1
                                                ,@NAME = 'Transportes 4 caminos'
                                                ,@ADDRESS = 'El naranjo'
                                                ,@TELEPHONE = '12345678'
                                                ,@CONTACT = 'Diego'
                                                ,@MAIL = 'Diego@Transportes4caminos'  
                                                ,@LAST_UPDATE_BY = 'ADMIN'
												,@IS_OWN = 1
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_UPDATE_TRANSPORT_COMPANY
    (
     @TRANSPORT_COMPANY_CODE INT
    ,@NAME VARCHAR(250)
    ,@ADDRESS VARCHAR(250)
    ,@TELEPHONE VARCHAR(25)
    ,@CONTACT VARCHAR(50)
    ,@MAIL VARCHAR(100)
    ,@LAST_UPDATE_BY VARCHAR(25)
	,@IS_OWN INT
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    BEGIN TRY

        UPDATE
            [wms].[OP_WMS_TRANSPORT_COMPANY]
        SET
            [NAME] = @NAME
           ,[ADDRESS] = @ADDRESS
           ,[TELEPHONE] = @TELEPHONE
           ,[CONTACT] = @CONTACT
           ,[MAIL] = @MAIL
           ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
           ,[LAST_UPDATE] = GETDATE()
		   ,[IS_OWN] = @IS_OWN
        WHERE
            [TRANSPORT_COMPANY_CODE] = @TRANSPORT_COMPANY_CODE;

        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,CAST(@TRANSPORT_COMPANY_CODE AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@error [Codigo];
    END CATCH;


END;