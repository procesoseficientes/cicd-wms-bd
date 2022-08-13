-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2016-11-04
-- Description:	 Obtener todos los registros de la tabla  OP_WMS_HH_BUTTON_CONFIG donde el CODE_DEVICE sea igual al del parametro y al igual que valor ASCII 

-- Autor:	marvin.solares
-- Fecha de Creacion: 	20191216@GForce@Madagascar
-- Description:	 agrego clausula toupper a filtro de modelo de dispositivo


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_DEVICE_BUTTON_CONFIGURATION] @MANUFACTURER = 'Motorola Solutions, Inc.'
              , @MODEL  = 'MC67'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DEVICE_BUTTON_CONFIGURATION]
(
    @MANUFACTURER VARCHAR(25),
    @MODEL VARCHAR(125),
    @ASCII INT = NULL
)
AS
BEGIN

    SELECT [OWHBC].[BUTTON_ACTION_ID],
           [OWHBA].[CODE_ACTION],
           [OWHBC].[ASCCI_VALUE]
    FROM [wms].[OP_WMS_HH_BUTTON_CONFIG] [OWHBC]
        INNER JOIN [wms].[OP_WMS_DEVICE] [OWD]
            ON [OWHBC].[DEVICE_ID] = [OWD].[DEVICE_ID]
        INNER JOIN [wms].[OP_WMS_HH_BUTTON_ACTION] [OWHBA]
            ON [OWHBC].[BUTTON_ACTION_ID] = [OWHBA].[BUTTON_ACTION_ID]
    WHERE [OWD].[MANUFACTURER] = [OWD].[MANUFACTURER]
          AND UPPER(ISNULL(@MODEL, '')) = UPPER([OWD].[MODEL])
          AND
          (
              @ASCII = NULL
              OR [OWHBC].[ASCCI_VALUE] = [OWHBC].[ASCCI_VALUE]
          );

END;