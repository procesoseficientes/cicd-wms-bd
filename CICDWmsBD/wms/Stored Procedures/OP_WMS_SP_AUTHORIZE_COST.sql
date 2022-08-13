-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-26 @ Team ERGON - Sprint ERGON 
-- Description:	        autoriza un costo detalle

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20191217 GForce@Madagascar
-- Description:	        seteo status para que no pueda ser vista en la orden de preparado la línea


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_AUTHORIZE_COST] @DOC_ID = 282840
                                                  , @LINE_NUMBER = 2
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AUTHORIZE_COST]
(
    @DOC_ID NUMERIC,
    @LINE_NUMBER NUMERIC,
    @LOGIN VARCHAR(25)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [wms].[OP_WMS_POLIZA_DETAIL]
        SET [IS_AUTHORIZED] = 1,
            [LAST_UPDATED] = GETDATE(),
            [LAST_UPDATED_BY] = @LOGIN,
            PICKING_STATUS = 'ASSIGNED'
        WHERE [DOC_ID] = @DOC_ID
              AND [LINE_NUMBER] = @LINE_NUMBER;


        SELECT 1 AS Resultado,
               'Proceso Exitoso' Mensaje,
               0 Codigo;


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT -1 AS Resultado,
               ERROR_MESSAGE() Mensaje,
               @@error Codigo;

    END CATCH;



END;