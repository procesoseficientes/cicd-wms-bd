-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/19/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Verifica si la licencia esta en la bodega.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_LICENSE_IN_IMPLOSION]
					@LICENSE_ID = 189,
					@WAREHOUSE = 'BODEGA_11'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LICENSE_IN_IMPLOSION]
    (
      @LICENSE_ID INT ,
      @WAREHOUSE VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;
		--
        DECLARE @BODEGA_VALIDA INT = 0;
		--
        SELECT TOP 1
                @BODEGA_VALIDA = 1
        FROM    [wms].[OP_WMS_LICENSES]
        WHERE   [LICENSE_ID] = @LICENSE_ID
                AND [CURRENT_WAREHOUSE] = @WAREHOUSE;
		--
        SELECT  CASE WHEN @BODEGA_VALIDA = 1 THEN 1
                     ELSE -1
                END AS Resultado ,
                CASE WHEN @BODEGA_VALIDA = 1 THEN 'Proceso Exitoso'
                     ELSE 'La licencia no existe o no se encuentra en la bodega.'
                END AS Mensaje ,
                0 Codigo ,
                '' DbData;
    END;