-- =============================================
-- Autor:                         Alejandro.Ochoa
-- Fecha de Creacion:      18-07-19
-- Description:                   SP que Actualiza el GPS del cliente proviniente de SONDA
/*
-- Ejemplo de Ejecucion:
                           EXEC [dbo].[SAE_UPDATE_CUSTOMER_GPS] @CUSTOMER = @CUSTOMER
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_UPDATE_CUSTOMER_GPS]
(@CUSTOMER INT)
AS
BEGIN
    SET NOCOUNT ON;

       DECLARE       @CODE_CUSTOMER VARCHAR(50),
                     @LATITUDE VARCHAR(30),
                     @LONGITUDE VARCHAR(30)

    BEGIN TRY
        BEGIN TRANSACTION;

              SELECT
                     @CODE_CUSTOMER = [scc].[CODE_CUSTOMER]
                     ,@LATITUDE = SUBSTRING([scc].[GPS], 1, CHARINDEX(',', [scc].[GPS]) - 1)
                     ,@LONGITUDE = SUBSTRING([scc].[GPS], CHARINDEX(',', [scc].[GPS]) + 1, LEN([scc].[GPS]))
              FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_CUSTOMER_CHANGE] [scc]
              WHERE CUSTOMER = @CUSTOMER
              ORDER BY [scc].[CUSTOMER] ASC;

        UPDATE [SAE70EMPRESA01].[dbo].[CLIE01]
        SET [LAT_GENERAL]= @LATITUDE, [LON_GENERAL] = @LONGITUDE
        WHERE LTRIM(RTRIM([CLAVE])) = @CODE_CUSTOMER;
              
        COMMIT;
        SELECT 1 AS [Resultado],
               ('Proceso Exitoso') [Mensaje],
               0 [Codigo],
               ('Proceso Exitoso') [DbData];

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ERROR_MSG VARCHAR(500) = ERROR_MESSAGE();    
        --
        SELECT -1 AS [Resultado],
               ('Proceso fallido: ' + @ERROR_MSG) [Mensaje],
               0 [Codigo],
               '0' [DbData];

    END CATCH;

END;
