-- =============================================
-- Autor:				DIEGO.AS
-- Fecha de Creacion: 	12/2/2019 @ G-Force - TEAM Sprint Madagascar
-- Historia/Bug:		Product Backlog Item 33839: Top transacciones por Licencia
-- Descripcion: 		12/2/2019 - Obtiene los registros las ultimas N transacciones de la LICENCIA recibida

/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_GET_TRANSACTIONS_BY_LICENSE_SUPER]
	@LICENSE_ID = 177681
	, @TOP = 10 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSACTIONS_BY_LICENSE_SUPER]
(
    @LICENSE_ID INT,
    @TOP INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    -- -----------------------------------------------------------------------------------
    -- SE OBTIENEN LOS REGISTROS DE TRANSACCIONES EN BASE AL LIMITE Y LICENCIA RECIBIDOS
    -- -----------------------------------------------------------------------------------
    SELECT TOP (@TOP)
           [LOGIN_ID],
           [LOGIN_NAME],
           [TRANS_DATE],
           [MATERIAL_CODE],
           [MATERIAL_BARCODE],
           [CLIENT_OWNER],
           [MATERIAL_DESCRIPTION],
           CASE
               WHEN [BATCH] = '' THEN
                   NULL
               ELSE
                   [BATCH]
           END [BATCH],
           [DATE_EXPIRATION],
           [TONE],
           [CALIBER],
           [SERIAL],
           [QUANTITY_UNITS],
           [TRANS_TYPE],
           [TRANS_DESCRIPTION],
           [TRANS_SUBTYPE],
           CASE
               WHEN [QUANTITY_UNITS] < 0 THEN
                   'EGRESO'
               ELSE
                   'INGRESO'
           END [MOVEMENT_TYPE],
           [TASK_ID],
           [LICENSE_ID],
           [SOURCE_LICENSE],
           [TARGET_LICENSE],
           [NAME_SUPPLIER],
           [SOURCE_LOCATION],
           [TARGET_LOCATION],
           [SOURCE_WAREHOUSE],
           [TARGET_WAREHOUSE]
    FROM [wms].[OP_WMS_TRANS]
    WHERE (
              [LICENSE_ID] = @LICENSE_ID
              OR [SOURCE_LICENSE] = @LICENSE_ID
              OR [TARGET_LICENSE] = @LICENSE_ID
          )
          AND [STATUS] = 'PROCESSED'
    ORDER BY [TRANS_DATE] DESC;
END;