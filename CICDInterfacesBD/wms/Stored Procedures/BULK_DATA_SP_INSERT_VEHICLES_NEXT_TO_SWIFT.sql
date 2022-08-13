-- =============================================
-- Product Backlog Item 35601: Cambios Simulador de Rentabilidad
-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	15-Enero-2020 G-Force@Oklahoma-Next
-- Description:			Sp que inserta los vehiculos de Next hacia la DB de swift

/* Ejemplo de Ejecucion:
	EXECUTE [wms].[BULK_DATA_SP_INSERT_VEHICLES_NEXT_TO_SWIFT]
*/
-- =============================================  
CREATE PROCEDURE [wms].[BULK_DATA_SP_INSERT_VEHICLES_NEXT_TO_SWIFT]
AS
BEGIN
    SET NOCOUNT ON;
    ---------------------------------------------------------------------------------
    -- DECLARAMOS LA VARIABLE PARA OBTENER EL ID DE LA EMPRESA DE TRANSPORTE POR DEFECTO
    ---------------------------------------------------------------------------------
    DECLARE @ID_TRANSPORT_COMPANY INT = 0;

    ---------------------------------------------------------------------------------
    -- VALIDAMOS SI EXISTE LA EMPRESA DE TRANSPORTE POR DEFECTO
    ---------------------------------------------------------------------------------
    IF EXISTS
    (
        SELECT TOP 1
               1
        FROM [OP_WMS_ALZA].[WMS].[OP_WMS_TRANSPORT_COMPANY]
        WHERE [NAME] = 'Empresa de transporte por defecto'
    )
    BEGIN
        SELECT @ID_TRANSPORT_COMPANY = [TRANSPORT_COMPANY_CODE]
        FROM [OP_WMS_ALZA].[WMS].[OP_WMS_TRANSPORT_COMPANY]
        WHERE [NAME] = 'Empresa de transporte por defecto';
    END;
    ELSE
    BEGIN
        INSERT INTO [OP_WMS_ALZA].[WMS].[OP_WMS_TRANSPORT_COMPANY]
        (
            [NAME],
            [ADDRESS],
            [TELEPHONE],
            [CONTACT],
            [MAIL],
            [LAST_UPDATE],
            [LAST_UPDATE_BY],
            [IS_OWN]
        )
        VALUES
        (   'Empresa de transporte por defecto', -- NAME - varchar(250)
            '',                                  -- ADDRESS - varchar(250)
            '',                                  -- TELEPHONE - varchar(25)
            '',                                  -- CONTACT - varchar(50)
            '',                                  -- MAIL - varchar(100)
            GETDATE(),                           -- LAST_UPDATE - datetime
            'REGISTRO_POR_DEFECTO',              -- LAST_UPDATE_BY - varchar(25)
            0                                    -- IS_OWN - int
            );

        SELECT @ID_TRANSPORT_COMPANY = [TRANSPORT_COMPANY_CODE]
        FROM [OP_WMS_ALZA].[WMS].[OP_WMS_TRANSPORT_COMPANY]
        WHERE [NAME] = 'Empresa de transporte por defecto'
              AND [LAST_UPDATE_BY] = 'REGISTRO_POR_DEFECTO';
    END;

    ---------------------------------------------------------------------------------
    -- CREAMOS UN MERGE DE LOS DATOS DE LA TABLA DE PILOTOS SWIFT CONTRA LA DE NEXT
    ---------------------------------------------------------------------------------
    MERGE [OP_WMS_ALZA].[WMS].[OP_WMS_VEHICLE] [SV]
    USING
    (SELECT * FROM [Next].[dbo].[Vehicle]) [NV]
    ON ([NV].[Id] = [SV].[VEHICLE_EXTERNAL_ID])
    WHEN MATCHED THEN
        UPDATE SET [SV].[BRAND] = [NV].[Brand],
                   [SV].[LINE] = [NV].[Line],
                   [SV].[MODEL] = [NV].[Model],
                   [SV].[COLOR] = [NV].[Color],
                   [SV].[CHASSIS_NUMBER] = [NV].[ChassisNumber],
                   [SV].[ENGINE_NUMBER] = [NV].[EngineNumber],
                   [SV].[VIN_NUMBER] = [NV].[VinNumber],
                   [SV].[PLATE_NUMBER] = [NV].[PlateNumber],
                   [SV].[WEIGHT] = [NV].[Weight],
                   [SV].[HIGH] = [NV].[High],
                   [SV].[WIDTH] = [NV].[Width],
                   [SV].[DEPTH] = [NV].[Depth],
                   [SV].[VOLUME_FACTOR] = [NV].[VolumeFactor],
                   [SV].[LAST_UPDATE] = GETDATE(),
                   [SV].[LAST_UPDATE_BY] = 'BULK_DATA',
                   [SV].[PILOT_CODE] =
                   (
                       SELECT TOP 1 [P].[PILOT_CODE]
                       FROM [OP_WMS_ALZA].[WMS].[OP_WMS_PILOT] [P]
                       WHERE [P].[PILOT_EXTERNAL_ID] = [NV].[PilotId]
                   ),                   
                   [SV].[IS_ACTIVE] = [NV].[IsActive],
                   [SV].[STATUS] = [NV].[Status],
                   [SV].[FILL_RATE] = IIF(ISNULL([NV].[FillRate], 00.00) > 100, 100, ISNULL([NV].[FillRate], 00.00))
    WHEN NOT MATCHED THEN
        INSERT
        (
            [BRAND],
            [LINE],
            [MODEL],
            [COLOR],
            [CHASSIS_NUMBER],
            [ENGINE_NUMBER],
            [VIN_NUMBER],
            [PLATE_NUMBER],
            [TRANSPORT_COMPANY_CODE],
            [WEIGHT],
            [HIGH],
            [WIDTH],
            [DEPTH],
            [VOLUME_FACTOR],
            [LAST_UPDATE],
            [LAST_UPDATE_BY],
            [PILOT_CODE],
            [IS_ACTIVE],
            [STATUS],
            [FILL_RATE],
            [VEHICLE_AXLES],
            [INSURANCE_DOC_ID],
            [AVERAGE_COST_PER_KILOMETER],
            [VEHICLE_EXTERNAL_ID]
        )
        VALUES
        (   [NV].[Brand], [NV].[Line], [NV].[Model], [NV].[Color], [NV].[ChassisNumber], [NV].[EngineNumber],
            [NV].[VinNumber], [NV].[PlateNumber], @ID_TRANSPORT_COMPANY, [NV].[Weight], [NV].[High], [NV].[Width],
            [NV].[Depth], [NV].[VolumeFactor], GETDATE(), 'BULK_DATA',
            (
                SELECT TOP 1 [PILOT_CODE]
                FROM [OP_WMS_ALZA].[WMS].[OP_WMS_PILOT]
                WHERE [PILOT_EXTERNAL_ID] = [NV].[PilotId]
            ), [NV].[IsActive], [NV].[Status],
            IIF(ISNULL([NV].[FillRate], 00.00) > 100, 100, ISNULL([NV].[FillRate], 00.00)), [NV].[VehicleAxles], NULL,
            [NV].[AverageCostPerKilometer], [NV].[Id]);

END;