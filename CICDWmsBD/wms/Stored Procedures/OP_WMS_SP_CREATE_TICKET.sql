-- =============================================
-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	18-Dic-2019 G-Force@Napoles-Swift
-- Description:			Agrega un nuevo registro a la tabla de tickets y
--						Devuelve el formato de impresión.
-- Product Backlog Item 34372: Pantalla de creación de Ticket

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CREATE_TICKET]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_TICKET]
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        ---------------------------------------------------------------------------------
        -- DECLARAMOS LAS VARIABLES A UTILIZAR
        ---------------------------------------------------------------------------------

        DECLARE @CORRELATIVE_TICKET BIGINT,
                @COMPANY_CODE VARCHAR(25),
                @ADD_DATE DATETIME = GETDATE(),
                @DATE_FORMAT AS VARCHAR(25),
                @FORMAT_TICKET AS VARCHAR(MAX);

        ---------------------------------------------------------------------------------
        -- OBTENEMOS LA EMPRESA
        ---------------------------------------------------------------------------------
        SELECT TOP (1)
            @COMPANY_CODE = [COMPANY_CODE]
        FROM [wms].[OP_SETUP_COMPANY];

        ---------------------------------------------------------------------------------
        -- FORMATEAMOS LA FECHA, SE MUESTRA EN LA IMPRESION
        ---------------------------------------------------------------------------------
        SELECT @DATE_FORMAT = FORMAT(@ADD_DATE, 'dd/MM/yyyy hh:mm:ss tt');

        ---------------------------------------------------------------------------------
        -- INSERTAMOS EL NUEVO TICKET Y OBTENEMOS EL CORRELATIVO
        ---------------------------------------------------------------------------------
        INSERT INTO [wms].[OP_WMS_TICKETS]
        (
            [POLIZA_DOC_ID],
            [CREATED_DATE],
            [STATUS]
        )
        VALUES
        (   NULL,      -- POLIZA_DOC_ID - numeric(18, 0)
            @ADD_DATE, -- CREATED_DATE - datetime
            'PRINTED'  -- STATUS - varchar(20)
            );

        SELECT @CORRELATIVE_TICKET = [TICKET_NUMBER]
        FROM [wms].[OP_WMS_TICKETS]
        WHERE [CREATED_DATE] = @ADD_DATE
              AND [STATUS] = 'PRINTED';

        ---------------------------------------------------------------------------------
        -- CREAMOS EL FORMATO DE IMPRESION DE LA ETIQUETA
        ---------------------------------------------------------------------------------
        SELECT @FORMAT_TICKET = '! 0 50 50 200 1
! U1 LMARGIN 5
! U1 PAGE-WIDTH 1400
BARCODE 128 3 1 65 100 5 ' + CAST(@CORRELATIVE_TICKET AS VARCHAR(50)) + '
LEFT 5 T 0 3 100 100 ' + @COMPANY_CODE + '
LEFT 5 T 0 1 100 130 ' + @DATE_FORMAT + '
PRINT
! U1 getvar "device.host_status"
';

        ---------------------------------------------------------------------------------
        -- MOSTRAMOS EL CODIGO DE OPERACION SI EL PROCESO ES EXITOSO
        ---------------------------------------------------------------------------------
        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               @FORMAT_TICKET AS [DbData];

    END TRY
    BEGIN CATCH
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@ERROR [Codigo],
               '0' AS [DbData];
    END CATCH;
END;