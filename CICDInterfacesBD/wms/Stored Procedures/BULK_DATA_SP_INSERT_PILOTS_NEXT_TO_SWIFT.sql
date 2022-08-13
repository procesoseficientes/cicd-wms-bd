-- =============================================
-- Product Backlog Item 35601: Cambios Simulador de Rentabilidad
-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	14-Enero-2020 G-Force@Oklahoma-Next
-- Description:			Sp que inserta los pilotos de Next hacia la DB de swift

/* Ejemplo de Ejecucion:
	EXECUTE [wms].[BULK_DATA_SP_INSERT_PILOTS_NEXT_TO_SWIFT]
*/
-- =============================================  
CREATE PROCEDURE [wms].[BULK_DATA_SP_INSERT_PILOTS_NEXT_TO_SWIFT]
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------------------
    -- CREAMOS UN MERGE DE LOS DATOS DE LA TABLA DE PILOTOS SWIFT CONTRA LA DE NEXT
    ---------------------------------------------------------------------------------
    MERGE [OP_WMS_ALZA].[WMS].[OP_WMS_PILOT] [P]
    USING
    (
        SELECT [U].[Name],
               [P].[IdentificationDocumentNumber],
               [P].[LicenseNumber],
               [P].[LiceseType],
               [P].[LicenseExpirationDate],
               [P].[Address],
               [U].[Phone],
               [U].[Email],
               [P].[Comment],
               [P].[Id]
        FROM [Next].[dbo].[Pilot] [P]
            INNER JOIN [Next].[dbo].[User] [U]
                ON ([U].[Id] = [P].[UserId])
    ) [NP]
    ON ([NP].[Id] = [P].[PILOT_EXTERNAL_ID])
    WHEN MATCHED THEN
        UPDATE SET [P].[NAME] = [NP].[Name],
                   [P].[IDENTIFICATION_DOCUMENT_NUMBER] = [NP].[IdentificationDocumentNumber],
                   [P].[LICENSE_NUMBER] = [NP].[LicenseNumber],
                   [P].[LICESE_TYPE] = [NP].[LiceseType],
                   [P].[LICENSE_EXPIRATION_DATE] = [NP].[LicenseExpirationDate],
                   [P].[ADDRESS] = [NP].[Address],
                   [P].[TELEPHONE] = [NP].[Phone],
                   [P].[MAIL] = [NP].[Email],
                   [P].[COMMENT] = [NP].[Comment],
                   [P].[LAST_UPDATE] = GETDATE(),
                   [P].[LAST_UPDATE_BY] = 'BULK_DATA'
    WHEN NOT MATCHED THEN
        INSERT
        (
            [NAME],
            [LAST_NAME],
            [IDENTIFICATION_DOCUMENT_NUMBER],
            [LICENSE_NUMBER],
            [LICESE_TYPE],
            [LICENSE_EXPIRATION_DATE],
            [ADDRESS],
            [TELEPHONE],
            [MAIL],
            [COMMENT],
            [LAST_UPDATE],
            [LAST_UPDATE_BY],
            [PILOT_EXTERNAL_ID]
        )
        VALUES
        ([NP].[Name], '', [NP].[IdentificationDocumentNumber], [NP].[LicenseNumber], [NP].[LiceseType],
         [NP].[LicenseExpirationDate], [NP].[Address], [NP].[Phone], [NP].[Email], [NP].[Comment], GETDATE(),
         'BULK_DATA', [NP].[Id]);
END;