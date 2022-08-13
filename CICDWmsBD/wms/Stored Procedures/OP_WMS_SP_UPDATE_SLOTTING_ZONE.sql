-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		12-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    Actualiza el campo de mandatoria en la configuracion de slotting
--/*
-- Ejemplo de Ejecucion:
--        EXEC [wms].[OP_WMS_SP_UPDATE_SLOTTING_ZONE] @ID_SLOTTING_ZONE = 'E80CD6C1-3D8D-E911-8106-60A44CCD8810', -- varchar(50)
--													  @MANDATORY = 1 -- bit
--*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_SLOTTING_ZONE]
    (
      @ID_SLOTTING_ZONE UNIQUEIDENTIFIER ,
      @MANDATORY BIT
    )
AS
    BEGIN TRY
		
        DECLARE @ID_SLOTTING_CONVERTED VARCHAR(50);
        SET @ID_SLOTTING_CONVERTED = CONVERT(VARCHAR(50), @ID_SLOTTING_ZONE);

        UPDATE  [wms].[OP_WMS_SLOTTING_ZONE]
        SET     [MANDATORY] = @MANDATORY
        WHERE   [ID] = @ID_SLOTTING_CONVERTED;

        SELECT  1 AS [Resultado] ,
                'Proceso Exitoso' [Mensaje] ,
                0 [Codigo];

    END TRY

    BEGIN CATCH
		
        SELECT  -1 AS [Resultado] ,
                ERROR_MESSAGE() [Mensaje] ,
                @@ERROR [Codigo];

    END CATCH;