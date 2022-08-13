-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		13-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    ELIMINA LAS FAMILIAS DE LA CONFIGURACION DE SLOTTING
--/*
-- Ejemplo de Ejecucion:
/*
	EXECUTE [wms].[OP_WMS_SP_DELETE_SLOTTING_ZONE_BY_CLASS] @ID_SLOTTING_ZONE = 'E80CD6C1-3D8D-E911-8106-60A44CCD8810', -- varchar(50)
																@XML = '<ArrayOfClase>
																			<Clase>
																				<CLASS_ID>43</CLASS_ID>
																				<CLASS_NAME>ALIMENTO PARA PERRO</CLASS_NAME>
																			</Clase>
																			<Clase>
																				<CLASS_ID>44</CLASS_ID>
																				<CLASS_NAME>ALIMENTO PARA GATO</CLASS_NAME>
																			</Clase>
																		</ArrayOfClase>' -- xml
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_SLOTTING_ZONE_BY_CLASS]
(
    @ID_SLOTTING_ZONE UNIQUEIDENTIFIER,
    @XML AS XML
)
AS
BEGIN TRY

    SET NOCOUNT ON;

    -- Se lee el documento XML
    DECLARE @CLASS_TABLE TABLE
    (
        [CLASS_ID] INT,
        [CLASS_NAME] VARCHAR(250)
    );

    INSERT INTO @CLASS_TABLE
    (
        [CLASS_ID],
        [CLASS_NAME]
    )
    SELECT [x].[data].[query]('./CLASS_ID').[value]('.', 'INTEGER') [FAMILY_ID],
           [x].[data].[query]('./CLASS_NAME').[value]('.', 'VARCHAR(250)') [DESCRIPTION_FAMILY]
    FROM @XML.[nodes]('/ArrayOfClase/Clase') AS [x]([data]);

    DELETE [SZD]
    FROM [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZD]
        INNER JOIN @CLASS_TABLE [CT]
            ON ([SZD].[CLASS_ID] = [CT].[CLASS_ID])
    WHERE [SZD].[ID_SLOTTING_ZONE] = @ID_SLOTTING_ZONE;

    SELECT 1 AS [Resultado],
           'Proceso Exitoso' [Mensaje],
           0 [Codigo];

END TRY
BEGIN CATCH

    SELECT -1 AS [Resultado],
           ERROR_MESSAGE() [Mensaje],
           @@ERROR [Codigo];

END CATCH;