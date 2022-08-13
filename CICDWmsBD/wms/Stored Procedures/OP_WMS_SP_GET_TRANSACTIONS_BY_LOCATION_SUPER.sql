-- =============================================
-- Autor:				DIEGO.AS
-- Fecha de Creacion: 	12/2/2019 @ G-Force - TEAM Sprint Madagascar
-- Historia/Bug:		Product Backlog Item 33839: Top transacciones por Licencia
-- Descripcion: 		12/2/2019 - Obtiene los registros las ultimas N transacciones de la UBICACION recibida

-- Modificacion         9-Dic-2019 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Historia/Bug:		Product Backlog Item 33839: Top transacciones por Licencia
-- Descripcion:			Se agregan las columnas SOURCE_LOCATION y TARGET_LOCATION como parte de los resultados
/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_GET_TRANSACTIONS_BY_LOCATION_SUPER]
	@LOCATION = 'B03-R01-C01-NA'
	, @TOP = 10 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSACTIONS_BY_LOCATION_SUPER]
(
    @LOCATION VARCHAR(50),
    @TOP INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    -- -----------------------------------------------------------------------------------
    -- SE OBTIENEN LOS REGISTROS DE TRANSACCIONES EN BASE AL LIMITE Y UBICACION RECIBIDOS
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
		   [SOURCE_LOCATION],
		   [TARGET_LOCATION],
           [TARGET_LICENSE],
           [NAME_SUPPLIER]
    FROM [wms].[OP_WMS_TRANS]
    WHERE (
              [SOURCE_LOCATION] = @LOCATION
              OR [TARGET_LOCATION] = @LOCATION
          )
          AND [STATUS] = 'PROCESSED'
    ORDER BY [TRANS_DATE] DESC;
END;