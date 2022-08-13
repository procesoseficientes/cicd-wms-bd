-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		12-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    Agrega nueva configuracion de slotting si no existe de lo contrario agrega solo
--							las nuevas familias.
/*
-- Ejemplo de Ejecucion:
	EXECUTE [wms].[OP_WMS_SP_INSERT_SLOTTING_ZONE_BY_CLASS] @WAREHOUSE_CODE = 'BODEGA_07', -- varchar(25)
																@ZONE_ID = 70, -- int
																@ZONE = 'Z_BODEGA_06', -- varchar(50)
																@MANDATORY = 0, -- bit
																@XML = '<ArrayOfClase>
																			<Clase>
																				<CLASS_ID>3</CLASS_ID>
																				<CLASS_NAME>Alimento de Tortuga</CLASS_NAME>
																			</Clase>
																		</ArrayOfClase>' -- xml
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_SLOTTING_ZONE_BY_CLASS]
(
    @WAREHOUSE_CODE VARCHAR(25),
    @ZONE_ID INTEGER,
    @ZONE VARCHAR(50),
    @MANDATORY BIT,
    @XML AS XML
)
AS
BEGIN TRY

    SET NOCOUNT ON;

    ---------------------------------------------------------------------------------
    --VERIFICAMOS LOS DATOS SI EXISTEN, SI NO EXISTEN DEVOLVEMOS LOS VALORES
    ---------------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT *
        FROM [wms].[OP_WMS_ZONE]
        WHERE [WAREHOUSE_CODE] = @WAREHOUSE_CODE
              AND [ZONE_ID] = @ZONE_ID
    )
    BEGIN

        SELECT -1 AS [Resultado],
               CONCAT('No se encontro bodega: ', @WAREHOUSE_CODE, ' , zona: ', @ZONE_ID) AS [Mensaje],
               -1 AS [Codigo];

        RETURN;
    END;

    DECLARE @SLOTTING_ID UNIQUEIDENTIFIER = NULL;

    ---------------------------------------------------------------------------------
    --DECLARAMOS UNA VARIABLE TIPO TABLA PARA ALMACENAR EL XML
    ---------------------------------------------------------------------------------

    DECLARE @CLASS_TABLE TABLE
    (
        [CLASS_ID] INT,
        [CLASS_NAME] VARCHAR(250)
    );

    ---------------------------------------------------------------------------------
    --LEEMOS E INSERTAMOS EL XML DENTRO DE LA TABLA TEMPORAL
    ---------------------------------------------------------------------------------

    INSERT INTO @CLASS_TABLE
    (
        [CLASS_ID],
        [CLASS_NAME]
    )
    SELECT [x].[data].[query]('./CLASS_ID').[value]('.', 'INTEGER') [FAMILY_ID],
           [x].[data].[query]('./CLASS_NAME').[value]('.', 'VARCHAR(250)') [DESCRIPTION_FAMILY]
    FROM @XML.[nodes]('/ArrayOfClase/Clase') AS [x]([data]);


    SELECT TOP 1
           @SLOTTING_ID = [SZ].[ID]
    FROM [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
    WHERE [SZ].[ZONE_ID] = @ZONE_ID
          AND [SZ].[WAREHOUSE_CODE] = @WAREHOUSE_CODE;

    ---------------------------------------------------------------------------------
    --SI NO EXISTE LA CONFIGURACION DE SLOTTING CREAMOS UN NUEVO REGISTRO
    ---------------------------------------------------------------------------------

    IF (@SLOTTING_ID IS NULL)
    BEGIN
        SET @SLOTTING_ID = NEWID();
        INSERT INTO [wms].[OP_WMS_SLOTTING_ZONE]
        (
            [ID],
            [WAREHOUSE_CODE],
            [ZONE_ID],
            [ZONE],
            [MANDATORY]
        )
        VALUES
        (   @SLOTTING_ID,    -- ID -- UNIQUEIDENTIFIER 
            @WAREHOUSE_CODE, -- WAREHOUSE_CODE - varchar(25)
            @ZONE_ID,        -- ZONE_ID - int
            @ZONE,           -- ZONE_DESCRIPTION - varchar(50)
            @MANDATORY       -- MANDATORY - bit
            );
    END;

    ---------------------------------------------------------------------------------
    -- INSERTAMOS LOS REGISTROS A LA TABLA DE SLOTTING_ZONE_BY_CLASS
    ---------------------------------------------------------------------------------

    INSERT INTO [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS]
    (
        [ID_SLOTTING_ZONE],
        [CLASS_ID],
        [CLASS_NAME]
    )
    SELECT @SLOTTING_ID,
           [CT].[CLASS_ID],
           [CT].[CLASS_NAME]
    FROM @CLASS_TABLE [CT];

    SELECT 1 AS [Resultado],
           'Proceso Exitoso' [Mensaje],
           0 [Codigo],
           CAST(@SLOTTING_ID AS VARCHAR(50)) AS [DbData];

END TRY
BEGIN CATCH


    SELECT -1 AS [Resultado],
           ERROR_MESSAGE() [Mensaje],
           @@ERROR [Codigo];

END CATCH;