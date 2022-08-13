-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-10-21 @ Team REBORN - Sprint Drache
-- Description:	        Sp que elimina el detalle de la certificacion

-- Modificacion 11/14/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Elimina por codigo de caja

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_DELETE_CERTIFICATION_DETAIL] @CERTIFICATION_DETAIL_ID = 1                                                
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_CERTIFICATION_DETAIL]
    (
     @CERTIFICATION_DETAIL_ID INT
    ,@BOX_BARCODE VARCHAR(50) = NULL
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    BEGIN TRY
        IF (@BOX_BARCODE IS NULL)
        BEGIN
            DELETE
                [wms].[OP_WMS_CERTIFICATION_DETAIL]
            WHERE
                [CERTIFICATION_DETAIL_ID] = @CERTIFICATION_DETAIL_ID;
        END;
        ELSE
        BEGIN
			-- ------------------------------------------------------------------------------------
            -- Al eliminar una caja el parametro CERTIFICATION_DETAIL_ID, es el HEADER_ID debido a que esta es la respuesta de la eliminacion de la caja.
            -- ------------------------------------------------------------------------------------
			DELETE
                [wms].[OP_WMS_CERTIFICATION_DETAIL]
            WHERE
                [BOX_BARCODE] = @BOX_BARCODE AND [CERTIFICATION_HEADER_ID] = @CERTIFICATION_DETAIL_ID;                 END;
	
        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,'' [DbData];

    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@error [Codigo];
    END CATCH;


END;