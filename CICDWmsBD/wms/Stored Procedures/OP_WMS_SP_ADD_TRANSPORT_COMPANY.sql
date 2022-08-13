-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que agrega una empresa de transporte

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega columna IS_OWN

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_ADD_TRANSPORT_COMPANY] @NAME = 'Transportes 4 caminos'
                                                ,@ADDRESS = 'El naranjo'
                                                ,@TELEPHONE = '12345678'
                                                ,@CONTACT = 'Diego'
                                                ,@MAIL = 'Diego@Transportes4caminos'
                                                ,@LAST_UPDATE_BY = 'ADMIN'
												,@IS_OWN = 1
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_ADD_TRANSPORT_COMPANY
    (
     @NAME VARCHAR(250)
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

        DECLARE @ID INT;

        INSERT  INTO [wms].[OP_WMS_TRANSPORT_COMPANY]
                (
                 [NAME]
                ,[ADDRESS]
                ,[TELEPHONE]
                ,[CONTACT]
                ,[MAIL]
                ,[LAST_UPDATE_BY]
				,[IS_OWN]
	            )
        VALUES
                (
                 @NAME
                ,@ADDRESS
                ,@TELEPHONE
                ,@CONTACT
                ,@MAIL
                ,@LAST_UPDATE_BY
				,@IS_OWN
                );

        SET @ID = SCOPE_IDENTITY();

        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,CAST(@ID AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@error [Codigo];
    END CATCH;

END;