-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-02-2016
-- Description:			Inicializa el inventario de las bodegas de los vendedores

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_INITIALIZING_INVENORY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INITIALIZING_INVENORY]

AS
BEGIN
	SET NOCOUNT ON;
	--
	UPDATE I
	SET ON_HAND = 0
	FROM [SONDA].[SWIFT_INVENTORY] I
	WHERE
		I.WAREHOUSE = I.LOCATION 
		AND I.BATCH_ID IS NULL
		AND I.PALLET_ID IS NULL
		AND I.WAREHOUSE LIKE 'V%'
	--
	PRINT 'Cantidad de bodegas afectadas: ' + CAST(@@rowcount AS VARCHAR)
END
