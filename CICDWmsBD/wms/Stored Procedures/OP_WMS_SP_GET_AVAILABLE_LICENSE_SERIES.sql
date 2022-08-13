-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/3/2018 @ NEXUS-Team Sprint Capibara 
-- Description:			Obtiene las series disponibles de la licencia

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_AVAILABLE_LICENSE_SERIES]
					@LICENSE_ID = 439727,
					@MATERIAL_ID = 'arium/100001'
					
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_AVAILABLE_LICENSE_SERIES]
    (
     @LICENSE_ID INT
    ,@MATERIAL_ID VARCHAR(50)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    SELECT
        [LICENSE_ID]
       ,[MATERIAL_ID]
       ,[SERIAL]
    FROM
        [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
    WHERE
        [LICENSE_ID] = @LICENSE_ID
        AND [MATERIAL_ID] = @MATERIAL_ID
        AND ISNULL([WAVE_PICKING_ID], 0) = 0
        AND [STATUS] = 1;
END;